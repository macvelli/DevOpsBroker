#!/bin/bash

#
# install-drivers.sh - DevOpsBroker script for installing proprietary drivers
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
# This script performs the following steps:
#   o Gathers devices with available drivers to install
#   o Ask user which driver to install for devices with multiple available drivers
#   o Installs selected drivers
# -----------------------------------------------------------------------------
#


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Preprocessing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Display error if not running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "\033[1minstall-drivers.sh: \033[38;5;203mPermission denied (you must be root)\033[0m"

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


################################### Actions ###################################

# Clear screen and print banner only if called from command line
if [ $SHLVL -eq 1 ]; then
  clear

  bannerMsg="DevOpsBroker Ubuntu 16.04 Desktop Proprietary Drivers Installer"

  echo -e $(bold kobi)
  echo    "╔═════════════════════════════════════════════════════════════════╗"
  echo -e "║ "$(white)$bannerMsg$(kobi)                                     "║"
  echo    "╚═════════════════════════════════════════════════════════════════╝"
  echo -e $(reset)

fi

# Exit if proprietary drivers already installed
if [ -f /etc/dob/device-drivers.info ] && [ "$1" != "-f" ]; then
  printInfo "Proprietary drivers already installed"
  echo
  echo -e "$(bold)Valid Options:$(reset)"
  echo -e "$(bold)  -f$(reset)	Force reevaluation of proprietary drivers"
  echo

  exit 0
fi

#
# Proprietary Drivers Installation
#

printBanner "Proprietary Drivers Installation"

# Make the /etc/dob directory
mkdir -p --mode=0755 /etc/dob

declare -a deviceArray
declare -a driverArray
declare -a installList

printInfo "Gather devices with available drivers to install"
ubuntu-drivers devices | tee /etc/dob/device-drivers.info
chmod 644 /etc/dob/device-drivers.info

mapfile -t deviceArray < <(cat /etc/dob/device-drivers.info | perl -n -e'/^vendor.+:.(.+)/ && print "\n$1";' -e'/^driver.+:.([a-z0-9-]+)/ && print "\t$1";')

IFS=$'\t'
for i in "${!deviceArray[@]}"; do

  # Zero index is always empty
  if [ $i -gt 0 ]; then
    vendorDrivers=( ${deviceArray[i]} )

    if [ ${#vendorDrivers[@]} -gt 2 ]; then
      echo -e "$(bold)Which driver do you want to install for the device from ${vendorDrivers[0]}?$(reset)"

      select selectedDriver in "${vendorDrivers[@]:1}"; do
	installList+=( "$selectedDriver" )

	break;
      done
    else
      installList+=( "${vendorDrivers[1]}" )
    fi
  fi
done

if [ ${#installList[@]} -eq 0 ]; then
  printInfo "No devices with available proprietary drivers found"

else
  echo
  for driver in "${installList[@]}"; do
    printBanner "Installing $driver"

    apt -y install $driver

    echo
  done
fi

exit 0

