#!/bin/bash

#
# configure-nic.sh - DevOpsBroker script for configuring network interfaces
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
# o Display the initcwnd/initrwnd values for the default interface:
# ip route show
#
# o Display network interface configuration including txqueuelength:
# ifconfig enp4s0
#
# o Display or change Ethernet adapter settings:
# sudo ethtool --show-features enp4s0
# sudo ethtool --offload enp4s0 tx-checksum-ipv4 on tx-checksum-ipv6 on tx-nocache-copy off
# sudo ethtool --offload enp4s0 rx on tx on tso on ufo on sg on gso on
#
# o Bounce the network interface:
# sudo ifdown enp4s0 && sudo ifup enp4s0
#
# -----------------------------------------------------------------------------
#


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Preprocessing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Display error if not running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "\033[1mconfigure-nic.sh: \033[38;5;203mPermission denied (you must be root)\033[0m"

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

# Set tune-nic.sh location and make it executable
tuneNic=$(isExecutable "$SCRIPT_DIR/tune-nic.sh")

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ OPTION Parsing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## Options
NIC="$1"

# Set NIC to default network interface if no command-line parameters passed
if [ -z "$NIC" ]; then
  NIC=$(ip -4 route show default | awk '{ print $5 }')

# Display error if network interface parameter is invalid
elif [ ! -d /proc/sys/net/ipv4/conf/$NIC ]; then
  printError "configure-nic.sh" "Invalid network interface $NIC"
  echo
  printUsage "configure-nic.sh NIC"

  exit 1
fi


################################### Actions ###################################

# Clear screen and print banner only if called from command line
if [ $SHLVL -eq 1 ]; then
  clear

  bannerMsg="DevOpsBroker Ubuntu 16.04 Desktop Network Interface Configurator"

  echo -e $(bold kobi)
  echo    "╔══════════════════════════════════════════════════════════════════╗"
  echo -e "║ "$(white)$bannerMsg$(kobi)                                      "║"
  echo    "╚══════════════════════════════════════════════════════════════════╝"
  echo -e $(reset)

fi

#
# /etc/network/if-up.d/ Configuration
#

# Install /etc/network/if-up.d/tune-$NIC.sh
if [ ! -f /etc/network/if-up.d/tune-$NIC.sh ]; then
  # BEGIN /etc/network/if-up.d/tune-$NIC.sh

  printInfo "Installing /etc/network/if-up.d/tune-$NIC.sh"

  # Execute template script
  $SHELL -c "$tuneNic $NIC" > "$SCRIPT_DIR/tune-$NIC.sh"

  # Install as root:root with rwxr-xr-x privileges
  install -o root -g root -m 755 "$SCRIPT_DIR/tune-$NIC.sh" /etc/network/if-up.d

  # Clean up
  rm "$SCRIPT_DIR/tune-$NIC.sh"

  printInfo "Restart $NIC interface"
  echo
  ifdown $NIC && ifup $NIC

  echo

elif [ "$tuneNic" -nt /etc/network/if-up.d/tune-$NIC.sh ]; then
  printInfo "Updating /etc/network/if-up.d/tune-$NIC.sh"

  # Execute template script
  $SHELL -c "$tuneNic $NIC" > "$SCRIPT_DIR/tune-$NIC.sh"

  # Install as root:root with rwxr-xr-x privileges
  install -b --suffix .bak -o root -g root -m 755 "$SCRIPT_DIR/tune-$NIC.sh" /etc/network/if-up.d

  # Clean up
  rm "$SCRIPT_DIR/tune-$NIC.sh"

  printInfo "Restart $NIC interface"
  echo
  ifdown $NIC && ifup $NIC

  echo

  # END /etc/network/if-up.d/tune-$NIC.sh
fi

exit 0

