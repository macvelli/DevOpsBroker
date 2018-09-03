#!/bin/bash

#
# makefile.tpl - DevOpsBroker template script for generating makefiles
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

################################## Variables ##################################

## Options
projectName="$1"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ OPTION Parsing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Display usage if no project name parameter specified
if [ -z "$projectName" ]; then
  printUsage "makefile.tpl PROJ_NAME ${gold}[UBUNTU_RELEASE] [KERNEL_VERSION]"

  exit 1
fi

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Template ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Set $ubuntuRelease and $kernelVersion variables
ubuntuRelease=${2:-"$(getUbuntuRelease)"}
kernelVersion=${3:-"$(getKernelVersion)"}

## Template
/bin/cat << EOF
#
# makefile - Description goes here
#
# Copyright (C) 2018 AUTHOR_NAME <email@address.com>
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
# Developed on $ubuntuRelease running kernel.osrelease = $kernelVersion
#
# -----------------------------------------------------------------------------
#

CC=/usr/bin/gcc
CFLAGS=-Wall -g

all: $projectName

.PHONY: all clean

bin/$projectName.o: src/$projectName.c
	\$(CC) \$(CFLAGS) -c src/$projectName.c -o bin/$projectName.o

$projectName: bin/$projectName.o
	\$(CC) bin/$projectName.o -o $projectName

clean:
	rm -f $projectName bin/$projectName.o

EOF
