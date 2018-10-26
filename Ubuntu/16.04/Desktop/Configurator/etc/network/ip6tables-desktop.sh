#!/bin/bash

#
# ip6tables-desktop.sh - DevOpsBroker IPv6 ip6tables firewall script
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
# Uses a Block Listing approach (Default Policy: ACCEPT, Rules DROP/REJECT)
#
# Features:
#   o Drop fragmented incoming/outgoing packets
#   o All ICMPv6 filtering is done in the RAW table
#   o Valid ICMPv6 and UDP traffic is set to NOTRACK
#   o All traffic on lo is set to NOTRACK
#   o Drop incoming/outgoing Canon/Epson printer discovery packets
#   o Drop all incoming/outgoing INVALID packets
#   o Disable FORWARD
#   o Protocol-specific FILTER chains for TCP/UDP/ICMPv6
#
# References:
#   o man iptables
#   o man iptables-extensions
#
# Notes:
#   o REJECT rules are not allowed in the RAW table
#   o NOTRACK targets do not stop processing in the RAW table
#   o The global scope IPv6 address is equivalent to a **PUBLIC** IPv4 address
#     and must be treated as such
#
# Useful Linux Command-Line Utilities
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# o List rules currently configured:
# sudo firewall -6 list
# sudo firewall -6 list FILTER INPUT
#
# TODO: https://www.snort.org/ - filter packets for "alerts" or concerning traffic
# TODO: http://manpages.ubuntu.com/manpages/bionic/man8/mtr.8.html
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
SCRIPT_EXEC=$( $EXEC_BASENAME "$BASH_SOURCE" )

# Display error if not running as root
if [ "$USER" != 'root' ]; then
	printError "$SCRIPT_EXEC" 'Permission denied (you must be root)'
	exit 1
fi

################################## Variables ##################################

IP6TABLES=/sbin/ip6tables
IP6TABLES_SAVE=/sbin/ip6tables-save

## IPv6 Address Scopes
IPv6_LOCAL_SUBNET='fe80::/64'
ALL_NODES_ADDR='ff02::1'
ALL_ROUTERS_ADDR='ff02::2'
MLDv2_ADDR='ff02::16'
mDNSv6_ADDR='ff02::fb'
SOLICITED_NODE_ADDR='ff02::1:ff00:0/104'

################################### Actions ###################################

# Clear screen only if called from command line
if [ $SHLVL -eq 1 ]; then
	clear
fi

printBox "DevOpsBroker $UBUNTU_RELEASE ip6tables Configurator" 'true'

#
# Gather IPv6 Gateway information
#
mapfile -t ipv6RouteList < <($EXEC_IP -6 route show)

for ipv6Route in "${ipv6RouteList[@]}"; do
	if [[ "$ipv6Route" =~ ^default ]]; then
		defaultRoute=( $ipv6Route )

		IPv6_DEFAULT_GATEWAY=${defaultRoute[2]}
		NIC=${defaultRoute[4]}
	elif [[ "$ipv6Route" == *'proto ra'* ]]; then
		kernelRoute=( $ipv6Route )

		IPv6_GLOBAL_SUBNET=${kernelRoute[0]}
	fi
done

#
# Gather IPv6 Address information
#
mapfile -t ipv6AddrList < <($EXEC_IP -6 address show dev $NIC)

for ipv6Address in "${ipv6AddrList[@]}"; do
	if [[ "$ipv6Address" == *'scope global'* ]]; then
		addressLine=( $ipv6Address )

		IPv6_GLOBAL_ADDR=${addressLine[1]}
	elif [[ "$ipv6Address" == *'scope link'* ]]; then
		addressLine=( $ipv6Address )

		IPv6_LOCAL_ADDR=${addressLine[1]}
	fi
done

echo "${bold}Network Interface: ${green}$NIC"
echo "${white}IPv6 Global Address: ${green}$IPv6_GLOBAL_ADDR"
echo "${white}IPv6 Global Subnet: ${green}$IPv6_GLOBAL_SUBNET"
echo "${white}IPv6 Local Address: ${green}$IPv6_LOCAL_ADDR"
echo "${white}IPv6 Local Subnet: ${green}$IPv6_LOCAL_SUBNET"
echo "${white}IPv6 Default Gateway: ${green}$IPv6_DEFAULT_GATEWAY${reset}"

echo

# Set default policies / Flush rules / Delete user-defined chains
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
printInfo 'Initializing RAW Table'
$IP6TABLES -t raw -P OUTPUT ACCEPT
$IP6TABLES -t raw -F
$IP6TABLES -t raw -X

