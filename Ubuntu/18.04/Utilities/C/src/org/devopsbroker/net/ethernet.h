/*
 * ethernet.h - DevOpsBroker C header file for the org.devopsbroker.net.Ethernet struct
 *
 * Copyright (C) 2019 Edward Smith <edwardsmith@devopsbroker.org>
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
 * Developed on Ubuntu 18.04.1 LTS running kernel.osrelease = 4.15.0-43
 *
 * echo ORG_DEVOPSBROKER_NET_ETHERNET | md5sum | cut -c 25-32
 * -----------------------------------------------------------------------------
 */

#ifndef ORG_DEVOPSBROKER_NET_ETHERNET_H
#define ORG_DEVOPSBROKER_NET_ETHERNET_H

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdlib.h>
#include <stdint.h>

#include <assert.h>

#include <net/if.h>
#include <linux/ethtool.h>

#include "../socket/ipv4.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════

typedef struct ifreq EthernetRequest;   // Request struct for making ioctl calls
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

static_assert(sizeof(EthernetRequest) == 40, "Check your assumptions");

typedef struct ethtool_cmd EthernetStatus;
/*	uint32_t    cmd;
	uint32_t    supported;
	uint32_t    advertising;
	uint16_t    speed;
	uint8_t     duplex;
	uint8_t     port;
	uint8_t     phy_address;
	uint8_t     transceiver;
	uint8_t     autoneg;
	uint8_t     mdio_support;
	uint32_t    maxtxpkt;
	uint32_t    maxrxpkt;
	uint16_t    speed_hi;
	uint8_t     eth_tp_mdix;
	uint8_t     eth_tp_mdix_ctrl;
	uint32_t    lp_advertising;
	uint32_t    reserved[2];
*/

static_assert(sizeof(EthernetStatus) == 44, "Check your assumptions");

typedef struct Ethernet {
	EthernetStatus status;
	uint32_t speed;
	uint32_t mtu;
} Ethernet;

static_assert(sizeof(Ethernet) == 52, "Check your assumptions");

// ═════════════════════════════ Global Variables ═════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    d3843373_createEthernet
 * Description: Creates a Ethernet struct instance
 *
 * Returns:     A Ethernet struct instance
 * ----------------------------------------------------------------------------
 */
static inline Ethernet *d3843373_createEthernet() {
	Ethernet *ethernet = malloc(sizeof(Ethernet));

	// TODO: Fill in with struct initialization code

	return ethernet;
}

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    d3843373_destroyEthernet
 * Description: Frees the memory allocated to the Ethernet struct pointer
 *
 * Parameters:
 *   ethernet	A pointer to the Ethernet instance to destroy
 * ----------------------------------------------------------------------------
 */
static inline void d3843373_destroyEthernet(Ethernet *ethernet) {
	free(ethernet);
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~ Initialization Functions ~~~~~~~~~~~~~~~~~~~~~~~~~

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    d3843373_initEthernet
 * Description: Initializes an existing Ethernet struct
 *
 * Parameters:
 *   ethernet	A pointer to the Ethernet instance to initalize
 * ----------------------------------------------------------------------------
 */
static inline void d3843373_initEthernet(Ethernet *ethernet) {

	// TODO: Fill in with struct initialization code

}

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    d3843373_initEthernetRequest
 * Description: Initializes an existing EthernetRequest struct
 *
 * Parameters:
 *   request        A pointer to the EthernetRequest instance to initialize
 *   deviceName     A pointer to the Ethernet device name string
 * ----------------------------------------------------------------------------
 */
void d3843373_initEthernetRequest(EthernetRequest *request, char *deviceName);

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Utility Functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    d3843373_getEthernetMTU
 * Description: Retrieves the Ethernet MTU for the Ethernet struct
 *
 * Parameters:
 *   ethernet       A pointer to the Ethernet instance to populate
 *   request        A pointer to the EthernetRequest instance
 *   ipv4Socket     A pointer to a IPv4Socket instance
 * ----------------------------------------------------------------------------
 */
void d3843373_getEthernetMTU(Ethernet *ethernet, EthernetRequest *request, IPv4Socket *ipv4Socket);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    d3843373_getEthernetStatus
 * Description: Retrieves the Ethernet Status for the Ethernet struct
 *
 * Parameters:
 *   ethernet       A pointer to the Ethernet instance to populate
 *   request        A pointer to the EthernetRequest instance
 *   ipv4Socket     A pointer to a IPv4Socket instance
 * ----------------------------------------------------------------------------
 */
void d3843373_getEthernetStatus(Ethernet *ethernet, EthernetRequest *request, IPv4Socket *ipv4Socket);

#endif /* ORG_DEVOPSBROKER_NET_ETHERNET_H */
