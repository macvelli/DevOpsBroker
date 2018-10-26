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
SCRIPT_EXEC=$( $EXEC_BASENAME "$BASH_SOURCE" )

# Display error if not running as root
if [ "$USER" != 'root' ]; then
	printError "$SCRIPT_EXEC" 'Permission denied (you must be root)'
	exit 1
fi

################################## Variables ##################################

IPTABLES=/sbin/iptables
IPTABLES_SAVE=/sbin/iptables-save

################################### Actions ###################################

# Clear screen only if called from command line
if [ $SHLVL -eq 1 ]; then
	clear
fi

printBox "DevOpsBroker $UBUNTU_RELEASE iptables Configurator" 'true'

#
# Gather IPv4 Gateway information
#
mapfile -t ipv4RouteList < <($EXEC_IP -4 route show)

for ipv4Route in "${ipv4RouteList[@]}"; do
	# Process IPv4 routes
	if [[ "$ipv4Route" =~ ^default ]]; then
		defaultRoute=( $ipv4Route )

		IPv4_DEFAULT_GATEWAY=${defaultRoute[2]}
		NIC=${defaultRoute[4]}
	elif [[ "$ipv4Route" == *'proto kernel'* ]]; then
		kernelRoute=( $ipv4Route )

		IPv4_SUBNET=${kernelRoute[0]}
	fi
done

#
# Gather IPv4 Address information
#
mapfile -t ipv4AddrList < <($EXEC_IP -4 address show dev $NIC)

for ipv4Address in "${ipv4AddrList[@]}"; do
	# Process IPv6 addresses
	if [[ "$ipv4Address" == *'scope global'* ]]; then
		addressLine=( $ipv4Address )

		IPv4_ADDR=${addressLine[1]}
	fi
done

echo "${bold}Network Interface: ${green}$NIC"
echo "${white}IPv4 Address: ${green}$IPv4_ADDR"
echo "${white}IPv4 Subnet: ${green}$IPv4_SUBNET"
echo "${white}IPv4 Default Gateway: ${green}$IPv4_DEFAULT_GATEWAY${reset}"
echo

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
$IPTABLES -t raw -N fragment_drop
$IPTABLES -t raw -A fragment_drop -m limit --limit 3/min --limit-burst 2 -j LOG --log-prefix '[IPv4 FRAG BLOCK] ' --log-level 7
$IPTABLES -t raw -A fragment_drop -j DROP

# Rate limit Localhost logging
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
$IPTABLES -t raw -N localhost_drop
$IPTABLES -t raw -A localhost_drop -m limit --limit 3/min --limit-burst 2 -j LOG --log-prefix '[LOCALHOST BLOCK] ' --log-level 7
$IPTABLES -t raw -A localhost_drop -j DROP

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

printInfo 'NOTRACK incoming lo interface traffic'
$IPTABLES -t raw -A PREROUTING -i lo -j do_not_track

printInfo 'DROP incoming fragmented packets'
$IPTABLES -t raw -A PREROUTING -f -j fragment_drop

printInfo 'Drop 127.0.0.0/8 destination packets not on lo'
$IPTABLES -t raw -A PREROUTING ! -i lo -d 127.0.0.0/8 -j localhost_drop

# Create PREROUTING filter chains for each protocol
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

## TCP
$IPTABLES -t raw -N raw-tcp-pre
$IPTABLES -t raw -A PREROUTING -p tcp -j raw-tcp-pre

## UDP
$IPTABLES -t raw -N raw-udp-pre
$IPTABLES -t raw -A PREROUTING -p udp -j raw-udp-pre

## IGMP
$IPTABLES -t raw -N raw-igmp-pre
$IPTABLES -t raw -A PREROUTING -p igmp -j raw-igmp-pre

## ICMP
$IPTABLES -t raw -N raw-icmp-pre
$IPTABLES -t raw -A PREROUTING -p icmp -j raw-icmp-pre

## ALL OTHERS
$IPTABLES -t raw -A PREROUTING -j ACCEPT

echo

#
# **********************
# * raw-icmp-pre Rules *
# **********************
#

printInfo 'Allow ICMP destination-unreachable'
$IPTABLES -t raw -A raw-icmp-pre -p icmp -m icmp --icmp-type destination-unreachable -j do_not_track

printInfo 'Allow ICMP parameter-problem'
$IPTABLES -t raw -A raw-icmp-pre -p icmp -m icmp --icmp-type parameter-problem -j do_not_track

printInfo 'Allow ICMP echo-request'
$IPTABLES -t raw -A raw-icmp-pre -p icmp -m icmp --icmp-type echo-request -m limit --limit 2/s --limit-burst 1 -j do_not_track

