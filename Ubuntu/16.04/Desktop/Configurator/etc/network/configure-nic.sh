#!/bin/bash

#
# configure-nic.sh - DevOpsBroker script for configuring network interfaces
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
# Display the initcwnd/initrwnd values for the default interface:
#   o ip route show
#
# Display network interface configuration including txqueuelength:
#   o ifconfig enp4s0
#
# Display or change Ethernet adapter settings:
#   o sudo ethtool --show-features enp4s0
#   o sudo ethtool --offload enp4s0 tx-checksum-ipv4 on tx-checksum-ipv6 on tx-nocache-copy off
#   o sudo ethtool --offload enp4s0 rx on tx on tso on ufo on sg on gso on
#
# Bounce the network interface:
#   o sudo ifdown enp4s0 && sudo ifup enp4s0
#
# NetworkManager Man Pages
#   o man NetworkManager
#   o man nmcli
#   o man nm-online
#
# NetworkManager command-line
#   o nmcli -t --fields UUID connection show
#   o nmcli connection show uuid 604f6d5f-4780-4ee8-806e-d06dacf8702f | grep -F 'connection.interface-name'
# -----------------------------------------------------------------------------
#

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Preprocessing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Load /etc/devops/ansi.conf if ANSI_CONFIG is unset
if [ -z "$ANSI_CONFIG" ] && [ -f /etc/devops/ansi.conf ]; then
	source /etc/devops/ansi.conf
fi

${ANSI_CONFIG?"[1;91mCannot load '/etc/devops/ansi.conf': No such file[0m"}

# Load /etc/devops/exec.conf if EXEC_CONFIG is unset
if [ -z "$EXEC_CONFIG" ] && [ -f /etc/devops/exec.conf ]; then
	source /etc/devops/exec.conf
fi

${EXEC_CONFIG?"[1;91mCannot load '/etc/devops/exec.conf': No such file[0m"}

# Load /etc/devops/functions.conf if FUNC_CONFIG is unset
if [ -z "$FUNC_CONFIG" ] && [ -f /etc/devops/functions.conf ]; then
	source /etc/devops/functions.conf
fi

${FUNC_CONFIG?"[1;91mCannot load '/etc/devops/functions.conf': No such file[0m"}

## Script information
SCRIPT_INFO=( $($EXEC_SCRIPTINFO "$BASH_SOURCE") )
SCRIPT_DIR="${SCRIPT_INFO[0]}"
SCRIPT_EXEC="${SCRIPT_INFO[1]}"

# Display error if not running as root
if [ "$USER" != 'root' ]; then
	printError "$SCRIPT_EXEC" 'Permission denied (you must be root)'
	exit 1
fi

# Set tune-nic.tpl location and make it executable
tuneNic=$(isExecutable "$SCRIPT_DIR"/if-up.d/tune-nic.tpl)

################################## Variables ##################################

## Bash exec variables
EXEC_NMCLI=/usr/bin/nmcli

## Options
NIC=${1:-"$($EXEC_IP -4 route show default | $EXEC_AWK '{ print $5 }')"}

## Variables
export TMPDIR=${TMPDIR:-'/tmp'}
echoOnExit=false

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ OPTION Parsing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Display error if network interface parameter is invalid
if [ ! -L /sys/class/net/$NIC ]; then
	printError "$SCRIPT_EXEC" "Cannot access '$NIC': No such network interface"
	echo
	printUsage "$SCRIPT_EXEC NIC"

	exit 1
fi

################################### Actions ###################################

# Clear screen only if called from command line
if [ $SHLVL -eq 1 ]; then
	clear
fi

printBox "DevOpsBroker $UBUNTU_RELEASE Network Interface Configurator" 'true'

# Exit if default interface is a virtual network device (i.e. bridge, tap, etc)
if [[ "$($EXEC_READLINK /sys/class/net/$NIC)" == *"/devices/virtual/"* ]]; then
	printInfo "Default network interface '$NIC' is virtual"
	printInfo 'Exiting'

	exit 0
fi

#
# NetworkManager Configuration
#

mapfile -t uuidInterfaceList < <($EXEC_NMCLI -t --fields UUID connection show)

for uuidInterface in "${uuidInterfaceList[@]}"; do

	mapfile -t connectionInfoList < <($EXEC_NMCLI connection show uuid $uuidInterface)

	for connectionInfo in "${connectionInfoList[@]}"; do
		if [[ "$connectionInfo" == connection.interface-name:* ]]; then
			splitString=( $connectionInfo )
			interfaceName=${splitString[1]}
		elif [[ "$connectionInfo" == ipv4.may-fail:* ]]; then
			splitString=( $connectionInfo )
			ipv4MayFail=${splitString[1]}
		elif [[ "$connectionInfo" == ipv6.may-fail:* ]]; then
			splitString=( $connectionInfo )
			ipv6MayFail=${splitString[1]}
		fi
	done

	if [ "$ipv4MayFail" == 'yes' ]; then
		printInfo "Setting 'ipv4.may-fail' equal to 'no' on $interfaceName"

		$EXEC_NMCLI connection modify uuid $uuidInterface ipv4.may-fail no

		echoOnExit=true
	fi

	if [ "$ipv6MayFail" == 'yes' ]; then
		printInfo "Setting 'ipv6.may-fail' equal to 'no' on $interfaceName"

		$EXEC_NMCLI connection modify uuid $uuidInterface ipv6.may-fail no

		echoOnExit=true
	fi
done

#
# /etc/network/if-up.d/ Configuration
#

if [ ! -f /etc/network/if-up.d/tune-$NIC ]; then
	printInfo "Installing /etc/network/if-up.d/tune-$NIC"

	# Execute template script
	"$tuneNic" $NIC > "$TMPDIR"/tune-$NIC

	# Install as root:root with rwxr-xr-x privileges
	$EXEC_INSTALL -o root -g root -m 755 "$TMPDIR"/tune-$NIC /etc/network/if-up.d

	# Clean up
	$EXEC_RM "$TMPDIR"/tune-$NIC

	printInfo "Restart $NIC interface"
	echo
	$EXEC_IFDOWN $NIC && $EXEC_IFUP $NIC

	echoOnExit=true

elif [ "$tuneNic" -nt /etc/network/if-up.d/tune-$NIC ]; then
	printInfo "Updating /etc/network/if-up.d/tune-$NIC"

	# Execute template script
	"$tuneNic" $NIC > "$TMPDIR"/tune-$NIC

	# Install as root:root with rwxr-xr-x privileges
	$EXEC_INSTALL -o root -g root -m 755 "$TMPDIR"/tune-$NIC /etc/network/if-up.d

	# Clean up
	$EXEC_RM "$TMPDIR"/tune-$NIC

	printInfo "Restart $NIC interface"
	echo
	$EXEC_IFDOWN $NIC && $EXEC_IFUP $NIC

	echoOnExit=true
fi

if [ $echoOnExit == 'true' ]; then
	echo
fi

exit 0
