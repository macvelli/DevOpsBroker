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

## Script information
SCRIPT_EXEC=$( $EXEC_BASENAME "$BASH_SOURCE" )

# Display error if not running as root
if [ "$EUID" -ne 0 ]; then
  echo "${bold}$SCRIPT_EXEC: ${bittersweet}Permission denied (you must be root)${reset}"

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

bannerMsg='DevOpsBroker Ubuntu 16.04 Desktop iptables Configurator'

echo ${bold} ${wisteria}
echo '╔═════════════════════════════════════════════════════════╗'
echo "║ ${white}$bannerMsg${wisteria}"			       '║'
echo '╚═════════════════════════════════════════════════════════╝'
echo ${reset}

#
# Gather IPv4 Gateway information
#
IFS="$newline"; ipv4RouteList=( $($EXEC_IP -4 route show) ); unset IFS;

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
IFS="$newline"; ipv4AddrList=( $($EXEC_IP -4 address show dev $NIC) ); unset IFS;

for ipv4Address in "${ipv4AddrList[@]}"; do
  # Process IPv6 addresses
  if [[ "$ipv4Address" == *'scope global'* ]]; then
    addressLine=( $ipv4Address )

    IPv4_ADDR=${addressLine[1]}
  fi
done

echo "${bold}Network Interface: ${pastelGreen}$NIC"
echo "${white}IPv4 Address: ${pastelGreen}$IPv4_ADDR"
echo "${white}IPv4 Subnet: ${pastelGreen}$IPv4_SUBNET"
echo "${white}IPv4 Default Gateway: ${pastelGreen}$IPv4_DEFAULT_GATEWAY${reset}"
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
$IPTABLES -t raw -A fragment_drop -m limit --limit 3/min --limit-burst 10 -j LOG --log-prefix '[IPv4 FRAG BLOCK] ' --log-level 7
$IPTABLES -t raw -A fragment_drop -j DROP

# Rate limit Localhost logging
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
$IPTABLES -t raw -N localhost_drop
$IPTABLES -t raw -A localhost_drop -m limit --limit 3/min --limit-burst 10 -j LOG --log-prefix '[LOCALHOST BLOCK] ' --log-level 7
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

# Create PREROUTING filter chains for ICMP and UDP
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

printInfo 'Drop fragmented incoming packets'
$IPTABLES -t raw -A PREROUTING -f -j fragment_drop

printInfo 'Drop 127.0.0.0/8 destination packets not on lo'
$IPTABLES -t raw -A PREROUTING ! -i lo -d 127.0.0.0/8 -j localhost_drop

printInfo 'Do not track incoming IPv4 Loopback interface traffic in the conntrack table'
$IPTABLES -t raw -A PREROUTING -i lo -j do_not_track

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
$IPTABLES -t raw -A raw-icmp-pre -m limit --limit 3/min --limit-burst 10 -j LOG --log-prefix '[IPv4 ICMP BLOCK] ' --log-level 7
$IPTABLES -t raw -A raw-icmp-pre -j DROP

echo

#
# **********************
# * raw-igmp-pre Rules *
# **********************
#

printInfo 'Allow mDNS IGMP MULTICAST incoming packets'
$IPTABLES -t raw -A raw-igmp-pre -s $IPv4_SUBNET -d 224.0.0.251/32 -p igmp -m pkttype --pkt-type multicast -j do_not_track

printInfo 'Allow Link-local Multicast Name Resolution IGMP MULTICAST incoming packets'
$IPTABLES -t raw -A raw-igmp-pre -s $IPv4_SUBNET -d 224.0.0.252/32 -p igmp -m pkttype --pkt-type multicast -j do_not_track

printInfo 'Allow all-hosts IGMP MULTICAST incoming packets'
$IPTABLES -t raw -A raw-igmp-pre -s $IPv4_SUBNET -d 224.0.0.1/32 -p igmp -m pkttype --pkt-type multicast -j do_not_track