printInfo 'Allow ICMP echo-reply'
$IPTABLES -t raw -A raw-icmp-pre -p icmp -m icmp --icmp-type echo-reply -j do_not_track

printInfo 'Allow ICMP time-exceeded'
$IPTABLES -t raw -A raw-icmp-pre -p icmp -m icmp --icmp-type time-exceeded -j do_not_track

printInfo 'DROP all other ICMP INPUT'
$IPTABLES -t raw -A raw-icmp-pre -m limit --limit 3/min --limit-burst 2 -j LOG --log-prefix '[IPv4 ICMP BLOCK] ' --log-level 7
$IPTABLES -t raw -A raw-icmp-pre -j DROP

echo

#
# **********************
# * raw-igmp-pre Rules *
# **********************
#

printInfo 'Allow incoming mDNS IGMP MULTICAST packets'
$IPTABLES -t raw -A raw-igmp-pre -s $IPv4_SUBNET -d 224.0.0.251/32 -p igmp -m pkttype --pkt-type multicast -j do_not_track

printInfo 'Allow incoming Link-local Multicast Name Resolution IGMP MULTICAST packets'
$IPTABLES -t raw -A raw-igmp-pre -s $IPv4_SUBNET -d 224.0.0.252/32 -p igmp -m pkttype --pkt-type multicast -j do_not_track

printInfo 'Allow incoming all-hosts IGMP MULTICAST packets'
$IPTABLES -t raw -A raw-igmp-pre -s $IPv4_SUBNET -d 224.0.0.1/32 -p igmp -m pkttype --pkt-type multicast -j do_not_track

printInfo 'DROP all other IGMP INPUT'
$IPTABLES -t raw -A raw-igmp-pre -m limit --limit 3/min --limit-burst 2 -j LOG --log-prefix '[IPv4 IGMP BLOCK] ' --log-level 7
$IPTABLES -t raw -A raw-igmp-pre -j DROP

echo

#
# **********************
# * raw-tcp-pre Rules *
# **********************
#

printInfo 'NOTRACK incoming HTTP/HTTPS TCP response packets'
$IPTABLES -t raw -A raw-tcp-pre -p tcp -m tcp --sport 443 -j do_not_track
$IPTABLES -t raw -A raw-tcp-pre -p tcp -m tcp --sport 80 -j do_not_track

printInfo 'NOTRACK incoming SMB TCP response packets'
$IPTABLES -t raw -A raw-tcp-pre -p tcp -m tcp --sport 445 -j do_not_track

printInfo 'ACCEPT all other TCP input'
$IPTABLES -t raw -A raw-tcp-pre -j ACCEPT

echo

#
# *********************
# * raw-udp-pre Rules *
# *********************
#

printInfo 'Drop all DHCP request packets'
$IPTABLES -t raw -A raw-udp-pre -s 0.0.0.0 -d 255.255.255.255 -p udp -m udp --sport 68 --dport 67 -j DROP

printInfo 'Drop incoming Canon/Epson printer discovery packets'
$IPTABLES -t raw -A raw-udp-pre -p udp -m multiport --dports 8610,8612,3289 -j DROP

printInfo 'NOTRACK incoming UDP packets'
$IPTABLES -t raw -A raw-udp-pre -j do_not_track

echo

#
# ==============================
# = Configure RAW OUTPUT Chain =
# ==============================
#

printInfo 'NOTRACK outgoing lo interface traffic'
$IPTABLES -t raw -A OUTPUT -o lo -j do_not_track

printInfo 'DROP outgoing fragmented packets'
$IPTABLES -t raw -A OUTPUT -f -j fragment_drop

# Create OUTPUT filter chains for each protocol
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

## TCP
$IPTABLES -t raw -N raw-tcp-out
$IPTABLES -t raw -A OUTPUT -p tcp -j raw-tcp-out

## UDP
$IPTABLES -t raw -N raw-udp-out
$IPTABLES -t raw -A OUTPUT -p udp -j raw-udp-out

## IGMP
printInfo 'NOTRACK outgoing IPv4 IGMP packets'
$IPTABLES -t raw -A OUTPUT -p igmp -j do_not_track

## ICMP
printInfo 'NOTRACK outgoing IPv4 ICMP packets'
$IPTABLES -t raw -A OUTPUT -p icmp -j do_not_track

## ALL OTHERS
$IPTABLES -t raw -A OUTPUT -j ACCEPT

echo

#
# *********************
# * raw-tcp-out Rules *
# *********************
#

