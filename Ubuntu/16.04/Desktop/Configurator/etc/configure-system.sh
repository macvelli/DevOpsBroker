#!/bin/bash

#
# configure-system.sh - DevOpsBroker script for systemwide configurations
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
# The following systemwide initialization files are configured by this script:
#
# o /etc/adduser.conf
# o /etc/bash.bashrc
# o /etc/modules
# o /etc/skel/.profile
# o /etc/skel/.bashrc
# o /etc/skel/.bash_aliases
# o /etc/skel/.bash_logout
# o /etc/skel/.config/gtk-3.0/gtk.css
#
# Also creates the following directories for users of the system to utilize:
# o /cache
# o /persist
#
# Other configuration tasks include:
# o Enable the PAM_UMASK module and set the global UMASK
# o Fix Default Applications for Common MIME Types
# o Show Hidden Startup Applications
#
# Useful Linux Command-Line Utilities
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# o Print all or part of the Bash shell environment
# printenv
# -----------------------------------------------------------------------------
#


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Preprocessing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Display error if not running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "\033[1mconfigure-system.sh: \033[38;5;203mPermission denied (you must be root)\033[0m"

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


################################## Functions ##################################

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function:	installSkeleton
# Description:	Installs the DevOpsBroker settings file in the /etc/skel
#		directory
#
# Parameter $1:	The name of the DevOpsBroker settings file to install
# Parameter $2:	The name of the /etc/skel file
# Parameter $3: The directory where to install the file
# -----------------------------------------------------------------------------
function installSkeleton() {
  # BEGIN install skeleton function

  if [ ! -f $3/$2 ] || ! grep -Fq "DevOpsBroker" $3/$2; then
    printInfo "Installing $3/$2"

    # Install as root:root with rw-r--r-- privileges
    install -o root -g root -m 644 "$SCRIPT_DIR/../home/$1" $3/$2

    echo

  elif [ "$SCRIPT_DIR/../home/$1" -nt $3/$2 ]; then
    printInfo "Updating $3/$2"

    # Install as root:root with rw-r--r-- privileges
    install -o root -g root -m 644 "$SCRIPT_DIR/../home/$1" $3/$2

    echo

  fi

  # END install skeleton function
}


################################### Actions ###################################

# Clear screen and print banner only if called from command line
if [ $SHLVL -eq 1 ]; then
  clear

  bannerMsg="DevOpsBroker Ubuntu 16.04 Desktop System Configurator"

  echo -e $(bold kobi)
  echo    "╔═══════════════════════════════════════════════════════╗"
  echo -e "║ "$(white)$bannerMsg$(kobi)                           "║"
  echo    "╚═══════════════════════════════════════════════════════╝"
  echo -e $(reset)

fi

# Install /etc/adduser.conf
installConfig "adduser.conf" "$SCRIPT_DIR" /etc

# Install /etc/bash.bashrc
installConfig "bash.bashrc" "$SCRIPT_DIR" /etc

# Install /etc/modules
installConfig "modules" "$SCRIPT_DIR" /etc

# Install /etc/ntp.conf
installConfig "ntp.conf" "$SCRIPT_DIR" /etc "ntp"

# Install /etc/profile
installConfig "profile" "$SCRIPT_DIR" /etc

# Install /etc/skel/.profile
installSkeleton "profile.dob" ".profile" "/etc/skel"

# Install /etc/skel/.bashrc
installSkeleton "bashrc.dob" ".bashrc" "/etc/skel"

# Install /etc/skel/.bash_aliases
installSkeleton "bash_aliases.dob" ".bash_aliases" "/etc/skel"

# Install /etc/skel/.bash_logout
installSkeleton "bash_logout.dob" ".bash_logout" "/etc/skel"

# Install /etc/skel/.config/gtk-3.0/gtk.css
if [ ! -d /etc/skel/.config/gtk-3.0 ]; then

  mkdir -p --mode=0700 /etc/skel/.config/gtk-3.0

fi

installSkeleton "gtk.css" "gtk.css" "/etc/skel/.config/gtk-3.0"

# Make /cache directory for user cache
if [ ! -d /cache ]; then
  printInfo "Creating /cache directory"

  mkdir --mode=0775 /cache
  chown root:users /cache

  echo
fi

# Make /persist directory for user
if [ ! -d /persist ]; then
  printInfo "Creating /persist directory"

  mkdir --mode=0775 /persist
  chown root:users /persist

  echo
fi

#
# UMASK Configuration
#

if ! grep -q '^session optional[[:blank:]]*pam_umask\.so' /etc/pam.d/common-session; then
  printInfo "Enabling pam_umask module"

echo -e "
session optional\t\t\tpam_umask.so" >> /etc/pam.d/common-session

  echo
fi

if [ ! -f /etc/login.defs.orig ]; then
  printInfo "Configuring global umask"

  # Backup original /etc/login.defs file
  cp /etc/login.defs /etc/login.defs.orig

  # Modify /etc/login.defs to configure global umask
  sed -i -e 's/^\(UMASK[[:blank:]]*\)[0-7]\{3\}/\1027/' -e 's/^\(USERGROUPS_ENAB[[:blank:]]*\)yes/\1no/' /etc/login.defs

  echo
fi

#
# Fix Default Applications for Common MIME Types
#

if (( $(grep -F "audio/mp4=rhythmbox.desktop" /usr/share/applications/defaults.list /etc/gnome/defaults.list | wc -l) < 2 )); then
  # BEGIN Fix Default Applications

  printBanner "Fixing Default Applications for Common MIME Types"

  printInfo "Change default application for common audio files to Rhythmbox"

  # Fix /usr/share/applications/defaults.list audio defaults
  sed -i -E 's/^(audio\/)(ac3|mp4|mpeg|x-m4a|x-mp3|x-mpeg|x-ms-wma|x-pn-aiff|x-pn-wav|x-wav)=.*/\1\2=rhythmbox.desktop/' /usr/share/applications/defaults.list

  # Fix /etc/gnome/defaults.list audio defaults
  sed -i -E 's/^(audio\/)(ac3|mp4|mpeg|x-m4a|x-mp3|x-mpeg|x-ms-wma|x-pn-aiff|x-pn-wav|x-wav)=.*/\1\2=rhythmbox.desktop/' /etc/gnome/defaults.list

  printInfo "Change default application for video files to VLC"

  # Fix /usr/share/applications/defaults.list video defaults
  sed -i -E 's/^(.*video.*=).+/\1vlc_vlc.desktop/' /usr/share/applications/defaults.list

  # Fix /etc/gnome/defaults.list video defaults
  sed -i -E 's/^(.*video.*=).+/\1vlc_vlc.desktop/' /etc/gnome/defaults.list

  echo

  # END Fix Default Applications
fi

#
# Show Hidden Startup Applications
#   o Ubuntu Search -> Startup Applications
#

if grep -Fq "NoDisplay=true" /etc/xdg/autostart/*.desktop; then
  # BEGIN Show Hidden Startup Applications

  printInfo "Show hidden startup applications under Ubuntu Search -> Startup Applications"

  # Enable display of each hidden startup application
  sed -i 's/NoDisplay=true/NoDisplay=false/g' /etc/xdg/autostart/*.desktop

  echo

  # END Show Hidden Startup Applications
fi

exit 0

