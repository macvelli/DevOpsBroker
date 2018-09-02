#!/bin/bash

#
# device-drivers.sh - DevOpsBroker script for installing proprietary drivers
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
# this program.  If not, see <https://www.gnu.org/licenses/>.
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

# Load /etc/devops/ansi.conf if ANSI_CONFIG is unset
if [ -z "$ANSI_CONFIG" ] && [ -f /etc/devops/ansi.conf ]; then
	source /etc/devops/ansi.conf
fi

${ANSI_CONFIG?"[1;38;2;255;100;100mCannot load '/etc/devops/ansi.conf': No such file[0m"}

# Load /etc/devops/exec.conf if EXEC_CONFIG is unset
if [ -z "$EXEC_CONFIG" ] && [ -f /etc/devops/exec.conf ]; then
	source /etc/devops/exec.conf
fi

${EXEC_CONFIG?"${bold}${bittersweet}Cannot load '/etc/devops/exec.conf': No such file${reset}"}

# Load /etc/devops/functions.conf if FUNC_CONFIG is unset
if [ -z "$FUNC_CONFIG" ] && [ -f /etc/devops/functions.conf ]; then
	source /etc/devops/functions.conf
fi

${FUNC_CONFIG?"${bold}${bittersweet}Cannot load '/etc/devops/functions.conf': No such file${reset}"}

## Script information
SCRIPT_EXEC=$( $EXEC_BASENAME "$BASH_SOURCE" )

# Display error if not running as root
if [ "$USER" !=  'root' ]; then
	printError "$SCRIPT_EXEC" 'Permission denied (you must be root)'
	exit 1
fi

################################## Variables ##################################

## Bash exec variables
EXEC_DRIVERS=/usr/bin/ubuntu-drivers

################################### Actions ###################################

# Clear screen only if called from command line
if [ $SHLVL -eq 1 ]; then
	clear
fi

bannerMsg='DevOpsBroker Ubuntu 16.04 Desktop Proprietary Drivers Installer'

echo ${bold} ${wisteria}
echo '╔═════════════════════════════════════════════════════════════════╗'
echo "║ ${white}$bannerMsg${wisteria}"                                 '║'
echo '╚═════════════════════════════════════════════════════════════════╝'
echo ${reset}

# Exit if proprietary drivers already installed
if [ -f /etc/devops/device-drivers.info ] && [ "$1" != '-f' ]; then
	printInfo 'Proprietary drivers already installed'
	echo
	printUsage "$SCRIPT_EXEC ${gold}[-f]"

	echo ${bold}
	echo "Valid Options:${romantic}"
	echo -e ${gold}'  -f\t'  ${romantic}'Force reevaluation of proprietary drivers'
	echo ${reset}

	exit 0
fi

#
# Proprietary Drivers Installation
#

# Make the /etc/devops directory
if [ ! -d /etc/devops ]; then
	$EXEC_MKDIR --mode=0755 /etc/devops
fi

printInfo 'Gathering devices with available drivers to install'
$EXEC_DRIVERS devices | $EXEC_TEE /etc/devops/device-drivers.info
$EXEC_CHMOD 644 /etc/devops/device-drivers.info
echo

mapfile -t deviceArray < <($EXEC_GREP -E '^(vendor|driver)' /etc/devops/device-drivers.info)
declare -A vendorDriverMap
declare -a installList

IFS=': '
for device in "${deviceArray[@]}"; do
	if [[ "$device" == vendor* ]]; then
		vendorName=( $device )
		vendor="${vendorName[@]:1}"
	elif [[ "$device" == driver* ]]; then
		driverName=( $device )
		vendorDriverList="${vendorDriverMap[$vendor]}"

		if [ -z "$vendorDriverList" ]; then
			vendorDriverMap[$vendor]="${driverName[1]}"
		else
			vendorDriverMap[$vendor]="$vendorDriverList:${driverName[1]}"
		fi
	fi
done

for key in "${!vendorDriverMap[@]}"; do
	vendorDriverList=( ${vendorDriverMap[$key]} )
	vendorDriverList+=( "Skip" )
	COLUMNS=${#vendorDriverList[@]}

	echo "${bold}Which driver do you want to install for the device from '${pastelGreen}$key${white}'?${reset}"
	select selectedDriver in "${vendorDriverList[@]}"; do
		if [ "$selectedDriver" != 'Skip' ]; then
			installList+=( "$selectedDriver" )
		fi
		break;
	done
done

echo

if [ ${#installList[@]} -eq 0 ]; then
	printInfo 'No proprietary drivers to install'
else
	for driver in "${installList[@]}"; do
		printBanner "Installing $driver"
		$EXEC_APT -y install $driver
		echo
	done
fi

echo

exit 0
