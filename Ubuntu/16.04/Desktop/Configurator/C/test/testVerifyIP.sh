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

# Load /etc/dob/ansi.conf if bittersweet function does not exist
if [[ ! "$(declare -F 'bittersweet')" ]]; then
  . /etc/dob/ansi.conf
fi

# Load /etc/dob/functions.conf if printBanner function does not exist
if [[ ! "$(declare -F 'printBanner')" ]]; then
  . /etc/dob/functions.conf
fi

# Find the script and executable directories
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
EXEC_DIR=$(dirname "$SCRIPT_DIR")

# Executable variable
verifyip="$EXEC_DIR/verifyip"

# Pass/Fail messages
pass="$(bold padua)pass$(reset)"
fail="$(bold bittersweet)fail$(reset)"


################################## Functions ##################################

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function:	negativeTest
# Description:	Expects a negative outcome from the applied test
#
# Parameter $1:	The IP Address to test
# -----------------------------------------------------------------------------
function negativeTest() {
  if ! "$verifyip" "$1"; then
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
  if "$verifyip" "$1"; then
    echo $pass
  else
    echo $fail
  fi
}


################################### Testing ###################################

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Positive Testing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

printBanner "Positive Testing"

## IPv4 Address Type
printInfo "IPv4 Address Type"
echo -e "verifyip 0.0.0.0\t\t\t\t"	 "[$(positiveTest '0.0.0.0')]"
echo -e "verifyip 127.0.0.1\t\t\t\t"	 "[$(positiveTest '127.0.0.1')]"
echo -e "verifyip 255.255.255.255\t\t\t" "[$(positiveTest '255.255.255.255')]"
echo

## IPv6 Address Type
printInfo "IPv6 Address Type"
echo -e "verifyip ::\t\t\t\t\t"				   "[$(positiveTest '::')]"
echo -e "verifyip ::1\t\t\t\t\t"			   "[$(positiveTest '::1')]"
echo -e "verifyip 2001:db8::2:1\t\t\t\t"		   "[$(positiveTest '2001:db8::2:1')]"
echo -e "verifyip 2001:DB8::2:1\t\t\t\t"		   "[$(positiveTest '2001:DB8::2:1')]"
echo -e "verifyip ::ffff:c000:0280\t\t\t"		   "[$(positiveTest '::ffff:c000:0280')]"
echo -e "verifyip ::ffff:192.0.2.128\t\t\t"		   "[$(positiveTest '::ffff:192.0.2.128')]"
echo -e "verifyip 2001:0db8:85a3::8a2e:0370:7334\t\t"	   "[$(positiveTest '2001:0db8:85a3::8a2e:0370:7334')]"
echo -e "verifyip 2001:0db8:85a3:0000:0000:8a2e:0370:7334" "[$(positiveTest '2001:0db8:85a3:0000:0000:8a2e:0370:7334')]"
echo

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Negative Testing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

printBanner "Negative Testing"

## Argument Testing
printInfo "Argument Testing"
echo -e "verifyip\t\t\t\t\t"	 	 "[$(negativeTest)]"
echo -e "verifyip covfefe\t\t\t\t"	 "[$(negativeTest 'covfefe')]"
echo

## IPv4 Address Type
printInfo "IPv4 Address Type"
echo -e "verifyip .0.0.0\t\t\t\t\t"	 "[$(negativeTest '.0.0.0')]"
echo -e "verifyip 0..0.0\t\t\t\t\t"	 "[$(negativeTest '0..0.0')]"
echo -e "verifyip 0.0..0\t\t\t\t\t"	 "[$(negativeTest '0.0..0')]"
echo -e "verifyip 0.0.0.\t\t\t\t\t"	 "[$(negativeTest '0.0.0.')]"
echo -e "verifyip 0.0.0.0.\t\t\t\t"	 "[$(negativeTest '0.0.0.0.')]"
echo -e "verifyip g.0.0.0\t\t\t\t"	 "[$(negativeTest 'g.0.0.0')]"
echo -e "verifyip 0.g.0.0\t\t\t\t"	 "[$(negativeTest '0.g.0.0')]"
echo -e "verifyip 0.0.g.0\t\t\t\t"	 "[$(negativeTest '0.0.g.0')]"
echo -e "verifyip 0.0.0.g\t\t\t\t"	 "[$(negativeTest '0.0.0.g')]"
echo -e "verifyip 1234.0.0.0\t\t\t\t"	 "[$(negativeTest '1234.0.0.0')]"
echo -e "verifyip 0.1234.0.0\t\t\t\t"	 "[$(negativeTest '0.1234.0.0')]"
echo -e "verifyip 0.0.1234.0\t\t\t\t"	 "[$(negativeTest '0.0.1234.0')]"
echo -e "verifyip 0.0.0.1234\t\t\t\t"	 "[$(negativeTest '0.0.0.1234')]"
echo -e "verifyip 0\t\t\t\t\t"		 "[$(negativeTest '0')]"
echo -e "verifyip 0.0\t\t\t\t\t"	 "[$(negativeTest '0.0')]"
echo -e "verifyip 0.0.0\t\t\t\t\t"	 "[$(negativeTest '0.0.0')]"
echo -e "verifyip 0.0.0.0.0\t\t\t\t"	 "[$(negativeTest '0.0.0.0.0')]"
echo -e "verifyip 256.0.0.0\t\t\t\t"	 "[$(negativeTest '256.0.0.0')]"
echo -e "verifyip 0.256.0.0\t\t\t\t"	 "[$(negativeTest '0.256.0.0')]"
echo -e "verifyip 0.0.256.0\t\t\t\t"	 "[$(negativeTest '0.0.256.0')]"
echo -e "verifyip 0.0.0.256\t\t\t\t"	 "[$(negativeTest '0.0.0.256')]"
echo

