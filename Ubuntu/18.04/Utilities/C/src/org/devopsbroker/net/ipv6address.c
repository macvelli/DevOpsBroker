/*
 * ipv6address.c - DevOpsBroker C source file for the org.devopsbroker.net.IPv6Address struct
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
 * Developed on Ubuntu 18.04.1 LTS running kernel.osrelease = 4.15.0-38
 *
 * -----------------------------------------------------------------------------
 */

// ════════════════════════════ Feature Test Macros ═══════════════════════════

#define _DEFAULT_SOURCE

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdlib.h>

#include "ipv6address.h"
#include "ip-util.h"

#include "../lang/error.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ════════════════════════════ Function Prototypes ═══════════════════════════


// ═════════════════════════════ Global Variables ═════════════════════════════


// ═════════════════════════ Function Implementations ═════════════════════════

/*
int b7808f25_initIPv6Address(IPv6Address *ipv6Address, char *ipAddress) {

	char *source = ipAddress;
	register int ch = *source;
	register int arrayLength = 0;
	register uint16_t *hextetArray = ipv6Address->hextetArray;
	int emptyGroupIndex = -1;

	// TODO: Initialize the hextetArray to all zeroes

	if (ch == ':') {
		// Display error if invalid IPv6 format
		if (*(++source) != ':') {
			a25c96b2_invalidIPv6Address(ipAddress);
		}

		// Valid IPv6 Address
		if (*source == '\0') {
			ipv6Address->cidrSuffix = 0;
			return;
		}

		emptyGroupIndex = 0;
		hextetArray[arrayLength++] = b7808f25_getHextetValue(&source);

		if (*source == ':') {
			source++;

			// Check for the special IPv4-mapped notation
			if (hextetArray[0] == 0xffff && a25c96b2_detectIPType(source) == 4) {
				hextetArray[0] = 0;
				hextetArray[1] = 0;
				hextetArray[2] = 0;
				hextetArray[3] = 0;
				hextetArray[4] = 0;
				hextetArray[5] = 0xffff;

				hextetArray[6] = (a25c96b2_getOctetValue(&source) << 8);
				hextetArray[6] |= a25c96b2_getOctetValue(&source);
				hextetArray[7] = (a25c96b2_getOctetValue(&source) << 8);
				hextetArray[7] |= a25c96b2_getOctetValue(&source);

				// Derive cidrSuffix
				ipv6Address->cidrSuffix = (ch == '/') ? a25c96b2_getCIDRSuffix(source, 128) : 0;

				// Display error if invalid IPv6 format
				if (ch || ipv6Address->cidrSuffix == SYSTEM_ERROR_CODE) {
					a25c96b2_invalidIPv6Address(ipAddress);
				}

				// Valid IPv6 Address
				return;
			}
		}
	}

	while (ch && ch != '/' && arrayLength < 8) {
		if (ch == ':') {
			// Display error if invalid IPv6 format
			if (emptyGroupIndex >= 0) {
				a25c96b2_invalidIPv6Address(ipAddress);
			}

			emptyGroupIndex = arrayLength;
			ch = *(++source);
			continue;
		}

		hextetArray[arrayLength++] = b7808f25_getHextetValue(&source);

		ch = *source;
	}

	if (arrayLength == 7) {
		a25c96b2_invalidIPv6Address(ipAddress);
	}

	// Derive cidrSuffix
	ipv6Address->cidrSuffix = (ch == '/') ? a25c96b2_getCIDRSuffix(++source, 128) : 0;

	// Display error if invalid IPv6 format
	if (ipv6Address->cidrSuffix == SYSTEM_ERROR_CODE) {
		a25c96b2_invalidIPv6Address(ipAddress);
	}

	// TODO: Process IPv6 data
	return 0;
}
*/
