#!/bin/bash

#
# configure-fstab.sh - DevOpsBroker script for configuring /etc/fstab
#
# Copyright (C) 2019 Edward Smith <edwardsmith@devopsbroker.org>
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
# Developed on Ubuntu 18.04.2 LTS running kernel.osrelease = 4.18.0-15
#
# o Optimize all filesystems to use noatime
# o Harden the /tmp partition (if defined)
# o Optimize Reserved Block Percentage on ext4 filesystems
# o Create RAM Disk
# -----------------------------------------------------------------------------
#

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Preprocessing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Load /etc/devops/ansi.conf if ANSI_CONFIG is unset
if [ -z "$ANSI_CONFIG" ] && [ -f /etc/devops/ansi.conf ]; then
	source /etc/devops/ansi.conf
fi

${ANSI_CONFIG?"[1;91mCannot load '/etc/devops/ansi.conf': No such file[0m"}

# Load /etc/devops/exec.conf if EXEC_CONFIG is unset
if [ -z "$EXEC_CONFIG" ] && [ -f /etc/devops/exec.conf ]; then
	source /etc/devops/exec.conf
fi

${EXEC_CONFIG?"[1;91mCannot load '/etc/devops/exec.conf': No such file[0m"}

# Load /etc/devops/functions.conf if FUNC_CONFIG is unset
if [ -z "$FUNC_CONFIG" ] && [ -f /etc/devops/functions.conf ]; then
	source /etc/devops/functions.conf
fi

${FUNC_CONFIG?"[1;91mCannot load '/etc/devops/functions.conf': No such file[0m"}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Robustness ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

set -o errexit                 # Exit if any statement returns a non-true value
set -o nounset                 # Exit if use an uninitialised variable
set -o pipefail                # Exit if any statement in a pipeline returns a non-true value
IFS=$'\n\t'                    # Default the Internal Field Separator to newline and tab

## Script information
SCRIPT_INFO=( $($EXEC_SCRIPTINFO "$BASH_SOURCE") )
SCRIPT_DIR="${SCRIPT_INFO[0]}"
SCRIPT_EXEC="${SCRIPT_INFO[1]}"

# Display error if not running as root
if [ "$USER" != 'root' ]; then
	printError "$SCRIPT_EXEC" 'Permission denied (you must be root)'
	exit 1
fi

# Ensure the fstab.tpl script is executable
fstabTpl=$(isExecutable "$SCRIPT_DIR"/fstab.tpl)

################################## Functions ##################################

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function:     tuneReservedBlocks
# Description:  Tunes the Reserved Blocks setting on ext4 filesystems
# -----------------------------------------------------------------------------
function tuneReservedBlocks() {
	mapfile -t ext4DeviceList < <($EXEC_FINDMNT -bno SOURCE,SIZE -t ext4)

	for ext4Device in "${ext4DeviceList[@]}"; do
		local deviceInfo=( $ext4Device )
		local partitionName=${deviceInfo[0]}
		local partitionSize=${deviceInfo[1]}

		# Normalize partition sizes to GiB
		partitionSize=$[ ($partitionSize + 1073741823) / 1073741824 ]

		# Determine reserved block percentage
		local reserveBlockPct=5

		if [ $partitionSize -eq 6 ]; then
			reserveBlockPct=4
		elif [ $partitionSize -gt 6 ] && [ $partitionSize -lt 10 ]; then
			reserveBlockPct=3
		elif [ $partitionSize -ge 10 ] && [ $partitionSize -lt 15 ]; then
			reserveBlockPct=2
		elif [ $partitionSize -ge 15 ]; then
			reserveBlockPct=1
		fi

		# Adjust reserved block percentage (if necessary)
		if (( $reserveBlockPct < 5 )); then
			printInfo "Tuning reserved block percentage to $reserveBlockPct on $partitionName"
			$EXEC_TUNE2FS -m $reserveBlockPct $partitionName
		fi
	done
}

################################## Variables ##################################

## Bash exec variables
EXEC_FINDMNT=/bin/findmnt
EXEC_TUNE2FS=/sbin/tune2fs

## Variables
export TMPDIR=${TMPDIR:-'/tmp'}
remountAll=false

################################### Actions ###################################

# Clear screen only if called from command line
if [ $SHLVL -eq 1 ]; then
	clear
fi

printBox "DevOpsBroker $UBUNTU_RELEASE /etc/fstab Configurator" 'true'

# Exit if /etc/fstab already configured
if [ -f /etc/fstab.orig ] && [ "$1" != '-f' ]; then
	printInfo '/etc/fstab already configured'
	echo
	printUsage "$SCRIPT_EXEC ${gold}[-f]"

	echo ${bold}
	echo "Valid Options:${romantic}"
	echo -e ${gold}'  -f\t'  ${romantic}'Force /etc/fstab reconfiguration'
	echo ${reset}

	exit 0
fi

#
# Create RAM Disk
#
if [ ! -d /mnt/ramdisk ]; then
	printInfo 'Creating RAM Disk'

	# Make the /mnt/ramdisk directory
	$EXEC_MKDIR --mode=0777 /mnt/ramdisk

	# Add entry to /etc/fstab to mount ramdisk
	echo '# ramdisk is on /mnt/ramdisk' >> /etc/fstab
	echo 'ramdisk	/mnt/ramdisk	tmpfs	nosuid,nodev,noatime,comment=x-gvfs-show,size=512M	0	0' >> /etc/fstab

	# Need to remount all filesystems
	remountAll=true
fi

#
# /etc/fstab Configuration
#

# Configure /etc/fstab
if [ ! -f /etc/fstab.orig ]; then
	printBanner 'Configure /etc/fstab'

	# Execute template script
	"$fstabTpl" > "$TMPDIR"/fstab

	# Install as root:root with rw-rw-r-- privileges
	$EXEC_INSTALL -b --suffix .orig -o root -g root -m 644 "$TMPDIR"/fstab /etc

	# Clean up
	$EXEC_RM "$TMPDIR"/fstab

	# Need to remount all filesystems
	remountAll=true

elif [ "$1" == '-f' ]; then
	printBanner 'Reconfiguring /etc/fstab'

	# Execute template script
	"$fstabTpl" > "$TMPDIR"/fstab

	# Install as root:root with rw-rw-r-- privileges
	$EXEC_INSTALL -b --suffix .bak -o root -g root -m 644 "$TMPDIR"/fstab /etc

	# Clean up
	$EXEC_RM "$TMPDIR"/fstab

	# Need to remount all filesystems
	remountAll=true
fi

# Remount all filesystems
if [ "$remountAll" == 'true' ]; then
	# Optimize Reserved Block Percentage on ext2/ext3/ext4 filesystems
	tuneReservedBlocks

	printInfo 'Remount all filesystems'
	$EXEC_MOUNT -a
	$EXEC_SYSTEMCTL daemon-reload
fi

echo

exit 0
