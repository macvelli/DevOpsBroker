#!/bin/bash

#
# update-utils.sh - DevOpsBroker script for installing and updating utility scripts and executables
#
# Copyright (C) 2018-2019 Edward Smith <edwardsmith@devopsbroker.org>
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
# Developed on Ubuntu 16.04.5 LTS running kernel.osrelease = 4.15.0-24
#
# -----------------------------------------------------------------------------
#

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Preprocessing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
	printError $SCRIPT_EXEC 'Permission denied (you must be root)'
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
		$EXEC_CHOWN --changes --no-dereference root:users "$symlink"
		echoOnExit=true
	fi
}

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function:     installService
# Description:  Installs the firewall service into /usr/local/sbin/services
#
# Parameter $1: The name of the service to install
# -----------------------------------------------------------------------------
function installService() {
	local service="$1"
	local destDir=/usr/local/sbin/services
	local sourceDir="$SCRIPT_DIR/$destDir"

	if [ ! -f $destDir/$service ]; then
		printInfo "Installing firewall service $destDir/$service"

		# Install as root:sudo with rwxr-x--- privileges
		$EXEC_INSTALL -o root -g sudo -m 750 "$sourceDir/$service" $destDir
		echoOnExit=true

	elif [ "$sourceDir/$service" -nt $destDir/$service ]; then
		printInfo "Updating firewall service $destDir/$service"

		# Install as root:sudo with rwxr-x--- privileges
		$EXEC_INSTALL -o root -g sudo -m 750 "$sourceDir/$service" $destDir
		echoOnExit=true
	fi
}

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function:     installSystemUtility
# Description:  Installs the system administration utility into /usr/local/sbin
#
# Parameter $1: The name of the utility to install
# -----------------------------------------------------------------------------
function installSystemUtility() {
	local utility="$1"
	local sourceDir="$SCRIPT_DIR/usr/local/sbin"

	if [ ! -f /usr/local/sbin/$utility ]; then
		printInfo "Installing system utility /usr/local/sbin/$utility"

		# Install system utility as root:sudo with rwxr-x--- privileges
		$EXEC_INSTALL -o root -g sudo -m 750 "$sourceDir/$utility" /usr/local/sbin
		echoOnExit=true

	elif [ "$sourceDir/$utility" -nt /usr/local/sbin/$utility ]; then
		printInfo "Updating system utility /usr/local/sbin/$utility"

		# Install system utility as root:sudo with rwxr-x--- privileges
		$EXEC_INSTALL -o root -g sudo -m 750 "$sourceDir/$utility" /usr/local/sbin
		echoOnExit=true
	fi
}

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function:     installUserUtility
# Description:  Installs the user utility into /usr/local/bin
#
# Parameter $1: The name of the utility to install
# -----------------------------------------------------------------------------
function installUserUtility() {
	local utility="$1"
	local sourceDir="$SCRIPT_DIR/usr/local/bin"

	if [ ! -f /usr/local/bin/$utility ]; then
		printInfo "Installing user utility /usr/local/bin/$utility"

		# Install user utility as root:users with rwxr-xr-x privileges
		$EXEC_INSTALL -o root -g users -m 755 "$sourceDir/$utility" /usr/local/bin
		echoOnExit=true

	elif [ "$sourceDir/$utility" -nt /usr/local/bin/$utility ]; then
		printInfo "Updating user utility /usr/local/bin/$utility"

		# Install user utility as root:users with rwxr-xr-x privileges
		$EXEC_INSTALL -o root -g users -m 755 "$sourceDir/$utility" /usr/local/bin
		echoOnExit=true
	fi
}

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function:     installTemplate
# Description:  Installs the venture template to /usr/local/bin/template
#
# Parameter $1: The name of the template to install
# -----------------------------------------------------------------------------
function installTemplate() {
	local template="$1"
	local sourceDir="$SCRIPT_DIR"/usr/local/bin/template

	if [ ! -f /usr/local/bin/template/$template ]; then
		printInfo "Installing venture template /usr/local/bin/template/$template"

		# Install venture template as root:users with rwxr-xr-x privileges
		$EXEC_INSTALL -o root -g users -m 755 "$sourceDir/$template" /usr/local/bin/template
		echoOnExit=true

	elif [ "$sourceDir/$template" -nt /usr/local/bin/template/$template ]; then
		printInfo "Updating venture template /usr/local/bin/template/$template"

		# Install venture template as root:users with rwxr-xr-x privileges
		$EXEC_INSTALL -b --suffix=.bak -o root -g users -m 755 "$sourceDir/$template" /usr/local/bin/template
		echoOnExit=true
	fi
}

################################## Variables ##################################

## Variables
echoOnExit=false

################################### Actions ###################################

# Clear screen only if called from command line
if [ $SHLVL -eq 1 ]; then
	clear
fi

printBox "DevOpsBroker $UBUNTU_RELEASE Utility Updater" 'true'

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~ System Administration ~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Install addUserToGroup system administration utility
installSystemUtility addUserToGroup

# Install appbroker system administration utility
installSystemUtility appbroker

# Install bindmount system administration utility
installSystemUtility bindmount

# Install bridgebroker system administration utility
installSystemUtility bridgebroker

# Install dirchmod system administration utility
installSystemUtility dirchmod

