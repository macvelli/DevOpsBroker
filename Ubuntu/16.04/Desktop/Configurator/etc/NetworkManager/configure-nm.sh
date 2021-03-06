#!/bin/bash

#
# configure-nm.sh - DevOpsBroker script for configuring NetworkManager
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
# Developed on Ubuntu 16.04.5 LTS running kernel.osrelease = 4.15.0-33
#
# The following configuration files are managed by this script:
#
# o /etc/NetworkManager/NetworkManager.conf
# o /etc/NetworkManager/dispatcher.d/pre-up.d/10-firewall
# o /etc/NetworkManager/dispatcher.d/pre-up.d/20-nf_conntrack
# o /etc/NetworkManager/system-connections/$NIC
# o /etc/NetworkManager/dispatcher.d/tune-$NIC
#
# Useful Linux Command-Line Utilities
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Display the IPv4/IPv6 routing table entries:
#   o ip -4 route show
#   o ip -6 route show
#
# Display network interface configuration including txqueuelength:
#   o ifconfig enp4s0
#
# Display or change Ethernet adapter settings:
#   o sudo ethtool --show-features enp4s0
#   o sudo ethtool --offload enp4s0 tx-checksum-ipv4 on tx-checksum-ipv6 on tx-nocache-copy off
#   o sudo ethtool --offload enp4s0 rx on tx on tso on ufo on sg on gso on
#
# Restart the network interface:
#   o nmcli device disconnect enp4s0 && nmcli device connect enp4s0
#
# NetworkManager Man Pages:
#   o man NetworkManager
#   o man nmcli
#   o man nm-online
#   o man nm-settings
#
# NetworkManager command-line:
#   o nmcli -t --fields UUID connection show
#   o nmcli connection show uuid 604f6d5f-4780-4ee8-806e-d06dacf8702f | grep -F 'connection.interface-name'
# -----------------------------------------------------------------------------
#

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Preprocessing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
tuneNic=$(isExecutable "$SCRIPT_DIR"/dispatcher.d/tune-nic.tpl)

################################## Functions ##################################

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function:     installNMScript
# Description:  Installs the specified NetworkManager script
#
# Parameter $1: The NetworkManager script to install
# -----------------------------------------------------------------------------
function installNMScript() {
	local nmScript="$1"

	if [ ! -f "/etc/NetworkManager/$nmScript" ] || [ "$SCRIPT_DIR/$nmScript" -nt "/etc/NetworkManager/$nmScript" ]; then
		printInfo "Installing /etc/NetworkManager/$nmScript"

		# Install as root:root with rwxr-xr-x privileges
		$EXEC_INSTALL -o root -g root -m 755 "$SCRIPT_DIR/$nmScript" "/etc/NetworkManager/$nmScript"

		restartNetworkManager=true
		echoOnExit=true
	fi
}

################################## Variables ##################################

## Bash exec variables
EXEC_NMCLI=/usr/bin/nmcli

## Options
NIC=${1:-"$($EXEC_IP -4 route show default | $EXEC_AWK '{ print $5 }')"}

## Variables
export TMPDIR=${TMPDIR:-'/tmp'}
isWireless=false
restartNetworkManager=false
restartNIC=false
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

printBox "DevOpsBroker $UBUNTU_RELEASE NetworkManager Configurator" 'true'

# Exit if default interface is a virtual network device (i.e. bridge, tap, etc)
if [[ "$($EXEC_READLINK /sys/class/net/$NIC)" == *"/devices/virtual/"* ]]; then
	printInfo "Default network interface '$NIC' is virtual"
	printInfo 'Exiting'

	exit 0
fi

# Set isWireless to 'true' if $NIC is a wireless interface device
if [ -d /sys/class/net/$NIC/wireless ]; then
	isWireless=true
fi

# Install /etc/NetworkManager/NetworkManager.conf
installConfig 'NetworkManager.conf' "$SCRIPT_DIR" /etc/NetworkManager

