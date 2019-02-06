/*
 * ipv4address.h - DevOpsBroker C header file for the org.devopsbroker.net.IPv4Address struct
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
 * Developed on Ubuntu 18.04.1 LTS running kernel.osrelease = 4.15.0-39
 *
 * echo ORG_DEVOPSBROKER_NET_IPV4ADDRESS | md5sum | cut -c 25-32
 *
 * The method signatures defined in this header file are implemented in the
 * following files:
 *
 *   o ipv4address.linux.asm
 * -----------------------------------------------------------------------------
 */

#ifndef ORG_DEVOPSBROKER_NET_IPV4ADDRESS_H
#define ORG_DEVOPSBROKER_NET_IPV4ADDRESS_H

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdint.h>

#include <assert.h>

// ═══════════════════════════════ Preprocessor ═══════════════════════════════

#define IPV4_STRBUF_LEN   20

// ═════════════════════════════════ Typedefs ═════════════════════════════════

typedef enum IPv4StringType {
	IPV4_ADDR = 0,
	IVP4_CIDR_SUFFIX = 256,
	IPV4_SUBNET = 2,
	IPV4_ROUTE = 259
} IPv4StringType;

typedef struct IPv4Address {
	uint32_t address;         // 192.168.1.102
	uint32_t cidrSuffix;      // 24
	uint32_t subnetMask;      // 255.255.255.0
	uint32_t routingPrefix;   // 192.168.1.0
} IPv4Address;

static_assert(sizeof(IPv4Address) == 16, "Check your assumptions");

// ═════════════════════════════ Global Variables ═════════════════════════════


// ════════════════════════════ Function Prototypes ═══════════════════════════

// ~~~~~~~~~~~~~~~~~~~~~~~~~ Create/Destroy Functions ~~~~~~~~~~~~~~~~~~~~~~~~~

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    e1e7e8f5_createIPv4Address
 * Description: Creates a IPv4Address struct instance
 *
 * Parameters:
 *   ipAddress  A string representation of an IPv4 address
 * Returns:     A IPv4Address struct instance
 * ----------------------------------------------------------------------------
 */
IPv4Address *e1e7e8f5_createIPv4Address(char *ipAddress);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    e1e7e8f5_destroyIPv4Address
 * Description: Frees the memory allocated to the IPv4Address struct pointer
 *
 * Parameters:
 *   ipv4Address    A pointer to the IPv4Address instance to destroy
 * ----------------------------------------------------------------------------
 */
void e1e7e8f5_destroyIPv4Address(IPv4Address *ipv4Address);

// ~~~~~~~~~~~~~~~~~~~~~~~~~ Initialization Functions ~~~~~~~~~~~~~~~~~~~~~~~~~

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    e1e7e8f5_initIPv4Address
 * Description: Initializes an existing IPv4Address struct
 *
 * Parameters:
 *   ipv4Address	A pointer to the IPv4Address instance to initalize
 *   ipAddress      A string representation of an IPv4 address
 * Returns:         Zero if no errors occurred, -1 otherwise
 * ----------------------------------------------------------------------------
 */
int e1e7e8f5_initIPv4Address(IPv4Address *ipv4Address, char *ipAddress);

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Utility Functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    e1e7e8f5_deriveSubnetMask
 * Description: Takes the IPv4 address and CIDR suffix and derives both the
 *              subnet mask and the routing prefix
 *
 * Parameters:
 *   ipv4Address    A pointer to the IPv4Address instance
 * ----------------------------------------------------------------------------
 */
void e1e7e8f5_deriveSubnetMask(IPv4Address *ipv4Address);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    e1e7e8f5_toString
 * Description: Returns the string representation of the IPv4 address
 *
 * Parameters:
 *   ipv4Address    A pointer to the IPv4Address instance to reference
 *   strType        The IPv4 string type to generate
 * Returns:         The string representation of the IPv4 address
 * ----------------------------------------------------------------------------
 */
char *e1e7e8f5_toString(IPv4Address *ipv4Address, IPv4StringType strType);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    e1e7e8f5_extractString
 * Description: Populates the char *buffer with the string representation of
 *              the IPv4 address
 *
 * Parameters:
 *   ipv4Address    A pointer to the IPv4Address instance to reference
 *   strType        The IPv4 string type to generate
 *   buffer         The char *buffer to populate
 * ----------------------------------------------------------------------------
 */
void e1e7e8f5_extractString(IPv4Address *ipv4Address, IPv4StringType strType, char *buffer);

#endif /* ORG_DEVOPSBROKER_NET_IPV4ADDRESS_H */
