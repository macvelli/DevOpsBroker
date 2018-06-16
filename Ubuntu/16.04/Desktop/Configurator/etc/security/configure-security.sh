#!/bin/bash

#
# configure-security-limits.sh - DevOpsBroker script for configuring /etc/security
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
# Useful Linux Command-Line Utilities
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# o Display user limits:
# ulimit -a
#
# -----------------------------------------------------------------------------
#


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Preprocessing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Display error if not running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "\033[1mconfigure-security.sh: \033[38;5;203mPermission denied (you must be root)\033[0m"

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

# Ensure the 60-user-limits.conf.sh script is executable
userLimitsConf=$(isExecutable "$SCRIPT_DIR/limits.d/60-user-limits.conf.sh")


################################### Actions ###################################

# Clear screen and print banner only if called from command line
if [ $SHLVL -eq 1 ]; then
  clear

  bannerMsg="DevOpsBroker Ubuntu 16.04 Desktop Security Configurator"

  echo -e $(bold kobi)
  echo    "╔════════════════════════════════════════════════════════════════╗"
  echo -e "║ "$(white)$bannerMsg$(kobi)                                    "║"
  echo    "╚════════════════════════════════════════════════════════════════╝"
  echo -e $(reset)

fi

#
# /etc/security/limits.d/ Configuration
#

# Install /etc/security/limits.d/60-user-limits.conf
if [ ! -f /etc/security/limits.d/60-user-limits.conf ]; then
  # BEGIN /etc/security/limits.d/60-user-limits.conf

  printInfo "Installing /etc/security/limits.d/60-user-limits.conf"

  # Execute template script
  $SHELL -c "$userLimitsConf" > "$SCRIPT_DIR/limits.d/60-user-limits.conf"

  # Install as root:root with rw-r--r-- privileges
  install -o root -g root -m 644 "$SCRIPT_DIR/limits.d/60-user-limits.conf" /etc/security/limits.d

  # Clean up
  rm "$SCRIPT_DIR/limits.d/60-user-limits.conf"

  echo

elif [ "$userLimitsConf" -nt /etc/security/limits.d/60-user-limits.conf ]; then
  printInfo "Updating /etc/security/limits.d/60-user-limits.conf"

  # Execute template script
  $SHELL -c "$userLimitsConf" > "$SCRIPT_DIR/limits.d/60-user-limits.conf"

  # Install as root:root with rw-r--r-- privileges
  install -b --suffix .bak -o root -g root -m 644 "$SCRIPT_DIR/limits.d/60-user-limits.conf" /etc/security/limits.d

  # Clean up
  rm "$SCRIPT_DIR/limits.d/60-user-limits.conf"

  echo

  # END /etc/security/limits.d/60-user-limits.conf
fi

exit 0