printInfo 'Initializing MANGLE Table'
$IP6TABLES -t mangle -P INPUT ACCEPT
$IP6TABLES -t mangle -P FORWARD ACCEPT
$IP6TABLES -t mangle -P OUTPUT ACCEPT
$IP6TABLES -t mangle -F
$IP6TABLES -t mangle -X

printInfo 'Initializing NAT Table'
$IP6TABLES -t nat -P OUTPUT ACCEPT
$IP6TABLES -t nat -F
$IP6TABLES -t nat -X

printInfo 'Initializing FILTER Table'
$IP6TABLES -t filter -P INPUT ACCEPT
$IP6TABLES -t filter -P FORWARD ACCEPT
$IP6TABLES -t filter -P OUTPUT ACCEPT
$IP6TABLES -t filter -F
$IP6TABLES -t filter -X

echo

################################## RAW Table ##################################

printBanner 'Configuring RAW Table'

#
# =====================================
# = Custom Jump Targets for RAW Table =
# =====================================
#

# Rate limit Fragment logging
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
$IP6TABLES -t raw -N fragment_drop
$IP6TABLES -t raw -A fragment_drop -m limit --limit 3/min --limit-burst 2 -j LOG --log-prefix '[IPv6 FRAG BLOCK] ' --log-level 7
$IP6TABLES -t raw -A fragment_drop -j DROP

# Rate limit ICMPv6 logging
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
$IP6TABLES -t raw -N icmpv6_drop
$IP6TABLES -t raw -A icmpv6_drop -m limit --limit 3/min --limit-burst 2 -j LOG --log-prefix '[IPv6 ICMPv6 BLOCK] ' --log-level 7
$IP6TABLES -t raw -A icmpv6_drop -j DROP

# Perform NOTRACK and ACCEPT
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
$IP6TABLES -t raw -N do_not_track
$IP6TABLES -t raw -A do_not_track -j NOTRACK
$IP6TABLES -t raw -A do_not_track -j ACCEPT

#
# ==================================
# = Configure RAW PREROUTING Chain =
# ==================================

printInfo 'NOTRACK incoming lo interface traffic'
$IP6TABLES -t raw -A PREROUTING -i lo -j do_not_track

printInfo 'DROP incoming fragmented packets'
$IP6TABLES -t raw -A PREROUTING -m frag --fragmore -j fragment_drop

# Create PREROUTING filter chains for each protocol
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

## TCP
$IP6TABLES -t raw -N raw-tcp-pre
$IP6TABLES -t raw -A PREROUTING -p tcp -j raw-tcp-pre

## UDP
$IP6TABLES -t raw -N raw-udp-pre
$IP6TABLES -t raw -A PREROUTING -p udp -j raw-udp-pre

## ICMPv6
$IP6TABLES -t raw -N raw-icmpv6-pre
$IP6TABLES -t raw -A PREROUTING -p icmpv6 -j raw-icmpv6-pre

## ALL OTHERS
$IP6TABLES -t raw -A PREROUTING -j ACCEPT

echo

#
# ************************
# * raw-icmpv6-pre Rules *
# ************************
#

## ICMPv6 Link-Local
$IP6TABLES -t raw -N raw-icmpv6-pre-local
$IP6TABLES -t raw -A raw-icmpv6-pre -s $IPv6_LOCAL_SUBNET -j raw-icmpv6-pre-local

#
# ******************************
# * raw-icmpv6-pre-local Rules *
# ******************************
#
# ICMPv6 Type       ICMPv6 Message
# ¯¯¯¯¯¯¯¯¯¯¯       ¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# 133               router-solicitation
# 134               router-advertisement
# 135               neighbor-solicitation
# 136               neighbor-advertisement
# 137               redirect
#

printInfo 'Allow ICMPv6 router-advertisement input'
$IP6TABLES -t raw -A raw-icmpv6-pre-local -d $ALL_NODES_ADDR -p icmpv6 -m icmpv6 --icmpv6-type router-advertisement -j do_not_track

printInfo "Allow ICMPv6 neighbor-solicitation (to $IPv6_GLOBAL_SUBNET) input"
$IP6TABLES -t raw -A raw-icmpv6-pre-local -d $IPv6_GLOBAL_SUBNET -p icmpv6 -m icmpv6 --icmpv6-type neighbor-solicitation -j do_not_track

