#!/bin/bash

#
# configure-fstab.sh - DevOpsBroker script for configuring /etc/fstab
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
# o Optimize all filesystems to use noatime
# o Harden the /tmp partition (if defined)
# o Optimize Reserved Block Percentage on ext4 filesystems
# o Create RAM Disk
# o TODO: Enable metadata checksums
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

# Ensure the sysctl.conf.tpl script is executable
fstabTpl=$(isExecutable "$SCRIPT_DIR"/fstab.tpl)

################################## Functions ##################################

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function:	tuneReservedBlocks
# Description:	Tunes the Reserved Blocks setting on ext4 filesystems
# -----------------------------------------------------------------------------
function tuneReservedBlocks() {
  # BEGIN tuneReservedBlocks function

  IFS=$'\n'
  local ext4DeviceList=( $($EXEC_FINDMNT -b -n -o SOURCE,SIZE -t ext4) )
  unset IFS

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

  # END tuneReservedBlocks function
}

################################## Variables ##################################

## Bash exec variables
EXEC_FINDMNT=/bin/findmnt
EXEC_MOUNT=/bin/mount
EXEC_TUNE2FS=/sbin/tune2fs

remountAll=false

################################### Actions ###################################

# Clear screen only if called from command line
if [ $SHLVL -eq 1 ]; then
  clear
fi

bannerMsg='DevOpsBroker Ubuntu 16.04 Desktop /etc/fstab Configurator'

echo ${bold} ${wisteria}
echo '╔═══════════════════════════════════════════════════════════╗'
echo "║ ${white}$bannerMsg${wisteria}"				 '║'
echo '╚═══════════════════════════════════════════════════════════╝'
echo ${reset}

# Exit if /etc/fstab already configured
if [ -f /etc/fstab.orig ] && [ "$1" != '-f' ]; then
  printInfo '/etc/fstab already configured'
  echo
  printUsage "$SCRIPT_EXEC ${gold}[-f]"

  echo ${bold}
  echo "Valid Options:${romantic}"
  echo '  -f	Force /etc/fstab reconfiguration'
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
echo '# ramdisk is on /mnt/ramdisk
ramdisk /mnt/ramdisk tmpfs nosuid,nodev,noatime,comment=x-gvfs-show,size=512M     0       0' >> /etc/fstab

  # Need to remount all filesystems
  remountAll=true
fi

#
# /etc/fstab Configuration
#

# Configure /etc/fstab
if [ ! -f /etc/fstab.orig ]; then
  printBanner "Configure /etc/fstab"

  # Execute template script
  "$fstabTpl" > "$SCRIPT_DIR"/fstab

  # Install as root:root with rw-rw-r-- privileges
  $EXEC_INSTALL -b --suffix .orig -o root -g root -m 664 "$SCRIPT_DIR"/fstab /etc

  # Clean up
  $EXEC_RM "$SCRIPT_DIR"/fstab

  # Need to remount all filesystems
  remountAll=true
elif [ "$1" == '-f' ]; then
  printBanner "Reconfiguring /etc/fstab"

  # Execute template script
  "$fstabTpl" > "$SCRIPT_DIR"/fstab

  # Install as root:root with rw-rw-r-- privileges
  $EXEC_INSTALL -b --suffix .bak -o root -g root -m 664 "$SCRIPT_DIR"/fstab /etc

  # Clean up
  $EXEC_RM "$SCRIPT_DIR"/fstab

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






# TODO: Only works on 64-bit ext4 partitions (mkfs.ext4 -O metadata_csum,64bit /dev/sdx)
# TODO: sudo debugfs -R features /dev/sda1
# TODO: sudo tune2fs -l /dev/sdb2
#
#  printInfo "Enable metadata checksums"
#  if [ grep -Fq "sse4_2" /proc/cpuinfo ]; then
#
#echo "
## Enable hardware-accelerated metadata checksums
#crc32c_intel" >> /etc/modules
#
#else
#
#echo "
## Enable software metadata checksums
#crc32c_generic" >> /etc/modules
