/*
 * verifyip.c - DevOpsBroker utility for validating IPv4 or IPv6 addresses
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
 * ----------------------------------------------------------------------------
 * Developed on Ubuntu 16.04.4 LTS running kernel.osrelease = 4.13.0-43
 *
 * https://en.wikipedia.org/wiki/IPv6_address
 *   o IPv6 address is represented as eight groups of four hexadecimal digits
 *   o Groups are separated by colons (:)
 *   o Hexadecimal digits are case-insensitive
 *   o Leading zeroes in a group may be omitted, but each group must retain at
 *     least one hexadecimal digit
 *   o One or more consecutive groups containing zeros only may be replaced
 *     with a single empty group, using two consecutive colons (::) This
 *     substitution may only be applied once to avoid ambiguity
 *   o Supports the special IPv4-mapped notation ::ffff:192.0.2.128
 *   o (::) is not used to shorten just a single 0 field
 *
 * TODO: Read from stdin
 * ----------------------------------------------------------------------------
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#include "org/devopsbroker/lang/error.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════

static int detectIPType(const char *ipAddress);
static void verifyIPv4(const char *ipAddress);
static void verifyIPv6(const char *ipAddress);

// ═════════════════════════════ Global Variables ═════════════════════════════


// ══════════════════════════════════ main() ══════════════════════════════════

int main(int argc, char *argv[]) {
	if (argc < 2) {
		c7c88e52_printUsage("verifyip IP_ADDR");
		exit(EXIT_FAILURE);
	}

	// IP Address parameter
	char *ip = argv[1];
	int ipType = detectIPType(ip);

	if (ipType == 4) {
		verifyIPv4(ip);
	} else if (ipType == 6) {
		verifyIPv6(ip);
	} else {
		exit(EXIT_FAILURE);
	}

	// Exit with success
	exit(EXIT_SUCCESS);
}

// ═════════════════════════ Function Implementations ═════════════════════════

static int detectIPType(register const char *ipAddress) {
	register char ch = *ipAddress;

	while (ch) {
		// IPv4 Address Type
		if (ch == '.') {
			return 4;
		}

		// IPv6 Address Type
		if ((ch >= 'a' && ch <= 'f') || (ch >= 'A' && ch <= 'F') || ch == ':') {
			return 6;
		}

		ch = (*++ipAddress);
	}

	// Could not detect IP Address Type
	exit(EXIT_FAILURE);
}

static void verifyIPv4(register const char *ipAddress) {
	register char ch = *ipAddress;
	register int octet = 0;
	register int count = 0;
	register int groups = 1;

	while (ch) {
		if (ch >= '0' && ch <= '9') {
			octet *= 10;
			octet += (ch - '0');

			// Invalid IP Address format
			if (octet > 255 || ++count > 3) {
				exit(EXIT_FAILURE);
			}
		} else if (ch == '.') {
			// Invalid IP Address format
			if (count == 0 || ++groups > 4) {
				exit(EXIT_FAILURE);
			}

			count = 0;
			octet = 0;
		} else {
			// Invalid character detected in IP Address
			exit(EXIT_FAILURE);
		}

		ch = (*++ipAddress);
	}

	// Invalid IP Address format
	if (groups != 4 || count == 0) {
		exit(EXIT_FAILURE);
	}
}

static void verifyIPv6(register const char *ipAddress) {
	register char ch = *ipAddress;
	register int count = 0;
	register int groups = 1;
	bool hasEmptyGroup = false;

	// Verify IPv6 Address that starts with a colon
	if (ch == ':') {
		// Invalid IP Address format
		if (*(++ipAddress) != ':') {
			exit(EXIT_FAILURE);
		}

		ch = *(++ipAddress);
		// Invalid IP Address format
		if (ch == ':') {
			exit(EXIT_FAILURE);
		}

		// Valid IPv6 Address format
		if (ch == '\0') {
			return;
		}

		hasEmptyGroup = true;
		groups++;

		// Check for the special IPv4-mapped notation
		if (ch == 'f' || ch == 'F') {
			do {
				// Invalid IP Address format
				if (++count > 4) {
					exit(EXIT_FAILURE);
				}

				ch = *(++ipAddress);
			} while (ch == 'f' || ch == 'F');

			if (count == 4) {
				// Invalid IP Address format
				if (ch != ':') {
					exit(EXIT_FAILURE);
				}

				ch = *(++ipAddress);
				// Invalid IP Address format
				if (ch == ':') {
					exit(EXIT_FAILURE);
				}

				int ipType = detectIPType(ipAddress);
				if (ipType == 4) {
					verifyIPv4(ipAddress);
					return;
				}
			} else {
				while (ch != ':') {
					if ((ch >= '0' && ch <= '9') || (ch >= 'a' && ch <= 'f') || (ch >= 'A' && ch <= 'F')) {
						// Invalid IP Address format
						if (++count > 4) {
							exit(EXIT_FAILURE);
						}

						ch = *(++ipAddress);
					} else {
						// Invalid IP Address format
						exit(EXIT_FAILURE);
					}
				}

				ch = *(++ipAddress);
				// Invalid IP Address format
				if (ch == ':') {
					exit(EXIT_FAILURE);
				}
			}

			groups++;
			count = 0;
		}
	}

	do {
		if ((ch >= '0' && ch <= '9') || (ch >= 'a' && ch <= 'f') || (ch >= 'A' && ch <= 'F')) {
			// Invalid IP Address format
			if (++count > 4) {
				exit(EXIT_FAILURE);
			}

			ch = *(++ipAddress);
		} else if (ch == ':') {
			ch = *(++ipAddress);

			if (ch == ':') {
				// Invalid IP Address format
				if (hasEmptyGroup) {
					exit(EXIT_FAILURE);
				}

				ch = *(++ipAddress);
				// Invalid IP Address format
				if (ch == ':') {
					exit(EXIT_FAILURE);
				}

				hasEmptyGroup = true;
			}

			// Invalid IP Address format
			if (++groups > 8) {
				exit(EXIT_FAILURE);
			}

			count = 0;
		} else {
			// Invalid character detected in IP Address
			exit(EXIT_FAILURE);
		}
	} while (ch);

	// Invalid IP Address format
	if (count == 0 || (hasEmptyGroup && groups > 6)) {
		exit(EXIT_FAILURE);
	}
}
