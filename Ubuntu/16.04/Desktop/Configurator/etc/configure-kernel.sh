#!/bin/bash

#
# configure-kernel.sh - DevOpsBroker script for configuring Linux kernel tuning
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
# See sysctl(8) and sysctl.conf(5) for more information.
#
# Useful Linux Command-Line Utilities
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# o Show the complete list of all sysctl parameters:
# sysctl -a
#
# o Set the MTU on a network interface:
# ifconfig enp4s0 mtu NNNN
#
# o Monitor kernel behavior with regard to the VM dirty pages:
# grep -A 1 dirty /proc/vmstat
#
# o Check cwnd runtime value:
# ss -nli | fgrep cwnd
#
# o Determine Connection States:
# netstat -tan | grep ':80 ' | awk '{print $6}' | sort | uniq -c
#
# o View TCP/UDP/IP Session Information:
# ss -s
#
# TODO: Audit kernel parameters to ensure they are properly set
# TODO: Audit security settings (i.e. umask) to ensure they are properly set,
#	especially for someone in the sudo group
# -----------------------------------------------------------------------------
#


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Preprocessing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Display error if not running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "\033[1mconfigure-kernel.sh: \033[38;5;203mPermission denied (you must be root)\033[0m"

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
sysctlConf=$(isExecutable "$SCRIPT_DIR/sysctl.conf.sh")


################################## Functions ##################################

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function:	execSpeedTest
# Description:	Executes the Internet Speed Test
# -----------------------------------------------------------------------------
function execSpeedTest() {
  # Install speedtest-cli if necessary
  if [ ! -f /usr/bin/speedtest-cli ]; then
    echo
    echo "Installing speedtest-cli..."
    apt-get -y install speedtest-cli
  fi

  if [ ! -f /tmp/tuneKernel_speedtest.tmp ]; then
    printInfo "Executing Internet speed test"
    speedtest-cli | tee /tmp/tuneKernel_speedtest.tmp
    printInfo "Internet speed test finished"
    echo
  fi
}


################################### Actions ###################################

# Clear screen and print banner only if called from command line
if [ $SHLVL -eq 1 ]; then
  clear

  bannerMsg="DevOpsBroker Ubuntu 16.04 Desktop Kernel Tuning"

  echo -e $(bold kobi)
  echo    "╔═════════════════════════════════════════════════╗"
  echo -e "║ "$(white)$bannerMsg$(kobi)                     "║"
  echo    "╚═════════════════════════════════════════════════╝"
  echo -e $(reset)

fi

#
# Linux Kernel Tuning
#
if ! grep -Fq "DevOpsBroker" /etc/sysctl.conf; then
  # BEGIN /etc/sysctl.conf

  printBanner "Installing /etc/sysctl.conf"

  # Execute Internet speed test
  execSpeedTest

  # Execute template script
  $SHELL -c "$sysctlConf" > "$SCRIPT_DIR/sysctl.conf"

  # Install as root:root with rw-r--r-- privileges
  install -b --suffix .orig -o root -g root -m 644 "$SCRIPT_DIR/sysctl.conf" /etc

  # Clean up
  rm "$SCRIPT_DIR/sysctl.conf"

  printInfo "Load kernel tuning parameters from /etc/sysctl.conf"
  sysctl -p

  echo

elif [ "$sysctlConf" -nt /etc/sysctl.conf ]; then

  printBanner "Updating /etc/sysctl.conf"

  # Execute Internet speed test
  execSpeedTest

  # Execute template script
  $SHELL -c "$sysctlConf" > "$SCRIPT_DIR/sysctl.conf"

  # Install as root:root with rw-r--r-- privileges
  install -b --suffix .bak -o root -g root -m 644 "$SCRIPT_DIR/sysctl.conf" /etc

  # Clean up
  rm "$SCRIPT_DIR/sysctl.conf"

  printInfo "Load kernel tuning parameters from /etc/sysctl.conf"
  sysctl -p

  echo

  # END /etc/sysctl.conf
fi

exit 0