printInfo 'NOTRACK outgoing HTTP/HTTPS TCP request packets'
$IPTABLES -t raw -A raw-tcp-out -p tcp -m tcp --dport 443 -j do_not_track
$IPTABLES -t raw -A raw-tcp-out -p tcp -m tcp --dport 80 -j do_not_track

printInfo 'NOTRACK outgoing SMB TCP request packets'
$IPTABLES -t raw -A raw-tcp-out -p tcp -m tcp --dport 445 -j do_not_track

printInfo 'ACCEPT all other TCP output'
$IPTABLES -t raw -A raw-tcp-out -j ACCEPT

echo

#
# *********************
# * raw-udp-out Rules *
# *********************
#

printInfo 'Drop outgoing Canon/Epson printer discovery packets'
$IPTABLES -t raw -A raw-udp-out -p udp -m multiport --dports 8610,8612,3289 -j DROP

printInfo 'NOTRACK outgoing UDP packets'
$IPTABLES -t raw -A raw-udp-out -p udp -j do_not_track

echo

################################ MANGLE Table #################################

printBanner 'Configuring MANGLE Table'

#
# =====================================
# = Configure MANGLE PREROUTING Chain =
# =====================================
#

printInfo 'Drop all incoming INVALID packets'
$IPTABLES -t mangle -A PREROUTING -m conntrack --ctstate INVALID -j DROP

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
$IPTABLES -t mangle -A OUTPUT -m conntrack --ctstate INVALID -j DROP

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
$IPTABLES -N in_deny
$IPTABLES -A in_deny -m limit --limit 3/min --limit-burst 2 -j LOG --log-prefix '[IPv4 INPUT BLOCK] ' --log-level 7
$IPTABLES -A in_deny -j REJECT --reject-with icmp-port-unreachable

# Rate limit OUTPUT Deny logging
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
$IPTABLES -N out_deny
$IPTABLES -A out_deny -m limit --limit 3/min --limit-burst 2 -j LOG --log-prefix '[IPv4 OUTPUT BLOCK] ' --log-level 7
$IPTABLES -A out_deny -j REJECT --reject-with icmp-port-unreachable

# Rate limit TCP REJECT logging
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
$IPTABLES -N tcp_reject
$IPTABLES -A tcp_reject -m limit --limit 3/min --limit-burst 2 -j LOG --log-prefix '[IPv4 TCP BLOCK] ' --log-level 7
$IPTABLES -A tcp_reject -p tcp -j REJECT --reject-with tcp-reset

#
# ================================
# = Configure FILTER INPUT Chain =
# ================================
#

printInfo 'Allow Loopback interface INPUT'
$IPTABLES -A INPUT -i lo -j ACCEPT

echo

# Create INPUT filter chains for each protocol
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

## TCP
$IPTABLES -N filter-tcp-in
$IPTABLES -A INPUT -p tcp -j filter-tcp-in

## UDP
$IPTABLES -N filter-udp-in
$IPTABLES -A INPUT -p udp -j filter-udp-in

## IGMP (Filtering done in RAW table so ACCEPT here)
$IPTABLES -A INPUT -p igmp -j ACCEPT

## ICMP (Filtering done in RAW table so ACCEPT here)
$IPTABLES -A INPUT -p icmp -j ACCEPT

## ALL OTHERS
$IPTABLES -A INPUT -j in_deny

#
# ***********************
# * filter-tcp-in Rules *
# ***********************
#

printInfo 'Allow incoming HTTP/HTTPS TCP response packets'
$IPTABLES -A filter-tcp-in -p tcp -m tcp --sport 443 -j ACCEPT
$IPTABLES -A filter-tcp-in -p tcp -m tcp --sport 80 -j ACCEPT

printInfo 'Allow incoming SMB TCP response packets'
$IPTABLES -A filter-tcp-in -p tcp -m tcp --sport 445 -s $IPv4_SUBNET -j ACCEPT

printInfo 'Allow Established TCP Sessions'
$IPTABLES -A filter-tcp-in -p tcp -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

printInfo 'REJECT all other TCP input'
$IPTABLES -A filter-tcp-in -j tcp_reject

echo

#
# ***********************
# * filter-udp-in Rules *
# ***********************
#

## UDP Multicast
$IPTABLES -N filter-udp-in-mcast
$IPTABLES -A filter-udp-in -p udp -m pkttype --pkt-type multicast -j filter-udp-in-mcast

## UDP Broadcast
$IPTABLES -N filter-udp-in-bcast
$IPTABLES -A filter-udp-in -p udp -m pkttype --pkt-type broadcast -j filter-udp-in-bcast

printInfo 'Allow incoming DNS UDP packets'
$IPTABLES -A filter-udp-in -p udp -m udp --sport 53 -j ACCEPT

