#!/bin/bash

#
# configure-apt-mirror.sh - DevOpsBroker script for configuring apt mirror site
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
# 1. Pulls the list of mirror sites from http://mirrors.ubuntu.com/mirrors.txt
# 2. Take the five fastest sites by latency using ping test
# 3. Take fastest site overall by using throughput test
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
	printError "$SCRIPT_EXEC" 'Permission denied (you must be root)'

	exit 1
fi

# Ensure the sources-list.tpl script is executable
sourcesListTpl=$(isExecutable "$SCRIPT_DIR"/sources-list.tpl)

################################## Variables ##################################

## Bash exec variables
EXEC_TRUNCATE=/usr/bin/truncate

################################### Actions ###################################

# Clear screen only if called from command line
if [ $SHLVL -eq 1 ]; then
	clear
fi

bannerMsg='DevOpsBroker Ubuntu 16.04 Desktop APT Mirror Configurator'

echo ${bold} ${wisteria}
echo '╔═══════════════════════════════════════════════════════════╗'
echo "║ ${white}$bannerMsg${wisteria}"                           '║'
echo '╚═══════════════════════════════════════════════════════════╝'
echo ${reset}

if ! $EXEC_GREP -Fq 'DevOpsBroker' /etc/apt/sources.list; then
	# BEGIN Configure apt mirror site

	printBanner 'Configuring /etc/apt/sources.list mirror'

	# Pull the list of mirror sites
	if [ ! -f /tmp/ubuntu-mirrors.txt ]; then
		printInfo 'Pull the list of mirror sites from http://mirrors.ubuntu.com/mirrors.txt'
		$EXEC_CURL -s http://mirrors.ubuntu.com/mirrors.txt -o /tmp/ubuntu-mirrors.txt
	fi

	declare -a mirrorArray

	mapfile -t mirrorArray < /tmp/ubuntu-mirrors.txt

	if [ -f /tmp/ping.job ]; then
		# Truncate the /tmp/ping.job file if exists
		$EXEC_TRUNCATE -s 0 /tmp/ping.job
	fi

	for mirror in "${mirrorArray[@]}"; do
		# Select only http mirror sites and blacklist evowise.com
		if [[ "$mirror" == http* ]] && [[ "$mirror" != *'evowise.com'* ]]; then
			# Extract the FQDN
			fqdn=${mirror:7}
			fqdn="${fqdn%%/*}"

			# Add to the /tmp/ping.job file
			echo "$EXEC_PING -c 2 -W 1 $fqdn | $EXEC_AWK -v fqdn=\"$fqdn\" -F '/' 'END {print "'$5'", fqdn}'" >> /tmp/ping.job
		fi
	done

	# Execute the /tmp/ping.job in parallel
	printInfo 'Execute ping test to find the five fastest sites by latency'
	$EXEC_PARALLEL -j0 --no-notice :::: /tmp/ping.job | $EXEC_AWK '/^[0-9]*\.[0-9]*/{ print $0 }' | $EXEC_SORT -nk1 | $EXEC_HEAD -5 | $EXEC_AWK '{ print $2 }' > /tmp/ping.results

	declare -a pingResultsArray

	mapfile -t pingResultsArray < /tmp/ping.results

	declare fastestMirror
	declare -i fastestThroughput
	declare -i throughput

	fastestThroughput=0

	for pingResult in "${pingResultsArray[@]}"; do
		for mirror in "${mirrorArray[@]}"; do
			if [[ $mirror = *"$pingResult"* ]]; then
				printInfo "Testing throughput for mirror $mirror"
				throughput=$($EXEC_CURL -o /dev/null -s -w %{speed_download} "$mirror"ls-lR.gz | $EXEC_SED 's/\.[0-9]*//')

				if [ $throughput -gt $fastestThroughput ]; then
					fastestThroughput=$throughput
					fastestMirror=$mirror
				fi
			fi
		done
	done

	printInfo "Configuring /etc/apt/sources.list to use the fastest mirror --> $fastestMirror"

	# Install /etc/apt/sources.list
	if ! grep -Fq 'DevOpsBroker' /etc/apt/sources.list; then
		printInfo 'Installing /etc/apt/sources.list'

		# Execute template script
		"$sourcesListTpl" $fastestMirror > "$SCRIPT_DIR"/sources.list

		# Install as root:root with rw-r--r-- privileges
		$EXEC_INSTALL -o root -g root -m 644 "$SCRIPT_DIR"/sources.list /etc/apt
	else
		printInfo 'Updating /etc/apt/sources.list'

		# Execute template script
		"$sourcesListTpl" $fastestMirror > "$SCRIPT_DIR"/sources.list

		# Install as root:root with rw-r--r-- privileges
		$EXEC_INSTALL -b --suffix .bak -o root -g root -m 644 "$SCRIPT_DIR"/sources.list /etc/apt
	fi

	# Clean up
	$EXEC_RM "$SCRIPT_DIR"/sources.list

	printInfo 'Download package information from new apt mirror site'
	$EXEC_APT update

	echo

	# END Configure apt mirror site
fi

exit 0
