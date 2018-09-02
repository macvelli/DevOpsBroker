#!/bin/bash

#
# tune-diskio.tpl - DevOpsBroker template for configuring disk I/O parameters
#
# 2018 Edward Smith <edwardsmith@devopsbroker.org>
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
# Developed on Ubuntu 16.04.5 LTS running kernel.osrelease = 4.15.0-33
#
# -----------------------------------------------------------------------------
#

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Preprocessing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
SCRIPT_DIR="${SCRIPT_INFO[0]}"
SCRIPT_EXEC="${SCRIPT_INFO[1]}"

# Display error if not running as root
if [ "$USER" != 'root' ]; then
	printError "$SCRIPT_EXEC" 'Permission denied (you must be root)'
	exit 1
fi

################################## Variables ##################################

## Bash exec variables
EXEC_BLOCKDEV=/sbin/blockdev
EXEC_HDPARM=/sbin/hdparm
EXEC_LSBLK=/bin/lsblk

## Options
deviceNode="$1"

## Variables
export TMPDIR=${TMPDIR:-'/tmp'}
blockDevice="${deviceNode/"/dev"/"/sys/block"}/device"
blockSize=512
ioPoll=1
ioPollDelay=2
ncqPrioEnable=0
queueDepth=1
rqAffinity=2

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ OPTION Parsing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Display usage if no parameters given
if [ -z "$deviceNode" ]; then
	printUsage "$SCRIPT_EXEC DEVICE_NODE"
	exit 1
fi

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Template ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Gather Serial Number, Device Transport Type, and Device Type
attributeList=($($EXEC_LSBLK -dnp --exclude 7 --output SERIAL,TRAN,TYPE $deviceNode 2>/dev/null))

if [ "${attributeList[2]}" != 'disk' ]; then
	printError "$SCRIPT_EXEC" "Cannot tune '$deviceNode': Not a block device"
	echo
	printUsage "$SCRIPT_EXEC DEVICE_NODE"

	exit 1
fi

# Initialize variables
serialNumber=${attributeList[0]}
transportType=${attributeList[1]}
deviceType=${attributeList[2]}
udevRuleFile="65-diskio-${serialNumber}.rules"

# Execute sequential read benchmark
if [ ! -f /etc/devops/diskio-${serialNumber}.info ]; then
	printInfo "Executing $deviceNode sequential read benchmark"
	$EXEC_HDPARM -t $deviceNode | tee /etc/devops/diskio-${serialNumber}.info
	echo
fi

if [ "$transportType" == 'sata' ] && [ -f "$blockDevice/queue_depth" ]; then
	queueDepth=$($EXEC_CAT "$blockDevice/queue_depth")

	if [ -f "$blockDevice/ncq_prio_enable" ]; then
		ncqPrioEnable=1
	fi
fi

# Calculate nrRequests value
blockDeviceInfo=($($EXEC_BLOCKDEV --getss --getmaxsect $deviceNode))
nrRequests=$( min $[ (${blockDeviceInfo[0]} * ${blockDeviceInfo[1]}) / $blockSize ] 2048 )
nrRequests=$[ ($nrRequests / $queueDepth) * $queueDepth ]

# Load disk I/O benchmark data
diskIOBench=($($EXEC_CAT /etc/devops/diskio-${serialNumber}.info))
diskSpeed=${diskIOBench[11]::-3}
diskMetric=${diskIOBench[12]}

# Calculate read_ahead_kb value
if [ "$diskMetric" == 'MB/sec' ]; then
	diskSpeed=$[ $diskSpeed * 1048576 ]
	readAheadKB=$[ $diskSpeed / 65536000 * 64 ]
	readAheadKB=$( max $readAheadKB 64 )
fi

# Calculate read_lat_nsec/write_lat_nsec values
nanoSecLat=$[ $diskSpeed / $blockSize ]
nanoSecLat=$[ 1000000000 / $nanoSecLat ]

# Calculate Event Poll Milliseconds for Kernel polling
eventPollMs=$( max $[ ($nanoSecLat + 500) / 1000 ] 1 )


## Template
/bin/cat << EOF > "$TMPDIR"/$udevRuleFile
#
# $udevRuleFile
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
# Developed on Ubuntu 16.04.5 LTS running kernel.osrelease = 4.15.0-33
#
# -----------------------------------------------------------------------------
#

# Disk I/O settings for $serialNumber
ACTION=="add|change", SUBSYSTEM=="block", ENV{ID_SERIAL_SHORT}!="$serialNumber", GOTO="disk-io-settings-end"

ATTR{events_poll_msecs}="$eventPollMs"
ATTR{queue/iosched/read_lat_nsec}="$nanoSecLat"
ATTR{queue/iosched/write_lat_nsec}="$nanoSecLat"
ATTR{queue/io_poll}="$ioPoll"
ATTR{queue/nr_requests}="$nrRequests"
ATTR{queue/read_ahead_kb}="$readAheadKB"
ATTR{queue/rq_affinity}="$rqAffinity"

LABEL="disk-io-settings-end"

ACTION=="add|change", SUBSYSTEMS=="scsi", DRIVERS=="sd", ATTR{ncq_prio_enable}="$ncqPrioEnable"

EOF

# Install as root:root with rw-r--r-- privileges
$EXEC_INSTALL -b --suffix .bak -o root -g root -m 644 "$TMPDIR/$udevRuleFile" /etc/udev/rules.d/

$EXEC_RM "$TMPDIR/$udevRuleFile"

exit 0
