/*
 * ipv6address.h - DevOpsBroker C header file for the org.devopsbroker.net.IPv6Address struct
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
 * echo ORG_DEVOPSBROKER_NET_IPV6ADDRESS | md5sum | cut -c 25-32
 *
 * The method signatures defined in this header file are implemented in the
 * following files:
 *
 *   o ipv6address.linux.asm
 *   o ipv6address.c (TODO: Migrate all functionality to ASM)
 * -----------------------------------------------------------------------------
 */

#ifndef ORG_DEVOPSBROKER_NET_IPV6ADDRESS_H
#define ORG_DEVOPSBROKER_NET_IPV6ADDRESS_H

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdbool.h>
#include <stdint.h>

#include <assert.h>

// ═══════════════════════════════ Preprocessor ═══════════════════════════════

#define IPV6_STRBUF_LEN   48

// ═════════════════════════════════ Typedefs ═════════════════════════════════

typedef struct IPv6Address {
	uint8_t address[16];   // 2001:db8:1234:5678:9abc:def0:fed:cba9
	uint32_t cidrSuffix;   // e.g. 48
} IPv6Address;

static_assert(sizeof(IPv6Address) == 20, "Check your assumptions");

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
 *   ipv6Address	A pointer to the IPv6Address instance to destroy
 * ----------------------------------------------------------------------------
 */
void b7808f25_destroyIPv6Address(IPv6Address *ipv6Address);

// ~~~~~~~~~~~~~~~~~~~~~~~~~ Initialization Functions ~~~~~~~~~~~~~~~~~~~~~~~~~

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    b7808f25_initIPv6Address
 * Description: Initializes an existing IPv6Address struct
 *
 * Parameters:
 *   iPv6Address	A pointer to the IPv6Address instance to initalize
 *   ipAddress      A string representation of an IPv6 address
 * Returns:         Zero if no errors occurred, -1 otherwise
 * ----------------------------------------------------------------------------
 */
int b7808f25_initIPv6Address(IPv6Address *ipv6Address, char *ipAddress);

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Utility Functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    b7808f25_deriveSubnet
 * Description: Takes the IPv6 address and derives the subnet which is always
 *              the highest 64 bits of the IPv6 address
 *
 * Parameters:
 *   ipv6Address    A pointer to the IPv6Address instance
 *   ipv6Subnet     A pointer to the IPv6Address to populate with the subnet
 * ----------------------------------------------------------------------------
 */
void b7808f25_deriveSubnet(IPv6Address *ipv6Address, IPv6Address *ipv6Subnet);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    b7808f25_extractString
 * Description: Populates the char *buffer with the string representation of
 *              the IPv6 address
 *
 * Parameters:
 *   ipv6Address    A pointer to the IPv4Address instance to reference
 *   buffer         The char *buffer to populate
 * ----------------------------------------------------------------------------
 */
void b7808f25_extractString(IPv6Address *ipv6Address, char *buffer);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    b7808f25_isIpAddressZero
 * Description: Detects whether or not an IPv6 address is zero
 *
 * Parameters:
 *   ipv6Address    A pointer to the IPv4Address instance to reference
 * Returns:         True if the IPv6 address is zero, false otherwise
 * ----------------------------------------------------------------------------
 */
bool b7808f25_isIpAddressZero(IPv6Address *ipv6Address);

#endif /* ORG_DEVOPSBROKER_NET_IPV6ADDRESS_H */
