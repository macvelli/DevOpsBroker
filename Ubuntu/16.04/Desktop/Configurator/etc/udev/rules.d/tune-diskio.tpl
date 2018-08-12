#!/bin/bash

#
# tune-diskio.tpl - DevOpsBroker template for configuring disk I/O parameters
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
SCRIPT_INFO=( $($EXEC_SCRIPTINFO "$BASH_SOURCE") )
SCRIPT_FILE="$BASH_SOURCE"
SCRIPT_DIR="${SCRIPT_INFO[0]}"
SCRIPT_EXEC="${SCRIPT_INFO[1]}"

# Display error if not running as root
if [ "$EUID" -ne 0 ]; then
  echo "${bold}$SCRIPT_EXEC: ${bittersweet}Permission denied (you must be root)${reset}"

  exit 1
fi

################################## Functions ##################################

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function:	tuneDiskIO
# Description:	Tunes Disk I/O for the block device
# -----------------------------------------------------------------------------
function tuneDiskIO() {
  # BEGIN tuneDiskIO function

  # Execute sequential read benchmark
  if [ ! -f /etc/devops/diskio-${serialNumber}.info ]; then
    printInfo "Executing $deviceName sequential read benchmark"

    $EXEC_HDPARM -t $deviceName | tee /etc/devops/diskio-${serialNumber}.info

    echo
  fi

  # Find the queue depth value for the block device
  local queueDepth=''
  if [ $transportType == 'sata' ]; then
    local hdQueueDepth=($($EXEC_HDPARM -I $deviceName 2>/dev/null | $EXEC_GREP -F 'Queue depth:'))
    queueDepth=${hdQueueDepth[2]}
  fi

  if [ -z $queueDepth ]; then
    queueDepth=1
  fi

  # Calculate nrRequests value
  local blockDevice=($($EXEC_BLOCKDEV --getss --getbsz --getmaxsect $deviceName))
  local nrRequests=$queueDepth
  local blockSize=${blockDevice[1]}

  local targetValue=$[ ${blockDevice[0]} * ${blockDevice[2]} ]
  targetValue=$[ $targetValue / $blockSize ]

  while [ $nrRequests -lt $targetValue ]; do
    nrRequests=$[ $nrRequests * 2 ]
  done

  # Load disk I/O benchmark data
  local diskIOBench=($($EXEC_CAT /etc/devops/diskio-${serialNumber}.info))
  local diskSpeed=${diskIOBench[11]}
  local diskMetric=${diskIOBench[12]}
  local readAheadKB=16000

  # Calculate read_ahead_kb value
  if [ "$diskMetric" == 'MB/sec' ]; then
    diskSpeed=$($EXEC_BC <<< "$diskSpeed * 1048576")
    diskSpeed="${diskSpeed::-3}"
  fi

  millisecond=$[ ($readAheadKB * 2000) / $diskSpeed ]

  while [ $millisecond -eq 0 ]; do
    readAheadKB=$[ $readAheadKB * 2 ]
    millisecond=$[ ($readAheadKB * 2000) / $diskSpeed ]
  done

  readAheadKB=$[ $readAheadKB / 1000 ]

  # Calculate read_lat_nsec/write_lat_nsec values
  local nanoSecLat=$[ $diskSpeed / $blockSize ]
  nanoSecLat=$[ 1000000000 / $nanoSecLat ]

  # Set io_poll io_poll_delay rq_affinity values
  local ioPoll=1
  local ioPollDelay=2
  local ncqEnable=1
  local rqAffinity=2

  udevRules="${udevRules}# Disk I/O settings for $deviceName\n"
  udevRules="${udevRules}ENV{ID_SERIAL_SHORT}!=\"$serialNumber\", GOTO=\"disk-io-settings-end\"\n"
  udevRules="${udevRules}ENV{DEVTYPE}!=\"disk\", GOTO=\"disk-io-settings-end\"\n\n"

  # disk-io-settings-begin
  udevRules="${udevRules}ACTION==\"add\", ATTR{device/queue_depth}=\"$queueDepth\"\n"
  udevRules="${udevRules}ACTION==\"add\", ATTR{queue/iosched/read_lat_nsec}=\"$nanoSecLat\"\n"
  udevRules="${udevRules}ACTION==\"add\", ATTR{queue/iosched/write_lat_nsec}=\"$nanoSecLat\"\n"
  udevRules="${udevRules}ACTION==\"add\", ATTR{queue/io_poll}=\"$ioPoll\"\n"
  udevRules="${udevRules}ACTION==\"add\", ATTR{queue/io_poll_delay}=\"$ioPollDelay\"\n"
  udevRules="${udevRules}ACTION==\"add\", ATTR{queue/nr_requests}=\"$nrRequests\"\n"
  udevRules="${udevRules}ACTION==\"add\", ATTR{queue/read_ahead_kb}=\"$readAheadKB\"\n"
  udevRules="${udevRules}ACTION==\"add\", ATTR{queue/rq_affinity}=\"$rqAffinity\"\n"
  udevRules="${udevRules}\n"
  udevRules="${udevRules}LABEL=\"disk-io-settings-end\"\n"

  # END tuneDiskIO function
}

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function:	execTemplate
# Description:	Executes the Disk I/O Template
# -----------------------------------------------------------------------------
function execTemplate() {

## Template
/bin/cat << EOF > "$SCRIPT_DIR"/$udevRulesFile
#
# $udevRulesFile
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
# -----------------------------------------------------------------------------
#

$(echo -e $udevRules)

EOF

}


################################## Variables ##################################

## Bash exec variables
EXEC_BC=/usr/bin/bc
EXEC_BLOCKDEV=/sbin/blockdev
EXEC_HDPARM=/sbin/hdparm
EXEC_LSBLK=/bin/lsblk

## Options
deviceName="$1"

## Variables
serialNumber=''
transportType=''
deviceType=''
udevRules=''

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ OPTION Parsing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Display usage if no parameters given
if [ -z "$deviceName" ]; then
  printUsage "$SCRIPT_EXEC DEVICE_NAME"
  exit 1
fi

################################### Actions ###################################

# Gather Serial Number, Device Transport Type, and Device Type
attributeList=($($EXEC_LSBLK -d -n -p --exclude 7 --output SERIAL,TRAN,TYPE $deviceName))

# Initialize variables
serialNumber=${attributeList[0]}
transportType=${attributeList[1]}
deviceType=${attributeList[2]}

if [ $deviceType == 'disk' ]; then
  # Tune disk I/O
  udevRulesFile="65-diskio-${serialNumber}.rules"

  if [ ! -f /etc/udev/rules.d/$udevRulesFile ]; then
    printInfo "Installing /etc/udev/rules.d/$udevRulesFile"

    tuneDiskIO

    execTemplate
  elif [ "$SCRIPT_FILE" -nt /etc/udev/rules.d/$udevRulesFile ]; then
    printInfo "Updating /etc/udev/rules.d/$udevRulesFile"

    tuneDiskIO

    execTemplate
  fi
fi
