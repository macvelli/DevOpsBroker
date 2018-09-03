#!/bin/bash

#
# testVerifyIP.sh - DevOpsBroker Bash test script for the verifyip utility
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
SCRIPT_DIR=$( $EXEC_DIRNAME "$BASH_SOURCE" )
EXEC_DIR="$SCRIPT_DIR/.."

################################## Functions ##################################

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function:	negativeTest
# Description:	Expects a negative outcome from the applied test
#
# Parameter $1:	The IP Address to test
# -----------------------------------------------------------------------------
function negativeTest() {
  if ! "$EXEC_VERIFYIP" "$1"; then
    echo $pass
  else
    echo $fail
  fi
}

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function:	positiveTest
# Description:	Expects a positive outcome from the applied test
#
# Parameter $1:	The IP Address to test
# -----------------------------------------------------------------------------
function positiveTest() {
  if "$EXEC_VERIFYIP" "$1"; then
    echo $pass
  else
    echo $fail
  fi
}


################################## Variables ##################################

## Bash exec variables
EXEC_VERIFYIP="$EXEC_DIR/verifyip"

# Pass/Fail messages
pass="${bold}${pastelGreen}pass${reset}"
fail="${bold}${bittersweet}fail${reset}"

################################### Testing ###################################

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Positive Testing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

printBanner 'Positive Testing'

## IPv4 Address Type
printInfo 'IPv4 Address Type'
echo 'verifyip 0.0.0.0'"					[$(positiveTest '0.0.0.0')]"
echo 'verifyip 127.0.0.1'"					[$(positiveTest '127.0.0.1')]"
echo 'verifyip 255.255.255.255'"				[$(positiveTest '255.255.255.255')]"
echo

## IPv6 Address Type
printInfo 'IPv6 Address Type'
echo 'verifyip ::'"						[$(positiveTest '::')]"
echo 'verifyip ::1'"						[$(positiveTest '::1')]"
echo 'verifyip 2001:db8::2:1'"					[$(positiveTest '2001:db8::2:1')]"
echo 'verifyip 2001:DB8::2:1'"					[$(positiveTest '2001:DB8::2:1')]"
echo 'verifyip ::ffff:c000:0280'"				[$(positiveTest '::ffff:c000:0280')]"
echo 'verifyip ::ffff:192.0.2.128'"				[$(positiveTest '::ffff:192.0.2.128')]"
echo 'verifyip 2001:0db8:85a3::8a2e:0370:7334'"			[$(positiveTest '2001:0db8:85a3::8a2e:0370:7334')]"
echo 'verifyip 2001:0db8:85a3:0000:0000:8a2e:0370:7334'"	[$(positiveTest '2001:0db8:85a3:0000:0000:8a2e:0370:7334')]"
echo

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Negative Testing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

printBanner 'Negative Testing'

## Argument Testing
printInfo 'Argument Testing'
echo 'verifyip'"						[$(negativeTest)]"
echo 'verifyip covfefe'"					[$(negativeTest 'covfefe')]"
echo

