#!/bin/bash

#
# sysctl.conf.tpl - DevOpsBroker script for generating /etc/sysctl.conf configuration
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
# Configuration file for setting system variables. See the /etc/sysctl.d/
# directory for additional system variable configuration files.
#
# See sysctl.conf(5) and sysctl(8) for more information.
#
# Protects from the following attacks:
#   o SYN Flood Attack
#   o TCP Time-Wait Attack
#   o Source IP Address Spoofing
#   o MITM Attacks
#   o Bad Error Messages
#
# Every kernel parameter that can be tuned specifically for your machine is
# dynamically calculated based upon your machine configuration, network
# interface, and Internet connection speed.
# -----------------------------------------------------------------------------
#

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Preprocessing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

# Display error if not running as root
if [ "$USER" != 'root' ]; then
	printError 'sysctl.conf.tpl' 'Permission denied (you must be root)'

	exit 1
fi

## Script information
SCRIPT_DIR=$( $EXEC_DIRNAME "$BASH_SOURCE" )

################################## Functions ##################################

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function:     calcOptWindow
# Description:  Calculate the Optimal Window value
#
# Parameter $1: The Unscaled Window value
# Parameter $2: he Maximum BDP
# -----------------------------------------------------------------------------
function calcOptWindow() {
	local unscaledWin=$1
	local maxBDP=$2

	echo "$[ ($maxBDP / $unscaledWin) * $unscaledWin + $unscaledWin ]"
}

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function:     executePingTest
# Description:  Execute the ping test to get Round Trip Time
# -----------------------------------------------------------------------------
function executePingTest() {

	# Add to the /tmp/ping.job file
	echo "$EXEC_PING -c 4 -n -W 1 ec2.us-east-1.amazonaws.com | $EXEC_AWK -F '/' 'END {printf \"%1.0f\n\", \$5}'" > /tmp/ping.job
	echo "$EXEC_PING -c 4 -n -W 1 ec2.us-east-2.amazonaws.com | $EXEC_AWK -F '/' 'END {printf \"%1.0f\n\", \$5}'" >> /tmp/ping.job
	echo "$EXEC_PING -c 4 -n -W 1 ec2.us-west-1.amazonaws.com | $EXEC_AWK -F '/' 'END {printf \"%1.0f\n\", \$5}'" >> /tmp/ping.job
	echo "$EXEC_PING -c 4 -n -W 1 ec2.us-west-2.amazonaws.com | $EXEC_AWK -F '/' 'END {printf \"%1.0f\n\", \$5}'" >> /tmp/ping.job
	echo "$EXEC_PING -c 4 -n -W 1 ec2.ca-central-1.amazonaws.com | $EXEC_AWK -F '/' 'END {printf \"%1.0f\n\", \$5}'" >> /tmp/ping.job
	echo "$EXEC_PING -c 4 -n -W 1 ec2.us-gov-west-1.amazonaws.com | $EXEC_AWK -F '/' 'END {printf \"%1.0f\n\", \$5}'" >> /tmp/ping.job

	# Also look at GCP
	echo "$EXEC_PING -c 4 -n -W 1 us-east1.googleusercontent.com | $EXEC_AWK -F '/' 'END {printf \"%1.0f\n\", \$5}'" >> /tmp/ping.job
	echo "$EXEC_PING -c 4 -n -W 1 us-east4.googleusercontent.com | $EXEC_AWK -F '/' 'END {printf \"%1.0f\n\", \$5}'" >> /tmp/ping.job
	echo "$EXEC_PING -c 4 -n -W 1 us-west1.googleusercontent.com | $EXEC_AWK -F '/' 'END {printf \"%1.0f\n\", \$5}'" >> /tmp/ping.job
	echo "$EXEC_PING -c 4 -n -W 1 us-west2.googleusercontent.com | $EXEC_AWK -F '/' 'END {printf \"%1.0f\n\", \$5}'" >> /tmp/ping.job
	echo "$EXEC_PING -c 4 -n -W 1 us-central1.googleusercontent.com | $EXEC_AWK -F '/' 'END {printf \"%1.0f\n\", \$5}'" >> /tmp/ping.job
	echo "$EXEC_PING -c 4 -n -W 1 northamerica-northeast1.googleusercontent.com | $EXEC_AWK -F '/' 'END {printf \"%1.0f\n\", \$5}'" >> /tmp/ping.job

	# Execute the /tmp/ping.job in parallel
	echo "$($EXEC_PARALLEL -j0 --no-notice :::: /tmp/ping.job | $EXEC_SORT -n | $EXEC_TAIL -1)"
}

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function:     tuneNetwork
# Description:  Tunes network settings
#
# Note: Bandwidth Delay Product = Available Bandwidth (KBytes/sec) x Round Trip Time (ms)
# -----------------------------------------------------------------------------
function tuneNetwork() {

	# Calculate Bandwidth Delay Product (BDP) of the network interface
	local NIC_BDP=$[ $NIC_SPEED * 5 ]

	# Calculate Bandwidth Delay Product (BDP) based on Internet Download speed
	local INET_DL_SPEED=$($EXEC_GREP -F "Download: " /etc/devops/speedtest.info | awk -F '[^0-9]*' '{print $2}')
	local INET_DL_BDP=$[ $INET_DL_SPEED * 125 * $NIC_LATENCY ]

	# Calculate Bandwidth Delay Product (BDP) based on Internet Upload speed
	local INET_UL_SPEED=$($EXEC_GREP -F "Upload: " /etc/devops/speedtest.info | awk -F '[^0-9]*' '{print $2}')
	local INET_UL_BDP=$[ $INET_UL_SPEED * 125 * $NIC_LATENCY ]

	# Determine the maximum receive BDP value
	local MAX_RCV_BDP=$[ $NIC_BDP > $INET_DL_BDP ? $NIC_BDP : $INET_DL_BDP ]

	# Determine the maximum send BDP value
	local MAX_SEND_BDP=$[ $NIC_BDP > $INET_UL_BDP ? $NIC_BDP : $INET_UL_BDP ]

	# Calculate the Unscaled TCP Window value (largest even multiple of TCP MSS less than 65535)
	UNSCALED_TCP_WIN=$[ 65535 / $NIC_TCP_MSS * $NIC_TCP_MSS ]

	# Calculate the Unscaled UDP Window value (largest even multiple of UDP MSS less than 65535)
	UNSCALED_UDP_WIN=$[ 65535 / $NIC_UDP_MSS * $NIC_UDP_MSS ]

	# Calculate the Optimal Window value based on UNSCALED_TCP_WIN and MAX_RCV_BDP
	local OPT_WIN=$(calcOptWindow $UNSCALED_TCP_WIN $MAX_RCV_BDP)

	# Configure TCP receive memory default and maximum values
	TCP_RMEM_DEFAULT=$[ $OPT_WIN / 2 ]
	TCP_RMEM_MAX=$OPT_WIN

	# Calculate the Optimal Window value based on UNSCALED_TCP_WIN and MAX_SEND_BDP
	OPT_WIN=$(calcOptWindow $UNSCALED_TCP_WIN $MAX_SEND_BDP)

	# Configure TCP send memory default and maximum values
	TCP_WMEM_DEFAULT=$[ $OPT_WIN / 2 ]
	TCP_WMEM_MAX=$OPT_WIN

	# Calculate min/pressure/max values for tcp_mem and udp_mem
	local NET_MEM_MIN=$[ ($TCP_RMEM_MAX + $TCP_WMEM_MAX) / $PAGESIZE * $NUM_CONNECTIONS ]
	local NET_MEM_PRESSURE=$[ $NET_MEM_MIN + ($NET_MEM_MIN / 3) ]
	local NET_MEM_MAX=$[ $NET_MEM_MIN * 2 ]

	TCP_MEM_MIN=$[ $NET_MEM_MIN / $NIC_TCP_MSS * $NIC_TCP_MSS ]
	TCP_MEM_PRESSURE=$[ $NET_MEM_PRESSURE / $NIC_TCP_MSS * $NIC_TCP_MSS ]
	TCP_MEM_MAX=$[ $NET_MEM_MAX / $NIC_TCP_MSS * $NIC_TCP_MSS ]

	UDP_MEM_MIN=$[ $NET_MEM_MIN / $NIC_UDP_MSS * $NIC_UDP_MSS ]
	UDP_MEM_PRESSURE=$[ $NET_MEM_PRESSURE / $NIC_UDP_MSS * $NIC_UDP_MSS ]
	UDP_MEM_MAX=$[ $NET_MEM_MAX / $NIC_UDP_MSS * $NIC_UDP_MSS ]

	# Calculate maximum number of queued incoming packets
	NETDEV_MAX_BACKLOG=$[ $UNSCALED_UDP_WIN * ($PAGESIZE / 1024) ]

	# Calculate TCP Small Queue limit per TCP socket
	TCP_LIMIT_OUTPUT_BYTES=$[ $UNSCALED_TCP_WIN * 2 ]
}

