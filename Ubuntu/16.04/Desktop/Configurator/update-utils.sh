#!/bin/bash

#
# update-utils.sh - DevOpsBroker script for installing and updating utility
#		    scripts and executables
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
# Developed on Ubuntu 16.04.5 LTS running kernel.osrelease = 4.15.0-24
#
# -----------------------------------------------------------------------------
#

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Preprocessing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
    $EXEC_CHOWN --no-dereference root:users "$symlink"
    echoOnExit=true
  fi

  # END create symbolic link
}

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function:	installSystemUtility
# Description:	Installs the system administration utility into /usr/local/sbin
#
# Parameter $1:	The name of the utility to install
# Parameter $2:	The source directory (where to find the utility to install)
# -----------------------------------------------------------------------------
function installSystemUtility() {
  # BEGIN install system utility function

  local utility="$1"
  local sourceDir="$2"

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

  # END install system utility function
}

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function:	installUserUtility
# Description:	Installs the user utility into /usr/local/bin
#
# Parameter $1:	The name of the utility to install
# Parameter $2:	The source directory (where to find the utility to install)
# -----------------------------------------------------------------------------
function installUserUtility() {
  # BEGIN install user utility function

  local utility="$1"
  local sourceDir="$2"

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

  # END install user utility function
}

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function:	installTemplate
# Description:	Installs the venture template to /usr/local/bin/template
#
# Parameter $1:	The name of the template to install
# -----------------------------------------------------------------------------
function installTemplate() {
  # BEGIN install venture template function

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

  # END install venture template function
}

################################## Variables ##################################

# Installation directory
INSTALL_DIR=/opt/devopsbroker/xenial/desktop/configurator

## Variables
echoOnExit=false

################################### Actions ###################################

# Clear screen and print banner only if called from command line
if [ $SHLVL -eq 1 ]; then
  clear

  bannerMsg='DevOpsBroker Ubuntu 16.04 Desktop Utility Updater'

  echo ${bold} ${wisteria}
  echo '╔═══════════════════════════════════════════════════╗'
  echo "║ ${white}$bannerMsg${wisteria}"                   '║'
  echo '╚═══════════════════════════════════════════════════╝'
  echo ${reset}
fi

# Build all C language utilties
/usr/bin/make -s --directory="$SCRIPT_DIR"/C

if [ "$SCRIPT_DIR" != "$INSTALL_DIR" ]; then
  $EXEC_CHOWN -R $SUDO_USER:$SUDO_USER "$SCRIPT_DIR"/C
fi

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~ System Administration ~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Install addUserToGroup system administration utility
installSystemUtility addUserToGroup "$SCRIPT_DIR"/usr/local/sbin

# Install disableJournal system administration utility
installSystemUtility disableJournal "$SCRIPT_DIR"/usr/local/sbin

# Install firewall system administration utility
installSystemUtility firewall "$SCRIPT_DIR"/usr/local/sbin

# Install pms system administration utility
installSystemUtility pms "$SCRIPT_DIR"/usr/local/sbin

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ User Utilities ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Install archive user utility
installUserUtility archive "$SCRIPT_DIR"/usr/local/bin

# Install between user utility
installUserUtility between "$SCRIPT_DIR"/C

# Install bgedit user utility
installUserUtility bgedit "$SCRIPT_DIR"/usr/local/bin

# Install convert-number user utility
installUserUtility convert-number "$SCRIPT_DIR"/usr/local/bin

# Create symbolic links to the convert-number user utility
createSymlink /usr/local/bin/binary /usr/local/bin/convert-number
createSymlink /usr/local/bin/decimal /usr/local/bin/convert-number
createSymlink /usr/local/bin/hex /usr/local/bin/convert-number
createSymlink /usr/local/bin/octal /usr/local/bin/convert-number

# Install decrypt user utility
installUserUtility decrypt "$SCRIPT_DIR"/usr/local/bin

# Install encrypt user utility
installUserUtility encrypt "$SCRIPT_DIR"/usr/local/bin

# Install extract user utility
installUserUtility extract "$SCRIPT_DIR"/usr/local/bin

# Install favicon user utility
installUserUtility favicon "$SCRIPT_DIR"/usr/local/bin

# Install firelog user utility
installUserUtility firelog "$SCRIPT_DIR"/C

# Install geoip user utility
installUserUtility geoip "$SCRIPT_DIR"/usr/local/bin

# Install git-config user utility
installUserUtility git-config "$SCRIPT_DIR"/usr/local/bin

# Install gnome-config user utility
installUserUtility gnome-config "$SCRIPT_DIR"/usr/local/bin

# Install hexToRgb user utility
installUserUtility hexToRgb "$SCRIPT_DIR"/usr/local/bin

# Install hypotenuse user utility
installUserUtility hypotenuse "$SCRIPT_DIR"/usr/local/bin

# Install kernel-config user utility
installUserUtility kernel-config "$SCRIPT_DIR"/usr/local/bin

# Install macaddr user utility
installUserUtility macaddr "$SCRIPT_DIR"/usr/local/bin

# Install printAnsi256 user utility
installUserUtility printAnsi256 "$SCRIPT_DIR"/usr/local/bin

# Install public-ip user utility
installUserUtility public-ip "$SCRIPT_DIR"/usr/local/bin

# Install qemu-config user utility
installUserUtility qemu-config "$SCRIPT_DIR"/usr/local/bin

# Install random-password user utility
installUserUtility random-password "$SCRIPT_DIR"/usr/local/bin

# Install reverse-dns user utility
installUserUtility reverse-dns "$SCRIPT_DIR"/usr/local/bin

# Install rgbToHex user utility
installUserUtility rgbToHex "$SCRIPT_DIR"/usr/local/bin

# Install scriptinfo user utility
installUserUtility scriptinfo "$SCRIPT_DIR"/C

# Install showFileFormat user utility
installUserUtility showFileFormat "$SCRIPT_DIR"/usr/local/bin

# Install sig user utility
installUserUtility sig "$SCRIPT_DIR"/usr/local/bin

# Install ssh-key user utility
installUserUtility ssh-key "$SCRIPT_DIR"/usr/local/bin

# Install symlink user utility
installUserUtility symlink "$SCRIPT_DIR"/usr/local/bin

# Install uuid user utility
installUserUtility uuid "$SCRIPT_DIR"/usr/local/bin

# Install venture user utility
installUserUtility venture "$SCRIPT_DIR"/usr/local/bin

# Install verifyip user utility
installUserUtility verifyip "$SCRIPT_DIR"/C

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Venture Templates ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Make /usr/local/bin/template directory
if [ ! -d /usr/local/bin/template ]; then
  printInfo 'Creating /usr/local/bin/template directory'

  $EXEC_MKDIR --mode=755 /usr/local/bin/template
  $EXEC_CHOWN root:users /usr/local/bin/template
  echoOnExit=true
fi

installTemplate 'bash-script.tpl'
installTemplate 'bash-template.tpl'
installTemplate 'header-file-c.tpl'
installTemplate 'makefile.tpl'
installTemplate 'source-file-c.tpl'

if [ $echoOnExit == 'true' ]; then
  echo
fi

exit 0
