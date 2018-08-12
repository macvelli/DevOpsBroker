#!/bin/bash

#
# install.sh - DevOpsBroker Ubuntu 16.04 Desktop Configurator install script
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
# To run this script:
#   o chmod u+x install.sh
#   o sudo ./install.sh
# -----------------------------------------------------------------------------
#

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Preprocessing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## Script information
SCRIPT_DIR=$( /usr/bin/dirname "$BASH_SOURCE" )

# Load $SCRIPT_DIR/etc/devops/ansi.conf
source "$SCRIPT_DIR"/etc/devops/ansi.conf

# Load $SCRIPT_DIR/etc/devops/exec.conf
source "$SCRIPT_DIR"/etc/devops/exec.conf

# Load $SCRIPT_DIR/etc/devops/functions.conf
source "$SCRIPT_DIR"/etc/devops/functions.conf

# Display error if not running as root
if [ "$EUID" -ne 0 ]; then
  echo "${bold}install.sh: ${bittersweet}Permission denied (you must be root)${reset}"

  exit 1
fi

################################## Functions ##################################

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function:	createSymlink
# Description:	Creates a symbolic link to the specified file
#
# Parameter $1:	The name of the symbolic link to create
# Parameter $2:	The target file to link to
# -----------------------------------------------------------------------------
function createSymlink() {
  # BEGIN create symbolic link

  local symlink="$1"
  local targetFile="$2"

  if [ ! -L "$symlink" ]; then
    printInfo "Creating symbolic link $symlink"
    $EXEC_LN -s "$targetFile" "$symlink"

    if [[ "$symlink" == /usr/local/sbin* ]]; then
      $EXEC_CHOWN --no-dereference root:devops "$symlink"
    elif [[ "$symlink" == /usr/local/bin* ]]; then
      $EXEC_CHOWN --no-dereference root:users "$symlink"
    fi
  fi

  # END create symbolic link
}

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function:	installConfFile
# Description:	Installs the specified DevOpsBroker configuration file
#
# Parameter $1:	The DevOpsBroker configuration file to install
# -----------------------------------------------------------------------------
function installConfFile() {
    if [ ! -f /etc/devops/$1 ]; then
        printInfo "Installing /etc/devops/$1"

        # Install as root:root with rw-r--r-- privileges
        $EXEC_INSTALL -o root -g root -m 644 "$SCRIPT_DIR"/etc/devops/$1 /etc/devops
    fi
}

################################## Variables ##################################

# Installation directory
INSTALL_DIR=/opt/devopsbroker/xenial/desktop/configurator

echoOnExit=false

################################### Actions ###################################

# Clear screen only if called from command line
if [ $SHLVL -eq 1 ]; then
  clear
fi

bannerMsg='DevOpsBroker Ubuntu 16.04 Desktop Configurator Installer'

echo ${bold} ${wisteria}
echo '╔══════════════════════════════════════════════════════════╗'
echo "║ ${white}$bannerMsg${wisteria}"				'║'
echo '╚══════════════════════════════════════════════════════════╝'
echo ${reset}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Initialization ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Build all C language utilties and install scriptinfo
/usr/bin/make -s --directory="$SCRIPT_DIR"/C
$EXEC_INSTALL -o root -g users -m 755 "$SCRIPT_DIR"/C/scriptinfo /usr/local/bin

# Set file ownership permissions
$EXEC_CHOWN -R $SUDO_USER:$SUDO_USER "$SCRIPT_DIR"
echo

# Add devops group
if [ -z "$($EXEC_GETENT group devops)" ]; then
  printInfo 'Adding devops group'
  $EXEC_ADDGROUP 'devops'
  echo
fi

# Add user to devops group, if necessary
userGroupList=$($EXEC_GROUPS $SUDO_USER)

if [[ ! "$userGroupList" =~ devops ]]; then
  printInfo "Adding $SUDO_USER to the devops group"
  $EXEC_ADDUSER $SUDO_USER 'devops'
  echo
fi