printInfo 'DROP all other IGMP INPUT'
$IPTABLES -t raw -A raw-igmp-pre -m limit --limit 3/min --limit-burst 10 -j LOG --log-prefix '[IPv4 IGMP BLOCK] ' --log-level 7
$IPTABLES -t raw -A raw-igmp-pre -j DROP

echo

#
# **********************
# * raw-tcp-pre Rules *
# **********************
#

printInfo 'Do not track incoming HTTP/HTTPS TCP packets in the conntrack table'
$IPTABLES -t raw -A raw-tcp-pre -p tcp -m tcp --sport 443 -j do_not_track
$IPTABLES -t raw -A raw-tcp-pre -p tcp -m tcp --sport 80 -j do_not_track

printInfo 'Do not track incoming SMB TCP packets in the conntrack table'
$IPTABLES -t raw -A raw-tcp-pre -p tcp -m tcp --sport 445 -j do_not_track

printInfo 'ACCEPT all other TCP input'
$IPTABLES -t raw -A raw-tcp-pre -j ACCEPT

echo

#
# *********************
# * raw-udp-pre Rules *
# *********************
#

printInfo 'Drop incoming netbios-ns/netbios-dgm packets'
$IPTABLES -t raw -A raw-udp-pre -p udp -m multiport --dports 137,138 -j DROP

printInfo 'Drop all DHCP request packets'
$IPTABLES -t raw -A raw-udp-pre -s 0.0.0.0 -d 255.255.255.255 -p udp -m udp --sport 68 --dport 67 -j DROP

printInfo 'Drop incoming Canon/Epson printer discovery packets'
$IPTABLES -t raw -A raw-udp-pre -p udp -m multiport --dports 8610,8612,3289 -j DROP

printInfo 'Do not track incoming IPv4 UDP packets in the conntrack table'
$IPTABLES -t raw -A raw-udp-pre -j do_not_track

echo

#
# ==============================
# = Configure RAW OUTPUT Chain =
# ==============================
#

printInfo 'Drop fragmented outgoing packets'
$IPTABLES -t raw -A OUTPUT -f -j fragment_drop

printInfo 'Do not track outgoing IPv4 Loopback interface traffic in the conntrack table'
$IPTABLES -t raw -A OUTPUT -o lo -j do_not_track

# Create OUTPUT filter chains for each protocol
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

## TCP
$IPTABLES -t raw -N raw-tcp-out
$IPTABLES -t raw -A OUTPUT -p tcp -j raw-tcp-out

## UDP
$IPTABLES -t raw -N raw-udp-out
$IPTABLES -t raw -A OUTPUT -p udp -j raw-udp-out

## IGMP
printInfo 'Do not track outgoing IPv4 IGMP packets in the conntrack table'
$IPTABLES -t raw -A OUTPUT -p igmp -j do_not_track

## ICMP
printInfo 'Do not track outgoing IPv4 ICMP packets in the conntrack table'
$IPTABLES -t raw -A OUTPUT -p icmp -j do_not_track

## ALL OTHERS
$IPTABLES -t raw -A OUTPUT -j ACCEPT

echo

#
# *********************
# * raw-tcp-out Rules *
# *********************
#

printInfo 'Do not track outgoing HTTP/HTTPS TCP packets in the conntrack table'
$IPTABLES -t raw -A raw-tcp-out -p tcp -m tcp --dport 443 -j do_not_track
$IPTABLES -t raw -A raw-tcp-out -p tcp -m tcp --dport 80 -j do_not_track

printInfo 'Do not track outgoing SMB TCP packets in the conntrack table'
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

printInfo 'Do not track outgoing IPv4 UDP packets in the conntrack table'
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
$IPTABLES -A in_deny -m limit --limit 3/min --limit-burst 10 -j LOG --log-prefix '[IPv4 INPUT BLOCK] ' --log-level 7
$IPTABLES -A in_deny -j REJECT --reject-with icmp-port-unreachable

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

