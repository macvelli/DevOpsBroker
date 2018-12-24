#!/bin/bash

#
# iptables-desktop.sh - DevOpsBroker IPv4 iptables firewall script
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
#   o All ICMP and IGMP filtering is done in the RAW table
#   o Valid ICMP, UDP, and IGMP traffic is set to NOTRACK
#   o All traffic on lo is set to NOTRACK
#   o Drop all incoming/outgoing Canon/Epson printer discovery packets
#   o Drop all incoming/outgoing INVALID packets
#   o Disable FORWARD
#   o Protocol-specific FILTER chains for TCP/UDP/ICMP/IGMP
#
# References:
#   o man iptables
#   o man iptables-extensions
#
# Notes:
#   o REJECT rules are not allowed in the RAW table
#
# Useful Linux Command-Line Utilities
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# o List rules currently configured:
# sudo firewall -4 list
# sudo firewall -4 list FILTER INPUT
#
# TODO: https://www.snort.org/ - filter packets for "alerts" or concerning traffic
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
SCRIPT_EXEC="${SCRIPT_INFO[1]}"

# Display error if not running as root
if [ "$USER" != 'root' ]; then
	printError "$SCRIPT_EXEC" 'Permission denied (you must be root)'
	exit 1
fi

################################## Variables ##################################

## Bash exec variables
IPTABLES=/sbin/iptables
IPTABLES_SAVE=/sbin/iptables-save

## Options
NIC="$1"

## Variables
IPv4_ADDRESS=''
IPv4_GATEWAY=''
IPv4_SUBNET=''
IPv4_SUBNET_IGMP='224.0.0.0/24'

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ OPTION Parsing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if [ -z "$NIC" ]; then
	mapfile -t ethList < <($EXEC_IP -br -4 addr show | $EXEC_GREP -E '^enp')

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
	IPv4_ADDRESS=${ethInfo[2]}
else
	# Display error if network interface parameter is invalid
	if [ ! -L /sys/class/net/$NIC ]; then
		printError "$SCRIPT_EXEC" "Cannot access '$NIC': No such network interface"
		echo
		printUsage "$SCRIPT_EXEC ${gold}[NIC]"

		exit 1
	fi

	IPv4_ADDRESS=$($EXEC_IP -br -4 address show dev $NIC | $EXEC_AWK '{ print $3; exit }')
fi

IPv4_GATEWAY=$($EXEC_IP -br -4 route show default | $EXEC_AWK '{ print $3; exit }')
IPv4_SUBNET=$(echo $IPv4_ADDRESS | $EXEC_SED -e 's/[0-9]+\//0\//')

################################### Actions ###################################

# Clear screen only if called from command line
if [ $SHLVL -eq 1 ]; then
	clear
fi

printBox "DevOpsBroker $UBUNTU_RELEASE iptables Configurator" 'true'

echo "${bold}Network Interface: ${green}$NIC"
echo "${white}IPv4 Address: ${green}$IPv4_ADDRESS"
echo "${white}IPv4 Gateway: ${green}$IPv4_GATEWAY"
echo "${white}IPv4 Subnet: ${green}$IPv4_SUBNET"
echo "${reset}"

#
# Set default policies / Flush rules / Delete user-defined chains
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
printInfo 'Initializing RAW Table'
$IPTABLES -t raw -P OUTPUT ACCEPT
$IPTABLES -t raw -F
$IPTABLES -t raw -X

printInfo 'Initializing MANGLE Table'
$IPTABLES -t mangle -P INPUT ACCEPT
$IPTABLES -t mangle -P FORWARD ACCEPT
$IPTABLES -t mangle -P OUTPUT ACCEPT
$IPTABLES -t mangle -F
$IPTABLES -t mangle -X

printInfo 'Initializing NAT Table'
$IPTABLES -t nat -P OUTPUT ACCEPT
$IPTABLES -t nat -F
$IPTABLES -t nat -X

