#!/bin/bash

#
# 60-user-limits.conf.sh - DevOpsBroker script for generating the configuration
#			   /etc/security/limits.d/60-user-limits.conf
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
  echo -e "\033[1m60-user-limits.conf.sh: \033[38;5;203mPermission denied (you must be root)\033[0m"

  exit 1
fi


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Template ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## Template variables

# Total amount of RAM available
RAM_TOTAL=$(grep -F MemTotal /proc/meminfo | awk '{print $2}')

# Global Maximum Number Simultaneous Open Files
FS_FILE_MAX=$[ $RAM_TOTAL / 10 ]
USER_FILE_MAX=$[ $FS_FILE_MAX / 4 ]


## Template
cat << EOF
#
# 60-user-limits.conf - DevOpsBroker configuration for user limits (bash ulimit)
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
# See bash(1) for more information on the ulimit command and its available
# options.
# -----------------------------------------------------------------------------
#

# Sets the core file size limit to unlimited for all users (except root)
* soft core unlimited
* hard core unlimited

# Set maximum number of open files for all users
* soft nofile $USER_FILE_MAX
* hard nofile $USER_FILE_MAX

# Set maximum number of open files for the root user
root soft nofile $USER_FILE_MAX
root hard nofile $USER_FILE_MAX

EOF

