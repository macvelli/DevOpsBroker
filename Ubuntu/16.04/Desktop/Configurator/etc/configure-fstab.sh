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
# o Optimize all ext2/ext3/ext4 filesystems to use noatime
# o Harden the /tmp partition (if defined)
# o Optimize Reserved Block Percentage on ext2/ext3/ext4 filesystems
# o Create RAM Disk
# o TODO: Enable metadata checksums
# -----------------------------------------------------------------------------
#


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Preprocessing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Display error if not running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "\033[1mconfigure-fstab.sh: \033[38;5;203mPermission denied (you must be root)\033[0m"

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


################################## Functions ##################################

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function:	tuneReservedBlocks
# Description:	Tunes the Reserved Blocks setting on ext2/ext3/ext4 filesystems
# -----------------------------------------------------------------------------
function tuneReservedBlocks() {
  # BEGIN tuneReservedBlocks function

  local IFS=$'\n'
  for blkInfo in $(lsblk -b -o NAME,FSTYPE,SIZE | awk '/ext2|ext3|ext4/{ print substr($1,7),$3 }'); do
    local partitionName="/dev/"${blkInfo:0:4}
    local partitionSize=${blkInfo:5}

    # Normalize partition sizes to GiB
    partitionSize=$[ ($partitionSize + 1073741823) / 1073741824 ]

    # Determine reserved block percentage
    local reserveBlockPct=5

    if (( $partitionSize >= 11 && $partitionSize <= 16 )); then
      reserveBlockPct=4
    elif (( $partitionSize >= 17 && $partitionSize <= 20 )); then
      reserveBlockPct=3
    elif (( $partitionSize >= 21 && $partitionSize <= 35 )); then
      reserveBlockPct=2
    elif (( $partitionSize > 35 )); then
      reserveBlockPct=1
    fi

    # Adjust reserved block percentage (if necessary)
    if (( $reserveBlockPct < 5 )); then
      tune2fs -m $reserveBlockPct $partitionName
    fi
  done

   # END tuneReservedBlocks function
}


################################## Variables ##################################

remountAll=false

################################### Actions ###################################

# Clear screen and print banner only if called from command line
if [ $SHLVL -eq 1 ]; then
  clear

  bannerMsg="DevOpsBroker Ubuntu 16.04 Desktop /etc/fstab Configurator"

  echo -e $(bold kobi)
  echo    "╔═══════════════════════════════════════════════════════════╗"
  echo -e "║ "$(white)$bannerMsg$(kobi)                               "║"
  echo    "╚═══════════════════════════════════════════════════════════╝"
  echo -e $(reset)

fi


#~~~~~~~~~~~~~~~~~~~~~~~~~~ /etc/fstab Configuration ~~~~~~~~~~~~~~~~~~~~~~~~~~

#
# o Optimize all ext2/ext3/ext4 filesystems to use noatime
# o Harden the /tmp partition (if defined)
#
if ! grep -Fq "noatime" /etc/fstab; then
  # BEGIN /etc/fstab Configuration

  printBanner "Configuring /etc/fstab"

  # Backup original /etc/fstab file
  cp /etc/fstab /etc/fstab.orig

  printInfo "Optimize all ext2/ext3/ext4 filesystems to use noatime"
  printInfo "Harden the /tmp partition (if defined)"

  # Set noatime on all ext2/ext3/ext4 partitions and harden /tmp (if defined)
  sed -E 's/^(UUID=.+(ext2|ext3|ext4)\s+)([a-z=,-]+)/\1\3,noatime/; s/^(UUID=.+\/tmp\s+\w+\s+)([a-z=,-]+)/\1\2,nodev,nosuid/' /etc/fstab

  # Need to remount all filesystems
  remountAll=true

  printInfo "Optimize Reserved Block Percentage on ext2/ext3/ext4 filesystems"
  echo
  tuneReservedBlocks
  echo

# TODO: Only works on 64-bit ext4 partitions (mkfs.ext4 -O metadata_csum,64bit /dev/sdx)
# TODO: debugfs -R features /dev/sda1
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

  # END /etc/fstab Configuration
fi

#
# Create RAM Disk
#
if [ ! -d /mnt/ramdisk ]; then
  # BEGIN Create RAM Disk

  printInfo "Creating RAM Disk"

  # Make the /mnt/ramdisk directory
  mkdir -p /mnt/ramdisk

  # Add entry to /etc/fstab to mount ramdisk
echo "# ramdisk is on /mnt/ramdisk
ramdisk /mnt/ramdisk tmpfs noatime,nodev,nosuid,comment=x-gvfs-show,size=512M 0 0" >> /etc/fstab

  # Need to remount all filesystems
  remountAll=true

  # END Create RAM Disk
fi

# Remount all filesystems
if [ "$remountAll" == "true" ]; then

  printInfo "Remount all filesystems"
  mount -a
  systemctl daemon-reload
  echo

fi

exit 0

