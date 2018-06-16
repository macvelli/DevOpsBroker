#!/bin/bash

#
# configure-samba.sh - DevOpsBroker script for configuring Samba
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
# This configuration script performs the following tasks:
#   o Installs/Updates /etc/samba/smb.conf
#   o Disables the NetBIOS service (nmbd)
#   o Creates /etc/samba/private directory for the passdb.tdb file
#
# -----------------------------------------------------------------------------
#


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Preprocessing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Display error if not running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "\033[1mconfigure-samba.sh: \033[38;5;203mPermission denied (you must be root)\033[0m"

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

# Set smb.conf.sh location and make it executable
smbConf=$(isExecutable "$SCRIPT_DIR/smb.conf.sh")


################################### Actions ###################################

# Clear screen and print banner only if called from command line
if [ $SHLVL -eq 1 ]; then
  clear

  bannerMsg="DevOpsBroker Ubuntu 16.04 Desktop Samba Configurator"

  echo -e $(bold kobi)
  echo    "╔══════════════════════════════════════════════════════╗"
  echo -e "║ "$(white)$bannerMsg$(kobi)                          "║"
  echo    "╚══════════════════════════════════════════════════════╝"
  echo -e $(reset)

fi

#
# /etc/samba/ Configuration
#

# Install /etc/samba/smb.conf
if ! grep -Fq "DevOpsBroker" /etc/samba/smb.conf; then
  # BEGIN /etc/samba/smb.conf

  printInfo "Installing /etc/samba/smb.conf"

  # Execute template script
  $SHELL -c "$smbConf" > "$SCRIPT_DIR/smb.conf"

  # Install as root:root with rw-r--r-- privileges
  install -b --suffix .orig -o root -g root -m 644 "$SCRIPT_DIR/smb.conf" /etc/samba

  # Clean up
  rm "$SCRIPT_DIR/smb.conf"

  printInfo "Restart smbd Service"
  systemctl restart smbd.service

  echo

elif [ "$smbConf" -nt /etc/samba/smb.conf ]; then
  printInfo "Updating /etc/samba/smb.conf"

  # Execute template script
  $SHELL -c "$smbConf" > "$SCRIPT_DIR/smb.conf"

  # Install as root:root with rw-r--r-- privileges
  install -b --suffix .bak -o root -g root -m 644 "$SCRIPT_DIR/smb.conf" /etc/samba

  # Clean up
  rm "$SCRIPT_DIR/smb.conf"

  printInfo "Restart smbd Service"
  systemctl restart smbd.service

  echo

  # END /etc/samba/smb.conf
fi

# Create /etc/samba/private directory
if [ ! -d /etc/samba/private ]; then
  # BEGIN Create /etc/samba/private directory

  printInfo "Creating /etc/samba/private directory"

  # Make the private directory for the passdb.tdb file
  mkdir -p --mode=0750 /etc/samba/private

  echo

  # END Create /etc/samba/private directory
fi

# Disable nmbd service
if ! systemctl status nmbd | grep -Fq "Active: inactive (dead)"; then
  printInfo "Disabling Samba NetBIOS nameserver"

  # Stop and disable nmbd service
  systemctl stop nmbd
  systemctl disable nmbd

  echo

fi

exit 0