printInfo 'Initializing FILTER Table'
$IPTABLES -t filter -P INPUT ACCEPT
$IPTABLES -t filter -P FORWARD ACCEPT
$IPTABLES -t filter -P OUTPUT ACCEPT
$IPTABLES -t filter -F
$IPTABLES -t filter -X

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
$IPTABLES -t raw -N ${NIC}_fragment_drop
$IPTABLES -t raw -A ${NIC}_fragment_drop -m limit --limit 3/min --limit-burst 2 -j LOG --log-prefix '[IPv4 FRAG BLOCK] ' --log-level 7
$IPTABLES -t raw -A ${NIC}_fragment_drop -j DROP

# Rate limit IGMP logging
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
$IPTABLES -t raw -N ${NIC}_igmp_drop
$IPTABLES -t raw -A ${NIC}_igmp_drop -m limit --limit 3/min --limit-burst 2 -j LOG --log-prefix '[IPv4 IGMP BLOCK] ' --log-level 7
$IPTABLES -t raw -A ${NIC}_igmp_drop -j DROP

# Perform NOTRACK and ACCEPT
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
$IPTABLES -t raw -N do_not_track
$IPTABLES -t raw -A do_not_track -j NOTRACK
$IPTABLES -t raw -A do_not_track -j ACCEPT

#
# ==================================
# = Configure RAW PREROUTING Chain =
# ==================================
#

printInfo 'DROP incoming fragmented packets'
$IPTABLES -t raw -A PREROUTING -f -j ${NIC}_fragment_drop

printInfo 'Allow incoming IPv4 Subnet packets on all network interfaces'
$IPTABLES -t raw -A PREROUTING -s $IPv4_SUBNET -j do_not_track
$IPTABLES -t raw -A PREROUTING -s $IPv4_SUBNET_IGMP -j do_not_track

# Create PREROUTING filter chains for each network interface
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

## lo
printInfo 'Allow incoming lo interface traffic'
$IPTABLES -t raw -A PREROUTING -i lo -j do_not_track

## NIC
printInfo "Process incoming $NIC interface traffic"
$IPTABLES -t raw -N raw-${NIC}-pre
$IPTABLES -t raw -A PREROUTING -i ${NIC} -j raw-${NIC}-pre

printInfo 'Allow all other incoming interface traffic'
$IPTABLES -t raw -A PREROUTING -j ACCEPT

echo

# Create PREROUTING filter chains for each protocol
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

## TCP
printInfo 'Process incoming TCP traffic'
$IPTABLES -t raw -N raw-${NIC}-tcp-pre
$IPTABLES -t raw -A raw-${NIC}-pre -p tcp -j raw-${NIC}-tcp-pre

## UDP
printInfo 'Process incoming UDP traffic'
$IPTABLES -t raw -N raw-${NIC}-udp-pre
$IPTABLES -t raw -A raw-${NIC}-pre -p udp -j raw-${NIC}-udp-pre

## ICMP
printInfo 'Process incoming ICMP traffic'
$IPTABLES -t raw -N raw-${NIC}-icmp-pre
$IPTABLES -t raw -A raw-${NIC}-pre -p icmp -j raw-${NIC}-icmp-pre

## IGMP
printInfo "DROP all incoming IGMP traffic not on $IPv4_SUBNET"
$IPTABLES -t raw -A raw-${NIC}-pre -j ${NIC}_igmp_drop

## ALL OTHERS
printInfo 'Further process all other incoming protocol traffic'
$IPTABLES -t raw -A raw-${NIC}-pre -j ACCEPT

echo

#
# *****************************
# * raw-${NIC}-icmp-pre Rules *
# *****************************
#

printInfo 'Allow ICMP destination-unreachable packets'
$IPTABLES -t raw -A raw-${NIC}-icmp-pre -p icmp -m icmp --icmp-type destination-unreachable -j do_not_track

printInfo 'Allow ICMP parameter-problem packets'
$IPTABLES -t raw -A raw-${NIC}-icmp-pre -p icmp -m icmp --icmp-type parameter-problem -j do_not_track

printInfo 'Allow ICMP echo-request packets'
$IPTABLES -t raw -A raw-${NIC}-icmp-pre -p icmp -m icmp --icmp-type echo-request -m limit --limit 2/s --limit-burst 1 -j do_not_track

printInfo 'Allow ICMP echo-reply packets'
$IPTABLES -t raw -A raw-${NIC}-icmp-pre -p icmp -m icmp --icmp-type echo-reply -j do_not_track

