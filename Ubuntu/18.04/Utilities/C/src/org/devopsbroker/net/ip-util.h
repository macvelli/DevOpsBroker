/*
 * ip-util.h - DevOpsBroker C header file for IP-related utility functions
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
 * echo ORG_DEVOPSBROKER_NET_IPUTIL_H | md5sum | cut -c 25-32
 * -----------------------------------------------------------------------------
 */

#ifndef ORG_DEVOPSBROKER_NET_IPUTIL_H
#define ORG_DEVOPSBROKER_NET_IPUTIL_H

// ═════════════════════════════════ Includes ═════════════════════════════════

//#include <stdint.h>

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ═════════════════════════════ Global Variables ═════════════════════════════


// ════════════════════════════ Function Prototypes ═══════════════════════════

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    a25c96b2_detectIPType
 * Description: Detects whether an IP address is IPv4 or IPv6
 *
 * Parameters:
 *   ipAddress      A string representation of an IP address
 * Returns:         A 4 for an IPv4 address, a 6 for an IPv6 address or -1 if invalid
 * ----------------------------------------------------------------------------
 */
int a25c96b2_detectIPType(const char *ipAddress);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    a25c96b2_invalidIPv4Address
 * Description: Prints an error message for an invalid IPv4 address and exits
 *
 * Parameters:
 *   ipAddress      An invalid string representation of an IPv4 address
 * ----------------------------------------------------------------------------
 */
void a25c96b2_invalidIPv4Address(const char *ipAddress);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    a25c96b2_invalidIPv6Address
 * Description: Prints an error message for an invalid IPv6 address and exits
 *
 * Parameters:
 *   ipAddress      An invalid string representation of an IPv6 address
 * ----------------------------------------------------------------------------
 */
void a25c96b2_invalidIPv6Address(const char *ipAddress);

#endif /* ORG_DEVOPSBROKER_NET_IPUTIL_H */
