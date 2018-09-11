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
if [ "$USER" != 'root' ]; then
	printError 'install.sh' 'Permission denied (you must be root)'
	exit 1
fi

################################## Functions ##################################

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function:     createSymlink
# Description:  Creates a symbolic link to the specified file
#
# Parameter $1: The name of the symbolic link to create
# Parameter $2: The target file to link to
# -----------------------------------------------------------------------------
function createSymlink() {
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
}

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function:     installConfFile
# Description:  Installs the specified DevOpsBroker configuration file
#
# Parameter $1: The DevOpsBroker configuration file to install
# -----------------------------------------------------------------------------
function installConfFile() {
	if [ ! -f /etc/devops/$1 ]; then
		printInfo "Installing /etc/devops/$1"

		# Install as root:root with rw-r--r-- privileges
		$EXEC_INSTALL -o root -g root -m 644 "$SCRIPT_DIR"/etc/devops/$1 /etc/devops
	fi
}

################################### Actions ###################################

# Clear screen only if called from command line
if [ $SHLVL -eq 1 ]; then
	clear
fi

printBox "DevOpsBroker $UBUNTU_RELEASE Configurator Installer" 'true'

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Initialization ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Add devops group
if [ -z "$($EXEC_GETENT group devops)" ]; then
	printInfo 'Adding devops group'
	$EXEC_ADDGROUP 'devops'
	echo
fi

# Add user to devops group, if necessary
userGroups=$($EXEC_GROUPS $SUDO_USER)

regExpr="\\bdevops\\b"
if [[ ! "$userGroups" =~ $regExpr ]]; then
	printInfo "Adding $SUDO_USER to the 'devops' group"
	$EXEC_ADDUSER $SUDO_USER 'devops'
fi

# Create /cache directory for user cache
if [ ! -d /cache ]; then
	printInfo 'Creating /cache directory'

	$EXEC_MKDIR --mode=0755 /cache
	$EXEC_CHOWN root:users /cache
fi