printInfo 'Allow ICMP time-exceeded packets'
$IPTABLES -t raw -A raw-${NIC}-icmp-pre -p icmp -m icmp --icmp-type time-exceeded -j do_not_track

printInfo 'DROP all other incoming ICMP traffic'
$IPTABLES -t raw -A raw-${NIC}-icmp-pre -m limit --limit 3/min --limit-burst 2 -j LOG --log-prefix '[IPv4 ICMP BLOCK] ' --log-level 7
$IPTABLES -t raw -A raw-${NIC}-icmp-pre -j DROP

echo

#
# ****************************
# * raw-${NIC}-tcp-pre Rules *
# ****************************
#

printInfo 'Do not track incoming HTTP/HTTPS TCP response packets'
$IPTABLES -t raw -A raw-${NIC}-tcp-pre -p tcp -m tcp --sport 443 -j do_not_track
$IPTABLES -t raw -A raw-${NIC}-tcp-pre -p tcp -m tcp --sport 80 -j do_not_track

printInfo 'Further process all other incoming TCP traffic'
$IPTABLES -t raw -A raw-${NIC}-tcp-pre -j ACCEPT

echo

#
# ****************************
# * raw-${NIC}-udp-pre Rules *
# ****************************
#

printInfo 'DROP all incoming DHCP request packets'
$IPTABLES -t raw -A raw-${NIC}-udp-pre -s 0.0.0.0 -d 255.255.255.255 -p udp -m udp --sport 68 --dport 67 -j DROP

printInfo 'DROP all incoming Canon/Epson printer discovery packets'
$IPTABLES -t raw -A raw-${NIC}-udp-pre -p udp -m multiport --dports 8610,8612,3289 -j DROP

printInfo 'Further process all other incoming UDP traffic'
$IPTABLES -t raw -A raw-${NIC}-udp-pre -j do_not_track

echo

#
# ==============================
# = Configure RAW OUTPUT Chain =
# ==============================
#

printInfo 'DROP outgoing fragmented packets'
$IPTABLES -t raw -A OUTPUT -f -j ${NIC}_fragment_drop

printInfo 'Allow outgoing IPv4 Subnet packets on all network interfaces'
$IPTABLES -t raw -A OUTPUT -d $IPv4_SUBNET -j do_not_track
$IPTABLES -t raw -A OUTPUT -d $IPv4_SUBNET_IGMP -j do_not_track

# Create PREROUTING filter chains for each network interface
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

## lo
printInfo 'Allow outgoing lo interface traffic'
$IPTABLES -t raw -A OUTPUT -o lo -j do_not_track

## NIC
printInfo "Process outgoing $NIC interface traffic"
$IPTABLES -t raw -N raw-${NIC}-out
$IPTABLES -t raw -A OUTPUT -o ${NIC} -j raw-${NIC}-out

printInfo 'ACCEPT all other outgoing interface traffic'
$IPTABLES -t raw -A OUTPUT -j ACCEPT

echo

# Create OUTPUT filter chains for each protocol
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

## TCP
printInfo 'Process outgoing TCP traffic'
$IPTABLES -t raw -N raw-${NIC}-tcp-out
$IPTABLES -t raw -A raw-${NIC}-out -p tcp -j raw-${NIC}-tcp-out

## UDP
printInfo 'Process outgoing UDP traffic'
$IPTABLES -t raw -N raw-${NIC}-udp-out
$IPTABLES -t raw -A raw-${NIC}-out -p udp -j raw-${NIC}-udp-out

## ICMP
printInfo 'Allow outgoing ICMP traffic'
$IPTABLES -t raw -A raw-${NIC}-out -p icmp -j do_not_track

## IGMP
printInfo "DROP all outgoing IGMP traffic not on $IPv4_SUBNET"
$IPTABLES -t raw -A raw-${NIC}-out -j ${NIC}_igmp_drop

## ALL OTHERS
printInfo 'DROP all other outgoing protocol traffic'
$IPTABLES -t raw -A raw-${NIC}-out -m limit --limit 3/min --limit-burst 2 -j LOG --log-prefix '[IPv4 OUTPUT BLOCK] ' --log-level 7
$IPTABLES -t raw -A raw-${NIC}-out -j DROP

