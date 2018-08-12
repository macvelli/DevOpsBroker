#!/bin/bash

#
# configure-grub.sh - DevOpsBroker script for configuring GRUB boot loader
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
# See https://www.gnu.org/software/grub/manual/grub/grub.html for more
# information on GRUB.
#
# o Enable lz4 Compression for zswap
# o Enable z3fold Pool for zswap
# o Set GRUB Timeout to 2 seconds
# o Enable zswap (lz4 compressor / z3fold zpool)
# o Disable NMI Watchdog
# o Enable Multi-Queue Block I/O Queueing
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

# Ensure the grub.tpl script is executable
grubTpl=$(isExecutable "$SCRIPT_DIR"/grub.tpl)

################################## Variables ##################################

## Bash exec variables
EXEC_UPDATE_GRUB=/usr/sbin/update-grub
EXEC_UPDATE_INITRAMFS=/usr/sbin/update-initramfs

echoOnExit=false

# Amount of RAM available in GB
RAM_GB=$[ ($(getRamTotal) + 1048575) / 1048576 ]

# Configure ZSwap Max Pool Percentage
if [ $RAM_GB -le 8 ]; then
  zswapMaxPoolPct=20
elif [ $RAM_GB -le 16 ]; then
  zswapMaxPoolPct=15
else
  zswapMaxPoolPct=10
fi


################################### Actions ###################################

# Clear screen only if called from command line
if [ $SHLVL -eq 1 ]; then
  clear
fi

bannerMsg='DevOpsBroker Ubuntu 16.04 Desktop GRUB Configurator'

echo ${bold} ${wisteria}
echo '╔═════════════════════════════════════════════════════╗'
echo "║ ${white}$bannerMsg${wisteria}"			   '║'
echo '╚═════════════════════════════════════════════════════╝'
echo ${reset}

#
# GRUB Configuration
#
if ! $EXEC_GREP -Fq 'zswap' /etc/default/grub; then
  # BEGIN GRUB Configuration

  printBanner 'Installing GRUB configuration'

  # Execute template script
  "$grubTpl" $zswapMaxPoolPct > "$SCRIPT_DIR"/grub

  # Install as root:root with rw-r--r-- privileges
  $EXEC_INSTALL -b --suffix .orig -o root -g root -m 644 "$SCRIPT_DIR"/grub /etc/default

  # Clean up
  $EXEC_RM "$SCRIPT_DIR"/grub

  printInfo 'Generate a new GRUB configuration file'
  $EXEC_UPDATE_GRUB

  if ! $EXEC_GREP -Fq '# Enable lz4 Compression for zswap' /etc/initramfs-tools/modules; then

    # Backup original /etc/initramfs-tools/modules file
    $EXEC_CP /etc/initramfs-tools/modules /etc/initramfs-tools/modules.orig

    printInfo 'Enable lz4 compression z3fold pool for zswap'

echo '
# Enable lz4 Compression for zswap
lz4
lz4_compress

# Enable z3fold Pool for zswap
z3fold
' >> /etc/initramfs-tools/modules

    printInfo 'Generate a new initramfs image'
    $EXEC_UPDATE_INITRAMFS -u
  fi

  echoOnExit=true

else

  currentMaxPoolPct=$($EXEC_SED -n 's/.* zswap.max_pool_percent=([0-9]*) .*/\1/p' /etc/default/grub)

  if [ $currentMaxPoolPct -ne $zswapMaxPoolPct ]; then

    printBanner 'Updating GRUB configuration'

    # Execute template script
    "$grubTpl" $zswapMaxPoolPct > "$SCRIPT_DIR"/grub

    # Install as root:root with rw-r--r-- privileges
    $EXEC_INSTALL -b --suffix .bak -o root -g root -m 644 "$SCRIPT_DIR"/grub /etc/default

    # Clean up
    $EXEC_RM "$SCRIPT_DIR"/grub

    printInfo 'Generate a new GRUB configuration file'
    $EXEC_UPDATE_GRUB

    echoOnExit=true
  fi

  # END GRUB Configuration
fi

if [ "$echoOnExit" == 'true' ]; then
  echo
fi

exit 0
