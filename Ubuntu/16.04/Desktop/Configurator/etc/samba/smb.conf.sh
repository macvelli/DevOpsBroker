#!/bin/bash

#
# smb.conf.sh - DevOpsBroker script for generating /etc/samba/smb.conf configuration
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
# Samba Version 4.3.11-Ubuntu
#
# Due to the vulnerabilities in the SMBv1 protocol:
#   o Only SMBv2 and SMBv3 are supported
#   o NetBIOS is disabled
#   o Samba only listens on port 445
#
# The Samba server can be accessed using:
#   o The IP address of the server (smb://192.168.1.123/)
#   o By mDNS convention (smb://hostname.local/)
# -----------------------------------------------------------------------------
#


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Preprocessing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Display error if not running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "\033[1msmb.conf.sh: \033[38;5;203mPermission denied (you must be root)\033[0m"

  exit 1
fi


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Template ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## Template variables

# Default network interface
DEFAULT_NIC=$(ip -4 route show default | awk '{ print $5 }')

# ifconfig NIC information
INET_ADDR=$(ifconfig $DEFAULT_NIC | grep 'inet addr:')

# Subnet
SUBNET=$(echo $INET_ADDR | awk '{ print substr($2,6) }' | sed -E 's/(([0-9]+\.){3}).*/\10/')

# Netmask
NETMASK=$(echo $INET_ADDR | awk '{ print substr($4,6) }')


## Template
cat << EOF
#
# smb.conf - DevOpsBroker configuration for Samba; see smb.conf(5) for help
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

[global]

## Browsing/Identification ###

# Change this to the workgroup/NT-domain name your Samba server will be part of
	workgroup = WORKGROUP
	case sensitive = no

# Domain master only applies to LANs that are inter-connected across a WAN
	domain master = no

# Server string is the equivalent of the NT Description field
	server string = %h (Ubuntu 16.04 Desktop)

# Run the Samba server as a "standalone server"
	server role = standalone server
	server services = s3fs

# Disable NetBIOS and only listen on port 445
	disable netbios = yes
	dns proxy = no
	name resolve order = host
	preferred master = no
	smb ports = 445

#### Networking ####

# The specific set of interfaces / networks to bind to
	interfaces = lo $DEFAULT_NIC

# Only bind to the named interfaces and/or networks listed above
	bind interfaces only = yes

# Only allow hosts on this subnet and localhost; deny the rest
	hosts allow = $SUBNET/$NETMASK 127.0.0.1
	hosts deny = all

#### Debugging/Accounting ####

# Use a separate log file for each machine that connects
	logging = syslog@0 /var/log/samba/%m.log@1

# Cap the size of the individual log files (in KiB)
	max log size = 1000

# Do something sensible when Samba crashes: mail the admin a backtrace
	panic action = /usr/share/samba/panic-action %d

####### Authentication #######

# Require the Samba client and server to use SMB2 signing
	client min protocol = SMB2
	client max protocol = SMB3
	client signing = disabled

	server min protocol = SMB2
	server max protocol = SMB3
	server signing = disabled

	client NTLMv2 auth = yes

# Defaults for guest access
	guest account = nobody
	guest ok = no
	map to guest = Bad User

# Disable all usershares configurations
	usershare allow guests = no
	usershare max shares = 0

# Don't allow the root user for network shares
	invalid users = root

# Encrypt passwords/obey PAM restrictions/use tdbsam database/enforce user security
	encrypt passwords = yes
	obey pam restrictions = yes
	passdb backend = tdbsam:/etc/samba/private/passdb.tdb
	security = user

# Don't synchronise the Linux and Samba user passwords - they can be different
	unix password sync = no

########## Printing ##########

# Do not load printers in the printcap for browsing
	load printers = no
	printcap name = /dev/null

############ Misc ############

# Read/write from/to file asynchronously when size of request is bigger than 2 KiB
	aio read size = 2048
	aio write size = 2048

# The number of minutes of inactivity before a connection is considered dead
	deadtime = 15

# A caching algorithm will be used to reduce the time taken for getwd() calls
	getwd cache = yes

# Support 64k streaming read and write variant SMB requests
	large readwrite = yes

# The maximum packet size that will be negotiated by Samba
	max xmit = 64280

# Incoming SMBwriteX calls greater than 16 KiB will be passed to underlying kernel
	min receivefile size = 16384

# Use Level II oplocks
	oplocks = yes
	kernel oplocks = no
	level2 oplocks = yes

# Favor low latency / Disable Nagle's algorithm / Keepalive / Optimize Rx/Tx Buffer Sizes
	socket options = IPTOS_LOWDELAY TCP_NODELAY SO_KEEPALIVE SO_RCVBUF=128480 SO_SNDBUF=128480

# Ignore Windows application requests for a sync call
	strict sync = no
	sync always = no

# Perform file lock checks only on non-oplocked files
	strict locking = Auto

# Use the more efficient sendfile system call, if available
	use sendfile = yes

# This cache allows Samba to batch client writes into a more efficient write size
	write cache size = 1027840

EOF