printInfo "Allow ICMPv6 neighbor-solicitation (to $SOLICITED_NODE_ADDR) input"
$IP6TABLES -t raw -A raw-icmpv6-pre-local -d $SOLICITED_NODE_ADDR -p icmpv6 -m icmpv6 --icmpv6-type neighbor-solicitation -j do_not_track

printInfo "Allow ICMPv6 neighbor-solicitation (to $IPv6_LOCAL_SUBNET) input"
$IP6TABLES -t raw -A raw-icmpv6-pre-local -d $IPv6_LOCAL_SUBNET -p icmpv6 -m icmpv6 --icmpv6-type neighbor-solicitation -j do_not_track

printInfo "Allow ICMPv6 neighbor-advertisement (to $IPv6_LOCAL_SUBNET) input"
$IP6TABLES -t raw -A raw-icmpv6-pre-local -d $IPv6_LOCAL_SUBNET -p icmpv6 -m icmpv6 --icmpv6-type neighbor-advertisement -j do_not_track

printInfo "Allow ICMPv6 neighbor-advertisement (to $ALL_NODES_ADDR) input"
$IP6TABLES -t raw -A raw-icmpv6-pre-local -d $ALL_NODES_ADDR -p icmpv6 -m icmpv6 --icmpv6-type neighbor-advertisement -j do_not_track

## Implicit RETURN to raw-icmpv6-pre

printInfo 'Allow ICMPv6 destination-unreachable input'
$IP6TABLES -t raw -A raw-icmpv6-pre -p icmpv6 -m icmpv6 --icmpv6-type destination-unreachable -j do_not_track

printInfo 'Allow ICMPv6 packet-too-big input'
$IP6TABLES -t raw -A raw-icmpv6-pre -p icmpv6 -m icmpv6 --icmpv6-type packet-too-big -j do_not_track

printInfo 'Allow ICMPv6 time-exceeded input'
$IP6TABLES -t raw -A raw-icmpv6-pre -p icmpv6 -m icmpv6 --icmpv6-type time-exceeded -j do_not_track

printInfo 'Allow ICMPv6 parameter-problem input'
$IP6TABLES -t raw -A raw-icmpv6-pre -p icmpv6 -m icmpv6 --icmpv6-type parameter-problem -j do_not_track

printInfo 'Allow ICMPv6 echo-request input'
$IP6TABLES -t raw -A raw-icmpv6-pre -p icmpv6 -m icmpv6 --icmpv6-type echo-request -m limit --limit 2/s --limit-burst 1 -j do_not_track

printInfo 'Allow ICMPv6 echo-reply input'
$IP6TABLES -t raw -A raw-icmpv6-pre -p icmpv6 -m icmpv6 --icmpv6-type echo-reply -j do_not_track

printInfo 'DROP all other ICMPv6 input'
$IP6TABLES -t raw -A raw-icmpv6-pre -j icmpv6_drop

echo

#
# **********************
# * raw-tcp-pre Rules *
# **********************
#

printInfo 'NOTRACK incoming HTTP/HTTPS TCP response packets'
$IP6TABLES -t raw -A raw-tcp-pre -p tcp -m tcp --sport 443 -j do_not_track
$IP6TABLES -t raw -A raw-tcp-pre -p tcp -m tcp --sport 80 -j do_not_track

printInfo 'NOTRACK incoming DNS TCP response packets'
$IP6TABLES -t raw -A raw-tcp-pre -p tcp -m tcp --sport 53 -j do_not_track

printInfo 'ACCEPT all other TCP input'
$IP6TABLES -t raw -A raw-tcp-pre -j ACCEPT

echo

#
# *********************
# * raw-udp-pre Rules *
# *********************
#

printInfo 'DROP incoming Canon/Epson printer discovery packets'
$IP6TABLES -t raw -A raw-udp-pre -p udp -m multiport --dports 8610,8612,3289 -j DROP

printInfo 'NOTRACK incoming UDP packets'
$IP6TABLES -t raw -A raw-udp-pre -j do_not_track

echo

#
# ==============================
# = Configure RAW OUTPUT Chain =
# ==============================
#

printInfo 'NOTRACK outgoing lo interface traffic'
$IP6TABLES -t raw -A OUTPUT -o lo -j do_not_track

printInfo 'DROP outgoing fragmented packets'
$IP6TABLES -t raw -A OUTPUT -m frag --fragmore -j fragment_drop

# Create OUTPUT filter chains for each protocol
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