if [ -d /mnt/ssd ]; then
	fstabEntries="$($EXEC_GREP -E '^# Bind mounts|^/mnt/ssd/(cache|opt|snap)' /etc/fstab)"

	addCacheEntry=false
	addOptEntry=false
	addSnapEntry=false

	# Create /mnt/ssd/cache directory for user cache
	if [ ! -d /mnt/ssd/cache ]; then
		printInfo 'Creating /mnt/ssd/cache directory'

		$EXEC_MKDIR --mode=0755 /mnt/ssd/cache
		$EXEC_CHOWN root:users /mnt/ssd/cache

		addCacheEntry=true
	fi

	# Move /opt directory to /mnt/ssd/opt
	if [ ! -d /mnt/ssd/opt ]; then
		printInfo 'Creating /mnt/ssd/opt directory'

		$EXEC_MKDIR --mode=0755 /mnt/ssd/opt

		addOptEntry=true
	fi

	# Move /snap directory to /mnt/ssd/snap
	if [ ! -d /mnt/ssd/snap ]; then
		printInfo 'Creating /mnt/ssd/snap directory'

		$EXEC_MKDIR --mode=0755 /mnt/ssd/snap

		addSnapEntry=true
	fi

	regExpr='^# Bind mounts'
	if [[ ! "$fstabEntries" =~ $regExpr ]]; then
		echo '# Bind mounts' >> /etc/fstab

		addCacheEntry=true
		addOptEntry=true
		addSnapEntry=true
	fi

	regExpr='/mnt/ssd/cache'
	if [ "$addCacheEntry" == 'true' ] || [[ ! "$fstabEntries" =~ $regExpr ]]; then
		printInfo "Adding /mnt/ssd/cache bind mount to /etc/fstab"
		echo '/mnt/ssd/cache	/cache	none	bind	0	0' >> /etc/fstab

		printInfo 'Bind mounting /mnt/ssd/cache directory to /cache'
		$EXEC_MOUNT --bind /mnt/ssd/cache /cache
	fi

	regExpr='/mnt/ssd/opt'
	if [ "$addOptEntry" == 'true' ] || [[ ! "$fstabEntries" =~ $regExpr ]]; then
		printInfo "Adding /mnt/ssd/opt bind mount to /etc/fstab"
		echo '/mnt/ssd/opt	/opt	none	bind	0	0' >> /etc/fstab

		if [ -z "$($EXEC_LS -A /mnt/ssd/opt)" ]; then
			printInfo 'Copying /opt directory to /mnt/ssd'
			$EXEC_CP -a /opt /mnt/ssd
		fi

		$EXEC_RM -rf /opt/*

		printInfo 'Bind mounting /mnt/ssd/opt directory to /opt'
		$EXEC_MOUNT --bind /mnt/ssd/opt /opt
	fi

	regExpr='/mnt/ssd/snap'
	if [ "$addSnapEntry" == 'true' ] || [[ ! "$fstabEntries" =~ $regExpr ]]; then
		printInfo "Adding /mnt/ssd/snap bind mount to /etc/fstab"
		echo '/mnt/ssd/snap	/snap	none	bind	0	0' >> /etc/fstab

		if [ -z "$($EXEC_LS -A /mnt/ssd/snap)" ]; then
			printInfo 'Copying /snap directory to /mnt/ssd'
			$EXEC_CP -a /snap /mnt/ssd
		fi

		$EXEC_RM -rf /snap/*

		printInfo 'Bind mounting /mnt/ssd/snap directory to /snap'
		$EXEC_MOUNT --bind /mnt/ssd/snap /snap
	fi
fi

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Installation ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Create /opt/devopsbroker/xenial/desktop/configurator directory
if [ ! -d $INSTALL_DIR ]; then
	printInfo "Creating $INSTALL_DIR directory"

	$EXEC_MKDIR --mode=2755 $INSTALL_DIR
	$EXEC_CHOWN -R root:devops /opt/devopsbroker
fi

# Copy files into the /opt/devopsbroker/xenial/desktop/configurator directory
printBanner "Copying files to $INSTALL_DIR/"

/bin/cp -uv --preserve=timestamps "$SCRIPT_DIR"/configure-desktop.sh "$INSTALL_DIR"
/bin/cp -uv --preserve=timestamps "$SCRIPT_DIR"/device-drivers.sh "$INSTALL_DIR"
/bin/cp -uv --preserve=timestamps "$SCRIPT_DIR"/ttf-msclearfonts.sh "$INSTALL_DIR"
/bin/cp -uv --preserve=timestamps "$SCRIPT_DIR"/update-utils.sh "$INSTALL_DIR"

/bin/cp -ruv --preserve=timestamps "$SCRIPT_DIR"/archives "$INSTALL_DIR"
/bin/cp -ruv --preserve=timestamps "$SCRIPT_DIR"/doc "$INSTALL_DIR"
/bin/cp -ruv --preserve=timestamps "$SCRIPT_DIR"/etc "$INSTALL_DIR"
/bin/cp -ruv --preserve=timestamps "$SCRIPT_DIR"/home "$INSTALL_DIR"
/bin/cp -ruv --preserve=timestamps "$SCRIPT_DIR"/perf "$INSTALL_DIR"
/bin/cp -ruvL --preserve=timestamps "$SCRIPT_DIR"/usr "$INSTALL_DIR"

echo
$EXEC_FIND "$INSTALL_DIR"/ -type f \( ! -name "*.sh" ! -name "*.tpl" \) -exec $EXEC_CHMOD 640 {} +
echo
$EXEC_FIND "$INSTALL_DIR"/ -type f \( -name "*.sh" -o -name "*.tpl" \) -exec $EXEC_CHMOD 750 {} +
echo
$EXEC_CHOWN -R root:devops "$INSTALL_DIR"/
echo

# Copy scriptinfo to /usr/local/bin
CP_OUTPUT="$(/bin/cp -uv --preserve=timestamps "$INSTALL_DIR"/usr/local/bin/scriptinfo /usr/local/bin)"
if [ ! -z "$CP_OUTPUT" ]  ; then
	/bin/chmod -c 755 /usr/local/bin/scriptinfo
	/bin/chown -c root:users /usr/local/bin/scriptinfo
fi

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

# Make symlink to etc/network/ip6tables-desktop.sh
createSymlink /usr/local/sbin/ip6tables-desktop "$INSTALL_DIR"/etc/network/ip6tables-desktop.sh

# Make symlink to etc/network/iptables-desktop.sh
createSymlink /usr/local/sbin/iptables-desktop "$INSTALL_DIR"/etc/network/iptables-desktop.sh

# Make symlink to etc/NetworkManager/configure-nm.sh
createSymlink /usr/local/sbin/configure-nm "$INSTALL_DIR"/etc/NetworkManager/configure-nm.sh

# Make symlink to etc/samba/configure-samba.sh
createSymlink /usr/local/sbin/configure-samba "$INSTALL_DIR"/etc/samba/configure-samba.sh

# Make symlink to etc/security/configure-security.sh
createSymlink /usr/local/sbin/configure-security "$INSTALL_DIR"/etc/security/configure-security.sh

# Make symlink to etc/udev/configure-udev.sh
createSymlink /usr/local/sbin/configure-udev "$INSTALL_DIR"/etc/udev/configure-udev.sh

# Make symlink to etc/udev/rules.d/tune-diskio.tpl
createSymlink /usr/local/sbin/tune-diskio "$INSTALL_DIR"/etc/udev/rules.d/tune-diskio.tpl

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