echo

#
# ****************************
# * raw-${NIC}-tcp-out Rules *
# ****************************
#

printInfo 'Do not track outgoing HTTP/HTTPS TCP request packets'
$IPTABLES -t raw -A raw-${NIC}-tcp-out -p tcp -m tcp --dport 443 -j do_not_track
$IPTABLES -t raw -A raw-${NIC}-tcp-out -p tcp -m tcp --dport 80 -j do_not_track

printInfo 'Further process all other outgoing TCP traffic'
$IPTABLES -t raw -A raw-${NIC}-tcp-out -j ACCEPT

echo

#
# ****************************
# * raw-${NIC}-udp-out Rules *
# ****************************
#

printInfo 'DROP outgoing Canon/Epson printer discovery packets'
$IPTABLES -t raw -A raw-${NIC}-udp-out -p udp -m multiport --dports 8610,8612,3289 -j DROP

printInfo 'Further process all other outgoing UDP traffic'
$IPTABLES -t raw -A raw-${NIC}-udp-out -p udp -j do_not_track

echo

################################ MANGLE Table #################################

printBanner 'Configuring MANGLE Table'

#
# =====================================
# = Configure MANGLE PREROUTING Chain =
# =====================================
#

printInfo 'DROP all incoming INVALID packets'
$IPTABLES -t mangle -A PREROUTING -m conntrack --ctstate INVALID -j DROP

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
$IPTABLES -t mangle -P FORWARD DROP

#
# =================================
# = Configure MANGLE OUTPUT Chain =
# =================================
#

printInfo 'DROP all outgoing INVALID packets'
$IPTABLES -t mangle -A OUTPUT -m conntrack --ctstate INVALID -j DROP

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
$IPTABLES -N ${NIC}_icmp_reject
$IPTABLES -A ${NIC}_icmp_reject -m limit --limit 3/min --limit-burst 2 -j LOG --log-prefix '[IPv4 BLOCK] ' --log-level 7
$IPTABLES -A ${NIC}_icmp_reject -j REJECT --reject-with icmp-port-unreachable

# Rate limit TCP REJECT logging
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
$IPTABLES -N ${NIC}_tcp_reject
$IPTABLES -A ${NIC}_tcp_reject -m limit --limit 3/min --limit-burst 2 -j LOG --log-prefix '[IPv4 BLOCK] ' --log-level 7
$IPTABLES -A ${NIC}_tcp_reject -p tcp -j REJECT --reject-with tcp-reset

#
# ================================
# = Configure FILTER INPUT Chain =
# ================================
#

# Create INPUT filter chains for each network interface
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

## lo
printInfo 'ACCEPT incoming lo interface traffic'
$IPTABLES -A INPUT -i lo -j ACCEPT

## NIC
printInfo "Process incoming $NIC interface traffic"
$IPTABLES -N filter-${NIC}-in
$IPTABLES -A INPUT -i ${NIC} -j filter-${NIC}-in

printInfo 'ACCEPT all other incoming interface traffic'
$IPTABLES -A INPUT -j ACCEPT

echo

# Create INPUT filter chains for each protocol
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

printInfo "Process incoming IPv4 Subnet packets on $NIC"
$IPTABLES -N filter-${NIC}-local-in
$IPTABLES -A filter-${NIC}-in -s $IPv4_SUBNET -j filter-${NIC}-local-in
$IPTABLES -A filter-${NIC}-in -s $IPv4_SUBNET_IGMP -j filter-${NIC}-local-in

## TCP
printInfo 'Process incoming TCP traffic'
$IPTABLES -N filter-${NIC}-tcp-in
$IPTABLES -A filter-${NIC}-in -p tcp -j filter-${NIC}-tcp-in

## UDP
printInfo 'Process incoming UDP traffic'
$IPTABLES -N filter-${NIC}-udp-mcast-in
$IPTABLES -A filter-${NIC}-in -p udp -m pkttype --pkt-type multicast -j filter-${NIC}-udp-mcast-in

