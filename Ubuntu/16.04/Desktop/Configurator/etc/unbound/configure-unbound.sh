#!/bin/bash

#
# configure-unbound.sh - DevOpsBroker script for configuring unbound DNS cache server
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
# Useful Linux Command-Line Utilities
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# o Use DNS lookup utility to see unbound in action (run twice)
# dig ubuntu.com
#
# o Query Internet name servers interactively
# nslookup google.com
# -----------------------------------------------------------------------------
#


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Preprocessing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Display error if not running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "\033[1mconfigure-unbound.sh: \033[38;5;203mPermission denied (you must be root)\033[0m"

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


################################### Actions ###################################

# Clear screen and print banner only if called from command line
if [ $SHLVL -eq 1 ]; then
  clear

  bannerMsg="DevOpsBroker Ubuntu 16.04 Desktop Unbound Configurator"

  echo -e $(bold kobi)
  echo    "╔════════════════════════════════════════════════════════╗"
  echo -e "║ "$(white)$bannerMsg$(kobi)                            "║"
  echo    "╚════════════════════════════════════════════════════════╝"
  echo -e $(reset)

fi

#
# unbound User Configuration
#
if ! groups unbound | grep -Fq 'syslog'; then
  printInfo "Adding unbound user to the syslog group"
  adduser unbound syslog

  echo
fi

#
# /etc/unbound/unbound.conf.d/ Configuration
#

# Install /etc/unbound/unbound.conf.d/dns-cache-server.conf
if [ ! -f /etc/unbound/unbound.conf.d/dns-cache-server.conf ]; then
  # BEGIN /etc/unbound/unbound.conf.d/dns-cache-server.conf

  printInfo "Configuring unbound DNS cache server"

  # Delete any default configurations in /etc/unbound/unbound.conf.d
  rm /etc/unbound/unbound.conf.d/*

  # Install as root:root with rw-r--r-- privileges
  install -o root -g root -m 644 "$SCRIPT_DIR/unbound.conf.d/dns-cache-server.conf" /etc/unbound/unbound.conf.d

  printInfo "Restart unbound service"
  systemctl restart unbound.service

  echo

elif [ "$SCRIPT_DIR/unbound.conf.d/dns-cache-server.conf" -nt /etc/unbound/unbound.conf.d/dns-cache-server.conf ]; then
  printInfo "Updating unbound DNS cache server configuration"

  # Install as root:root with rw-r--r-- privileges
  install -b --suffix .bak -o root -g root -m 644 "$SCRIPT_DIR/unbound.conf.d/dns-cache-server.conf" /etc/unbound/unbound.conf.d

  printInfo "Restart unbound service"
  systemctl restart unbound.service

  echo

  # END /etc/unbound/unbound.conf.d/dns-cache-server.conf
fi

#
# Reconfigure Network Manager to use unbound
#

if grep -Fq 'dns=dnsmasq' /etc/NetworkManager/NetworkManager.conf; then
  printInfo "Configuring Network Manager to use unbound"
  sed -i 's/dns=dnsmasq/dns=unbound/' /etc/NetworkManager/NetworkManager.conf
fi

exit 0

