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

# Display error if not running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "\033[1mconfigure-grub.sh: \033[38;5;203mPermission denied (you must be root)\033[0m"

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

# Ensure the sysctl.conf.sh script is executable
grubSh=$(isExecutable "$SCRIPT_DIR/grub.sh")


################################## Variables ##################################

# Total amount of RAM available
RAM_TOTAL=$(grep -F MemTotal /proc/meminfo | awk '{print $2}')

# Amount of RAM available in GB
RAM_GB=$[ ($RAM_TOTAL + 1048575) / 1048576 ]

# Configure ZSwap Max Pool Percentage
if (( $RAM_GB <= 2 )); then
  zswapMaxPoolPct=20
elif (( $RAM_GB <= 4 )); then
  zswapMaxPoolPct=15
elif (( $RAM_GB <= 6 )); then
  zswapMaxPoolPct=12
else
  zswapMaxPoolPct=10
fi


################################### Actions ###################################

# Clear screen and print banner only if called from command line
if [ $SHLVL -eq 1 ]; then
  clear

  bannerMsg="DevOpsBroker Ubuntu 16.04 Desktop GRUB Configurator"

  echo -e $(bold kobi)
  echo    "╔═════════════════════════════════════════════════════╗"
  echo -e "║ "$(white)$bannerMsg$(kobi)                         "║"
  echo    "╚═════════════════════════════════════════════════════╝"
  echo -e $(reset)

fi

#
# GRUB Configuration
#
if ! grep -Fq "zswap" /etc/default/grub; then
  # BEGIN GRUB Configuration

  printBanner "Installing GRUB configuration"

  # Execute template script
  $SHELL -c "$grubSh" $zswapMaxPoolPct > "$SCRIPT_DIR/grub"

  # Install as root:root with rw-r--r-- privileges
  install -b --suffix .orig -o root -g root -m 644 "$SCRIPT_DIR/grub" /etc/default

  # Clean up
  rm "$SCRIPT_DIR/grub"

  printInfo "Generate a new GRUB configuration file"
  update-grub
  echo

  if ! grep -Fq "# Enable lz4 Compression for zswap" /etc/initramfs-tools/modules; then

    # Backup original /etc/initramfs-tools/modules file
    cp /etc/initramfs-tools/modules /etc/initramfs-tools/modules.orig

    printInfo "Enable lz4 compression z3fold pool for zswap"

echo "
# Enable lz4 Compression for zswap
lz4
lz4_compress

# Enable z3fold Pool for zswap
z3fold
" >> /etc/initramfs-tools/modules

    printInfo "Generate a new initramfs image"
    update-initramfs -u
    echo
  fi

else

  currentMaxPoolPct=$(sed -r -n 's/.* zswap.max_pool_percent=([0-9]*) .*/\1/p' /etc/default/grub)

  if [ $currentMaxPoolPct -ne $zswapMaxPoolPct ]; then

    printBanner "Updating GRUB configuration"

    # Execute template script
    $SHELL -c "$grubSh" $zswapMaxPoolPct > "$SCRIPT_DIR/grub"

    # Install as root:root with rw-r--r-- privileges
    install -b --suffix .bak -o root -g root -m 644 "$SCRIPT_DIR/grub" /etc/default

    # Clean up
    rm "$SCRIPT_DIR/grub"

    printInfo "Generate a new GRUB configuration file"
    update-grub
    echo
  fi

  # END GRUB Configuration
fi

exit 0

