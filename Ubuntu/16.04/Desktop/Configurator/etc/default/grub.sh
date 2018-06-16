#!/bin/bash

#
# grub.sh - DevOpsBroker script for generating /etc/default/grub configuration
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
# -----------------------------------------------------------------------------
#


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Preprocessing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Display error if not running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "\033[1mgrub.sh: \033[38;5;203mPermission denied (you must be root)\033[0m"

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

# Display usage if no parameters given
if [ -z "$1" ]; then
  printUsage "grub.sh ZSWAP_MAX_POOL_PCT"

  exit 1
fi

# Display error if not running on Ubuntu 16.04 xenial
if [[ ! "$1" =~ ^[0-9]+$ ]] || \
      [ "$1" -lt 0 ] || \
      [ "$1" -gt 100 ]; then
  printError "grub.sh" "Invalid ZSwap max pool percent $1"
  echo
  printUsage "grub.sh ZSWAP_MAX_POOL_PCT"

  exit 1
fi


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Template ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## Template variables
isEfiBoot=$([ -d /sys/firmware/efi ] && echo -n "true" || echo -n "false")
efiReboot=$([ "$isEfiBoot" = true ] && echo -n "reboot=efi" || echo -n "")
defaultCmdLine="zswap.enabled=1 zswap.compressor=lz4 zswap.zpool=z3fold zswap.max_pool_percent=$1 nmi_watchdog=0 scsi_mod.use_blk_mq=1"

if [ "$isEfiBoot" = true ]; then
  defaultCmdLine="acpi=force $defaultCmdLine"
fi


## Template
cat << EOF
#
# grub - DevOpsBroker configuration for /etc/default/grub
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
# If you change this file, run 'update-grub' afterwards to update
# /boot/grub/grub.cfg.
#
# For full documentation of the options in this file, see:
#   info -f grub -n 'Simple configuration'
#
# - See https://help.ubuntu.com/community/UEFI about booting using UEFI.
# - See https://wiki.archlinux.org/index.php/GRUB/Tips_and_tricks for GRUB tips
#   and tricks.
# -----------------------------------------------------------------------------
#

GRUB_DEFAULT=0
GRUB_TIMEOUT_STYLE=countdown
GRUB_TIMEOUT=0
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT="$defaultCmdLine"
GRUB_CMDLINE_LINUX="$efiReboot"

# Uncomment to enable BadRAM filtering, modify to suit your needs
# This works with Linux (no patch required) and with any kernel that obtains
# the memory map information from GRUB (GNU Mach, kernel of FreeBSD ...)
#GRUB_BADRAM="0x01234567,0xfefefefe,0x89abcdef,0xefefefef"

# Uncomment to disable graphical terminal (grub-pc only)
#GRUB_TERMINAL=console

# The resolution used on graphical terminal
# note that you can use only modes which your graphic card supports via VBE
# you can see them in real GRUB with the command 'vbeinfo'
#GRUB_GFXMODE=640x480

# Uncomment if you don't want GRUB to pass "root=UUID=xxx" parameter to Linux
#GRUB_DISABLE_LINUX_UUID=true

# Uncomment to disable generation of recovery mode menu entries
#GRUB_DISABLE_RECOVERY="true"

# Uncomment to get a beep at grub start
#GRUB_INIT_TUNE="480 440 1"

EOF

exit 0