# Install disableJournal system administration utility
installSystemUtility disableJournal

# Install firechain system administration utility
installSystemUtility firechain

# Install firewall system administration utility
installSystemUtility firewall

# Install gksu system administration utility
installSystemUtility gksu

# Install logbroker system administration utility
installSystemUtility logbroker

# Install movedir system administration utility
installSystemUtility movedir

# Install pms system administration utility
installSystemUtility pms

# Install reportcrash system administration utility
installSystemUtility reportcrash

# Install schedtuner system administration utility
installSystemUtility schedtuner

# Install smbshare system administration utility
installSystemUtility smbshare

# Install wipedisk system administration utility
installSystemUtility wipedisk

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Firewall Services ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Make /usr/local/sbin/services directory
if [ ! -d /usr/local/sbin/services ]; then
	printInfo 'Creating /usr/local/sbin/services directory'

	$EXEC_MKDIR --parents --mode=0750 /usr/local/sbin/services
	$EXEC_CHOWN --changes root:sudo /usr/local/sbin/services
	echoOnExit=true
fi

installService 'smbd'

installService 'smtp-client'

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ User Utilities ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Install albumart user utility
installUserUtility albumart

# Install archive user utility
installUserUtility archive

# Install bash_reboot user utility
installUserUtility bash_reboot

# Install between user utility
installUserUtility between

# Install bgedit user utility
installUserUtility bgedit

# Install certauth user utility
installUserUtility certauth

# Install convert-number user utility
installUserUtility convert-number

# Create symbolic links to the convert-number user utility
createSymlink /usr/local/bin/binary /usr/local/bin/convert-number
createSymlink /usr/local/bin/decimal /usr/local/bin/convert-number
createSymlink /usr/local/bin/hex /usr/local/bin/convert-number
createSymlink /usr/local/bin/octal /usr/local/bin/convert-number

# Install convert-temp user utility
installUserUtility convert-temp

# Create symbolic links to the convert-temp user utility
createSymlink /usr/local/bin/celsius    /usr/local/bin/convert-temp
createSymlink /usr/local/bin/fahrenheit /usr/local/bin/convert-temp
createSymlink /usr/local/bin/kelvin     /usr/local/bin/convert-temp

# Install deb-control user utility
installUserUtility deb-control

# Install decrypt user utility
installUserUtility decrypt

# Install derivesubnet user utility
installUserUtility derivesubnet

# Install encrypt user utility
installUserUtility encrypt

# Install extract user utility
installUserUtility extract

# Install favicon user utility
installUserUtility favicon

# Install firelog user utility
installUserUtility firelog

# Install geoip user utility
installUserUtility geoip

# Install git-repo user utility
installUserUtility git-repo

# Install gnome-config user utility
installUserUtility gnome-config

# Install hexToRgb user utility
installUserUtility hexToRgb

# Install hypotenuse user utility
installUserUtility hypotenuse

# Install kernel-config user utility
installUserUtility kernel-config

# Install lwp user utility
installUserUtility lwp

# Install macaddr user utility
installUserUtility macaddr

# Install md5sums user utility
installUserUtility md5sums

# Install nettuner user utility
installUserUtility nettuner

# Install printAnsi16 user utility
installUserUtility printAnsi16

# Install printAnsi256 user utility
installUserUtility printAnsi256

# Install public-ip user utility
installUserUtility public-ip

# Install qemu-config user utility
installUserUtility qemu-config

# Install random-password user utility
installUserUtility random-password

# Install reverse-dns user utility
installUserUtility reverse-dns

# Install rgbToHex user utility
installUserUtility rgbToHex

# Install scriptinfo user utility
installUserUtility scriptinfo

# Install shades user utility
installUserUtility shades

# Install showFileFormat user utility
installUserUtility showFileFormat

# Install snippet user utility
installUserUtility snippet

# Install sshbroker user utility
installUserUtility sshbroker

# Install symlink user utility
installUserUtility symlink

# Install tints user utility
installUserUtility tints

# Install trim user utility
installUserUtility trim

# Install udev user utility
installUserUtility udev

# Install uuid user utility
installUserUtility uuid

# Install variations user utility
installUserUtility variations

# Install venture user utility
installUserUtility venture

# Install verify user utility
installUserUtility verify

# Install verifyclass user utility
installUserUtility verifyclass

# Install verifyip user utility
installUserUtility verifyip

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Venture Templates ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Make /usr/local/bin/template directory
if [ ! -d /usr/local/bin/template ]; then
	printInfo 'Creating /usr/local/bin/template directory'

	$EXEC_MKDIR --parents --mode=755 /usr/local/bin/template
	$EXEC_CHOWN --changes root:users /usr/local/bin/template
	echoOnExit=true
fi

installTemplate 'asm-source-file.tpl'
installTemplate 'bash-complete.tpl'
installTemplate 'bash-script.tpl'
installTemplate 'bash-template.tpl'
installTemplate 'c-enum-source.tpl'
installTemplate 'c-header-file.tpl'
installTemplate 'c-source-file.tpl'
installTemplate 'c-struct-source.tpl'
installTemplate 'fileinfo.tpl'
installTemplate 'html5.tpl'
installTemplate 'linux-conf.tpl'
installTemplate 'makefile.tpl'

if [ $echoOnExit == 'true' ]; then
	echo
fi

exit 0