################################## Variables ##################################

## Configuration
NUM_CONNECTIONS=25

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ General Information ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Total amount of RAM available
RAM_TOTAL=$(getRamTotal)

# Amount of RAM available in GB
RAM_GB=$[ ($RAM_TOTAL + 1048575) / 1048576 ]

# Memory Page Size
PAGESIZE=$(getconf PAGE_SIZE)

# --------------------------- Filesystem Information --------------------------

# Global Maximum Number Simultaneous Open Files
FS_FILE_MAX=$[ $RAM_TOTAL / 10 ]

# ---------------------------- Network Information ----------------------------

# Default network interface
NIC=$($EXEC_IP -4 route show default | $EXEC_AWK '{ print $5 }')

if [[ "$($EXEC_READLINK /sys/class/net/$NIC)" == *"/devices/virtual/"* ]]; then
	printInfo "Default network interface '$NIC' is virtual"
	printInfo 'Exiting'

	exit 0
fi

# Actual Mbit/s speed of the network interface
NIC_SPEED=$[ $($EXEC_CAT /sys/class/net/$NIC/speed) * 125 ]

# Maximum Transmission Unit (MTU) of the network interface
NIC_MTU=$(cat /sys/class/net/$NIC/mtu)

# Enable MTU Probing if using Jumbo Frames
MTU_PROBING=$[ $NIC_MTU > 1500 ? 0 : 1 ]

