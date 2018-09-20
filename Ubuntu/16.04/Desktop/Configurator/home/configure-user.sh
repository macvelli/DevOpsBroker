#!/bin/bash

#
# configure-user.sh - DevOpsBroker script for configuring users
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
# Creates the following directories for the user:
#   o $userhome/bin
#   o $userhome/.local/bin
#   o $userhome/.config/gtk-3.0
#   o $userhome/.config/systemd/user
#
# Installs the following Bash configuration files in the home directory of the
# user:
#   o .bash_aliases
#   o .bash_logout
#   o .bash_personal
#   o .bashrc
#   o .config/gtk-3.0/gtk.css
#   o .config/gtk-3.0/settings.ini
#   o .gitconfig
#   o .profile
#
# Installs the following templates to $userhome/Templates:
#   o New CSS.css
#   o New HTML.html
#   o New JavaScript.js
#   o New LibreOffice Calc.ods
#   o New LibreOffice Draw.odg
#   o New LibreOffice Impress.odp
#   o New LibreOffice Math.odf
#   o New LibreOffice Writer.odt
#   o New Systemd.service
#
# Manages the following /etc/skel configurations:
#   o /etc/skel/.bash_aliases
#   o /etc/skel/.bash_logout
#   o /etc/skel/.bash_personal
#   o /etc/skel/.bashrc
#   o /etc/skel/.gitconfig
#   o /etc/skel/.profile
#   o /etc/skel/.config/gtk-3.0/gtk.css
#   o /etc/skel/.config/gtk-3.0/settings.ini
#
# Adds the user to the 'users' group (if necessary)
# Adds the user to the 'audio' group (if necessary)
# Adds the user to the 'video' group (if necessary)
# Adds the user to the 'kvm' group
#
# Moves the user's Firefox cache to /mnt/ramdisk
#
# Generate SSH keys
#
# Configure GPG
#
# Installs systemd user service ssh-agent.service
#
# Applies stricter file and directory settings to the user's home directory
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

## Script information
SCRIPT_INFO=( $($EXEC_SCRIPTINFO "$BASH_SOURCE") )
SCRIPT_DIR="${SCRIPT_INFO[0]}"
SCRIPT_EXEC="${SCRIPT_INFO[1]}"

# Display error if not running as root
if [ "$USER" != 'root' ]; then
	printError "$SCRIPT_EXEC" 'Permission denied (you must be root)'
	exit 1
fi

################################## Functions ##################################

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function:     installSkeleton
# Description:  Installs the user configuration file into the /etc/skel directory
#
# Parameter $1: Name of the configuration file to install
# Parameter $2: Name of the /etc/skel file
# -----------------------------------------------------------------------------
function installSkeleton() {
	if [ ! -f "/etc/skel/$2" ] || [ "$SCRIPT_DIR/$1" -nt "/etc/skel/$2" ]; then
		printInfo "Installing /etc/skel/$2"

		# Install as root:root with rw-r--r-- privileges
		$EXEC_INSTALL -o root -g root -m 644 "$SCRIPT_DIR/$1" "/etc/skel/$2"
	fi
}

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function:     installTemplate
# Description:  Installs the template file into the $userhome/Templates directory
#
# Parameter $1: Name of the template file to install
# -----------------------------------------------------------------------------
function installTemplate() {
	local templateFile="$@"

	if [ ! -f "$userhome/Templates/$templateFile" ]; then
		printInfo "Installing $userhome/Templates/$templateFile"

		# Install as $username:$username with rw-r----- privileges
		$EXEC_INSTALL -o $username -g $username -m 640 "$SCRIPT_DIR/Templates/$templateFile" "$userhome"/Templates
	fi
}

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function:     installUserConfig
# Description:  Installs the user configuration file into the $userhome directory
#
# Parameter $1: Name of the configuration file to install
# Parameter $2: Name of the source configuration file
# -----------------------------------------------------------------------------
function installUserConfig() {
	local configFile="$1"
	local sourceFile="$2"

	if [ ! -f "$userhome/$configFile" ] || ! $EXEC_GREP -Fq 'DevOpsBroker' "$userhome/$configFile"; then
		printInfo "Installing $userhome/$configFile"

		# Install as $username:$username with rw-r----- privileges
		$EXEC_INSTALL -b --suffix .orig -o $username -g $username -m 640 "$SCRIPT_DIR/$sourceFile" "$userhome/$configFile"

	elif [ "$SCRIPT_DIR/$sourceFile" -nt "$userhome/$configFile" ]; then
		printInfo "Updating $userhome/$configFile"

		# Install as $username:$username with rw-r----- privileges
		$EXEC_INSTALL -b --suffix .bak -o $username -g $username -m 640 "$SCRIPT_DIR/$sourceFile" "$userhome/$configFile"
	fi
}

