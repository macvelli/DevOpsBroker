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

################################## Variables ##################################

## Options
NIC="$1"

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

################################### Actions ###################################

# Actual Mbit/s speed of the network interface
NIC_SPEED=$($EXEC_CAT /sys/class/net/$NIC/speed)

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

if [ -z "$IFACE" ] && [ -z "$MODE" ] && [ -z "$PHASE" ]; then
	IFACE='$NIC'
	MODE='start'
	PHASE='post-up'
fi

################################### Actions ###################################

/usr/bin/logger -p syslog.notice -i Called tune-$NIC with interface "\$IFACE" mode "\$MODE" and phase "\$PHASE";

if [ "\$IFACE" == '$NIC' ] && [ "\$MODE" == 'start' ] && [ "\$PHASE" == 'post-up' ]; then
	# Optimize TX Queue Length
	/sbin/ip link set $NIC txqueuelen $TX_QUEUE_LENGTH

	# Offload RX/TX/TSO/UFO/SG/GSO Processing
	/sbin/ethtool --offload $NIC rx on tx on tso on ufo on sg on gso on

	# Optimize IPv4/IPv6 initcwnd and initrwnd values
	/usr/bin/sudo /usr/local/sbin/initcrwnd $NIC &
fi

exit 0

EOF

exit 0