# TCP Maximum Segment Size (MSS) = MTU - 20 (IP Header size) - 20 (TCP Header size)
NIC_TCP_MSS=$[ $NIC_MTU - 20 - 20 ]

# UDP Maximum Segment Size (MSS) = MTU - 20 (IP Header size) - 8 (UDP Header size)
NIC_UDP_MSS=$[ $NIC_MTU - 20 - 8 ]

# Call executePingTest()
printInfo 'Execute ping test to find the slowest site by latency'
NIC_LATENCY="$(executePingTest)"

# Call tuneNetwork()
tuneNetwork

# ------------------------- Virtual Memory Information ------------------------

# Configure VM Dirty Ratio / VM Dirty Background Ratio / VM VFS Cache Pressure
case $RAM_GB in
[1-2]*)
	VM_DIRTY_RATIO=8
	VM_DIRTY_BG_RATIO=4
	VM_VFS_CACHE_PRESSURE=150
	;;
[3-4]*)
	VM_DIRTY_RATIO=6
	VM_DIRTY_BG_RATIO=3
	VM_VFS_CACHE_PRESSURE=125
	;;
[5-6]*)
	VM_DIRTY_RATIO=5
	VM_DIRTY_BG_RATIO=3
	VM_VFS_CACHE_PRESSURE=100
	;;
[7-8]*)
	VM_DIRTY_RATIO=4
	VM_DIRTY_BG_RATIO=2
	VM_VFS_CACHE_PRESSURE=90
	;;
[9-12]*)
	VM_DIRTY_RATIO=3
	VM_DIRTY_BG_RATIO=2
	VM_VFS_CACHE_PRESSURE=80
	;;
*)
	VM_DIRTY_RATIO=2
	VM_DIRTY_BG_RATIO=1
	VM_VFS_CACHE_PRESSURE=70
	;;
esac

# Configure VM Minimum Free Memory (1% of physical RAM)
VM_MIN_FREE_KB=$[ $RAM_TOTAL / 100 ]

## Template
cat << EOF > "$SCRIPT_DIR"/sysctl.conf
#
# sysctl.conf - DevOpsBroker Linux kernel tuning configuration file
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

#
# Linux Kernel Tuning Configuration
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

# Set the hostname of the machine
#kernel.hostname = covfefe

# Set the domain name of the host
#kernel.domainname = example.com

# Set Default Kernel Log Levels
kernel.printk = 4 4 1 7

# Enable PID Append To Kernel Core Dumps
kernel.core_uses_pid = 1

# Disable NMI Watchdog
kernel.nmi_watchdog = 0

# Disable Magic SysRq Key
kernel.sysrq = 0

#
# Filesystem Kernel Tuning Configuration
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

# Optimize Global Maximum Number Simultaneous Open Files
fs.file-max = $FS_FILE_MAX

#
# Network Kernel Tuning Configuration
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

# Set Default Queuing Discipline
net.core.default_qdisc = fq_codel

# Optimize Maximum Number of Queued Incoming Packets
net.core.netdev_max_backlog = $NETDEV_MAX_BACKLOG

# Optimize Maximum Amount of Option Memory Buffers
net.core.optmem_max = $UNSCALED_TCP_WIN

# Enable IPv6
net.ipv6.conf.all.disable_ipv6 = 0
net.ipv6.conf.default.disable_ipv6 = 0

# Accept IPv6 Router Advertisements
net.ipv6.conf.all.accept_ra = 1
net.ipv6.conf.all.autoconf = 1
net.ipv6.conf.default.accept_ra = 1
net.ipv6.conf.default.autoconf = 1

# Do not accept source routed packets
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0

# Do not accept ICMP REDIRECT Messages
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0

