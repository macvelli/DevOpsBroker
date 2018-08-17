#!/bin/bash

#
# configure-kernel.sh - DevOpsBroker script for configuring Linux kernel tuning
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
# See sysctl(8) and sysctl.conf(5) for more information.
#
# Useful Linux Command-Line Utilities
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# o Show the complete list of all sysctl parameters:
# sysctl -a
#
# o Set the MTU on a network interface:
# ifconfig enp4s0 mtu NNNN
#
# o Monitor kernel behavior with regard to the VM dirty pages:
# grep -A 1 dirty /proc/vmstat
#
# o Check cwnd runtime value:
# ss -nli | fgrep cwnd
#
# o Determine Connection States:
# netstat -tan | grep ':80 ' | awk '{print $6}' | sort | uniq -c
#
# o View TCP/UDP/IP Session Information:
# ss -s
#
# TODO: Audit kernel parameters to ensure they are properly set
# TODO: Audit security settings (i.e. umask) to ensure they are properly set,
#	especially for someone in the sudo group
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

# Ensure the sysctl.conf.tpl script is executable
sysctlConf=$(isExecutable "$SCRIPT_DIR"/sysctl.conf.tpl)

################################## Functions ##################################

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function:	execSpeedTest
# Description:	Executes the Internet Speed Test
# -----------------------------------------------------------------------------
function execSpeedTest() {
    # Install speedtest-cli if necessary
    if [ ! -f $EXEC_SPEED_TEST ]; then
        printBanner 'Installing speedtest-cli'

        $EXEC_APT -y install speedtest-cli

        echo
    fi

    if [ ! -f /etc/devops/speedtest.info ]; then
        printInfo 'Executing Internet speed test'

        $EXEC_SPEED_TEST | tee /etc/devops/speedtest.info

        printInfo 'Internet speed test finished'
        echo
    fi
}

################################## Variables ##################################

## Bash exec variables
EXEC_SPEED_TEST=/usr/bin/speedtest-cli
EXEC_SYSCTL=/sbin/sysctl

## Variables
tunedKernel=false

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ OPTION Parsing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Delete /etc/devops/speedtest.info on force kernel retune
if [ "$1" == '-f' ]; then
    $EXEC_RM /etc/devops/speedtest.info 2>/dev/null
fi

################################### Actions ###################################

# Clear screen only if called from command line
if [ $SHLVL -eq 1 ]; then
    clear
fi

bannerMsg='DevOpsBroker Ubuntu 16.04 Desktop Kernel Tuning'

echo ${bold} ${wisteria}
echo '╔═════════════════════════════════════════════════╗'
echo "║ ${white}$bannerMsg${wisteria}"                 '║'
echo '╚═════════════════════════════════════════════════╝'
echo ${reset}

#
# Linux Kernel Tuning
#
if ! $EXEC_GREP -Fq 'DevOpsBroker' /etc/sysctl.conf; then
    # BEGIN /etc/sysctl.conf

    printBanner 'Installing /etc/sysctl.conf'

    # Execute Internet speed test
    execSpeedTest

    # Execute template script
    "$sysctlConf"

	if [ -f "$SCRIPT_DIR"/sysctl.conf ]; then
    	# Install as root:root with rw-r--r-- privileges
    	$EXEC_INSTALL -b --suffix .orig -o root -g root -m 644 "$SCRIPT_DIR"/sysctl.conf /etc

    	# Clean up
    	$EXEC_RM "$SCRIPT_DIR"/sysctl.conf

    	printInfo 'Load kernel tuning parameters from /etc/sysctl.conf'
    	$EXEC_SYSCTL -p

    	tunedKernel=true
	fi

elif [ "$sysctlConf" -nt /etc/sysctl.conf ] || [ "$1" == '-f' ]; then

    printBanner 'Updating /etc/sysctl.conf'

    # Execute Internet speed test
    execSpeedTest

    # Execute template script
    "$sysctlConf"

	if [ -f "$SCRIPT_DIR"/sysctl.conf ]; then
		# Install as root:root with rw-r--r-- privileges
	    $EXEC_INSTALL -b --suffix .bak -o root -g root -m 644 "$SCRIPT_DIR"/sysctl.conf /etc

    	# Clean up
    	$EXEC_RM "$SCRIPT_DIR"/sysctl.conf

    	printInfo 'Load kernel tuning parameters from /etc/sysctl.conf'
    	$EXEC_SYSCTL -p

    	tunedKernel=true
	fi

    # END /etc/sysctl.conf
fi

if [ "$tunedKernel" == 'true' ]; then
    echo
else
    printInfo 'Linux kernel already tuned'
    echo
    printUsage "$SCRIPT_EXEC ${gold}[-f]"

    echo ${bold}
    echo "Valid Options:${romantic}"
    echo '  -f	Force retuning of Linux kernel'
    echo ${reset}
fi

exit 0