printInfo 'Allow HTTP/HTTPS TCP incoming packets'
$IPTABLES -A filter-tcp-in -p tcp -m tcp --sport 443 -j ACCEPT
$IPTABLES -A filter-tcp-in -p tcp -m tcp --sport 80 -j ACCEPT

printInfo 'Allow SMB TCP incoming packets'
$IPTABLES -A filter-tcp-in -s $IPv4_SUBNET -p tcp -m tcp --sport 445 -j ACCEPT

printInfo 'Allow Established TCP Sessions'
$IPTABLES -A filter-tcp-in -p tcp -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

printInfo 'REJECT all other TCP input'
$IPTABLES -A filter-tcp-in -m limit --limit 3/min --limit-burst 10 -j LOG --log-prefix '[IPv4 TCP BLOCK] ' --log-level 7
$IPTABLES -A filter-tcp-in -p tcp -j REJECT --reject-with tcp-reset

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

printInfo 'Allow DNS UDP incoming packets'
$IPTABLES -A filter-udp-in -p udp -m udp --sport 53 -j ACCEPT

printInfo 'Allow Google Talk Voice and Video incoming packets'
$IPTABLES -A filter-udp-in -p udp -m multiport --sports 19302,19305:19309 -j ACCEPT

printInfo 'Allow NTP UDP incoming packets'
$IPTABLES -A filter-udp-in -p udp -m udp --sport 123 -j ACCEPT

printInfo "Allow DHCP UDP incoming packets (from $IPv4_DEFAULT_GATEWAY)"
$IPTABLES -A filter-udp-in -s $IPv4_DEFAULT_GATEWAY -d $IPv4_SUBNET -p udp -m udp --sport 67 --dport 68 -j ACCEPT

printInfo 'Allow SNMP UDP incoming packets'
$IPTABLES -A filter-udp-in -p udp -m udp --sport 161 -j ACCEPT

printInfo 'REJECT all other UDP INPUT'
$IPTABLES -A filter-udp-in -j in_deny

echo

#
# *****************************
# * filter-udp-in-bcast Rules *
# *****************************
#

printInfo 'Allow uPnP UDP BROADCAST incoming packets'
$IPTABLES -A filter-udp-in-bcast -s $IPv4_SUBNET -d 255.255.255.255/32 -p udp -m udp --dport 1900 -j ACCEPT

printInfo 'Allow WS-Discovery UDP BROADCAST incoming packets'
$IPTABLES -A filter-udp-in-bcast -s $IPv4_SUBNET -p udp -m udp --dport 1124 -j ACCEPT

printInfo 'Allow DHCP UDP BROADCAST incoming packets'
$IPTABLES -A filter-udp-in-bcast -s $IPv4_SUBNET -p udp -m udp --sport 67 --dport 68 -j ACCEPT

printInfo 'Allow SNMP UDP BROADCAST incoming packets'
$IPTABLES -A filter-udp-in-bcast -s $IPv4_SUBNET -p udp -m udp --dport 161 -j ACCEPT

printInfo 'REJECT all other UDP BROADCAST INPUT'
$IPTABLES -A filter-udp-in-bcast -j in_deny

echo

#
# *****************************
# * filter-udp-in-mcast Rules *
# *****************************
#

printInfo 'Allow mDNS UDP MULTICAST incoming packets'
$IPTABLES -A filter-udp-in-mcast -s $IPv4_SUBNET -d 224.0.0.251/32 -p udp -m udp --dport 5353 -j ACCEPT

printInfo 'Allow all-hosts UDP MULTICAST incoming packets'
$IPTABLES -A filter-udp-in-mcast -s $IPv4_SUBNET -d 224.0.0.1/32 -p udp -j ACCEPT

printInfo 'Allow uPnP UDP MULTICAST incoming packets'
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


################################ IPTABLES-SAVE ################################

printInfo 'Persisting iptables Rules'

# Backup existing /etc/network/iptables.rules
cp /etc/network/iptables.rules /etc/network/iptables.rules.bak

# Save /etc/network/iptables.rules
$IPTABLES_SAVE > /etc/network/iptables.rules

echo

exit 0
