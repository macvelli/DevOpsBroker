/*
 * ip-util.c - DevOpsBroker C source file for IP-related utility functions
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
 *
 * -----------------------------------------------------------------------------
 * Developed on Ubuntu 18.04.1 LTS running kernel.osrelease = 4.15.0-38
 *
 * -----------------------------------------------------------------------------
 */

// ════════════════════════════ Feature Test Macros ═══════════════════════════

#define _DEFAULT_SOURCE

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdio.h>

#include "ip-util.h"

#include "../lang/error.h"
#include "../lang/stringbuilder.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ═════════════════════════════ Global Variables ═════════════════════════════


// ═════════════════════════ Function Implementations ═════════════════════════
/*
int a25c96b2_detectIPType(register const char *ipAddress) {
	register char ch = *ipAddress | 0x20;
	register uint32_t charPos = 0;

	while (ch && charPos < 5) {
		// IPv4 Address Type
		if (ch == '.') {
			return 4;
		}

		// IPv6 Address Type
		if (ch == ':' || (ch >= 'a' && ch <= 'f')) {
			return 6;
		}

		ch = *(++ipAddress) | 0x20;
		charPos++;
	}

	// Could not detect IP Address Type
	return SYSTEM_ERROR_CODE;
}

uint32_t a25c96b2_getByteValue(register char **ipAddress) {
	register char *source = *ipAddress;
	register char ch = *source;
	register uint32_t value = 0;
	register int digit;

	do {
		digit = ch - '0';

		// Display error if digit is not a number
		if (digit < 0 || digit > 9) {
			a25c96b2_invalidIPv4Address(*ipAddress);
		}

		value *= 10;
		value += digit;

		// Display error if invalid decimal value
		if (value > 255) {
			a25c96b2_invalidIPv4Address(*ipAddress);
		}

		ch = *(++source);
	} while (ch && ch != '.' && ch != '/');

	return value;
}
*/
void a25c96b2_invalidIPv4Address(register const char *ipAddress) {
	StringBuilder errorMessage;
	c598a24c_initStringBuilder_uint32(&errorMessage, 128);

	c598a24c_append_string(&errorMessage, "Invalid IPv4 Address: '");
	c598a24c_append_string(&errorMessage, ipAddress);
	c598a24c_append_char(&errorMessage, '\'');

	c7c88e52_printError_string(errorMessage.buffer);
	free(errorMessage.buffer);
	exit(EXIT_FAILURE);
}

void a25c96b2_invalidIPv6Address(register const char *ipAddress) {
	StringBuilder errorMessage;
	c598a24c_initStringBuilder_uint32(&errorMessage, 128);

	c598a24c_append_string(&errorMessage, "Invalid IPv6 Address: '");
	c598a24c_append_string(&errorMessage, ipAddress);
	c598a24c_append_char(&errorMessage, '\'');

	c7c88e52_printError_string(errorMessage.buffer);
	free(errorMessage.buffer);
	exit(EXIT_FAILURE);
}