# Move /opt to /mnt/ssd/opt
if [ -d /mnt/ssd ] && [ ! -d /mnt/ssd/opt ]; then
  printInfo "Moving /opt to /mnt/ssd/opt"

  $EXEC_MKDIR --mode=0755 /mnt/ssd/opt

  $EXEC_MV /opt/* /mnt/ssd/opt/

  $EXEC_RM -rf /opt

  $EXEC_LN -s /mnt/ssd/opt /opt

  echo
fi

# Move /snap to /mnt/ssd/snap
if [ -d /mnt/ssd ] && [ ! -d /mnt/ssd/snap ]; then
  printInfo "Moving /snap to /mnt/ssd/snap"

  $EXEC_MKDIR --mode=0755 /mnt/ssd/snap

  $EXEC_MV /snap/* /mnt/ssd/snap/

  $EXEC_RM -rf /snap

  $EXEC_LN -s /mnt/ssd/snap /snap

  echo
fi

# Create /cache directory for user cache
if [ ! -L /cache ]; then
  printInfo 'Creating /cache directory'

  $EXEC_MKDIR --mode=0755 /mnt/ssd/cache

  $EXEC_CHOWN root:users /mnt/ssd/cache

  $EXEC_LN -s /mnt/ssd/cache /cache

  $EXEC_CHOWN --no-dereference root:users /cache

  echo
fi

# Create /opt/devopsbroker/xenial/desktop/configurator directory
if [ ! -d $INSTALL_DIR ]; then
  printInfo "Creating $INSTALL_DIR directory"

  echo -n ${perano}
  $EXEC_MKDIR --mode=2755 $INSTALL_DIR
  $EXEC_CHOWN -R root:devops /opt/devopsbroker
  echo ${reset}
fi

# Copy files into the /opt/devopsbroker/xenial/desktop/configurator directory
printInfo "Copying files to $INSTALL_DIR/"

echo ${perano}
$EXEC_RSYNC -r -t -v --include='/C/makefile' --include='/C/*/' --exclude='/C/*' --exclude='*.o' --exclude='/install.sh' --exclude='.keep' "$SCRIPT_DIR"/ "$INSTALL_DIR"/
echo
$EXEC_FIND "$INSTALL_DIR"/ -type f \( ! -name "*.sh" ! -name "*.tpl" \) -exec $EXEC_CHMOD 640 {} +
echo
$EXEC_FIND "$INSTALL_DIR"/ -type f \( -name "*.sh" -o -name "*.tpl" \) -exec $EXEC_CHMOD 750 {} +
echo
$EXEC_CHOWN -R root:devops "$INSTALL_DIR"/
echo -n ${reset}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Shell Scripts ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Make symlink to configure-desktop.sh
createSymlink /usr/local/sbin/configure-desktop "$INSTALL_DIR"/configure-desktop.sh

# Make symlink to device-drivers.sh
createSymlink /usr/local/sbin/device-drivers "$INSTALL_DIR"/device-drivers.sh

# Make symlink to ttf-msclearfonts.sh
createSymlink /usr/local/sbin/ttf-msclearfonts "$INSTALL_DIR"/ttf-msclearfonts.sh

# Make symlink to update-utils.sh
createSymlink /usr/local/sbin/update-utils "$INSTALL_DIR"/update-utils.sh

# Make symlink to etc/configure-fstab.sh
createSymlink /usr/local/sbin/configure-fstab "$INSTALL_DIR"/etc/configure-fstab.sh

# Make symlink to etc/configure-kernel.sh
createSymlink /usr/local/sbin/configure-kernel "$INSTALL_DIR"/etc/configure-kernel.sh

# Make symlink to etc/configure-system.sh
createSymlink /usr/local/sbin/configure-system "$INSTALL_DIR"/etc/configure-system.sh

# Make symlink to etc/apt/configure-apt-mirror.sh
createSymlink /usr/local/sbin/configure-apt-mirror "$INSTALL_DIR"/etc/apt/configure-apt-mirror.sh

# Make symlink to etc/default/configure-grub.sh
createSymlink /usr/local/sbin/configure-grub "$INSTALL_DIR"/etc/default/configure-grub.sh

# Make symlink to etc/network/configure-nic.sh
createSymlink /usr/local/sbin/configure-nic "$INSTALL_DIR"/etc/network/configure-nic.sh

# Make symlink to etc/network/ip6tables-desktop.sh
createSymlink /usr/local/sbin/ip6tables-desktop "$INSTALL_DIR"/etc/network/ip6tables-desktop.sh

# Make symlink to etc/network/iptables-desktop.sh
createSymlink /usr/local/sbin/iptables-desktop "$INSTALL_DIR"/etc/network/iptables-desktop.sh

# Make symlink to etc/samba/configure-samba.sh
createSymlink /usr/local/sbin/configure-samba "$INSTALL_DIR"/etc/samba/configure-samba.sh

# Make symlink to etc/security/configure-security.sh
createSymlink /usr/local/sbin/configure-security "$INSTALL_DIR"/etc/security/configure-security.sh

# Make symlink to etc/udev/configure-udev.sh
createSymlink /usr/local/sbin/configure-udev "$INSTALL_DIR"/etc/udev/configure-udev.sh

# Make symlink to etc/unbound/configure-unbound.sh
createSymlink /usr/local/sbin/configure-unbound "$INSTALL_DIR"/etc/unbound/configure-unbound.sh

# Make symlink to home/configure-user.sh
createSymlink /usr/local/sbin/configure-user "$INSTALL_DIR"/home/configure-user.sh

# Create /etc/devops directory
if [ ! -d /etc/devops ]; then
  printInfo 'Creating /etc/devops directory'
  $EXEC_MKDIR --mode=0755 /etc/devops
fi

# Install /etc/devops/ansi.conf
installConfFile "ansi.conf"

# Install /etc/devops/exec.conf
installConfFile "exec.conf"

# Install /etc/devops/functions.conf
installConfFile "functions.conf"

echo

exit 0
