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
# Installs the following Bash configuration files in the home directory of the
# user:
#   o .bash_aliases
#   o .bash_logout
#   o .bashrc
#   o .profile
#   o .config/gtk-3.0/gtk.css
#
# Creates the following directories for the user:
#   o $userhome/bin
#   o $userhome/.local/bin
#
# Applies stricter file and directory settings to the user's home directory
#
# Adds the user to the users group (if necessary)
#
# Moves the user's Firefox cache to /mnt/ramdisk
#
# Creates the /persist/$username directory
#
# -----------------------------------------------------------------------------
#


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Preprocessing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Display error if not running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "\033[1mconfigure-user.sh: \033[38;5;203mPermission denied (you must be root)\033[0m"

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
  printUsage "configure-user.sh USERNAME"

  exit 1
fi

nsswitch="$(getent passwd $1)"

# Ensure the argument is a valid username
if [ ${#nsswitch} -eq 0 ]; then
  printError "configure-user.sh" "Invalid username $1"
  echo
  printUsage "configure-user.sh USERNAME"

  exit 1
fi

IFS=':'; userInfo=($nsswitch); unset IFS;

# Ensure the user is using bash for the shell
if [[ ! "${userInfo[6]}" =~ bash$ ]]; then
  echo -e "$(bold)configure-user.sh: $(yellow)User shell not bash $(white)($(bittersweet)${userInfo[6]}$(white))$(reset)"

  exit 1
fi


################################## Functions ##################################

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function:	installTemplate
# Description:	Installs the template file into the $userhome/Templates directory
#
# Parameter $1:	Name of the template file to install
# -----------------------------------------------------------------------------
function installTemplate() {
  # BEGIN install template function

  local templateFile="$1"

  if [ ! -f "$userhome/Templates/$templateFile" ]; then
    printInfo "Installing $userhome/Templates/$templateFile"

    # Install as $username:$username with rw-r----- privileges
    install -o $username -g $username -m 640 "$SCRIPT_DIR/Templates/$templateFile" "$userhome/Templates"

    echo

  fi

  # END install template function
}

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function:	installUserConfig
# Description:	Installs the user configuration file into the $userhome directory
#
# Parameter $1:	Name of the configuration file to install
# Parameter $2:	Name of the source configuration file
# -----------------------------------------------------------------------------
function installUserConfig() {
  # BEGIN install user config function

  local configFile="$1"
  local sourceFile="$2"

  if [ ! -f "$userhome/$configFile" ] || \
       ! grep -Fq "DevOpsBroker" "$userhome/$configFile"; then
    printInfo "Installing $userhome/$configFile"

    # Install as $username:$username with rw-r----- privileges
    install -b --suffix .orig -o $username -g $username -m 640 "$SCRIPT_DIR/$sourceFile" "$userhome/$configFile"

    echo

  elif [ "$SCRIPT_DIR/$sourceFile" -nt "$userhome/$configFile" ]; then
    printInfo "Updating $userhome/$configFile"

    # Install as $username:$username with rw-r----- privileges
    install -b --suffix .bak -o $username -g $username -m 640 "$SCRIPT_DIR/$sourceFile" "$userhome/$configFile"

    echo

  fi

  # END install user config function
}


################################## Variables ##################################

# Find the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Set the $username and $userhome variables
username="$1"
userhome="${userInfo[5]}"


################################### Actions ###################################

# Clear screen and print banner only if called from command line
if [ $SHLVL -eq 1 ]; then
  clear

  bannerMsg="DevOpsBroker Ubuntu 16.04 Desktop User Configurator"

  echo -e $(bold kobi)
  echo    "╔═════════════════════════════════════════════════════╗"
  echo -e "║ "$(white)$bannerMsg$(kobi)                         "║"
  echo    "╚═════════════════════════════════════════════════════╝"
  echo -e $(reset)

fi

# Install $userhome/.bash_aliases
installUserConfig ".bash_aliases" "bash_aliases.dob"

# Install $userhome/.bash_logout
installUserConfig ".bash_logout" "bash_logout.dob"

# Install $userhome/.bashrc
installUserConfig ".bashrc" "bashrc.dob"

# Install $userhome/.profile
installUserConfig ".profile" "profile.dob"

if [ ! -d "$userhome/.config/gtk-3.0" ]; then
  # Create $userhome/.config/gtk-3.0 directory
  mkdir -p -m 700 "$userhome/.config/gtk-3.0"
  chown "$username:$username" "$userhome/.config/gtk-3.0"
fi

# Install $userhome/.config/gtk-3.0/gtk.css
#   o Fix scrollbar widths
installConfig "gtk.css" "$SCRIPT_DIR" "$userhome/.config/gtk-3.0"

# Install $userhome/Templates/New CSS.css
installTemplate "New CSS.css"

# Install $userhome/Templates/New HTML.html
installTemplate "New HTML.html"

# Install $userhome/Templates/New JavaScript.js
installTemplate "New JavaScript.js"

# Install $userhome/Templates/New LibreOffice Calc.ods
installTemplate "New LibreOffice Calc.ods"

# Install $userhome/Templates/New LibreOffice Draw.odg
installTemplate "New LibreOffice Draw.odg"

# Install $userhome/Templates/New LibreOffice Impress.odp
installTemplate "New LibreOffice Impress.odp"

# Install $userhome/Templates/New LibreOffice Math.odf
installTemplate "New LibreOffice Math.odf"

# Install $userhome/Templates/New LibreOffice Writer.odt
installTemplate "New LibreOffice Writer.odt"

# Install $userhome/Templates/New Systemd.service
installTemplate "New Systemd.service"

# Create $userhome/bin
if [ ! -d "$userhome/bin" ]; then
  printInfo "Create $userhome/bin directory"

  mkdir -p -m 750 "$userhome/bin"
  chown "$username:$username" "$userhome/bin"

  echo

fi

# Create $userhome/.local/bin
if [ ! -d "$userhome/.local/bin" ]; then
  printInfo "Create $userhome/.local/bin directory"

  mkdir -p -m 700 "$userhome/.local/bin"
  chown "$username:$username" "$userhome/.local/bin"

  echo

fi

#
# Apply stricter file and directory settings
#

if [ $(stat -c "%a" "$userhome") -ne 750 ]; then
  printInfo "Applying stricter directory security settings to $userhome"

  # Configure all normal directories with drwxr-x--- privileges
  find "$userhome" -name ".*" -prune -o -type d -print | xargs -r -I {} chmod 750 "{}" 2>/dev/null

  # Configure all hidden directories with drwx------ privileges
  find "$userhome" -maxdepth 1 -type d -name ".*" | xargs -r -I {} chmod 700 "{}" 2>/dev/null

  echo
fi

if [ $(stat -c "%a" "$userhome/.profile") -ne 640 ]; then
  printInfo "Applying stricter file security settings to $userhome"

  # Remove file ----wxrwx privileges
  find "$userhome" -type f | xargs -r -I {} chmod g-wx,o-rwx "{}" 2>/dev/null

  echo
fi

# Add $username to the users group
if ! groups $username | grep -Fq "users"; then
  printInfo "Adding $username to the users group"

  adduser $username "users"

  echo
fi

# Move Firefox cache to /mnt/ramdisk
if [ ! -d "/mnt/ramdisk/$username" ]; then
  printInfo "Moving Firefox cache to /mnt/ramdisk"

  # Create Firefox cache directory for the user in /mnt/ramdisk
  mkdir -p --mode=0700 /mnt/ramdisk/$username/mozilla/firefox
  chown -R $username:$username /mnt/ramdisk/$username

  # Create symlink to Firefox cache in /mnt/ramdisk
  rm -rf "$userhome/.cache/mozilla"
  ln -s "/mnt/ramdisk/$username/mozilla" "$userhome/.cache/mozilla"

  echo
fi

# Create /persist/$username directory
if [ ! -d "/persist/$username" ]; then
  printInfo "Creating /persist/$username directory"

  # Create persist directory for the user in /persist
  mkdir -p --mode=0700 /persist/$username
  chown -R $username:$username /persist/$username

  echo
fi

#
# Generate SSH Keys
#

if [ ! -d "$userhome/.ssh" ] || \
	[ $(find "$userhome/.ssh" -type f | wc -l) -eq 0 ]; then

  /usr/local/bin/ssh-key gen -d "$userhome" -u "$username"

fi

if [ ! -f "$userhome/.ssh/config" ]; then

  printInfo "Installing sample SSH client configuration"

  # Install as $username:$username with rw-r----- privileges
  install -o $username -g $username -m 640 "$SCRIPT_DIR/ssh/config" "$userhome/.ssh"

fi

#
# Configure GPG
#

if [ ! -d "$userhome/.gnupg" ]; then

  /usr/bin/gpg --gen-key

fi

if [ $(stat -c '%U:%G' "$userhome/.gnupg") != "$username:$username" ]; then
  # Change directory and file ownership to $username
  chown -R $username:$username "$userhome/.gnupg"

fi

exit 0

