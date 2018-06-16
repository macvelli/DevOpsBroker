#!/bin/bash

#
# install-services.sh - DevOpsBroker script for installing systemd user services
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
# This script does the following tasks:
#   o Places systemd user service files in ~/.config/systemd/user
#   o Enables the systemd user service
#   o Starts the systemd user service
#
# -----------------------------------------------------------------------------
#


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Preprocessing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Display error if running as root
if [ "$EUID" -eq 0 ]; then
  echo -e "\033[1minstall-services.sh: \033[38;5;203mPermission denied (you cannot be root)\033[0m"

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

# Create the ~/.config/systemd/user directory, if necessary
if [ ! -d ~/.config/systemd/user ]; then
  mkdir -p --mode=755 ~/.config/systemd/user
fi


################################### Actions ###################################

#
# Install ssh-agent.service
#

if [ ! -f ~/.config/systemd/user/ssh-agent.service ]; then

  printInfo "Installing systemd user service ssh-agent.service"

  # Install as $USER:$USER with rw-r--r-- privileges
  install -o $USER -g $USER -m 644 "$SCRIPT_DIR/home/systemd/ssh-agent.service" ~/.config/systemd/user

  printInfo "Enable systemd user service ssh-agent.service"
  /bin/systemctl --user enable ssh-agent.service

  printInfo "Start systemd user service ssh-agent.service"
  /bin/systemctl --user start ssh-agent.service

  echo

fi

exit 0

