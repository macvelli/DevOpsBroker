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
# o /etc/ntp.conf
# o /etc/profile
# o /etc/devops/ansi.conf
# o /etc/devops/exec.conf
# o /etc/devops/functions.conf
# o /etc/modprobe.d/kvm-amd.conf
# o /etc/skel/.bash_aliases
# o /etc/skel/.bash_logout
# o /etc/skel/.bash_personal
# o /etc/skel/.bashrc
# o /etc/skel/.gitconfig
# o /etc/skel/.profile
# o /etc/skel/.config/gtk-3.0/gtk.css
#
# Also creates the following directories for users of the system to utilize:
# o /cache
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
# Function:	installSkeleton
# Description:	Installs the DevOpsBroker settings file in the /etc/skel
#		directory
#
# Parameter $1:	The name of the DevOpsBroker settings file to install
# Parameter $2:	The name of the /etc/skel file
# Parameter $3: The directory where to install the file
# -----------------------------------------------------------------------------
function installSkeleton() {

  if [ "$SCRIPT_DIR/../home/$1" -nt $3/$2 ]; then
    printInfo "Installing $3/$2"

    # Install as root:root with rw-r--r-- privileges
    $EXEC_INSTALL -o root -g root -m 644 "$SCRIPT_DIR/../home/$1" $3/$2

    echoOnExit=true
  fi

}

################################## Variables ##################################

echoOnExit=false

################################### Actions ###################################

# Clear screen only if called from command line
if [ $SHLVL -eq 1 ]; then
  clear
fi

bannerMsg='DevOpsBroker Ubuntu 16.04 Desktop System Configurator'

echo ${bold} ${wisteria}
echo '╔═══════════════════════════════════════════════════════╗'
echo "║ ${white}$bannerMsg${wisteria}"			     '║'
echo '╚═══════════════════════════════════════════════════════╝'
echo ${reset}

# Create /etc/skel/.config/gtk-3.0 directory
if [ ! -d /etc/skel/.config/gtk-3.0 ]; then
  $EXEC_MKDIR --mode=0700 /etc/skel/.config/gtk-3.0
fi

# Install /etc/adduser.conf
installConfig 'adduser.conf' "$SCRIPT_DIR" /etc

# Install /etc/bash.bashrc
installConfig 'bash.bashrc' "$SCRIPT_DIR" /etc

# Install /etc/modules
installConfig 'modules' "$SCRIPT_DIR" /etc

# Install /etc/ntp.conf
installConfig 'ntp.conf' "$SCRIPT_DIR" /etc 'ntp'

# Install /etc/profile
installConfig 'profile' "$SCRIPT_DIR" /etc

# Install /etc/devops/ansi.conf
installConfig 'ansi.conf' "$SCRIPT_DIR"/devops /etc/devops

# Install /etc/devops/exec.conf
installConfig 'exec.conf' "$SCRIPT_DIR"/devops /etc/devops

# Install /etc/devops/functions.conf
installConfig 'functions.conf' "$SCRIPT_DIR"/devops /etc/devops

# Install /etc/modprobe.d/kvm-amd.conf
installConfig 'kvm-amd.conf' "$SCRIPT_DIR"/modprobe.d /etc/modprobe.d

# Install /etc/skel/.bash_aliases
installSkeleton 'bash_aliases' '.bash_aliases' '/etc/skel'

# Install /etc/skel/.bash_logout
installSkeleton 'bash_logout' '.bash_logout' '/etc/skel'

# Install /etc/skel/.bash_personal
installSkeleton 'bash_personal' '.bash_personal' '/etc/skel'

# Install /etc/skel/.bashrc
installSkeleton 'bashrc' '.bashrc' '/etc/skel'

# Install /etc/skel/.gitconfig
installSkeleton 'gitconfig' '.gitconfig' '/etc/skel'

# Install /etc/skel/.profile
installSkeleton 'profile' '.profile' '/etc/skel'

# Install /etc/skel/.config/gtk-3.0/gtk.css
installSkeleton 'gtk.css' 'gtk.css' '/etc/skel/.config/gtk-3.0'

#
# UMASK Configuration
#

if ! $EXEC_GREP -q '^session optional[[:blank:]]*pam_umask\.so' /etc/pam.d/common-session; then
  printInfo 'Enabling pam_umask module'

echo '
session optional			pam_umask.so' >> /etc/pam.d/common-session

  echoOnExit=true
fi

if [ ! -f /etc/login.defs.orig ]; then
  printInfo 'Configuring global umask'

  # Backup original /etc/login.defs file
  $EXEC_CP /etc/login.defs /etc/login.defs.orig

  # Modify /etc/login.defs to configure global umask
  $EXEC_SED -i -e 's/^(UMASK[[:blank:]]*)[0-7]{3}/\1027/' -e 's/^(USERGROUPS_ENAB[[:blank:]]*)yes/\1no/' /etc/login.defs

  echoOnExit=true
fi

#
# Fix Default Applications for Common MIME Types
#

if (( $($EXEC_GREP -F 'audio/mp4=rhythmbox.desktop' /usr/share/applications/defaults.list /etc/gnome/defaults.list | $EXEC_WC -l) < 2 )); then
  # BEGIN Fix Default Applications

  printBanner 'Fixing Default Applications for Common MIME Types'

  printInfo 'Change default application for common audio files to Rhythmbox'

  # Fix /usr/share/applications/defaults.list audio defaults
  $EXEC_SED -i 's/^(audio\/)(ac3|mp4|mpeg|x-m4a|x-mp3|x-mpeg|x-ms-wma|x-pn-aiff|x-pn-wav|x-wav)=.*/\1\2=rhythmbox.desktop/' /usr/share/applications/defaults.list

  # Fix /etc/gnome/defaults.list audio defaults
  $EXEC_SED -i 's/^(audio\/)(ac3|mp4|mpeg|x-m4a|x-mp3|x-mpeg|x-ms-wma|x-pn-aiff|x-pn-wav|x-wav)=.*/\1\2=rhythmbox.desktop/' /etc/gnome/defaults.list

  printInfo 'Change default application for video files to VLC'

  # Fix /usr/share/applications/defaults.list video defaults
  $EXEC_SED -i 's/^(.*video.*=).+/\1vlc_vlc.desktop/' /usr/share/applications/defaults.list

  # Fix /etc/gnome/defaults.list video defaults
  $EXEC_SED -i 's/^(.*video.*=).+/\1vlc_vlc.desktop/' /etc/gnome/defaults.list

  echoOnExit=true

  # END Fix Default Applications
fi

#
# Show Hidden Startup Applications
#   o Ubuntu Search -> Startup Applications
#
if $EXEC_GREP -Fq 'NoDisplay=true' /etc/xdg/autostart/*.desktop; then
  printInfo 'Show hidden startup applications under Ubuntu Search -> Startup Applications'

  $EXEC_SED -i 's/NoDisplay=true/NoDisplay=false/g' /etc/xdg/autostart/*.desktop

  echoOnExit=true
fi

if [ "$echoOnExit" == 'true' ]; then
  echo
fi

exit 0
