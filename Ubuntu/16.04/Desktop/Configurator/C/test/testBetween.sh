#!/bin/bash

#
# testBetween.sh - DevOpsBroker Bash test script for the between utility
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
between="$EXEC_DIR/between"

# Data directory
dataDir="$SCRIPT_DIR/between"

# Data input file
unicode="$dataDir/unicode.html"

# Diff command
DIFF="/usr/bin/diff -ad"

# Pass/Fail messages
pass="$(bold padua)pass$(reset)"
fail="$(bold bittersweet)fail$(reset)"

# Clean any lingering .out files
rm -f "$dataDir/*.out"


################################## Functions ##################################

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function:	negativeTest
# Description:	Expects a negative outcome from the applied test
#
# Parameter $1:	START parameter
# Parameter $2:	END parameter
# Parameter $3:	Name of file to process
# -----------------------------------------------------------------------------
function negativeTest() {
  local exitCode=0

  # 1. Run the test
  $between $1 $2 $3 1>/dev/null

  exitCode=$?

  if [ $exitCode -ne 0 ]; then
    echo $pass

    return 0;
  else
    echo $fail

    return 1;
  fi
}

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function:	positiveTest
# Description:	Expects a positive outcome from the applied test
#
# Parameter $1:	START parameter
# Parameter $2:	END parameter
# Parameter $3: Expected output file
# -----------------------------------------------------------------------------
function positiveTest() {
  local exitCode=0

  # 1. Run the test and save output to $dataDir/$3.out
  if [ ! -z "$1" ] && [ ! -z "$2" ] && [ -z "$3" ]; then
    cat "$dataDir/pre-div-test.expect" | $between $1 $2
  else
    "$between" "$1" "$2" "$unicode" > "$dataDir/$3.out"
  fi

  exitCode=$?

  if [ $exitCode -ne 0 ]; then
    echo $fail

    return 1;
  elif [ -z "$3" ]; then
    echo $pass

    return 0;
  fi

  # 2. Compare expected and actual outputs
  $DIFF "$dataDir/$3" "$dataDir/$3.out"

  exitCode=$?

  if [ $exitCode -eq 0 ]; then
    # Clean up successful output file
    rm -f $dataDir/$3.out

    echo $pass

    return 0;
  else
    echo $fail

    return 1;
  fi
}


################################### Testing ###################################

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Positive Testing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

printBanner "Positive Testing"

# between "<pre>" "</pre>" unicode.html
echo -e "between \"<pre>\" \"</pre>\" unicode.html\t\t"		"[$(positiveTest '<pre>' '</pre>' 'pre-test.expect')]"

# between "<title>" "</title>" unicode.html 
echo -e "between \"<title>\" \"</title>\" unicode.html\t"	"[$(positiveTest '<title>' '</title>' 'title-test.expect')]"

# between "</pre>" "</div>" unicode.html 
echo -e "between \"</pre>\" \"</div>\" unicode.html\t\t"	"[$(positiveTest '</pre>' '</div>' 'pre-div-test.expect')]"

# between foo bar 
echo -e "between foo bar\t\t\t\t\t"				"[$(positiveTest foo bar)]"

echo

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Negative Testing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

printBanner "Negative Testing"

## Argument Testing
printInfo "Argument Testing"
echo -e "between\t\t\t\t\t\t"	 	 "[$(negativeTest)]"
echo -e "between foo\t\t\t\t\t" 	 "[$(negativeTest foo)]"
echo -e "between foo bar baz\t\t\t\t"	 "[$(negativeTest foo bar baz)]"
echo

exit 0