## TCP
$IP6TABLES -t raw -N raw-tcp-out
$IP6TABLES -t raw -A OUTPUT -p tcp -j raw-tcp-out

## UDP
$IP6TABLES -t raw -N raw-udp-out
$IP6TABLES -t raw -A OUTPUT -p udp -j raw-udp-out

## ICMPv6
$IP6TABLES -t raw -N raw-icmpv6-out
$IP6TABLES -t raw -A OUTPUT -p icmpv6 -j raw-icmpv6-out

## ALL OTHERS
$IP6TABLES -t raw -A OUTPUT -j ACCEPT

echo

#
# ************************
# * raw-icmpv6-out Rules *
# ************************
#
# ICMPv6 Type       ICMPv6 Message
# ¯¯¯¯¯¯¯¯¯¯¯       ¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# 133               router-solicitation
# 134               router-advertisement
# 135               neighbor-solicitation
# 136               neighbor-advertisement
# 137               redirect
# 143               Version 2 Multicast Listener Report
#

printInfo 'Allow ICMPv6 neighbor-advertisement output'
$IP6TABLES -t raw -A raw-icmpv6-out -d $IPv6_LOCAL_SUBNET -p icmpv6 -m icmpv6 --icmpv6-type neighbor-advertisement -j do_not_track

printInfo "Allow ICMPv6 neighbor-solicitation (to $IPv6_LOCAL_SUBNET) output"
$IP6TABLES -t raw -A raw-icmpv6-out -d $IPv6_LOCAL_SUBNET -p icmpv6 -m icmpv6 --icmpv6-type neighbor-solicitation -j do_not_track

printInfo "Allow ICMPv6 neighbor-solicitation (to $SOLICITED_NODE_ADDR) output"
$IP6TABLES -t raw -A raw-icmpv6-out -d $SOLICITED_NODE_ADDR -p icmpv6 -m icmpv6 --icmpv6-type neighbor-solicitation -j do_not_track

printInfo 'Allow ICMPv6 destination-unreachable output'
$IP6TABLES -t raw -A raw-icmpv6-out -p icmpv6 -m icmpv6 --icmpv6-type destination-unreachable -j do_not_track

printInfo 'Allow ICMPv6 router-solicitation output'
$IP6TABLES -t raw -A raw-icmpv6-out -d $ALL_ROUTERS_ADDR -p icmpv6 -m icmpv6 --icmpv6-type router-solicitation -j do_not_track

printInfo 'Allow ICMPv6 Multicast Listenter Discover REPORT packet output'
$IP6TABLES -t raw -A raw-icmpv6-out -d $MLDv2_ADDR -p icmpv6 -m icmpv6 --icmpv6-type 143 -j do_not_track

printInfo 'Allow ICMPv6 packet-too-big output'
$IP6TABLES -t raw -A raw-icmpv6-out -p icmpv6 -m icmpv6 --icmpv6-type packet-too-big -j do_not_track

printInfo 'Allow ICMPv6 time-exceeded output'
$IP6TABLES -t raw -A raw-icmpv6-out -p icmpv6 -m icmpv6 --icmpv6-type time-exceeded -j do_not_track

printInfo 'Allow ICMPv6 parameter-problem output'
$IP6TABLES -t raw -A raw-icmpv6-out -p icmpv6 -m icmpv6 --icmpv6-type parameter-problem -j do_not_track

printInfo 'Allow ICMPv6 echo-request output'
$IP6TABLES -t raw -A raw-icmpv6-out -p icmpv6 -m icmpv6 --icmpv6-type echo-request -j do_not_track

printInfo 'Allow ICMPv6 echo-reply output'
$IP6TABLES -t raw -A raw-icmpv6-out -p icmpv6 -m icmpv6 --icmpv6-type echo-reply -j do_not_track

printInfo 'DROP all other ICMPv6 output'
$IP6TABLES -t raw -A raw-icmpv6-out -j icmpv6_drop

echo

#
# *********************
# * raw-tcp-out Rules *
# *********************
#

printInfo 'NOTRACK outgoing HTTP/HTTPS TCP request packets'
$IP6TABLES -t raw -A raw-tcp-out -p tcp -m tcp --dport 443 -j do_not_track
$IP6TABLES -t raw -A raw-tcp-out -p tcp -m tcp --dport 80 -j do_not_track

printInfo 'NOTRACK outgoing DNS TCP request packets'
$IP6TABLES -t raw -A raw-tcp-out -p tcp -m tcp --dport 53 -j do_not_track

