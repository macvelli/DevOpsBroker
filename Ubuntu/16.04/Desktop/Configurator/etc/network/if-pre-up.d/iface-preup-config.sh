#!/bin/bash

#
# iface-preup-config.sh - DevOpsBroker script for configuring the default
#			  network interface in /etc/network/interfaces
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
# Developed on Ubuntu 16.04.4 LTS running kernel.osrelease = 4.13.0-45
#
# This script performs the following tasks:
#   o Loads the iptables rules into memory
#   o Loads the ip6tables rules into memory
#   o Configures the nf_conntrack kernel module
# -----------------------------------------------------------------------------
#

################################### Actions ###################################

/usr/bin/logger -p syslog.notice -i Called iface-preup-config.sh with interface "$IFACE" mode "$MODE" and phase "$PHASE";

#
# Load iptables and ip6tables rules
#

/sbin/iptables-restore < /etc/network/iptables.rules
/sbin/ip6tables-restore < /etc/network/ip6tables.rules

# Enable acceptance of IPv6 default router advertisements
/sbin/sysctl -w net.ipv6.conf.$IFACE.accept_ra_defrtr=1

#
# Configure the nf_conntrack kernel module
#

# Optimize generic timeout to 2 minutes
/sbin/sysctl -w net.netfilter.nf_conntrack_generic_timeout=120

# Disable Conntrack Helpers
/sbin/sysctl -w net.netfilter.nf_conntrack_helper=0

# Enable TCP Strict Policy
/sbin/sysctl -w net.netfilter.nf_conntrack_tcp_loose=0

# Optimize TCP Timeout Close and Close-Wait
/sbin/sysctl -w net.netfilter.nf_conntrack_tcp_timeout_close=10
/sbin/sysctl -w net.netfilter.nf_conntrack_tcp_timeout_close_wait=20

# Optimize TCP Established Timeout to 12 hours
/sbin/sysctl -w net.netfilter.nf_conntrack_tcp_timeout_established=43200

# Optimize TCP FIN_WAIT Timeout to 20 seconds
/sbin/sysctl -w net.netfilter.nf_conntrack_tcp_timeout_fin_wait=20

# Optimize TCP Last ACK Timeout to 10 seconds
/sbin/sysctl -w net.netfilter.nf_conntrack_tcp_timeout_last_ack=10

# Optimize TCP Maximum Retransmit Timeout to 60 seconds
/sbin/sysctl -w net.netfilter.nf_conntrack_tcp_timeout_max_retrans=60

# Optimize TCP SYN Receive Timeout to 15 seconds
/sbin/sysctl -w net.netfilter.nf_conntrack_tcp_timeout_syn_recv=15

# Optimize TCP SYN Send Timeout to 30 seconds
/sbin/sysctl -w net.netfilter.nf_conntrack_tcp_timeout_syn_sent=30

# Optimize TCP TIME_WAIT Timeout to 60 seconds
/sbin/sysctl -w net.netfilter.nf_conntrack_tcp_timeout_time_wait=60

# Optimize TCP Unacknowledged Timeout to 60 seconds
/sbin/sysctl -w net.netfilter.nf_conntrack_tcp_timeout_unacknowledged=60

exit 0
