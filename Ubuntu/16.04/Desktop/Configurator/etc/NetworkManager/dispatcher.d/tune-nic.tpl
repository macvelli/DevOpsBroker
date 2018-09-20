#!/bin/bash

#
# tune-nic.tpl - DevOpsBroker script for generating /etc/network/if-up.d/tune-$NIC
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
# Configuration file for optimizing the Network Interface Card:
#   o Optimize TX Queue Length
#   o Offload RX/TX/TSO/UFO/SG/GSO Processing
#   o Optimize initcwnd and initrwnd
#
# Useful Linux Command-Line Utilities
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Display or change Ethernet adapter settings:
#   o sudo ethtool --show-features enp4s0
#   o sudo ethtool --offload enp4s0 tx-checksum-ipv4 on tx-checksum-ipv6 on tx-nocache-copy off
#   o sudo ethtool --offload enp4s0 rx on tx on tso on ufo on sg on gso on
#
# Routing tables under /proc:
#   o /proc/net/route
#   o /proc/net/ipv6_route
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

# Display error if not running as root
if [ "$USER" != 'root' ]; then
	printError 'tune-nic.tpl' 'Permission denied (you must be root)'
	exit 1
fi

################################## Variables ##################################

## Options
NIC="$1"

## Variables
isWireless=false

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ OPTION Parsing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Display usage if no parameters given
if [ -z "$NIC" ]; then
	printUsage 'tune-nic.tpl NIC'
	exit 1
fi

# Display error if network interface parameter is invalid
if [ ! -L /sys/class/net/$NIC ]; then
	printError 'tune-nic.tpl' "Cannot access '$NIC': No such network interface"
	echo
	printUsage 'tune-nic.tpl NIC'

	exit 1
fi

################################## Variables ##################################

## Bash exec variables
EXEC_IWCONFIG=/sbin/iwconfig

################################### Actions ###################################

# Set isWireless to 'true' if $NIC is a wireless interface device
if [ -d /sys/class/net/$NIC/wireless ]; then
	isWireless=true
fi

# Actual Mbit/s speed of the network interface
if [ "$isWireless" == 'true' ]; then
	NIC_SPEED=$($EXEC_IWCONFIG $NIC | $EXEC_AWK '/Bit Rate=[0-9]/{ split($2, a, "="); printf("%.0f\n", a[2]); }')
else
	NIC_SPEED=$($EXEC_CAT /sys/class/net/$NIC/speed)
fi

# Calculate the TX Queue Length
TX_QUEUE_LENGTH=$[ $NIC_SPEED * 10 ]

## Template
/bin/cat << EOF
#!/bin/bash

#
# tune-$NIC - DevOpsBroker network interface tuning script
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
# Configuration file for optimizing $NIC:
#   o TX Queue Length = $TX_QUEUE_LENGTH
#   o Offload as much packet processing as possible to the hardware layer
#   o initcwnd/initrwnd = 22 for default gateway
#   o initcwnd/initrwnd = 44 for link-local
# -----------------------------------------------------------------------------
#

################################## Variables ##################################

## Options
IFACE="\$1"
ACTION="\$2"

if [ -z "\$IFACE" ] && [ -z "\$ACTION" ]; then
	IFACE='$NIC'
	ACTION='up'
fi

################################### Actions ###################################

/usr/bin/logger -p syslog.notice -i Called /etc/NetworkManager/dispatcher.d/tune-$NIC with interface "\$IFACE" and action "\$ACTION";

if [ "\$IFACE" == '$NIC' ] && [ "\$ACTION" == 'up' ]; then
	# Optimize TX Queue Length
	/sbin/ip link set $NIC txqueuelen $TX_QUEUE_LENGTH

EOF

if [ "$isWireless" == 'false' ]; then
/bin/cat << EOF
	# Offload RX/TX/TSO/UFO/SG/GSO Processing
	/sbin/ethtool --offload $NIC rx on tx on tso on ufo on sg on gso on

EOF
fi

/bin/cat << EOF
	# Optimize IPv4/IPv6 initcwnd and initrwnd values
	/usr/bin/sudo /usr/local/sbin/initcrwnd $NIC 'true' &
fi

exit 0

EOF

exit 0
