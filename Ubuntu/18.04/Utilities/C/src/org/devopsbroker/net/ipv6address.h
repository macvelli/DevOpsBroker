/*
 * ipv6address.h - DevOpsBroker C header file for the org.devopsbroker.net.IPv6Address struct
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
 * Developed on Ubuntu 18.04.1 LTS running kernel.osrelease = 4.15.0-38
 *
 * echo ORG_DEVOPSBROKER_NET_IPV6ADDRESS | md5sum | cut -c 25-32
 * -----------------------------------------------------------------------------
 */

#ifndef ORG_DEVOPSBROKER_NET_IPV6ADDRESS_H
#define ORG_DEVOPSBROKER_NET_IPV6ADDRESS_H

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdint.h>

#include <assert.h>

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════

typedef struct IPv6Address {
	uint16_t global[8];        // 1234:5678:9abc:def0:0fed:cba9:8765:4321
	uint16_t local[8];         // fe80::1234:5678:9abc:def0
	int cidrSuffix;            // e.g. 48
} IPv6Address;

static_assert(sizeof(IPv6Address) == 36, "Check your assumptions");

// ═════════════════════════════ Global Variables ═════════════════════════════


// ════════════════════════════ Function Prototypes ═══════════════════════════

// ~~~~~~~~~~~~~~~~~~~~~~~~~ Create/Destroy Functions ~~~~~~~~~~~~~~~~~~~~~~~~~

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    b7808f25_createIPv6Address
 * Description: Creates an IPv6Address struct instance
 *
 * Parameters:
 *   ipAddress  A string representation of an IPv6 address
 * Returns:     An IPv6Address struct instance
 * ----------------------------------------------------------------------------
 */
IPv6Address *b7808f25_createIPv6Address(char *ipAddress);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    b7808f25_destroyIPv6Address
 * Description: Frees the memory allocated to the IPv6Address struct pointer
 *
 * Parameters:
 *   iPv6Address	A pointer to the IPv6Address instance to destroy
 * ----------------------------------------------------------------------------
 */
void b7808f25_destroyIPv6Address(IPv6Address *iPv6Address);

// ~~~~~~~~~~~~~~~~~~~~~~~~~ Initialization Functions ~~~~~~~~~~~~~~~~~~~~~~~~~

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    b7808f25_initIPv6Address
 * Description: Initializes an existing IPv6Address struct
 *
 * Parameters:
 *   iPv6Address	A pointer to the IPv6Address instance to initalize
 *   ipAddress      A string representation of an IPv6 address
 * ----------------------------------------------------------------------------
 */
void b7808f25_initIPv6Address(IPv6Address *ipv6Address, char *ipAddress);

#endif /* ORG_DEVOPSBROKER_NET_IPV6ADDRESS_H */
