/*
 * verifyip.c - DevOpsBroker utility for validating the input parameter is
 *		either a valid IPv4 or IPv6 address
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

#include "ansi.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ════════════════════════════════ Structures ════════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════

int detectIPType(char *ip);
void verifyIPv4(char *ip);
void verifyIPv6(char *ip);

// ═════════════════════════════ Global Variables ═════════════════════════════


// ══════════════════════════════════ main() ══════════════════════════════════

int main(int argc, char *argv[]) {
  if (argc < 2) {
    printUsage("verifyip IP_ADDR");
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
    // Could not detect IP Address Type
    exit(EXIT_FAILURE);
  }

  // Exit with success
  exit(EXIT_SUCCESS);
}

// ═════════════════════════ Function Implementations ═════════════════════════

int detectIPType(char *ip) {
  if (*(ip) == ':') {
    // IPv6 Address Type
    return 6;
  }

  char ch;
  for (char *ptr = ip; *(ptr) != '\0'; ptr++) {
    ch = *(ptr);

    if (ch == '.') {
      // IPv4 Address Type
      return 4;
    }

    if ((ch >= 'a' && ch <= 'f') || (ch >= 'A' && ch <= 'F') || ch == ':') {
      // IPv6 Address Type
      return 6;
    }
  }

  // Could not detect IP Address Type
  return 0;
}

void verifyIPv4(char *ip) {
  int count = 0;
  int groups = 1;
  int octet = 0;
  char ch;

  for (char *ptr = ip; *(ptr) != '\0'; ptr++) {
    ch = *(ptr);

    if (ch >= '0' && ch <= '9') {
      count++;
      octet = (octet * 10) + (ch - '0');

    } else if (ch == '.') {
      if (count == 0 || octet > 255) {
	// Invalid IP Address format
	exit(EXIT_FAILURE);
      }

      groups++;
      count = 0;
      octet = 0;
    } else {
      // Invalid character detected in IP Address
      exit(EXIT_FAILURE);
    }

    if (count > 3 || groups > 4) {
      // Invalid IP Address format
      exit(EXIT_FAILURE);
    }
  }

  if (groups != 4 || count == 0 || octet > 255) {
    // Invalid IP Address format
    exit(EXIT_FAILURE);
  }

}

void verifyIPv6(char *ip) {
  char *ptr = ip;
  int count = 0;
  int groups = 1;
  bool emptyGroup = false;
  char ch = *(ptr);

  // Verify IPv6 Address that starts with a colon
  if (ch == ':') {
    if (*(++ptr) != ':') {
      // Invalid IP Address format
      exit(EXIT_FAILURE);
    }

    if (*(++ptr) == ':') {
      // Invalid IP Address format
      exit(EXIT_FAILURE);
    } else if (*(ptr) == '\0') {
      // Valid IPv6 Address format
      return;
    }

    emptyGroup = true;
    groups++;

    // Check for the special IPv4-mapped notation
    while (*(ptr) == 'f' || *(ptr) == 'F') {
      count++;
      ptr++;

      if (count > 4) {
	// Invalid IP Address format
	exit(EXIT_FAILURE);
      }
    }

    if (count == 4) {
      if (*(ptr) == ':') {
	if (*(++ptr) == ':') {
	  // Invalid IP Address format
	  exit(EXIT_FAILURE);
	}

	int ipType = detectIPType(ptr);

	if (ipType == 4) {
	  verifyIPv4(ptr);

	  return;
	}

	groups++;
	count = 0;
      }
    }
  }

  while (*(ptr) != '\0') {
    ch = *(ptr);

    if ((ch >= '0' && ch <= '9') || (ch >= 'a' && ch <= 'f') || (ch >= 'A' && ch <= 'F')) {
      count++;
      ptr++;

    } else if (ch == ':') {
      groups++;
      count = 0;

      if (*(++ptr) == ':') {
	if (emptyGroup || *(++ptr) == ':') {
	  // Invalid IP Address format
	  exit(EXIT_FAILURE);
	}

	emptyGroup = true;
      }

    } else {
      // Invalid character detected in IP Address
      exit(EXIT_FAILURE);
    }

    if (count > 4 || groups > 8) {
      // Invalid IP Address format
      exit(EXIT_FAILURE);
    }
  }

  if (count == 0 || (emptyGroup && groups > 6)) {
    // Invalid IP Address format
    exit(EXIT_FAILURE);
  }

}
