/*
 * errorcorrectiontype.c - DevOpsBroker C source file for the org.devopsbroker.sysfs.ErrorCorrectionType enum
 *
 * Copyright (C) 2018-2019 Edward Smith <edwardsmith@devopsbroker.org>
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
 * Developed on Ubuntu 16.04.5 LTS running kernel.osrelease = 4.15.0-36
 *
 * -----------------------------------------------------------------------------
 */

// ════════════════════════════ Feature Test Macros ═══════════════════════════

#define _DEFAULT_SOURCE

// ═════════════════════════════════ Includes ═════════════════════════════════

#include "errorcorrectiontype.h"

#include "../lang/error.h"
#include "../lang/string.h"
#include "../lang/stringbuilder.h"

// ═════════════════════════════ Global Variables ═════════════════════════════

char *d485dfa0_stringList[] = { "None", "ECC", "Multi-bit ECC" };

// ═════════════════════════ Function Implementations ═════════════════════════

ErrorCorrectionType d485dfa0_getErrorCorrectionType(char *source) {
	// Find the appropriate ErrorCorrectionType
	for (register int i = 0; i < d485dfa0_NUM_VALUES; i++) {
		if (f6215943_isEqual(source, d485dfa0_stringList[i])) {
			return i;
		}
	}

	StringBuilder errorMessage;
	c598a24c_initStringBuilder(&errorMessage);

	c598a24c_append_string(&errorMessage, "Could not find '");
	c598a24c_append_string(&errorMessage, source);
	c598a24c_append_string(&errorMessage, "': No such ErrorCorrectionType");

	c7c88e52_printError_string(errorMessage.buffer);
	free(errorMessage.buffer);

	exit(EXIT_FAILURE);
}

char *d485dfa0_toStringErrorCorrectionType(const ErrorCorrectionType ect) {
	return d485dfa0_stringList[ect];
}
