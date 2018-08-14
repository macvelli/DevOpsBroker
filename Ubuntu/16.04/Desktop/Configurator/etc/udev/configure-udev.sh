#!/bin/bash

#
# configure-udev.sh - DevOpsBroker script for configuring udev rules
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
# Developed on Ubuntu 16.04.4 LTS running kernel.osrelease = 4.13.0-45
#
# Useful Linux Command-Line Utilities
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# o Measure read speed of any drive (Hard Drive/SSD/USB):
# hdparm -t /dev/sd(a|b|c|d...)
#
# o Call block device ioctls
# sudo blockdev --report /dev/sda
#
# o View all attached storage devices and their partitions
# sudo fdisk -l
#
# o View block device attributes
# sudo blkid -o udev -p /dev/sdc1
#
# o Probe USB hardward information
# hwinfo --usb
#
# o View verbose USB device information
# sudo lsusb -v -d 0x090c:0x1000
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
SCRIPT_INFO=( $($EXEC_SCRIPTINFO "$BASH_SOURCE") )
SCRIPT_DIR="${SCRIPT_INFO[0]}"
SCRIPT_EXEC="${SCRIPT_INFO[1]}"

# Display error if not running as root
if [ "$EUID" -ne 0 ]; then
  echo "${bold}$SCRIPT_EXEC: ${bittersweet}Permission denied (you must be root)${reset}"

  exit 1
fi

# Ensure the tune-diskio.tpl script is executable
tuneDiskIOTpl=$(isExecutable "$SCRIPT_DIR"/rules.d/tune-diskio.tpl)

################################## Variables ##################################

## Bash exec variables
EXEC_LSBLK=/bin/lsblk

## Variables
echoOnExit=false

################################### Actions ###################################

# Clear screen only if called from command line
if [ $SHLVL -eq 1 ]; then
  clear
fi

bannerMsg='DevOpsBroker Ubuntu 16.04 Desktop Udev Configurator'

echo ${bold} ${wisteria}
echo '╔═════════════════════════════════════════════════════╗'
echo "║ ${white}$bannerMsg${wisteria}"			   '║'
echo '╚═════════════════════════════════════════════════════╝'
echo ${reset}

#
# Disk I/O Schedulers Configuration
#   o /etc/udev/rules.d/60-io-schedulers.rules
#   o Queue scheduler: kyber
#

installConfig '60-io-schedulers.rules' "$SCRIPT_DIR"/rules.d /etc/udev/rules.d

#
# Disk I/O Tuning Configuration
#   o /etc/udev/rules.d/tune-diskio.tpl
#

# List all currently mounted block devices
blockDeviceList=($($EXEC_LSBLK -d -n -p --exclude 7 --output NAME))

for blockDevice in "${blockDeviceList[@]}"; do
  # Execute template script
  $tuneDiskIOTpl $blockDevice
done

# Install any udev rules files to /etc/udev/rules.d/
udevRuleFileList=($($EXEC_LS "$SCRIPT_DIR"/rules.d/65-diskio-*.rules 2>/dev/null))

for udevRuleFile in "${udevRuleFileList[@]}"; do
  # Install as root:root with rw-r--r-- privileges
  $EXEC_INSTALL -b --suffix .bak -o root -g root -m 644 "$udevRuleFile" /etc/udev/rules.d/

  $EXEC_RM "$udevRuleFile"

  echoOnExit=true
done

if [ "$echoOnExit" == 'true' ]; then
  echo
fi

exit 0