printInfo 'ACCEPT all other TCP output'
$IP6TABLES -t raw -A raw-tcp-out -j ACCEPT

echo

#
# *********************
# * raw-udp-out Rules *
# *********************
#

printInfo 'DROP outgoing Canon/Epson printer discovery packets'
$IP6TABLES -t raw -A raw-udp-out -p udp -m multiport --dports 8610,8612,3289 -j DROP

printInfo 'NOTRACK outgoing UDP packets'
$IP6TABLES -t raw -A raw-udp-out -j do_not_track

echo

################################ MANGLE Table #################################

printBanner 'Configuring MANGLE Table'

#
# =====================================
# = Configure MANGLE PREROUTING Chain =
# =====================================
#

printInfo 'Drop all incoming INVALID packets'
$IP6TABLES -t mangle -A PREROUTING -m conntrack --ctstate INVALID -j DROP

#
# ======================================
# = Configure MANGLE POSTROUTING Chain =
# ======================================
#


#
# =================================
# = Configure MANGLE OUTPUT Chain =
# =================================
#

printInfo 'Drop all outgoing INVALID packets'
$IP6TABLES -t mangle -A OUTPUT -m conntrack --ctstate INVALID -j DROP

#
# ================================
# = Configure MANGLE INPUT Chain =
# ================================
#


#
# ==================================
# = Configure MANGLE FORWARD Chain =
# ==================================
#

printInfo 'Disable routing'
$IP6TABLES -t mangle -P FORWARD DROP

echo

################################ FILTER Table #################################

printBanner 'Configuring FILTER Table'

#
# ========================================
# = Custom Jump Targets for FILTER Table =
# ========================================
#

# Rate limit INPUT Deny logging
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
$IP6TABLES -N in_deny
$IP6TABLES -A in_deny -m limit --limit 3/min --limit-burst 2 -j LOG --log-prefix '[IPv6 INPUT BLOCK] ' --log-level 7
$IP6TABLES -A in_deny -j REJECT --reject-with icmp6-port-unreachable

# Rate limit OUTPUT Deny logging
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
$IP6TABLES -N out_deny
$IP6TABLES -A out_deny -m limit --limit 3/min --limit-burst 2 -j LOG --log-prefix '[IPv6 OUTPUT BLOCK] ' --log-level 7
$IP6TABLES -A out_deny -j REJECT --reject-with icmp6-port-unreachable

#
# ================================
# = Configure FILTER INPUT Chain =
# ================================
#

printInfo 'Allow Loopback interface input'
$IP6TABLES -A INPUT -i lo -j ACCEPT

echo

# Create INPUT filter chains for each protocol
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

## TCP
$IP6TABLES -N filter-tcp-in
$IP6TABLES -A INPUT -p tcp -j filter-tcp-in

## UDP
$IP6TABLES -N filter-udp-in
$IP6TABLES -A INPUT -p udp -j filter-udp-in

## ICMPv6 (Filtering done in RAW table so ACCEPT here)
$IP6TABLES -A INPUT -p icmpv6 -j ACCEPT

## ALL OTHERS
$IP6TABLES -A INPUT -j in_deny

#
# ***********************
# * filter-tcp-in Rules *
# ***********************
#

printInfo 'Allow incoming HTTP/HTTPS TCP response packets'
$IP6TABLES -A filter-tcp-in -p tcp -m tcp --sport 443 -j ACCEPT
$IP6TABLES -A filter-tcp-in -p tcp -m tcp --sport 80 -j ACCEPT

printInfo 'Allow Established TCP Sessions'
$IP6TABLES -A filter-tcp-in -p tcp -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

printInfo 'Allow incoming DNS TCP response packets'
$IP6TABLES -A filter-tcp-in -p tcp -m tcp --sport 53 -j ACCEPT

printInfo 'REJECT all other TCP input'
$IP6TABLES -A filter-tcp-in -m limit --limit 3/min --limit-burst 2 -j LOG --log-prefix '[IPv6 TCP BLOCK] ' --log-level 7
$IP6TABLES -A filter-tcp-in -p tcp -j REJECT --reject-with tcp-reset

echo

#
# ***********************
# * filter-udp-in Rules *
# ***********************
#

printInfo 'Allow incoming DNS UDP packets'
$IP6TABLES -A filter-udp-in -p udp -m udp --sport 53 -j ACCEPT

printInfo 'Allow incoming NTP UDP packets'
$IP6TABLES -A filter-udp-in -p udp -m udp --sport 123 -j ACCEPT