################################## Variables ##################################

## Bash exec variables
EXEC_SSH_KEY=/usr/local/bin/ssh-key
EXEC_SUDO=/usr/bin/sudo
EXEC_SYMLINK=/usr/local/bin/symlink

## Options
username=${1:-$SUDO_USER}

## Variables
export TMPDIR=${TMPDIR:-'/tmp'}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ OPTION Parsing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

userRecord="$($EXEC_GETENT passwd $username)"

# Ensure the argument is a valid username
if [ ${#userRecord} -eq 0 ]; then
	printError "$SCRIPT_EXEC" "Cannot find '$username': No such user"
	echo
	printUsage "$SCRIPT_EXEC USER"

	exit 1
fi

IFS=':'; userInfo=($userRecord); unset IFS;

# Ensure the user is using bash for the shell
if [ "${userInfo[6]}" != '/bin/bash' ]; then
	printError "$SCRIPT_EXEC" "User shell not bash: ${userInfo[6]}"
	exit 1
fi

userhome="${userInfo[5]}"

################################### Actions ###################################

# Clear screen only if called from command line
if [ $SHLVL -eq 1 ]; then
	clear
fi

printBox "DevOpsBroker $UBUNTU_RELEASE User Configurator" 'true'

# Create $userhome/bin
if [ ! -d "$userhome"/bin ]; then
	printInfo "Create $userhome/bin directory"

	$EXEC_MKDIR --mode=750 "$userhome"/bin
	$EXEC_CHOWN $username:$username "$userhome"/bin
fi

# Create $userhome/.local/bin
if [ ! -d "$userhome"/.local/bin ]; then
	printInfo "Create $userhome/.local/bin directory"

	$EXEC_MKDIR --mode=750 "$userhome"/.local/bin
	$EXEC_CHOWN $username:$username "$userhome"/.local/bin
fi

# Create $userhome/.config/gtk-3.0 directory
if [ ! -d "$userhome"/.config/gtk-3.0 ]; then
	printInfo "Create $userhome/.config/gtk-3.0 directory"

	$EXEC_MKDIR --mode=750 "$userhome"/.config/gtk-3.0
	$EXEC_CHOWN $username:$username "$userhome"/.config/gtk-3.0
fi

# Create $userhome/.config/systemd/user directory
if [ ! -d "$userhome"/.config/systemd/user ]; then
	printInfo "Create $userhome/.config/systemd/user directory"

	$EXEC_MKDIR --mode=750 "$userhome"/.config/systemd/user
	$EXEC_CHOWN $username:$username "$userhome"/.config/systemd/user
fi

# Create /cache/$username directory
if [ ! -d /cache/$username ]; then
	printInfo "Create /cache/$username directory"

	$EXEC_MKDIR --mode=0700 /cache/$username
	$EXEC_CHOWN $username:$username /cache/$username
fi

# Move $userhome/.cache to /cache/$username
if [ -d /cache/$username ] && [ ! -L "$userhome"/.cache ]; then
	printInfo "Moving $userhome/.cache to /cache/$username"

	$EXEC_MV "$userhome"/.cache/* /cache/$username/
	$EXEC_RM -rf "$userhome"/.cache
	$EXEC_SYMLINK -o $username:$username "$userhome"/.cache /cache/$username
fi

# Install $userhome/.bash_aliases
installUserConfig '.bash_aliases' 'bash_aliases'

# Install $userhome/.bash_logout
installUserConfig '.bash_logout' 'bash_logout'

# Install $userhome/.bash_personal
if [ ! -f "$userhome"/.bash_personal ]; then
	printInfo "Installing $userhome/.bash_personal"

	# Install as $username:$username with rw-r----- privileges
	$EXEC_INSTALL -o $username -g $username -m 640 "$SCRIPT_DIR"/bash_personal "$userhome"/.bash_personal
fi

# Install $userhome/.bashrc
installUserConfig '.bashrc' 'bashrc'

# Install $userhome/.gitconfig
installUserConfig '.gitconfig' 'gitconfig'

# Install $userhome/.profile
installUserConfig '.profile' 'profile'

# Install $userhome/.config/gtk-3.0/gtk.css
installConfig 'gtk.css' "$SCRIPT_DIR/config/gtk-3.0" "$userhome/.config/gtk-3.0"

# Install $userhome/.config/gtk-3.0/settings.ini
installConfig 'settings.ini' "$SCRIPT_DIR/config/gtk-3.0" "$userhome/.config/gtk-3.0"

$EXEC_CHOWN -R $username:$username "$userhome/.config/gtk-3.0"

# Install $userhome/Templates/New CSS.css
installTemplate 'New CSS.css'

# Install $userhome/Templates/New HTML.html
installTemplate 'New HTML.html'

# Install $userhome/Templates/New JavaScript.js
installTemplate 'New JavaScript.js'

# Install $userhome/Templates/New LibreOffice Calc.ods
installTemplate 'New LibreOffice Calc.ods'

# Install $userhome/Templates/New LibreOffice Draw.odg
installTemplate 'New LibreOffice Draw.odg'

# Install $userhome/Templates/New LibreOffice Impress.odp
installTemplate 'New LibreOffice Impress.odp'

# Install $userhome/Templates/New LibreOffice Math.odf
installTemplate 'New LibreOffice Math.odf'

# Install $userhome/Templates/New LibreOffice Writer.odt
installTemplate 'New LibreOffice Writer.odt'

# Install $userhome/Templates/New Systemd.service
installTemplate 'New Systemd.service'

# Create /etc/skel/.config/gtk-3.0 directory
if [ ! -d /etc/skel/.config/gtk-3.0 ]; then
	$EXEC_MKDIR --mode=0755 /etc/skel/.config/gtk-3.0
fi

# Install /etc/skel/.bash_aliases
installSkeleton 'bash_aliases' '.bash_aliases'

# Install /etc/skel/.bash_logout
installSkeleton 'bash_logout' '.bash_logout'

# Install /etc/skel/.bash_personal
installSkeleton 'bash_personal' '.bash_personal'

# Install /etc/skel/.bashrc
installSkeleton 'bashrc' '.bashrc'

# Install /etc/skel/.gitconfig
installSkeleton 'gitconfig' '.gitconfig'

# Install /etc/skel/.profile
installSkeleton 'profile' '.profile'

# Install /etc/skel/.config/gtk-3.0/gtk.css
installSkeleton 'config/gtk-3.0/gtk.css' '.config/gtk-3.0/gtk.css'

# Install /etc/skel/.config/gtk-3.0/settings.ini
installSkeleton 'config/gtk-3.0/settings.ini' '.config/gtk-3.0/settings.ini'

userGroups=$( $EXEC_GROUPS $username )

# Add $username to the 'users' group
regExpr="\\busers\\b"
if [[ ! "$userGroups" =~ $regExpr ]]; then
	printInfo "Adding $username to the 'users' group"

	$EXEC_ADDUSER $username 'users'
fi

# Add $username to the 'audio' group
regExpr="\\baudio\\b"
if [[ ! "$userGroups" =~ $regExpr ]]; then
	printInfo "Adding $username to the 'audio' group"

	$EXEC_ADDUSER $username 'audio'
fi

# Add $username to the 'video' group
regExpr="\\bvideo\\b"
if [ ! -z "$($EXEC_GETENT group 'video')" ] &&  [[ ! "$userGroups" =~ $regExpr ]]; then
	printInfo "Adding $username to the 'video' group"

	$EXEC_ADDUSER $username 'video'
fi

# Add $username to the 'kvm' group
regExpr="\\bkvm\\b"
if [ ! -z "$($EXEC_GETENT group 'kvm')" ] && [[ ! "$userGroups" =~ $regExpr ]]; then
	printInfo "Adding $username to the 'kvm' group"

	$EXEC_ADDUSER $username 'kvm'
fi

# Move Firefox cache to /mnt/ramdisk
if [ ! -d "/mnt/ramdisk/$username/mozilla/firefox" ] && [ -d "$userhome"/.cache/mozilla/firefox ] ; then
	printInfo 'Moving Firefox cache to /mnt/ramdisk'

	# Create Firefox cache directory for the user in /mnt/ramdisk
	$EXEC_MKDIR --mode=0700 /mnt/ramdisk/$username/mozilla/firefox
	$EXEC_CHOWN -R $username:$username /mnt/ramdisk/$username

	# Create symlink to Firefox cache in /mnt/ramdisk
	$EXEC_CP -a "$userhome"/.cache/mozilla/firefox/* "/mnt/ramdisk/$username/mozilla/firefox"
	$EXEC_RM -rf "$userhome"/.cache/mozilla/firefox
	$EXEC_SYMLINK -o $username:$username "$userhome"/.cache/mozilla/firefox "/mnt/ramdisk/$username/mozilla/firefox"
fi

#
# Generate SSH Keys
#

# Clean out any errors that might have been made on install
if [ -f "$userhome"/.ssh ]; then
	$EXEC_RM "$userhome"/.ssh
fi

if [ ! -d "$userhome"/.ssh ] || [ $($EXEC_FIND "$userhome"/.ssh -type f | $EXEC_WC -l) -eq 0 ]; then
	/usr/bin/sudo -u $username $EXEC_SSH_KEY gen -d "$userhome" -u $username
fi

if [ ! -f "$userhome"/.ssh/config ]; then
	printInfo 'Installing sample SSH client configuration'

	# Install as $username:$username with rw-r----- privileges
	$EXEC_INSTALL -o $username -g $username -m 640 "$SCRIPT_DIR"/ssh/config "$userhome"/.ssh
fi

#
# Install ssh-agent.service
#

if [ ! -f "$userhome"/.config/systemd/user/ssh-agent.service ]; then
	printInfo 'Installing systemd user service ssh-agent.service'

	# Install as $username:$username with rw-r--r-- privileges
	$EXEC_INSTALL -o $username -g $username -m 644 "$SCRIPT_DIR"/systemd/ssh-agent.service "$userhome"/.config/systemd/user

	# Need XDG_RUNTIME_DIR and DBUS_SESSION_BUS_ADDRESS
	printInfo 'Enable systemd user service ssh-agent.service'
	$EXEC_SUDO -u $username XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" $EXEC_SYSTEMCTL --user enable ssh-agent.service

	printInfo 'Start systemd user service ssh-agent.service'
	$EXEC_SUDO -u $username XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" $EXEC_SYSTEMCTL --user start ssh-agent.service
fi

#
# Configure GPG
#

if [ ! -d "$userhome"/.gnupg ] || [ ! -f "$userhome"/.gnupg/pubring.gpg ]; then
	# Generate GPG key
	$EXEC_GPG --gen-key
fi

#
# Apply stricter file and directory settings
#

printInfo "Changing any root:root files and directories to '$username:$username'"

$EXEC_FIND "$userhome" -xdev -user root -group root -execdir $EXEC_CHOWN $username:$username {} +

printInfo "Applying stricter directory security settings to $userhome"

# Configure all hidden directories with drwx------ privileges
$EXEC_FIND "$userhome" -xdev -maxdepth 1 -type d -path "$userhome/.*" -perm /077 -exec $EXEC_CHMOD 700 {} +

# Configure all normal directories with drwxr-x--- privileges
$EXEC_FIND "$userhome" -xdev -type d -perm /027 -exec $EXEC_CHMOD 750 {} + 2>/dev/null

printInfo "Applying stricter file security settings to $userhome"

excludeDirs="-type d ( -name '.git' -o -name '.svn' ) -prune"

# Remove ----w-rwx file privileges
$EXEC_FIND "$userhome" -xdev $excludeDirs -o -type f -perm /027 -exec $EXEC_CHMOD g-w,o-rwx {} +

echo

exit 0
