#!/bin/bash

#
# tune-nic.tpl - DevOpsBroker script for generating network configuration file
#		 /etc/network/if-up.d/tune-$NIC
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

## Bash exec variables
EXEC_ETHTOOL=/sbin/ethtool

## Options
NIC="$1"

## Variables
routeChanges=''

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ OPTION Parsing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Display usage if no parameters given
if [ -z "$NIC" ]; then
  printUsage 'tune-nic.tpl NIC'
  echo

  exit 1
fi

# Display error if network interface parameter is invalid
if [ ! -d /proc/sys/net/ipv4/conf/$NIC ]; then
  printError 'tune-nic.tpl' "Cannot access '$NIC': No such network interface"
  echo
  printUsage 'tune-nic.tpl NIC'

  exit 1
fi

################################### Actions ###################################

# Actual Mbit/s speed of the network interface
NIC_SPEED=$($EXEC_ETHTOOL $NIC 2>/dev/null | $EXEC_GREP -F 'Speed:' | $EXEC_AWK -F '[^0-9]*' '{print $2}')

# Calculate the TX Queue Length
TX_QUEUE_LENGTH=$[ $NIC_SPEED >= 1000 ? 10000 : 1000 ]

## Template
cat << EOF
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

logger -p syslog.notice -i Called tune-$NIC with interface "\$IFACE" mode "\$MODE" and phase "\$PHASE";

if [ "\$IFACE" == '$NIC' ] && [ "\$MODE" == 'start' ] && [ "\$PHASE" == 'post-up' ]; then
  # Optimize TX Queue Length
  /sbin/ip link set $NIC txqueuelen $TX_QUEUE_LENGTH

  # Offload RX/TX/TSO/UFO/SG/GSO Processing
  /sbin/ethtool --offload $NIC rx on tx on tso on ufo on sg on gso on

  # Optimize IPv4 initcwnd and initrwnd values
  IFS=$'\n'; ipv4RouteList=( \$(/sbin/ip -4 route show) ); unset IFS;

  for ipv4Route in "\${ipv4RouteList[@]}"; do
    # Process IPv4 routes
    if [[ "\$ipv4Route" =~ ^default ]]; then
      defaultRoute=( \$ipv4Route )
      /sbin/ip route change \${defaultRoute[@]:0:5} initcwnd 22 initrwnd 22
    elif [[ "\$ipv4Route" == *"proto kernel"* ]]; then
      kernelRoute=( \$ipv4Route )
      /sbin/ip route change \${kernelRoute[@]:0:9} initcwnd 44 initrwnd 44
    fi
  done

  # Optimize IPv6 initcwnd and initrwnd values
  IFS=$'\n'; ipv6RouteList=( \$(/sbin/ip -6 route show) ); unset IFS;

  for ipv6Route in "\${ipv6RouteList[@]}"; do
    # Process IPv6 routes
    if [[ "\$ipv6Route" =~ ^default ]]; then
      defaultRoute=( \$ipv6Route )
      /sbin/ip route change \${defaultRoute[@]:0:9} initcwnd 22 initrwnd 22
    elif [[ "\$ipv6Route" == *"proto kernel"* ]]; then
      kernelRoute=( \$ipv6Route )
      /sbin/ip route change \${kernelRoute[@]:0:7} initcwnd 44 initrwnd 44
    fi
  done

fi

exit 0

EOF

exit 0
