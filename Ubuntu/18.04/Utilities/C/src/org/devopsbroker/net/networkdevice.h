/*
 * networkdevice.h - DevOpsBroker C header file for the org.devopsbroker.net.NetworkDevice struct
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
 * echo ORG_DEVOPSBROKER_NET_NETWORKDEVICE | md5sum | cut -c 25-32
 * -----------------------------------------------------------------------------
 */

#ifndef ORG_DEVOPSBROKER_NET_NETWORKDEVICE_H
#define ORG_DEVOPSBROKER_NET_NETWORKDEVICE_H

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdlib.h>
#include <stdint.h>

#include <assert.h>

#include <net/if.h>

#include "ipv4address.h"
#include "ipv6address.h"

#include "../socket/unix.h"
#include "../socket/netlink.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════

typedef struct ifreq NetworkDeviceRequest;   // Request struct for making ioctl calls
/*	char ifr_name[IFNAMSIZ];   // Interface name
	union {
		struct sockaddr ifr_addr;
		struct sockaddr ifr_dstaddr;
		struct sockaddr ifr_broadaddr;
		struct sockaddr ifr_netmask;
		struct sockaddr ifr_hwaddr;
		short           ifr_flags;
		int             ifr_ifindex;
		int             ifr_metric;
		int             ifr_mtu;
		struct ifmap    ifr_map;
		char            ifr_slave[IFNAMSIZ];
		char            ifr_newname[IFNAMSIZ];
		char           *ifr_data;
	}
*/

static_assert(sizeof(NetworkDeviceRequest) == 40, "Check your assumptions");

typedef struct NetworkDevice {
	IPv4Address ipv4Address;
	IPv6Address ipv6Global;
	IPv6Address ipv6Local;
	char *name;                     // enp7s0f3
	IPv6Address ipv6Gateway;
	uint32_t ipv4Gateway;           // e.g. 192.168.1.1
	uint32_t index;                 // e.g. 2
	char _padding[4];
} NetworkDevice;

static_assert(sizeof(NetworkDevice) == 96, "Check your assumptions");

// ═════════════════════════════ Global Variables ═════════════════════════════


// ════════════════════════════ Function Prototypes ═══════════════════════════

// ~~~~~~~~~~~~~~~~~~~~~~~~~ Create/Destroy Functions ~~~~~~~~~~~~~~~~~~~~~~~~~

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f0185083_createNetworkDevice
 * Description: Creates a NetworkDevice struct instance
 *
 * Parameters:
 *   deviceName     The name of the network device
 * Returns:         A NetworkDevice struct instance
 * ---------------------------------------------------------------------NetworkDeviceRequest-------
 */
NetworkDevice *f0185083_createNetworkDevice(char* deviceName);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f0185083_destroyNetworkDevice
 * Description: Frees the memory allocated to the NetworkDevice struct pointer
 *
 * Parameters:
 *   networkDevice	A pointer to the NetworkDevice instance to destroy
 * ----------------------------------------------------------------------------
 */
void f0185083_destroyNetworkDevice(NetworkDevice *networkDevice);

// ~~~~~~~~~~~~~~~~~~~~~~~~~ Initialization Functions ~~~~~~~~~~~~~~~~~~~~~~~~~

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f0185083_initNetworkDevice
 * Description: Initializes an existing NetworkDevice struct
 *
 * Parameters:
 *   networkDevice  A pointer to the NetworkDevice instance to initalize
 *   deviceName     The name of the network device
 * ----------------------------------------------------------------------------
 */
void f0185083_initNetworkDevice(NetworkDevice *networkDevice, char* deviceName);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f0185083_initNetworkDeviceRequest
 * Description: Initializes an existing NetworkDeviceRequest struct
 *
 * Parameters:
 *   networkDevice  A pointer to a NetworkDevice instance
 *   request        A pointer to the NetworkDeviceRequest instance to initialize
 * ----------------------------------------------------------------------------
 */
void f0185083_initNetworkDeviceRequest(NetworkDevice *networkDevice, NetworkDeviceRequest *request);

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Utility Functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f0185083_getIPv4Address
 * Description: Retrieves the IPv4 address for the NetworkDevice struct
 *
 * Parameters:
 *   networkDevice  A pointer to the NetworkDevice instance to populate
 *   netlinkSocket  A pointer to a NetlinkSocket instance
 * ----------------------------------------------------------------------------
 */
void f0185083_getIPv4Address(NetworkDevice *networkDevice, NetlinkSocket *netlinkSocket);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f0185083_getIPv4Gateway
 * Description: Retrieves the IPv4 gateway for the NetworkDevice struct
 *
 * Parameters:
 *   networkDevice  A pointer to the NetworkDevice instance to populate
 *   netlinkSocket  A pointer to a NetlinkSocket instance
 * ----------------------------------------------------------------------------
 */
void f0185083_getIPv4Gateway(NetworkDevice *networkDevice, NetlinkSocket *netlinkSocket);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f0185083_getIPv6Addresses
 * Description: Retrieves the IPv6 addresses for the NetworkDevice struct
 *
 * Parameters:
 *   networkDevice  A pointer to the NetworkDevice instance to populate
 *   netlinkSocket  A pointer to a NetlinkSocket instance
 * ----------------------------------------------------------------------------
 */
void f0185083_getIPv6Addresses(NetworkDevice *networkDevice, NetlinkSocket *netlinkSocket);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f0185083_getIPv6Gateway
 * Description: Retrieves the IPv6 gateway for the NetworkDevice struct
 *
 * Parameters:
 *   networkDevice  A pointer to the NetworkDevice instance to populate
 *   netlinkSocket  A pointer to a NetlinkSocket instance
 * ----------------------------------------------------------------------------
 */
void f0185083_getIPv6Gateway(NetworkDevice *networkDevice, NetlinkSocket *netlinkSocket);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f0185083_getNetworkDeviceIndex
 * Description: Retrieves the index number of a Linux network interface
 *
 * Parameters:
 *   networkDevice	A pointer to the NetworkDevice instance to populate
 *   request        A pointer to a NetworkDeviceRequest instance
 *   unixSocket     A pointer to a UnixSocket instance
 * ----------------------------------------------------------------------------
 */
void f0185083_getNetworkDeviceIndex(NetworkDevice *networkDevice, NetworkDeviceRequest *request, UnixSocket *unixSocket);

#endif /* ORG_DEVOPSBROKER_NET_NETWORKDEVICE_H */
