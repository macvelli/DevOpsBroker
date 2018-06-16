#!/bin/bash

#
# configure-apt-mirror.sh - DevOpsBroker script for configuring apt mirror site
#
# Copyright (C) 2018 Edward Smith <edwardsmith@devopsbroker.org>
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program.  If not, see <http://www.gnu.org/licenses/>.
#
# -----------------------------------------------------------------------------
# Developed on Ubuntu 16.04.4 LTS running kernel.osrelease = 4.13.0-43
#
# 1. Pulls the list of mirror sites from http://mirrors.ubuntu.com/mirrors.txt
#
# 2. Take the five fastest sites by latency using ping test
#
# 3. Take fastest site overall by using throughput test
# -----------------------------------------------------------------------------
#


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Preprocessing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Display error if not running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "\033[1mconfigure-apt-mirror.sh: \033[38;5;203mPermission denied (you must be root)\033[0m"

  exit 1
fi

# Load /etc/dob/ansi.conf if bittersweet function does not exist
if [[ ! "$(declare -F 'bittersweet')" ]]; then
  . /etc/dob/ansi.conf
fi

# Load /etc/dob/functions.conf if printBanner function does not exist
if [[ ! "$(declare -F 'printBanner')" ]]; then
  . /etc/dob/functions.conf
fi

# Find the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Ensure the sysctl.conf.sh script is executable
aptSourcesList=$(isExecutable "$SCRIPT_DIR/apt-sources-list.sh")


################################### Actions ###################################

# Clear screen and print banner only if called from command line
if [ $SHLVL -eq 1 ]; then
  clear

  bannerMsg="DevOpsBroker Ubuntu 16.04 Desktop APT Mirror Configurator"

  echo -e $(bold kobi)
  echo    "╔═══════════════════════════════════════════════════════════╗"
  echo -e "║ "$(white)$bannerMsg$(kobi)                               "║"
  echo    "╚═══════════════════════════════════════════════════════════╝"
  echo -e $(reset)

fi

if ! grep -Fq "DevOpsBroker" /etc/apt/sources.list; then
  # BEGIN Configure apt mirror site

  printBanner "Configuring /etc/apt/sources.list mirror"

  # Pull the list of mirror sites
  if [ ! -f /tmp/ubuntu-mirrors.txt ]; then
    printInfo "Pull the list of mirror sites from http://mirrors.ubuntu.com/mirrors.txt"
    curl -s http://mirrors.ubuntu.com/mirrors.txt -o /tmp/ubuntu-mirrors.txt
  fi

  declare -a mirrorArray

  mapfile -t mirrorArray < /tmp/ubuntu-mirrors.txt

  if [ -f /tmp/ping.job ]; then
    # Truncate the /tmp/ping.job file if exists
    truncate -s 0 /tmp/ping.job
  fi

  for mirror in "${mirrorArray[@]}"; do

    # Select only http mirror sites
    if [[ "$mirror" == http* ]]; then
      # Extract the FQDN
      fqdn=${mirror:7}
      fqdn="${fqdn%%/*}"

      # Add to the /tmp/ping.job file
      echo "ping -c 2 -W 1 $fqdn | awk -v fqdn=\"$fqdn\" -F '/' 'END {print "'$5'", fqdn}'" >> /tmp/ping.job
    fi

  done

  # Execute the /tmp/ping.job in parallel
  printInfo "Execute ping test to find the five fastest sites by latency"
  parallel -j0 --no-notice :::: /tmp/ping.job | awk '/^[0-9]*\.[0-9]*/{ print $0 }' | sort -nk1 | head -5 | awk '{ print $2 }' > /tmp/ping.results

  declare -a pingResultsArray

  mapfile -t pingResultsArray < /tmp/ping.results

  declare fastestMirror
  declare -i fastestThroughput
  declare -i throughput

  fastestThroughput=0

  for pingResult in "${pingResultsArray[@]}"; do

    for mirror in "${mirrorArray[@]}"; do

      if [[ $mirror = *"$pingResult"* ]]; then
        printInfo "Testing throughput for mirror $mirror"
        throughput=$(curl -o /dev/null -s -w %{speed_download} "$mirror"ls-lR.gz | sed 's/\.[0-9]*//')

        if [ $throughput -gt $fastestThroughput ]; then
          fastestThroughput=$throughput
          fastestMirror=$mirror
        fi
      fi

    done

  done

  printInfo "Configuring /etc/apt/sources.list to use the fastest mirror --> $fastestMirror"

  # Install /etc/apt/sources.list
  if ! grep -Fq "DevOpsBroker" /etc/apt/sources.list; then
    # BEGIN /etc/apt/sources.list

    printInfo "Installing /etc/apt/sources.list"

    # Execute template script
    $SHELL -c "$aptSourcesList" $fastestMirror > "$SCRIPT_DIR/sources.list"

    # Install as root:root with rw-r--r-- privileges
    install -o root -g root -m 644 "$SCRIPT_DIR/sources.list" /etc/apt

  else
    printInfo "Updating /etc/apt/sources.list"

    # Execute template script
    $SHELL -c "$aptSourcesList" $fastestMirror > "$SCRIPT_DIR/sources.list"

    # Install as root:root with rw-r--r-- privileges
    install -b --suffix .bak -o root -g root -m 644 "$SCRIPT_DIR/sources.list" /etc/apt

    # END /etc/apt/sources.list
  fi

  # Clean up
  rm "$SCRIPT_DIR/sources.list"

  printInfo "Download package information from new apt mirror site"
  apt update

  # END Configure apt mirror site
fi

exit 0

