#!/bin/bash

#
# tune-nic.sh - DevOpsBroker script for generating network configuration file
#		/etc/network/if-up.d/tune-$NIC.sh
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
# o Display or change Ethernet adapter settings:
# sudo ethtool --show-features enp4s0
# sudo ethtool --offload enp4s0 tx-checksum-ipv4 on tx-checksum-ipv6 on tx-nocache-copy off
# sudo ethtool --offload enp4s0 rx on tx on tso on ufo on sg on gso on
# -----------------------------------------------------------------------------
#


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Preprocessing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
  printUsage "tune-nic.sh NIC"

  exit 1
fi

# Display error if network interface parameter is invalid
if [ ! -d /proc/sys/net/ipv4/conf/$1 ]; then
  printError "tune-nic.sh" "Invalid network interface $1"
  echo
  printUsage "tune-nic.sh NIC"

  exit 1
fi


################################## Variables ##################################

# NIC Parameter
NIC="$1"

# Actual Mbit/s speed of the network interface
NIC_SPEED=$(ethtool $NIC 2>/dev/null | grep -F "Speed:" | awk -F '[^0-9]*' '{print $2}')

# Calculate the TX Queue Length
TX_QUEUE_LENGTH=$[ $NIC_SPEED >= 1000 ? 10000 : 1000 ]

# Default network interface
DEFAULT_GATEWAY=$(ip route | awk '/^default/{ print $3 }')

################################### Actions ###################################

## Template
cat << EOF
#!/bin/bash

#
# # tune-$NIC.sh - DevOpsBroker network interface tuning script
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
#   o initcwnd/initrwnd = 24
# -----------------------------------------------------------------------------
#

if [ "\$IFACE" == "$NIC" ]; then
  # Optimize TX Queue Length
  /sbin/ip link set $NIC txqueuelen $TX_QUEUE_LENGTH

  # Offload RX/TX/TSO/UFO/SG/GSO Processing
  /sbin/ethtool --offload $NIC rx on tx on tso on ufo on sg on gso on

  # Optimize initcwnd and initrwnd
  /sbin/ip route change default via $DEFAULT_GATEWAY dev $NIC initcwnd 24 initrwnd 24
fi

exit 0

EOF

