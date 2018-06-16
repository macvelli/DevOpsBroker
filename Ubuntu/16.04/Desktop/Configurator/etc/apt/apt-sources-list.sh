#!/bin/bash

#
# apt-sources-list.sh - DevOpsBroker script for generating /etc/apt/sources.list
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
# Parameters:
#   o $1: The name of the mirror to configure /etc/apt/sources.list with
# -----------------------------------------------------------------------------
#


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Preprocessing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Display error if not running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "\033[1mapt-sources-list.sh: \033[38;5;203mPermission denied (you must be root)\033[0m"

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
  printUsage "apt-sources-list.sh APT_MIRROR_SITE"

  exit 1
fi

# Backup original /etc/apt/sources.list
if [ ! -f /etc/apt/sources.list.orig ]; then
  cp /etc/apt/sources.list /etc/apt/sources.list.orig
fi

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Template ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## Template variables
fastestMirror=$1
origHeader=$(head -1 /etc/apt/sources.list.orig)


## Template
cat << EOF
#
# sources.list - DevOpsBroker configuration for /etc/apt/sources.list
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
$origHeader
# -----------------------------------------------------------------------------
#

deb $fastestMirror xenial main restricted
# deb-src $fastestMirror xenial main restricted

# Major bug fix updates produced after the final release of the distribution
deb $fastestMirror xenial-updates main restricted
# deb-src $fastestMirror xenial-updates main restricted

# Entirely unsupported software by the Ubuntu team
deb $fastestMirror xenial universe
# deb-src $fastestMirror xenial universe
deb $fastestMirror xenial-updates universe
# deb-src $fastestMirror xenial-updates universe

# Entirely unsupported software by the Ubuntu team
# May not be under a free license
deb $fastestMirror xenial multiverse
# deb-src $fastestMirror xenial multiverse
deb $fastestMirror xenial-updates multiverse
# deb-src $fastestMirror xenial-updates multiverse

# Includes newer versions of some applications
# May not have been tested as extensively as in the main release
deb $fastestMirror xenial-backports main restricted universe multiverse
# deb-src $fastestMirror xenial-backports main restricted universe multiverse

deb $fastestMirror xenial-security main restricted
# deb-src $fastestMirror xenial-security main restricted
deb $fastestMirror xenial-security universe
# deb-src $fastestMirror xenial-security universe
deb $fastestMirror xenial-security multiverse
# deb-src $fastestMirror xenial-security multiverse

EOF

exit 0

