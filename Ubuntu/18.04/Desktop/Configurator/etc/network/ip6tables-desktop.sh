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

## Bash exec variables
IP6TABLES=/sbin/ip6tables
IP6TABLES_SAVE=/sbin/ip6tables-save

## Options
NIC="$1"

## IPv6 Address Scopes
IPv6_ADDRESS_GLOBAL=''
IPv6_ADDRESS_LOCAL=''
IPv6_GATEWAY=''

IPv6_SUBNET_LOCAL='fe80::/64'
ALL_NODES_ADDR='ff02::1'
ALL_ROUTERS_ADDR='ff02::2'
MLDv2_ADDR='ff02::16'
mDNSv6_ADDR='ff02::fb'
SOLICITED_NODE_ADDR='ff02::1:ff00:0/104'

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ OPTION Parsing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if [ -z "$NIC" ]; then
	mapfile -t ethList < <($EXEC_IP -br -6 addr show | $EXEC_GREP -E '^enp')

	if [ ${#ethList[@]} -eq 1 ]; then
		ethInfo=(${ethList[0]})
	else
		declare -a selectList
		IFS=$'\n'
		for ethernet in ${ethList[@]}; do
			ethInfo=(${ethernet})
			selectList+=(${ethInfo[0]})
		done
		unset IFS

		OLD_COLUMNS=$COLUMNS
		COLUMNS=1
		echo "${bold}${yellow}Which Ethernet interface do you want to configure?${white}"
		select ethInterface in ${selectList[@]}; do
			for ((i=0; i<${#selectList[*]}; i++)); do
				if [ "$ethInterface" == ${selectList[i]} ]; then
					ethInfo=(${ethList[i]})
					break;
				fi
			done
			break;
		done
		COLUMNS=$OLD_COLUMNS
	fi

	NIC=${ethInfo[0]}
else
	# Display error if network interface parameter is invalid
	if [ ! -L /sys/class/net/$NIC ]; then
		printError "$SCRIPT_EXEC" "Cannot access '$NIC': No such network interface"
		echo
		printUsage "$SCRIPT_EXEC ${gold}[NIC]"

		exit 1
	fi

	ethInfo=( $($EXEC_IP -br -6 addr show dev $NIC) )
fi

IPv6_ADDRESS_GLOBAL=${ethInfo[2]}
IPv6_ADDRESS_LOCAL=${ethInfo[3]}
IPv6_GATEWAY=$($EXEC_IP -br -6 route show default dev $NIC | $EXEC_AWK '{ print $3; exit }')
# TODO: Need global subnet

################################### Actions ###################################

# Clear screen only if called from command line
if [ $SHLVL -eq 1 ]; then
	clear
fi

printBox "DevOpsBroker $UBUNTU_RELEASE ip6tables Configurator" 'true'

echo "${bold}Network Interface: ${green}$NIC"
echo "${white}IPv6 Global Address: ${green}$IPv6_ADDRESS_GLOBAL"
echo "${white}IPv6 Local Address: ${green}$IPv6_ADDRESS_LOCAL"
echo "${white}IPv6 Gateway: ${green}$IPv6_GATEWAY"
echo "${white}IPv6 Local Subnet: ${green}$IPv6_SUBNET_LOCAL"
echo "${reset}"

#
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
$IP6TABLES -t raw -N ${NIC}_fragment_drop
$IP6TABLES -t raw -A ${NIC}_fragment_drop -m limit --limit 3/min --limit-burst 2 -j LOG --log-prefix '[IPv6 FRAG BLOCK] ' --log-level 7
$IP6TABLES -t raw -A ${NIC}_fragment_drop -j DROP

# Perform NOTRACK and ACCEPT
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
$IP6TABLES -t raw -N do_not_track
$IP6TABLES -t raw -A do_not_track -j NOTRACK
$IP6TABLES -t raw -A do_not_track -j ACCEPT

#
# ==================================
# = Configure RAW PREROUTING Chain =
# ==================================
#

printInfo 'DROP incoming fragmented packets'
$IP6TABLES -t raw -A PREROUTING -m frag --fragmore -j ${NIC}_fragment_drop

printInfo 'Allow incoming Link-Local packets on all network interfaces'
$IP6TABLES -t raw -A PREROUTING -s $IPv6_SUBNET_LOCAL -j do_not_track

# Create PREROUTING filter chains for each network interface
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

## lo
printInfo 'Allow incoming lo interface traffic'
$IP6TABLES -t raw -A PREROUTING -i lo -j do_not_track

## NIC
printInfo "Process incoming $NIC interface traffic"
$IP6TABLES -t raw -N raw-${NIC}-pre
$IP6TABLES -t raw -A PREROUTING -i ${NIC} -j raw-${NIC}-pre

printInfo 'Allow all other incoming interface traffic'
$IP6TABLES -t raw -A PREROUTING -j ACCEPT

echo

# Create PREROUTING filter chains for each protocol
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

## TCP
printInfo 'Process incoming TCP traffic'
$IP6TABLES -t raw -N raw-${NIC}-tcp-pre
$IP6TABLES -t raw -A raw-${NIC}-pre -p tcp -j raw-${NIC}-tcp-pre

## UDP
printInfo 'Process incoming UDP traffic'
$IP6TABLES -t raw -N raw-${NIC}-udp-pre
$IP6TABLES -t raw -A raw-${NIC}-pre -p udp -j raw-${NIC}-udp-pre

## ICMPv6
printInfo 'Process incoming ICMPv6 traffic'
$IP6TABLES -t raw -N raw-${NIC}-icmpv6-pre
$IP6TABLES -t raw -A raw-${NIC}-pre -p icmpv6 -j raw-${NIC}-icmpv6-pre

## ALL OTHERS
printInfo 'Further process all other incoming protocol traffic'
$IP6TABLES -t raw -A raw-${NIC}-pre -j ACCEPT

echo

#
# *******************************
# * raw-${NIC}-icmpv6-pre Rules *
# *******************************
#

## ICMPv6 Link-Local
#$IP6TABLES -t raw -N raw-${NIC}-icmpv6-pre-local
#$IP6TABLES -t raw -A raw-${NIC}-icmpv6-pre -s $IPv6_SUBNET_LOCAL -j raw-${NIC}-icmpv6-pre-local

#
# *************************************
# * raw-${NIC}-icmpv6-pre-local Rules *
# *************************************
#
# ICMPv6 Type       ICMPv6 Message
# ¯¯¯¯¯¯¯¯¯¯¯       ¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# 133               router-solicitation
# 134               router-advertisement
# 135               neighbor-solicitation
# 136               neighbor-advertisement
# 137               redirect
#

#printInfo 'Allow ICMPv6 router-advertisement packets'
#$IP6TABLES -t raw -A raw-${NIC}-icmpv6-pre-local -p icmpv6 -m icmpv6 --icmpv6-type router-advertisement -j do_not_track

#printInfo 'Allow ICMPv6 neighbor-solicitation packets'
#$IP6TABLES -t raw -A raw-${NIC}-icmpv6-pre-local -p icmpv6 -m icmpv6 --icmpv6-type neighbor-solicitation -j do_not_track

#printInfo 'Allow ICMPv6 neighbor-advertisement packets'
#$IP6TABLES -t raw -A raw-${NIC}-icmpv6-pre-local -p icmpv6 -m icmpv6 --icmpv6-type neighbor-advertisement -j do_not_track

#printInfo 'Ignore ICMPv6 router-solicitation packets (we are not a router)'
#$IP6TABLES -t raw -A raw-${NIC}-icmpv6-pre-local -p icmpv6 -m icmpv6 --icmpv6-type router-solicitation -j DROP

## Implicit RETURN to raw-${NIC}-icmpv6-pre

printInfo 'Allow ICMPv6 destination-unreachable packets'
$IP6TABLES -t raw -A raw-${NIC}-icmpv6-pre -p icmpv6 -m icmpv6 --icmpv6-type destination-unreachable -j do_not_track

printInfo 'Allow ICMPv6 packet-too-big packets'
$IP6TABLES -t raw -A raw-${NIC}-icmpv6-pre -p icmpv6 -m icmpv6 --icmpv6-type packet-too-big -j do_not_track

printInfo 'Allow ICMPv6 parameter-problem packets'
$IP6TABLES -t raw -A raw-${NIC}-icmpv6-pre -p icmpv6 -m icmpv6 --icmpv6-type parameter-problem -j do_not_track

printInfo 'Allow ICMPv6 echo-request packets'
$IP6TABLES -t raw -A raw-${NIC}-icmpv6-pre -p icmpv6 -m icmpv6 --icmpv6-type echo-request -m limit --limit 2/s --limit-burst 1 -j do_not_track

printInfo 'Allow ICMPv6 echo-reply packets'
$IP6TABLES -t raw -A raw-${NIC}-icmpv6-pre -p icmpv6 -m icmpv6 --icmpv6-type echo-reply -j do_not_track

printInfo 'Allow ICMPv6 time-exceeded packets'
$IP6TABLES -t raw -A raw-${NIC}-icmpv6-pre -p icmpv6 -m icmpv6 --icmpv6-type time-exceeded -j do_not_track

printInfo 'DROP all other incoming ICMPv6 traffic'
$IP6TABLES -t raw -A raw-${NIC}-icmpv6-pre -m limit --limit 3/min --limit-burst 2 -j LOG --log-prefix '[IPv6 ICMP BLOCK] ' --log-level 7
$IP6TABLES -t raw -A raw-${NIC}-icmpv6-pre -j DROP

echo

#
# ****************************
# * raw-${NIC}-tcp-pre Rules *
# ****************************
#

printInfo 'Do not track incoming HTTP/HTTPS TCP response packets'
$IP6TABLES -t raw -A raw-${NIC}-tcp-pre -p tcp -m tcp --sport 443 -j do_not_track
$IP6TABLES -t raw -A raw-${NIC}-tcp-pre -p tcp -m tcp --sport 80 -j do_not_track

printInfo 'Do not track incoming DNS TCP response packets'
$IP6TABLES -t raw -A raw-${NIC}-tcp-pre -p tcp -m tcp --sport 53 -j do_not_track

printInfo 'Further process all other incoming TCP traffic'
$IP6TABLES -t raw -A raw-${NIC}-tcp-pre -j ACCEPT

echo

#
# ****************************
# * raw-${NIC}-udp-pre Rules *
# ****************************
#

printInfo 'DROP all incoming Canon/Epson printer discovery packets'
$IP6TABLES -t raw -A raw-${NIC}-udp-pre -p udp -m multiport --dports 8610,8612,3289 -j DROP

printInfo 'Further process all other incoming UDP traffic'
$IP6TABLES -t raw -A raw-${NIC}-udp-pre -j do_not_track

echo

#
# ==============================
# = Configure RAW OUTPUT Chain =
# ==============================
#

printInfo 'DROP outgoing fragmented packets'
$IP6TABLES -t raw -A OUTPUT -m frag --fragmore -j ${NIC}_fragment_drop

printInfo 'Allow outgoing Link-Local packets on all network interfaces'
$IP6TABLES -t raw -A OUTPUT -s $IPv6_SUBNET_LOCAL -j do_not_track

#
# ==============================
# = Configure RAW OUTPUT Chain =
# ==============================
#

# Create PREROUTING filter chains for each network interface
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

## lo
printInfo 'Allow outgoing lo interface traffic'
$IP6TABLES -t raw -A OUTPUT -o lo -j do_not_track

## NIC
printInfo "Process outgoing $NIC interface traffic"
$IP6TABLES -t raw -N raw-${NIC}-out
$IP6TABLES -t raw -A OUTPUT -o ${NIC} -j raw-${NIC}-out

printInfo 'ACCEPT all other outgoing interface traffic'
$IP6TABLES -t raw -A OUTPUT -j ACCEPT

echo

# Create OUTPUT filter chains for each protocol
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

## TCP
printInfo 'Process outgoing TCP traffic'
$IP6TABLES -t raw -N raw-${NIC}-tcp-out
$IP6TABLES -t raw -A raw-${NIC}-out -p tcp -j raw-${NIC}-tcp-out

## UDP
printInfo 'Process outgoing UDP traffic'
$IP6TABLES -t raw -N raw-${NIC}-udp-out
$IP6TABLES -t raw -A raw-${NIC}-out -p udp -j raw-${NIC}-udp-out

## ICMPv6
printInfo 'Allow outgoing ICMP traffic'
$IP6TABLES -t raw -A raw-${NIC}-out -p icmpv6 -j do_not_track

## ALL OTHERS
printInfo 'DROP all other outgoing protocol traffic'
$IP6TABLES -t raw -A raw-${NIC}-out -m limit --limit 3/min --limit-burst 2 -j LOG --log-prefix '[IPv6 OUTPUT BLOCK] ' --log-level 7
$IP6TABLES -t raw -A raw-${NIC}-out -j DROP

echo

#
# *******************************
# * raw-${NIC}-icmpv6-out Rules *
# *******************************
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

#printInfo 'Allow ICMPv6 neighbor-advertisement output'
#$IP6TABLES -t raw -A raw-icmpv6-out -d $IPv6_LOCAL_SUBNET -p icmpv6 -m icmpv6 --icmpv6-type neighbor-advertisement -j do_not_track
#
#printInfo "Allow ICMPv6 neighbor-solicitation (to $IPv6_LOCAL_SUBNET) output"
#$IP6TABLES -t raw -A raw-icmpv6-out -d $IPv6_LOCAL_SUBNET -p icmpv6 -m icmpv6 --icmpv6-type neighbor-solicitation -j do_not_track
#
#printInfo "Allow ICMPv6 neighbor-solicitation (to $SOLICITED_NODE_ADDR) output"
#$IP6TABLES -t raw -A raw-icmpv6-out -d $SOLICITED_NODE_ADDR -p icmpv6 -m icmpv6 --icmpv6-type neighbor-solicitation -j do_not_track
#
#printInfo 'Allow ICMPv6 destination-unreachable output'
#$IP6TABLES -t raw -A raw-icmpv6-out -p icmpv6 -m icmpv6 --icmpv6-type destination-unreachable -j do_not_track
#
#printInfo 'Allow ICMPv6 router-solicitation output'
#$IP6TABLES -t raw -A raw-icmpv6-out -d $ALL_ROUTERS_ADDR -p icmpv6 -m icmpv6 --icmpv6-type router-solicitation -j do_not_track
#
#printInfo 'Allow ICMPv6 Multicast Listenter Discover REPORT packet output'
#$IP6TABLES -t raw -A raw-icmpv6-out -d $MLDv2_ADDR -p icmpv6 -m icmpv6 --icmpv6-type 143 -j do_not_track
#
#printInfo 'Allow ICMPv6 packet-too-big output'
#$IP6TABLES -t raw -A raw-icmpv6-out -p icmpv6 -m icmpv6 --icmpv6-type packet-too-big -j do_not_track
#
#printInfo 'Allow ICMPv6 time-exceeded output'
#$IP6TABLES -t raw -A raw-icmpv6-out -p icmpv6 -m icmpv6 --icmpv6-type time-exceeded -j do_not_track
#
#printInfo 'Allow ICMPv6 parameter-problem output'
#$IP6TABLES -t raw -A raw-icmpv6-out -p icmpv6 -m icmpv6 --icmpv6-type parameter-problem -j do_not_track
#
#printInfo 'Allow ICMPv6 echo-request output'
#$IP6TABLES -t raw -A raw-icmpv6-out -p icmpv6 -m icmpv6 --icmpv6-type echo-request -j do_not_track
#
#printInfo 'Allow ICMPv6 echo-reply output'
#$IP6TABLES -t raw -A raw-icmpv6-out -p icmpv6 -m icmpv6 --icmpv6-type echo-reply -j do_not_track
#
#printInfo 'DROP all other ICMPv6 output'
#$IP6TABLES -t raw -A raw-icmpv6-out -j icmpv6_drop
#
#echo

#
# ****************************
# * raw-${NIC}-tcp-out Rules *
# ****************************
#

printInfo 'Do not track outgoing HTTP/HTTPS TCP request packets'
$IP6TABLES -t raw -A raw-${NIC}-tcp-out -p tcp -m tcp --dport 443 -j do_not_track
$IP6TABLES -t raw -A raw-${NIC}-tcp-out -p tcp -m tcp --dport 80 -j do_not_track

printInfo 'Do not track outgoing DNS TCP request packets'
$IP6TABLES -t raw -A raw-${NIC}-tcp-out -p tcp -m tcp --dport 53 -j do_not_track

printInfo 'Further process all other outgoing TCP traffic'
$IP6TABLES -t raw -A raw-${NIC}-tcp-out -j ACCEPT

echo

#
# ****************************
# * raw-${NIC}-udp-out Rules *
# ****************************
#

printInfo 'DROP outgoing Canon/Epson printer discovery packets'
$IP6TABLES -t raw -A raw-${NIC}-udp-out -p udp -m multiport --dports 8610,8612,3289 -j DROP

printInfo 'Further process all other outgoing UDP traffic'
$IP6TABLES -t raw -A raw-${NIC}-udp-out -j do_not_track

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

#
# =================================
# = Configure MANGLE OUTPUT Chain =
# =================================
#

printInfo 'DROP all outgoing INVALID packets'
$IP6TABLES -t mangle -A OUTPUT -m conntrack --ctstate INVALID -j DROP

#
# ======================================
# = Configure MANGLE POSTROUTING Chain =
# ======================================
#

echo

################################ FILTER Table #################################

printBanner 'Configuring FILTER Table'

#
# ========================================
# = Custom Jump Targets for FILTER Table =
# ========================================
#

# Rate limit ICMP REJECT logging
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
$IP6TABLES -N ${NIC}_icmp_reject
$IP6TABLES -A ${NIC}_icmp_reject -m limit --limit 3/min --limit-burst 2 -j LOG --log-prefix '[IPv6 BLOCK] ' --log-level 7
$IP6TABLES -A ${NIC}_icmp_reject -j REJECT --reject-with icmp6-port-unreachable

# Rate limit TCP REJECT logging
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
$IP6TABLES -N ${NIC}_tcp_reject
$IP6TABLES -A ${NIC}_tcp_reject -m limit --limit 3/min --limit-burst 2 -j LOG --log-prefix '[IPv6 BLOCK] ' --log-level 7
$IP6TABLES -A ${NIC}_tcp_reject -p tcp -j REJECT --reject-with tcp-reset

#
# ================================
# = Configure FILTER INPUT Chain =
# ================================
#

# Create INPUT filter chains for each network interface
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

## lo
printInfo 'ACCEPT incoming lo interface traffic'
$IP6TABLES -A INPUT -i lo -j ACCEPT

## NIC
printInfo "Process incoming $NIC interface traffic"
$IP6TABLES -N filter-${NIC}-in
$IP6TABLES -A INPUT -i ${NIC} -j filter-${NIC}-in

printInfo 'ACCEPT all other incoming interface traffic'
$IP6TABLES -A INPUT -j ACCEPT

echo

# Create INPUT filter chains for each protocol
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

printInfo "Process incoming Link-Local packets on $NIC"
$IP6TABLES -N filter-${NIC}-local-in
$IP6TABLES -A filter-${NIC}-in -s $IPv6_SUBNET_LOCAL -j filter-${NIC}-local-in

## TCP
printInfo 'Process incoming TCP traffic'
$IP6TABLES -N filter-${NIC}-tcp-in
$IP6TABLES -A filter-${NIC}-in -p tcp -j filter-${NIC}-tcp-in

## UDP
printInfo 'Process incoming UDP traffic'
$IP6TABLES -N filter-${NIC}-udp-ucast-in
$IP6TABLES -A filter-${NIC}-in -p udp -m pkttype --pkt-type unicast -j filter-${NIC}-udp-ucast-in

#$IP6TABLES -N filter-${NIC}-udp-mcast-in
#$IP6TABLES -A filter-${NIC}-in -p udp -m pkttype --pkt-type multicast -j filter-${NIC}-udp-mcast-in

#$IP6TABLES -N filter-${NIC}-udp-bcast-in
#$IP6TABLES -A filter-${NIC}-in -p udp -m pkttype --pkt-type broadcast -j filter-${NIC}-udp-bcast-in

## ICMPv6
printInfo 'ACCEPT all incoming ICMPv6 traffic not dropped in RAW table'
$IP6TABLES -A filter-${NIC}-in -p icmpv6 -j ACCEPT

## ALL OTHERS
printInfo 'REJECT all other incoming protocol traffic'
$IP6TABLES -A filter-${NIC}-in -j ${NIC}_icmp_reject

echo

#
# ********************************
# * filter-${NIC}-local-in Rules *
# ********************************
#

printInfo 'Perform incoming Link-Local TCP traffic accounting'
$IP6TABLES -A filter-${NIC}-local-in -p tcp -j ACCEPT

printInfo 'Perform incoming Link-Local UDP traffic accounting'
$IP6TABLES -A filter-${NIC}-local-in -p udp -j ACCEPT

printInfo 'Perform incoming Link-Local ICMPv6 traffic accounting'
$IP6TABLES -A filter-${NIC}-local-in -p icmpv6 -j ACCEPT

printInfo 'Perform incoming Link-Local OTHER traffic accounting'
$IP6TABLES -A filter-${NIC}-local-in -m limit --limit 3/min --limit-burst 2 -j LOG --log-prefix '[IPv6 INFO BLOCK] ' --log-level 7
$IP6TABLES -A filter-${NIC}-local-in -j ACCEPT

echo

#
# ******************************
# * filter-${NIC}-tcp-in Rules *
# ******************************
#

printInfo 'ACCEPT incoming HTTP/HTTPS TCP response packets'
$IP6TABLES -A filter-${NIC}-tcp-in -p tcp -m tcp --sport 443 -j ACCEPT
$IP6TABLES -A filter-${NIC}-tcp-in -p tcp -m tcp --sport 80 -j ACCEPT

printInfo 'ACCEPT incoming DNS TCP response packets'
$IP6TABLES -A filter-${NIC}-tcp-in -p tcp -m tcp --sport 53 -j ACCEPT

printInfo 'ACCEPT Established TCP Sessions'
$IP6TABLES -A filter-${NIC}-tcp-in -p tcp -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

printInfo 'REJECT all other incoming TCP traffic'
$IP6TABLES -A filter-${NIC}-tcp-in -j ${NIC}_tcp_reject

echo

#
# ******************************
# * filter-${NIC}-udp-in Rules *
# ******************************
#

## UDP Unicast
printInfo 'ACCEPT incoming HTTPS UDP response packets'
$IP6TABLES -A filter-${NIC}-udp-ucast-in -p udp -m udp --sport 443 -j ACCEPT

printInfo 'ACCEPT incoming DNS UDP response packets'
$IP6TABLES -A filter-${NIC}-udp-ucast-in -p udp -m udp --sport 53 -j ACCEPT

printInfo 'Allow incoming NTP UDP response packets'
$IP6TABLES -A filter-${NIC}-udp-ucast-in -p udp -m udp --sport 123 -j ACCEPT

printInfo 'REJECT all other incoming UDP UNICAST traffic'
$IP6TABLES -A filter-${NIC}-udp-ucast-in -j ${NIC}_icmp_reject

#printInfo 'Allow incoming Google Talk Voice and Video packets'
#$IP6TABLES -A filter-udp-in -p udp -m multiport --sports 19302,19305:19309 -j ACCEPT

#printInfo 'Allow incoming DHCPv6 UDP response packets'
#$IP6TABLES -A filter-udp-in -p udp -m udp --dport 546 -j ACCEPT

## UDP Multicast
#$IP6TABLES -N filter-udp-in-multicast
#$IP6TABLES -A filter-udp-in -p udp -m pkttype --pkt-type multicast -j filter-udp-in-multicast

#
# *********************************
# * filter-udp-in-multicast Rules *
# *********************************
#

#printInfo "Allow incoming mDNS UDP MULTICAST packets (from $IPv6_LOCAL_SUBNET)"
#$IP6TABLES -A filter-udp-in-multicast -s $IPv6_LOCAL_SUBNET -d $mDNSv6_ADDR -p udp -m udp --dport 5353 -j ACCEPT
#
#printInfo "Allow incoming mDNS UDP MULTICAST packets (from $IPv6_GLOBAL_SUBNET)"
#$IP6TABLES -A filter-udp-in-multicast -s $IPv6_GLOBAL_SUBNET -d $mDNSv6_ADDR -p udp -m udp --dport 5353 -j ACCEPT

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

# Create OUTPUT filter chains for each network interface
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

## lo
printInfo 'ACCEPT outgoing lo interface traffic'
$IP6TABLES -A OUTPUT -o lo -j ACCEPT

## NIC
printInfo "Process outgoing $NIC interface traffic"
$IP6TABLES -N filter-${NIC}-out
$IP6TABLES -A OUTPUT -o ${NIC} -j filter-${NIC}-out

printInfo 'ACCEPT all other outgoing interface traffic'
$IP6TABLES -A OUTPUT -j ACCEPT

echo

# Create OUTPUT filter chains for each protocol
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

printInfo "Process outgoing Link-Local packets on $NIC"
$IP6TABLES -N filter-${NIC}-local-out
$IP6TABLES -A filter-${NIC}-out -s $IPv6_SUBNET_LOCAL -j filter-${NIC}-local-out

## TCP
printInfo 'Process outgoing TCP traffic'
$IP6TABLES -N filter-${NIC}-tcp-out
$IP6TABLES -A filter-${NIC}-out -p tcp -j filter-${NIC}-tcp-out

## UDP
printInfo 'Process outgoing UDP traffic'
$IP6TABLES -N filter-${NIC}-udp-out
$IP6TABLES -A filter-${NIC}-out -p udp -j filter-${NIC}-udp-out

## ICMPv6
printInfo 'ACCEPT all outgoing ICMPv6 traffic'
$IP6TABLES -A filter-${NIC}-out -p icmpv6 -j ACCEPT

## ALL OTHERS
printInfo 'REJECT all other outgoing protocol traffic'
$IP6TABLES -A filter-${NIC}-out -j ${NIC}_icmp_reject

echo

#
# *********************************
# * filter-${NIC}-local-out Rules *
# *********************************
#

printInfo 'Perform outgoing Link-Local TCP traffic accounting'
$IP6TABLES -A filter-${NIC}-local-out -p tcp -j ACCEPT

printInfo 'Perform outgoing Link-Local UDP traffic accounting'
$IP6TABLES -A filter-${NIC}-local-out -p udp -j ACCEPT

printInfo 'Perform outgoing Link-Local ICMPv6 traffic accounting'
$IP6TABLES -A filter-${NIC}-local-out -p icmpv6 -j ACCEPT

printInfo 'Perform outgoing Link-Local OTHER traffic accounting'
$IP6TABLES -A filter-${NIC}-local-out -m limit --limit 3/min --limit-burst 2 -j LOG --log-prefix '[IPv6 INFO BLOCK] ' --log-level 7
$IP6TABLES -A filter-${NIC}-local-out -j ACCEPT

echo

#
# *******************************
# * filter-${NIC}-tcp-out Rules *
# *******************************
#

printInfo 'ACCEPT outgoing HTTP/HTTPS TCP request packets'
$IP6TABLES -A filter-${NIC}-tcp-out -p tcp -m tcp --dport 443 -j ACCEPT
$IP6TABLES -A filter-${NIC}-tcp-out -p tcp -m tcp --dport 80 -j ACCEPT

printInfo 'ACCEPT outgoing DNS TCP request packets'
$IP6TABLES -A filter-${NIC}-tcp-out -p tcp -m tcp --dport 53 -j ACCEPT

printInfo 'REJECT all other outgoing TCP traffic'
$IP6TABLES -A filter-${NIC}-tcp-out -j ${NIC}_tcp_reject

echo

#
# *******************************
# * filter-${NIC}-udp-out Rules *
# *******************************
#

printInfo 'ACCEPT outoging HTTPS UDP request packets'
$IP6TABLES -A filter-${NIC}-udp-out -p udp -m udp --dport 443 -j ACCEPT

printInfo 'ACCEPT outoging DNS UDP request packets'
$IP6TABLES -A filter-${NIC}-udp-out -p udp -m udp --dport 53 -j ACCEPT

printInfo 'ACCEPT outgoing NTP UDP request packets'
$IP6TABLES -A filter-${NIC}-udp-out -p udp -m udp --dport 123 -j ACCEPT

#printInfo 'Allow outgoing Google Talk Voice and Video packets'
#$IP6TABLES -A filter-udp-out -p udp -m multiport --dports 19302,19305:19309 -j ACCEPT

#printInfo 'Allow outgoing DHCPv6 UDP request packets'
#$IP6TABLES -A filter-udp-out -p udp -m udp --sport 546 --dport 547 -j ACCEPT

printInfo 'REJECT all other outgoing UDP traffic'
$IP6TABLES -A filter-${NIC}-udp-out -j ${NIC}_icmp_reject

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