printInfo 'Allow incoming Google Talk Voice and Video packets'
$IPTABLES -A filter-udp-in -p udp -m multiport --sports 19302,19305:19309 -j ACCEPT

printInfo 'Allow incoming mDNS UDP UNICAST packets'
$IPTABLES -A filter-udp-in -s $IPv4_SUBNET -p udp -m udp --sport 5353 -j ACCEPT

printInfo 'Allow incoming NTP UDP packets'
$IPTABLES -A filter-udp-in -p udp -m udp --sport 123 -j ACCEPT

printInfo "Allow incoming DHCP UDP packets from $IPv4_DEFAULT_GATEWAY"
$IPTABLES -A filter-udp-in -s $IPv4_DEFAULT_GATEWAY -d $IPv4_SUBNET -p udp -m udp --sport 67 --dport 68 -j ACCEPT

printInfo 'Allow incoming SNMP UDP packets'
$IPTABLES -A filter-udp-in -p udp -m udp --sport 161 -j ACCEPT

printInfo 'REJECT all other UDP INPUT'
$IPTABLES -A filter-udp-in -j in_deny

echo

#
# *****************************
# * filter-udp-in-bcast Rules *
# *****************************
#

printInfo 'Allow incoming uPnP UDP BROADCAST packets'
$IPTABLES -A filter-udp-in-bcast -s $IPv4_SUBNET -d 255.255.255.255/32 -p udp -m udp --dport 1900 -j ACCEPT

printInfo 'Allow incoming WS-Discovery UDP BROADCAST packets'
$IPTABLES -A filter-udp-in-bcast -s $IPv4_SUBNET -p udp -m udp --dport 1124 -j ACCEPT

printInfo 'Allow incoming DHCP UDP BROADCAST packets'
$IPTABLES -A filter-udp-in-bcast -s $IPv4_SUBNET -p udp -m udp --sport 67 --dport 68 -j ACCEPT

printInfo 'Allow incoming SNMP UDP BROADCAST packets'
$IPTABLES -A filter-udp-in-bcast -s $IPv4_SUBNET -p udp -m udp --dport 161 -j ACCEPT

printInfo 'REJECT all other UDP BROADCAST INPUT'
$IPTABLES -A filter-udp-in-bcast -j in_deny

echo

#
# *****************************
# * filter-udp-in-mcast Rules *
# *****************************
#

printInfo 'Allow incoming mDNS UDP MULTICAST packets'
$IPTABLES -A filter-udp-in-mcast -s $IPv4_SUBNET -d 224.0.0.251/32 -p udp -m udp --dport 5353 -j ACCEPT

printInfo 'Allow incoming all-hosts UDP MULTICAST packets'
$IPTABLES -A filter-udp-in-mcast -s $IPv4_SUBNET -d 224.0.0.1/32 -p udp -j ACCEPT

printInfo 'Allow incoming uPnP UDP MULTICAST packets'
$IPTABLES -A filter-udp-in-mcast -s $IPv4_SUBNET -d 239.255.255.250/32 -p udp -m udp --dport 1900 -j ACCEPT

printInfo 'REJECT all other UDP MULTICAST INPUT'
$IPTABLES -A filter-udp-in-mcast -j in_deny

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

printInfo 'Allow Loopback interface OUTPUT'
$IPTABLES -A OUTPUT -o lo -j ACCEPT

echo

# Create OUTPUT filter chains for each protocol
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

## TCP
$IPTABLES -N filter-tcp-out
$IPTABLES -A OUTPUT -p tcp -j filter-tcp-out

## UDP
$IPTABLES -N filter-udp-out
$IPTABLES -A OUTPUT -p udp -j filter-udp-out

## ALL OTHERS
$IPTABLES -A OUTPUT -j ACCEPT

#
# ************************
# * filter-tcp-out Rules *
# ************************
#

printInfo "Deny outgoing SMB/NetBIOS TCP request packets not on $IPv4_SUBNET"
$IPTABLES -A filter-tcp-out -p tcp -m multiport --dports 139,445 ! -d $IPv4_SUBNET -j tcp_reject

printInfo 'ACCEPT all other TCP output'
$IPTABLES -A filter-tcp-out -j ACCEPT

#
# ************************
# * filter-udp-out Rules *
# ************************
#

printInfo "Deny outgoing NetBIOS UDP request packets not on $IPv4_SUBNET"
$IPTABLES -A filter-udp-out -p udp -m multiport --dports 137,138 ! -d $IPv4_SUBNET -j out_deny

printInfo 'ACCEPT all other UDP output'
$IPTABLES -A filter-udp-out -j ACCEPT

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