## IPv4 Address Type
printInfo 'IPv4 Address Type'
echo 'verifyip .0.0.0'"						[$(negativeTest '.0.0.0')]"
echo 'verifyip 0..0.0'"						[$(negativeTest '0..0.0')]"
echo 'verifyip 0.0..0'"						[$(negativeTest '0.0..0')]"
echo 'verifyip 0.0.0.'"						[$(negativeTest '0.0.0.')]"
echo 'verifyip 0.0.0.0.'"					[$(negativeTest '0.0.0.0.')]"
echo 'verifyip g.0.0.0'"					[$(negativeTest 'g.0.0.0')]"
echo 'verifyip 0.g.0.0'"					[$(negativeTest '0.g.0.0')]"
echo 'verifyip 0.0.g.0'"					[$(negativeTest '0.0.g.0')]"
echo 'verifyip 0.0.0.g'"					[$(negativeTest '0.0.0.g')]"
echo 'verifyip 1234.0.0.0'"					[$(negativeTest '1234.0.0.0')]"
echo 'verifyip 0.1234.0.0'"					[$(negativeTest '0.1234.0.0')]"
echo 'verifyip 0.0.1234.0'"					[$(negativeTest '0.0.1234.0')]"
echo 'verifyip 0.0.0.1234'"					[$(negativeTest '0.0.0.1234')]"
echo 'verifyip 0'"						[$(negativeTest '0')]"
echo 'verifyip 0.0'"						[$(negativeTest '0.0')]"
echo 'verifyip 0.0.0'"						[$(negativeTest '0.0.0')]"
echo 'verifyip 0.0.0.0.0'"					[$(negativeTest '0.0.0.0.0')]"
echo 'verifyip 256.0.0.0'"					[$(negativeTest '256.0.0.0')]"
echo 'verifyip 0.256.0.0'"					[$(negativeTest '0.256.0.0')]"
echo 'verifyip 0.0.256.0'"					[$(negativeTest '0.0.256.0')]"
echo 'verifyip 0.0.0.256'"					[$(negativeTest '0.0.0.256')]"
echo

## IPv6 Address Type
printInfo 'IPv6 Address Type'
echo 'verifyip :fe80::aa:bb:cc:dd'"				[$(negativeTest ':fe80::aa:bb:cc:dd')]"
echo 'verifyip :::fe80::aa:bb:cc:dd'"				[$(negativeTest ':::fe80::aa:bb:cc:dd')]"
echo 'verifyip ::fffff:c000:0280'"				[$(negativeTest '::fffff:c000:0280')]"
echo 'verifyip ::ffff0:c000:0280'"				[$(negativeTest '::ffff0:c000:0280')]"
echo 'verifyip ::ffff::c000:0280'"				[$(negativeTest '::ffff::c000:0280')]"
echo 'verifyip ::ffff:uvw:xyz'"					[$(negativeTest '::ffff:uvw:xyz')]"
echo 'verifyip fe80::aa::bb:cc:dd'"				[$(negativeTest 'fe80::aa::bb:cc:dd')]"
echo 'verifyip fe80:aa:::bb:cc:dd'"				[$(negativeTest 'fe80:aa:::bb:cc:dd')]"
echo 'verifyip fe8z::aa:bb:cc:dd'"				[$(negativeTest 'fe80::az:bb:cc:dd')]"
echo 'verifyip fe80::az:bb:cc:dd'"				[$(negativeTest 'fe80::az:bb:cc:dd')]"
echo 'verifyip fe80::aa:bz:cc:dd'"				[$(negativeTest 'fe80::aa:bz:cc:dd')]"
echo 'verifyip fe80::aa:bb:cz:dd'"				[$(negativeTest 'fe80::aa:bb:cz:dd')]"
echo 'verifyip fe80::aa:bb:cc:dz'"				[$(negativeTest 'fe80::aa:bb:cc:dz')]"
echo 'verifyip fe80c::aa:bb:cc:dd'"				[$(negativeTest 'fe80c::aa:bb:cc:dd')]"
echo 'verifyip fe80::fe80c:bb:cc:dd'"				[$(negativeTest 'fe80::fe80c:bb:cc:dd')]"
echo 'verifyip fe80::aa:fe80c:cc:dd'"				[$(negativeTest 'fe80::aa:fe80c:cc:dd')]"
echo 'verifyip fe80::aa:bb:fe80c:dd'"				[$(negativeTest 'fe80::aa:bb:fe80c:dd')]"
echo 'verifyip fe80::aa:bb:cc:fe80c'"				[$(negativeTest 'fe80::aa:bb:cc:fe80c')]"
echo 'verifyip fe80::aa:bb:cc:dd:'"				[$(negativeTest 'fe80::aa:bb:cc:dd:')]"
echo 'verifyip 1:2:3::4:5:6:7'"					[$(negativeTest '1:2:3::4:5:6:7')]"
echo 'verifyip 1:2:3:4:5:6:7:8:9'"				[$(negativeTest '1:2:3:4:5:6:7:8:9')]"

echo

exit 0
