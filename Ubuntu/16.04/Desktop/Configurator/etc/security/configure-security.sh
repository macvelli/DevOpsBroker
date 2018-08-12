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

# Ensure the 60-user-limits.conf.tpl script is executable
userLimitsConf=$(isExecutable "$SCRIPT_DIR"/limits.d/60-user-limits.conf.tpl)

################################### Actions ###################################

# Clear screen only if called from command line
if [ $SHLVL -eq 1 ]; then
  clear
fi

bannerMsg='DevOpsBroker Ubuntu 16.04 Desktop Security Configurator'

echo ${bold} ${wisteria}
echo '╔═════════════════════════════════════════════════════════╗'
echo "║ ${white}$bannerMsg${wisteria}"			       '║'
echo '╚═════════════════════════════════════════════════════════╝'
echo ${reset}


#
# /etc/security/limits.d/ Configuration
#

# Install /etc/security/limits.d/60-user-limits.conf
if [ ! -f /etc/security/limits.d/60-user-limits.conf ]; then
  # BEGIN /etc/security/limits.d/60-user-limits.conf

  printInfo 'Installing /etc/security/limits.d/60-user-limits.conf'

  # Execute template script
  "$userLimitsConf" > "$SCRIPT_DIR"/limits.d/60-user-limits.conf

  # Install as root:root with rw-r--r-- privileges
  $EXEC_INSTALL -o root -g root -m 644 "$SCRIPT_DIR"/limits.d/60-user-limits.conf /etc/security/limits.d

  # Clean up
  $EXEC_RM "$SCRIPT_DIR"/limits.d/60-user-limits.conf

  echo

elif [ "$userLimitsConf" -nt /etc/security/limits.d/60-user-limits.conf ]; then
  printInfo 'Updating /etc/security/limits.d/60-user-limits.conf'

  # Execute template script
  "$userLimitsConf" > "$SCRIPT_DIR"/limits.d/60-user-limits.conf

  # Install as root:root with rw-r--r-- privileges
  $EXEC_INSTALL -b --suffix .bak -o root -g root -m 644 "$SCRIPT_DIR"/limits.d/60-user-limits.conf /etc/security/limits.d

  # Clean up
  $EXEC_RM "$SCRIPT_DIR"/limits.d/60-user-limits.conf

  echo

  # END /etc/security/limits.d/60-user-limits.conf
fi

exit 0