## IPv6 Address Type
printInfo "IPv6 Address Type"
echo -e "verifyip :fe80::aa:bb:cc:dd\t\t\t"	"[$(negativeTest ':fe80::aa:bb:cc:dd')]"
echo -e "verifyip :::fe80::aa:bb:cc:dd\t\t\t"	"[$(negativeTest ':::fe80::aa:bb:cc:dd')]"
echo -e "verifyip ::fffff:c000:0280\t\t\t"	"[$(negativeTest '::fffff:c000:0280')]"
echo -e "verifyip ::ffff0:c000:0280\t\t\t"	"[$(negativeTest '::ffff0:c000:0280')]"
echo -e "verifyip ::ffff::c000:0280\t\t\t"	"[$(negativeTest '::ffff::c000:0280')]"
echo -e "verifyip ::ffff:uvw:xyz\t\t\t\t"	"[$(negativeTest '::ffff:uvw:xyz')]"
echo -e "verifyip fe80::aa::bb:cc:dd\t\t\t"	"[$(negativeTest 'fe80::aa::bb:cc:dd')]"
echo -e "verifyip fe80:aa:::bb:cc:dd\t\t\t"	"[$(negativeTest 'fe80:aa:::bb:cc:dd')]"
echo -e "verifyip fe8z::aa:bb:cc:dd\t\t\t"	"[$(negativeTest 'fe80::az:bb:cc:dd')]"
echo -e "verifyip fe80::az:bb:cc:dd\t\t\t"	"[$(negativeTest 'fe80::az:bb:cc:dd')]"
echo -e "verifyip fe80::aa:bz:cc:dd\t\t\t"	"[$(negativeTest 'fe80::aa:bz:cc:dd')]"
echo -e "verifyip fe80::aa:bb:cz:dd\t\t\t"	"[$(negativeTest 'fe80::aa:bb:cz:dd')]"
echo -e "verifyip fe80::aa:bb:cc:dz\t\t\t"	"[$(negativeTest 'fe80::aa:bb:cc:dz')]"
echo -e "verifyip fe80c::aa:bb:cc:dd\t\t\t"	"[$(negativeTest 'fe80c::aa:bb:cc:dd')]"
echo -e "verifyip fe80::fe80c:bb:cc:dd\t\t\t"	"[$(negativeTest 'fe80::fe80c:bb:cc:dd')]"
echo -e "verifyip fe80::aa:fe80c:cc:dd\t\t\t"	"[$(negativeTest 'fe80::aa:fe80c:cc:dd')]"
echo -e "verifyip fe80::aa:bb:fe80c:dd\t\t\t"	"[$(negativeTest 'fe80::aa:bb:fe80c:dd')]"
echo -e "verifyip fe80::aa:bb:cc:fe80c\t\t\t"	"[$(negativeTest 'fe80::aa:bb:cc:fe80c')]"
echo -e "verifyip fe80::aa:bb:cc:dd:\t\t\t"	"[$(negativeTest 'fe80::aa:bb:cc:dd:')]"
echo -e "verifyip 1:2:3::4:5:6:7\t\t\t\t"	"[$(negativeTest '1:2:3::4:5:6:7')]"
echo -e "verifyip 1:2:3:4:5:6:7:8:9\t\t\t"	"[$(negativeTest '1:2:3:4:5:6:7:8:9')]"

exit 0