$IPTABLES -N filter-${NIC}-udp-bcast-in
$IPTABLES -A filter-${NIC}-in -p udp -m pkttype --pkt-type broadcast -j filter-${NIC}-udp-bcast-in

$IPTABLES -N filter-${NIC}-udp-ucast-in
$IPTABLES -A filter-${NIC}-in -p udp -m pkttype --pkt-type unicast -j filter-${NIC}-udp-ucast-in

## ICMP
printInfo 'ACCEPT all incoming ICMP traffic not dropped in RAW table'
$IPTABLES -A filter-${NIC}-in -p icmp -j ACCEPT

## ALL OTHERS
printInfo 'REJECT all other incoming protocol traffic'
$IPTABLES -A filter-${NIC}-in -j ${NIC}_icmp_reject

echo

#
# ********************************
# * filter-${NIC}-local-in Rules *
# ********************************
#

printInfo 'Perform incoming IPv4 Subnet TCP traffic accounting'
$IPTABLES -A filter-${NIC}-local-in -p tcp -j ACCEPT

printInfo 'Perform incoming IPv4 Subnet UDP traffic accounting'
$IPTABLES -A filter-${NIC}-local-in -p udp -j ACCEPT

printInfo 'Perform incoming IPv4 Subnet IGMP traffic accounting'
$IPTABLES -A filter-${NIC}-local-in -p igmp -j ACCEPT

printInfo 'Perform incoming IPv4 Subnet ICMP traffic accounting'
$IPTABLES -A filter-${NIC}-local-in -p icmp -j ACCEPT

printInfo 'Perform incoming IPv4 Subnet OTHER traffic accounting'
$IPTABLES -A filter-${NIC}-local-in -m limit --limit 3/min --limit-burst 2 -j LOG --log-prefix '[IPv4 INFO BLOCK] ' --log-level 7
$IPTABLES -A filter-${NIC}-local-in -j ACCEPT

echo

#
# ******************************
# * filter-${NIC}-tcp-in Rules *
# ******************************
#

printInfo 'ACCEPT incoming HTTP/HTTPS TCP response packets'
$IPTABLES -A filter-${NIC}-tcp-in -p tcp -m tcp --sport 443 -j ACCEPT
$IPTABLES -A filter-${NIC}-tcp-in -p tcp -m tcp --sport 80 -j ACCEPT

printInfo 'ACCEPT Established TCP Sessions'
$IPTABLES -A filter-${NIC}-tcp-in -p tcp -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

printInfo 'REJECT all other incoming TCP traffic'
$IPTABLES -A filter-${NIC}-tcp-in -j ${NIC}_tcp_reject

echo

#
# ******************************
# * filter-${NIC}-udp-in Rules *
# ******************************
#

## UDP Multicast
printInfo "REJECT all incoming UDP MULTICAST traffic not on $IPv4_SUBNET"
$IPTABLES -A filter-${NIC}-udp-mcast-in -j ${NIC}_icmp_reject

echo

## UDP Broadcast
printInfo "REJECT all incoming UDP BROADCAST traffic not on $IPv4_SUBNET"
$IPTABLES -A filter-${NIC}-udp-bcast-in -j ${NIC}_icmp_reject

echo

## UDP Unicast
printInfo 'ACCEPT incoming DNS UDP response packets'
$IPTABLES -A filter-${NIC}-udp-ucast-in -p udp -m udp --sport 53 -j ACCEPT

printInfo 'ACCEPT incoming NTP UDP response packets'
$IPTABLES -A filter-${NIC}-udp-ucast-in -p udp -m udp --sport 123 -j ACCEPT

printInfo 'ACCEPT incoming Google Talk Voice and Video UDP packets'
$IPTABLES -A filter-${NIC}-udp-ucast-in -p udp -m multiport --sports 19302,19305:19309 -j ACCEPT

printInfo 'REJECT all other incoming UDP UNICAST traffic'
$IPTABLES -A filter-${NIC}-udp-ucast-in -j ${NIC}_icmp_reject

echo

#
# ==================================
# = Configure FILTER FORWARD Chain =
# ==================================
#

printInfo 'Set default FORWARD policy to DROP'
$IPTABLES -P FORWARD DROP

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
$IPTABLES -A OUTPUT -o lo -j ACCEPT

