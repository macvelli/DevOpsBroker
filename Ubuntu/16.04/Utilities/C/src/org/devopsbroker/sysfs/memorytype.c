/*
 * memorytype.c - DevOpsBroker C source file for the org.devopsbroker.sysfs.MemoryType enum
 *
 * Copyright (C) 2018 Edward Smith <edwardsmith@devopsbroker.org>
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

#include "memorytype.h"

#include "../lang/error.h"
#include "../lang/string.h"
#include "../lang/stringbuilder.h"

// ═════════════════════════════ Global Variables ═════════════════════════════

char *memoryTypes = "Unknown\0SDRAM\0DDR\0DDR2\0DDR3\0DDR4\0";

const int c8391d73_stringIndexList[] = { 0, 8, 14, 18, 23, 28 };

// ═════════════════════════ Function Implementations ═════════════════════════

MemoryType c8391d73_getMemoryType(register char *source) {
	// Find the appropriate MemoryType
	register int stringIndex;
	for (register int i = 0; i < c8391d73_NUM_VALUES; i++) {
		// TODO: There is an opportunity to do a better search here
		stringIndex = c8391d73_stringIndexList[i];
		if (f6215943_search(source, &memoryTypes[stringIndex])) {
			return i;
		}
	}

	StringBuilder errorMessage;
	c598a24c_initStringBuilder(&errorMessage);

	c598a24c_append_string(&errorMessage, "Could not find '");
	c598a24c_append_string(&errorMessage, source);
	c598a24c_append_string(&errorMessage, "': No such MemoryType");

	c7c88e52_printError_string(errorMessage.buffer);
	free(errorMessage.buffer);

	exit(EXIT_FAILURE);
}

char *c8391d73_toStringMemoryType(const MemoryType memoryType) {
	register int stringIndex = c8391d73_stringIndexList[memoryType];
	return &memoryTypes[stringIndex];
}
