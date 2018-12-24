/*
 * ipv4address.c - DevOpsBroker C source file for the org.devopsbroker.net.IPv4Address struct
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
 * Developed on Ubuntu 18.04.1 LTS running kernel.osrelease = 4.15.0-39
 *
 * -----------------------------------------------------------------------------
 */

// ════════════════════════════ Feature Test Macros ═══════════════════════════

#define _DEFAULT_SOURCE

// ═════════════════════════════════ Includes ═════════════════════════════════

#include "ipv4address.h"

#include "../lang/string.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════


// ═════════════════════════════ Global Variables ═════════════════════════════


// ═════════════════════════ Function Implementations ═════════════════════════
/*
char *e1e7e8f5_toString_ipAddress(IPv4Address *ipv4Address, bool addCIDRSuffix) {
	char *ipAddress = malloc(sizeof(char) * 20);
	char *target = ipAddress;
	uint32_t address = ipv4Address->address;
	uint32_t value, remainder;

	// Convert first octet
	value = (address >> 24) & 0xFF;

	if (value >= 100) {
		remainder = value % 100;
		value /= 100;
		*(target++) = '0' + value;
		*(target++) = f6215943_digitTens[remainder];
		*(target++) = f6215943_digitOnes[remainder];
	} else if (value >= 10) {
		*(target++) = f6215943_digitTens[value];
		*(target++) = f6215943_digitOnes[value];
	} else {
		*(target++) = '0' + value;
	}

	*(target++) = '.';

	// Convert second octet
	value = (address >> 16) & 0xFF;

	if (value >= 100) {
		remainder = value % 100;
		value /= 100;
		*(target++) = '0' + value;
		*(target++) = f6215943_digitTens[remainder];
		*(target++) = f6215943_digitOnes[remainder];
	} else if (value >= 10) {
		*(target++) = f6215943_digitTens[value];
		*(target++) = f6215943_digitOnes[value];
	} else {
		*(target++) = '0' + value;
	}

	*(target++) = '.';

	// Convert third octet
	value = (address >> 8) & 0xFF;

	if (value >= 100) {
		remainder = value % 100;
		value /= 100;
		*(target++) = '0' + value;
		*(target++) = f6215943_digitTens[remainder];
		*(target++) = f6215943_digitOnes[remainder];
	} else if (value >= 10) {
		*(target++) = f6215943_digitTens[value];
		*(target++) = f6215943_digitOnes[value];
	} else {
		*(target++) = '0' + value;
	}

	*(target++) = '.';

	// Convert fourth octet
	value = address & 0xFF;

	if (value >= 100) {
		remainder = value % 100;
		value /= 100;
		*(target++) = '0' + value;
		*(target++) = f6215943_digitTens[remainder];
		*(target++) = f6215943_digitOnes[remainder];
	} else if (value >= 10) {
		*(target++) = f6215943_digitTens[value];
		*(target++) = f6215943_digitOnes[value];
	} else {
		*(target++) = '0' + value;
	}

	// Add CIDR suffix
	value = ipv4Address->cidrSuffix;
	if (addCIDRSuffix && value > 0) {
		*(target++) = '/';

		if (value >= 10) {
			*(target++) = f6215943_digitTens[value];
			*(target++) = f6215943_digitOnes[value];
		} else {
			*(target++) = '0' + value;
		}
	}

	*(target) = '\0';

	return ipAddress;
}
*/