## NIC
printInfo "Process outgoing $NIC interface traffic"
$IPTABLES -N filter-${NIC}-out
$IPTABLES -A OUTPUT -o ${NIC} -j filter-${NIC}-out

printInfo 'ACCEPT all other outgoing interface traffic'
$IPTABLES -A OUTPUT -j ACCEPT

echo

# Create OUTPUT filter chains for each protocol
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

printInfo "Process outgoing IPv4 Subnet packets on $NIC"
$IPTABLES -N filter-${NIC}-local-out
$IPTABLES -A filter-${NIC}-out -d $IPv4_SUBNET -j filter-${NIC}-local-out
$IPTABLES -A filter-${NIC}-out -d $IPv4_SUBNET_IGMP -j filter-${NIC}-local-out

## TCP
printInfo 'Process outgoing TCP traffic'
$IPTABLES -N filter-${NIC}-tcp-out
$IPTABLES -A filter-${NIC}-out -p tcp -j filter-${NIC}-tcp-out

## UDP
printInfo 'Process outgoing UDP traffic'
$IPTABLES -N filter-${NIC}-udp-out
$IPTABLES -A filter-${NIC}-out -p udp -j filter-${NIC}-udp-out

## ICMP
printInfo 'ACCEPT all outgoing ICMP traffic'
$IPTABLES -A filter-${NIC}-out -p icmp -j ACCEPT

## ALL OTHERS
printInfo 'REJECT all other outgoing protocol traffic'
$IPTABLES -A filter-${NIC}-out -j ${NIC}_icmp_reject

echo

#
# *********************************
# * filter-${NIC}-local-out Rules *
# *********************************
#

printInfo 'Perform outgoing IPv4 Subnet TCP traffic accounting'
$IPTABLES -A filter-${NIC}-local-out -p tcp -j ACCEPT

printInfo 'Perform outgoing IPv4 Subnet UDP traffic accounting'
$IPTABLES -A filter-${NIC}-local-out -p udp -j ACCEPT

printInfo 'Perform outgoing IPv4 Subnet IGMP traffic accounting'
$IPTABLES -A filter-${NIC}-local-out -p igmp -j ACCEPT

printInfo 'Perform outgoing IPv4 Subnet ICMP traffic accounting'
$IPTABLES -A filter-${NIC}-local-out -p icmp -j ACCEPT

printInfo 'Perform outgoing IPv4 Subnet OTHER traffic accounting'
$IPTABLES -A filter-${NIC}-local-out -m limit --limit 3/min --limit-burst 2 -j LOG --log-prefix '[IPv6 INFO BLOCK] ' --log-level 7
$IPTABLES -A filter-${NIC}-local-out -j ACCEPT

echo

#
# *******************************
# * filter-${NIC}-tcp-out Rules *
# *******************************
#

printInfo "REJECT outgoing SMB/NetBIOS TCP request packets not on $IPv4_SUBNET"
$IPTABLES -A filter-${NIC}-tcp-out -p tcp -m multiport --dports 139,445 ! -d $IPv4_SUBNET -j ${NIC}_tcp_reject

printInfo 'ACCEPT all other outgoing TCP traffic'
$IPTABLES -A filter-${NIC}-tcp-out -j ACCEPT

echo

#
# *******************************
# * filter-${NIC}-udp-out Rules *
# *******************************
#

printInfo "REJECT outgoing NetBIOS UDP request packets not on $IPv4_SUBNET"
$IPTABLES -A filter-${NIC}-udp-out -p udp -m multiport --dports 137,138 ! -d $IPv4_SUBNET -j ${NIC}_icmp_reject

printInfo 'ACCEPT all other outgoing UDP traffic'
$IPTABLES -A filter-${NIC}-udp-out -j ACCEPT

echo

################################ IPTABLES-SAVE ################################

printInfo 'Persisting iptables Rules'

# Backup existing /etc/network/iptables.rules
if [ -f /etc/network/iptables.rules ]; then
	$EXEC_CP /etc/network/iptables.rules /etc/network/iptables.rules.bak
fi

# Save /etc/network/iptables.rules
$IPTABLES_SAVE > /etc/network/iptables.rules

echo

exit 0