printInfo 'Allow incoming Google Talk Voice and Video packets'
$IP6TABLES -A filter-udp-in -p udp -m multiport --sports 19302,19305:19309 -j ACCEPT

printInfo 'Allow incoming DHCPv6 UDP response packets'
$IP6TABLES -A filter-udp-in -p udp -m udp --dport 546 -j ACCEPT

## UDP Multicast
$IP6TABLES -N filter-udp-in-multicast
$IP6TABLES -A filter-udp-in -p udp -m pkttype --pkt-type multicast -j filter-udp-in-multicast

#
# *********************************
# * filter-udp-in-multicast Rules *
# *********************************
#

printInfo "Allow incoming mDNS UDP MULTICAST packets (from $IPv6_LOCAL_SUBNET)"
$IP6TABLES -A filter-udp-in-multicast -s $IPv6_LOCAL_SUBNET -d $mDNSv6_ADDR -p udp -m udp --dport 5353 -j ACCEPT

printInfo "Allow incoming mDNS UDP MULTICAST packets (from $IPv6_GLOBAL_SUBNET)"
$IP6TABLES -A filter-udp-in-multicast -s $IPv6_GLOBAL_SUBNET -d $mDNSv6_ADDR -p udp -m udp --dport 5353 -j ACCEPT

#
# Implicit RETURN to filter-udp-in
#

printInfo 'REJECT all other UDP input'
$IP6TABLES -A filter-udp-in -j in_deny

echo

#
# ==================================
# = Configure FILTER FORWARD Chain =
# ==================================
#

printInfo 'Set default FORWARD policy to DROP'
$IP6TABLES -P FORWARD DROP

echo

#
# =================================
# = Configure FILTER OUTPUT Chain =
# =================================
#

printInfo 'Allow Loopback interface output'
$IP6TABLES -A OUTPUT -o lo -j ACCEPT

echo

# Create OUTPUT filter chains for each protocol
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

## TCP
$IP6TABLES -N filter-tcp-out
$IP6TABLES -A OUTPUT -p tcp -j filter-tcp-out

## UDP
$IP6TABLES -N filter-udp-out
$IP6TABLES -A OUTPUT -p udp -j filter-udp-out

## ICMPv6 (Filtering done in RAW table so ACCEPT here)
$IP6TABLES -A OUTPUT -p icmpv6 -j ACCEPT

## ALL OTHERS
$IP6TABLES -A OUTPUT -j out_deny

#
# ************************
# * filter-tcp-out Rules *
# ************************
#

printInfo 'Allow outgoing HTTP/HTTPS TCP request packets'
$IP6TABLES -A filter-tcp-out -p tcp -m tcp --dport 443 -j ACCEPT
$IP6TABLES -A filter-tcp-out -p tcp -m tcp --dport 80 -j ACCEPT

printInfo 'REJECT all other TCP output'
$IP6TABLES -A filter-tcp-out -j out_deny

echo

#
# ************************
# * filter-udp-out Rules *
# ************************
#

printInfo 'Allow outoging DNS UDP request packets'
$IP6TABLES -A filter-udp-out -p udp -m udp --dport 53 -j ACCEPT

printInfo 'Allow outgoing mDNS UDP MULTICAST request packets'
$IP6TABLES -A filter-udp-out -d $mDNSv6_ADDR -p udp -m udp --dport 5353 -j ACCEPT

printInfo 'Allow outgoing NTP UDP request packets'
$IP6TABLES -A filter-udp-out -p udp -m udp --dport 123 -j ACCEPT

printInfo 'Allow outgoing Google Talk Voice and Video packets'
$IP6TABLES -A filter-udp-out -p udp -m multiport --dports 19302,19305:19309 -j ACCEPT

printInfo 'Allow outgoing DHCPv6 UDP request packets'
$IP6TABLES -A filter-udp-out -p udp -m udp --sport 546 --dport 547 -j ACCEPT

printInfo 'REJECT all other UDP output'
$IP6TABLES -A filter-udp-out -j out_deny

echo

################################ IP6TABLES-SAVE ################################

printInfo 'Persisting ip6tables Rules'

# Backup existing /etc/network/ip6tables.rules
if [ -f /etc/network/ip6tables.rules ]; then
    $EXEC_CP /etc/network/ip6tables.rules /etc/network/ip6tables.rules.bak
fi

# Save /etc/network/ip6tables.rules
$IP6TABLES_SAVE > /etc/network/ip6tables.rules

echo

exit 0