if [ "$INSTALL_CONFIG" == 'true' ]; then
	restartNetworkManager=true
	echoOnExit=true
fi

# Install /etc/NetworkManager/dispatcher.d/pre-up.d/10-firewall
installNMScript 'dispatcher.d/pre-up.d/10-firewall'

# Install /etc/NetworkManager/dispatcher.d/pre-up.d/20-nf_conntrack
installNMScript 'dispatcher.d/pre-up.d/20-nf_conntrack'

# Modify NetworkManager connection for default network interface
if [ "$isWireless" == 'false' ] && [ ! -f /etc/NetworkManager/system-connections/$NIC ]; then
	printInfo "Modifying NetworkManager connection profile for '$NIC'"

	# Load existing NetworkManager connection profile
	connProfile=( $($EXEC_NMCLI --fields UUID,TYPE,DEVICE connection show --active | grep -F $NIC) )

	$EXEC_NMCLI connection modify uuid ${connProfile[0]} \
		connection.id $NIC \
		connection.interface-name $NIC \
		connection.autoconnect yes \
		connection.autoconnect-priority 1

	if [ "${connProfile[1]}" == '802-3-ethernet' ]; then
		$EXEC_NMCLI connection modify uuid ${connProfile[0]} \
			802-3-ethernet.wake-on-lan 32768
	fi

	$EXEC_NMCLI connection modify uuid ${connProfile[0]} \
		ipv4.dhcp-send-hostname yes \
		ipv4.dns-search "" \
		ipv4.ignore-auto-dns yes \
		ipv4.may-fail no \
		ipv4.method auto

	$EXEC_NMCLI connection modify uuid ${connProfile[0]} \
		ipv6.addr-gen-mode stable-privacy \
		ipv6.dhcp-send-hostname yes \
		ipv6.dns-search "" \
		ipv6.ignore-auto-dns yes \
		ipv6.ip6-privacy 0 \
		ipv6.may-fail yes \
		ipv6.method auto

	restartNetworkManager=true
	echoOnExit=true
fi

#
# /etc/NetworkManager/dispatcher.d Configuration
#

if [ ! -f /etc/NetworkManager/dispatcher.d/tune-$NIC ]; then
	printInfo "Installing /etc/NetworkManager/dispatcher.d/tune-$NIC"

	# Execute template script
	"$tuneNic" $NIC > "$TMPDIR"/tune-$NIC

	# Install as root:root with rwxr-xr-x privileges
	$EXEC_INSTALL -o root -g root -m 755 "$TMPDIR"/tune-$NIC /etc/NetworkManager/dispatcher.d

	# Clean up
	$EXEC_RM "$TMPDIR"/tune-$NIC

	restartNIC=true
	echoOnExit=true

elif [ "$tuneNic" -nt /etc/NetworkManager/dispatcher.d/tune-$NIC ]; then
	printInfo "Updating /etc/NetworkManager/dispatcher.d/tune-$NIC"

	# Execute template script
	"$tuneNic" $NIC > "$TMPDIR"/tune-$NIC

	# Install as root:root with rwxr-xr-x privileges
	$EXEC_INSTALL -o root -g root -m 755 "$TMPDIR"/tune-$NIC /etc/NetworkManager/dispatcher.d

	# Clean up
	$EXEC_RM "$TMPDIR"/tune-$NIC

	restartNIC=true
	echoOnExit=true
fi

if [ "$restartNetworkManager" == 'true' ]; then
	printInfo "Restarting NetworkManager service"
	echo
	$EXEC_SYSTEMCTL restart NetworkManager.service

elif [ "$restartNIC" == 'true' ]; then
	printInfo "Restarting $NIC interface"
	echo
	$EXEC_NMCLI device disconnect $NIC && $EXEC_NMCLI device connect $NIC
fi

if [ $echoOnExit == 'true' ]; then
	echo
fi

exit 0
