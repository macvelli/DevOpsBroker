#!/bin/bash

#
# c-struct-source.tpl - DevOpsBroker template script for generating C struct source files
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
# Developed on Ubuntu 16.04.5 LTS running kernel.osrelease = 4.15.0-34
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

################################## Variables ##################################

## Bash exec variables
EXEC_MD5SUM=/usr/bin/md5sum
EXEC_VERIFYCLASS=/usr/local/bin/verifyclass

## Options
structName="$1"

## Variables
includeGuard=''
typedefName=''
md5Hash=''
filename=''
variableName=''

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ OPTION Parsing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Display usage if struct name is missing
if [ -z "$structName" ]; then
	printUsage 'c-struct-source.tpl com.example.foo.Bar'
	exit 1
fi

# Display error if struct name is invalid
if ! $EXEC_VERIFYCLASS "$structName"; then
	printError 'c-struct-source.tpl' "Invalid C struct name: '$structName'"
	echo
	printUsage 'c-struct-source.tpl com.example.foo.Bar'

	exit 1
fi

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Template ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Set the C header file include guard
includeGuard="${structName//./_}"
includeGuard="${includeGuard^^}"

# Set the typedef name
typedefName="$(echo $structName | $EXEC_GREP -Eo '([A-Z][a-zA-Z0-9]+){1}$')"

# Set the md5hash of the include guard
md5Hash=$(echo $includeGuard | $EXEC_MD5SUM | $EXEC_CUT -c 25-32)

# Set the file name according to the typedef name
filename=${typedefName,,}

# Set the variable name according to the typedef name
variableName=${typedefName,}

# Set $ubuntuRelease and $kernelVersion variables
ubuntuRelease=${2:-"$(getUbuntuRelease)"}
kernelVersion=${3:-"$(getKernelVersion)"}

## Template
/bin/cat << EOF > $filename.h
/*
 * $filename.h - C header file for the ${structName} struct
 *
 * Copyright (C) 2018 AUTHOR_NAME <email@address.com>
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 * -----------------------------------------------------------------------------
 * Developed on $ubuntuRelease running kernel.osrelease = $kernelVersion
 *
 * echo $includeGuard | md5sum | cut -c 25-32
 * -----------------------------------------------------------------------------
 */

#ifndef ${includeGuard}_H
#define ${includeGuard}_H

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdlib.h>

#include <assert.h>

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════

typedef struct $typedefName {

	// TODO: Fill in with the attributes for the struct

} $typedefName;

static_assert(sizeof($typedefName) == 64, "Check your assumptions");

// ═════════════════════════════ Global Variables ═════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    ${md5Hash}_create${typedefName}
 * Description: Creates a ${typedefName} struct instance
 *
 * Returns:     A ${typedefName} struct instance
 * ----------------------------------------------------------------------------
 */
static inline ${typedefName} *${md5Hash}_create${typedefName}() {
	${typedefName} *${variableName} = malloc(sizeof(${typedefName}));

	// TODO: Fill in with struct initialization code

	return ${variableName};
}

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    ${md5Hash}_destroy${typedefName}
 * Description: Frees the memory allocated to the ${typedefName} struct pointer
 *
 * Parameters:
 *   ${variableName}	A pointer to the ${typedefName} instance to destroy
 * ----------------------------------------------------------------------------
 */
static inline void ${md5Hash}_destroy${typedefName}(${typedefName} *${variableName}) {
	free(${variableName});
}

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    ${md5Hash}_init${typedefName}
 * Description: Initializes an existing ${typedefName} struct
 *
 * Parameters:
 *   ${variableName}	A pointer to the ${typedefName} instance to initalize
 * ----------------------------------------------------------------------------
 */
static inline void ${md5Hash}_init${typedefName}(${typedefName} *${variableName}) {

	// TODO: Fill in with struct initialization code

}

#endif /* ${includeGuard}_H */

EOF

/bin/cat << EOF >> $filename.c
/*
 * $filename.c - C source file for the ${structName} struct
 *
 * Copyright (C) 2018 AUTHOR_NAME <email@address.com>
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 * -----------------------------------------------------------------------------
 * Developed on $ubuntuRelease running kernel.osrelease = $kernelVersion
 *
 * -----------------------------------------------------------------------------
 */

// ════════════════════════════ Feature Test Macros ═══════════════════════════

#define _DEFAULT_SOURCE

// ═════════════════════════════════ Includes ═════════════════════════════════

#include "$filename.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════


// ═════════════════════════════ Global Variables ═════════════════════════════


// ═════════════════════════ Function Implementations ═════════════════════════


EOF

exit 0
