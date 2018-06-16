#!/bin/bash

#
# ttf-msclearfonts.sh - DevOpsBroker script for installing Microsoft ClearType fonts
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
# The Microsoft ClearType Fonts include:
#   o Calibri
#   o Cambria
#   o Consolas
#   o Constantia
#   o Corbel
#
# This script will also install the following fonts, if available:
#   o Segoe UI
#   o Tahoma
#
# The best place to source Microsoft ClearType Fonts is from a Windows machine
# at C:\Windows\Fonts
#
# All Microsoft ClearType fonts are installed on Ubuntu Desktop 16.04 under the
# /usr/local/share/fonts directory
#
# Useful Linux Command-Line Utilities
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# o Reload Font Cache
# fc-cache -f -v
#
# o List available fonts
# fc-list
#
# o View font matching
# fc-match -v Calibri
#
# TODO: http://manpages.ubuntu.com/manpages/xenial/man1/yad.1.html
# -----------------------------------------------------------------------------
#

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Preprocessing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Display error if not running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "\033[1mttf-msclearfonts.sh: \033[38;5;203mPermission denied (you must be root)\033[0m"

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

################################### Actions ###################################

# Clear screen and print banner only if called from command line
if [ $SHLVL -eq 1 ]; then
  clear

  bannerMsg="DevOpsBroker Microsoft ClearType Fonts Installer"

  echo -e $(bold kobi)
  echo    "╔══════════════════════════════════════════════════╗"
  echo -e "║ "$(white)$bannerMsg$(kobi)                      "║"
  echo    "╚══════════════════════════════════════════════════╝"
  echo -e $(reset)

fi

# Exit if Microsoft ClearType fonts have already been installed
if [ -d /usr/local/share/fonts/microsoft/cleartype ]; then
  printInfo "Microsoft ClearType Fonts already installed"
  echo

  exit 0
fi

# Install Microsoft ClearType Fonts
printBanner "Installing Microsoft ClearType Fonts"

# Make the /usr/local/share/fonts/microsoft/cleartype directory
mkdir -p --mode=0755 /usr/local/share/fonts/microsoft/cleartype
chown -R root:staff /usr/local/share/fonts

printInfo "Select directory containing the Microsoft ClearType Fonts to install"
sourceDir=$(yad --file-selection --directory --title="Microsoft ClearType Fonts" --width=800 --height=600 --center --filename=$HOME/Desktop/)

# Install Calibri
if [ -f "$sourceDir/calibri.ttf" ]; then
  printInfo "Installing Calibri"

  install -o root -g staff -m 644 "$sourceDir/calibri*.ttf" /usr/local/share/fonts/microsoft/cleartype

  echo
fi

# Install Cambria
if [ -f "$sourceDir/cambria.ttc" ]; then
  printInfo " Installing Cambria"

  install -o root -g staff -m 644 "$sourceDir/cambria*.tt*" /usr/local/share/fonts/microsoft/cleartype

  echo
fi

# Install Consolas
if [ -f "$sourceDir/consola.ttf" ]; then
  printInfo "Installing Consolas"

  install -o root -g staff -m 644 "$sourceDir/consola*.ttf" /usr/local/share/fonts/microsoft/cleartype

  echo
fi

# Install Constantia
if [ -f "$sourceDir/constan.ttf" ]; then
  printInfo "Installing Constantia"

  install -o root -g staff -m 644 "$sourceDir/constan*.ttf" /usr/local/share/fonts/microsoft/cleartype

  echo
fi

# Install Corbel
if [ -f "$sourceDir/corbel.ttf" ]; then
  printInfo "Installing Corbel"

  install -o root -g staff -m 644 "$sourceDir/corbel*.ttf" /usr/local/share/fonts/microsoft/cleartype

  echo
fi

# Install Segoe UI
if [ -f "$sourceDir/segoeui.ttf" ]; then
  printInfo "Installing Segoe UI"

  install -o root -g staff -m 644 "$sourceDir/segoeui*.ttf" /usr/local/share/fonts/microsoft/cleartype

  echo
fi

# Install Tahoma
if [ -f "$sourceDir/tahoma.ttf" ]; then
  printInfo "Installing Tahoma"

  install -o root -g staff -m 644 "$sourceDir/tahoma*.ttf" /usr/local/share/fonts/microsoft/cleartype

  echo
fi

printInfo "Updating the font cache"

fc-cache -f -v

echo

exit 0