# Disable logging packets with impossible addresses
net.ipv4.conf.all.log_martians = 0
net.ipv4.conf.default.log_martians = 0

# Enable Source Address Verification
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Do not send ICMP REDIRECT Messages
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# Allow ICMP ECHO Requests (Ping)
net.ipv4.icmp_echo_ignore_all = 0

# Drop BROADCAST/MULTICAST ICMP ECHO Requests
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Ignore bogus ICMP error responses
net.ipv4.icmp_ignore_bogus_error_responses = 1

# Disable IP Forwarding
net.ipv4.ip_forward = 0
net.ipv4.conf.all.forwarding = 0
net.ipv6.conf.all.forwarding = 0
net.ipv4.conf.default.forwarding = 0
net.ipv6.conf.default.forwarding = 0

# Enable Path MTU Discovery
net.ipv4.ip_no_pmtu_disc = $MTU_PROBING

# Increase the total port range for both TCP and UDP connections
net.ipv4.ip_local_port_range = 1500 65001

# Use TCP-LP Congestion Control Algorithm
net.ipv4.tcp_congestion_control = lp

# Enable TCP Explicit Congestion Notification (ECN)
net.ipv4.tcp_ecn = 1

# Enable TCP Fast Open (TFO)
net.ipv4.tcp_fastopen = 1

# Optimize TCP FIN Timeout
net.ipv4.tcp_fin_timeout = 30

# Optimize TCP Small Queue Limit Per TCP Socket
net.ipv4.tcp_limit_output_bytes = $TCP_LIMIT_OUTPUT_BYTES

# Enable TCP Receive Buffer Auto-Tuning
net.ipv4.tcp_moderate_rcvbuf = 1

# Enable MTU Probing if using Jumbo Frames
net.ipv4.tcp_mtu_probing = $MTU_PROBING

# Enable TCP Metrics Cache
net.ipv4.tcp_no_metrics_save = 0

# Enable TCP Time-Wait Attack Protection
net.ipv4.tcp_rfc1337 = 1

# Enable TCP Select Acknowledgments
net.ipv4.tcp_sack = 1
net.ipv4.tcp_dsack = 1

# Disable TCP Slow Start After Idle
net.ipv4.tcp_slow_start_after_idle = 0

# Enable SYN Flood Attack Protection
net.ipv4.tcp_max_syn_backlog = 1024
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syncookies = 1

# Optimize TCP SYN Retries
net.ipv4.tcp_syn_retries = 5

# Disable IPv4 TCP Timestamps
net.ipv4.tcp_timestamps = 0

# Enable TCP TIME_WAIT Socket Reuse
net.ipv4.tcp_tw_reuse = 1

# Enable TCP Window Scaling
net.ipv4.tcp_window_scaling = 1

# Optimize TCP Receive Socket Buffer Size
net.core.rmem_default = $TCP_RMEM_DEFAULT
net.core.rmem_max = $TCP_RMEM_MAX
net.ipv4.tcp_rmem = $UNSCALED_TCP_WIN $TCP_RMEM_DEFAULT $TCP_RMEM_MAX

# Optimize TCP Send Socket Buffer Size
net.core.wmem_default = $TCP_WMEM_DEFAULT
net.core.wmem_max = $TCP_WMEM_MAX
net.ipv4.tcp_wmem = $UNSCALED_TCP_WIN $TCP_WMEM_DEFAULT $TCP_WMEM_MAX

# Optimize UDP Socket Buffer Size
net.ipv4.udp_rmem_min = $UNSCALED_UDP_WIN
net.ipv4.udp_wmem_min = $UNSCALED_UDP_WIN

# Optimize TCP/UDP Total Buffer Space
net.ipv4.tcp_mem = $TCP_MEM_MIN $TCP_MEM_PRESSURE $TCP_MEM_MAX
net.ipv4.udp_mem = $UDP_MEM_MIN $UDP_MEM_PRESSURE $UDP_MEM_MAX

# Set the IPv4 Route Minimum PMTU
net.ipv4.route.min_pmtu = 552

# Set the IPv4 Minimum Advertised MSS
net.ipv4.route.min_adv_mss = 512

#
# Virtual Memory Kernel Tuning Configuration
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

# Optimize VM Swappiness
vm.swappiness = 10

# Optimize VM Dirty Ratio
vm.dirty_ratio = $VM_DIRTY_RATIO

# Optimize VM Dirty Background Ratio
vm.dirty_background_ratio = $VM_DIRTY_BG_RATIO

# Optimize VM Minimum Free Memory
vm.min_free_kbytes = $VM_MIN_FREE_KB

# Optimize VM VFS Cache Pressure
vm.vfs_cache_pressure = $VM_VFS_CACHE_PRESSURE

EOF
