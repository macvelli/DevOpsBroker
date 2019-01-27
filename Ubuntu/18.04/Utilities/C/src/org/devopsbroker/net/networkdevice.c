/*
 * networkdevice.c - DevOpsBroker C source file for the org.devopsbroker.net.NetworkDevice struct
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

#include <sys/ioctl.h>

#include "networkdevice.h"

#include "../lang/error.h"
#include "../lang/memory.h"
#include "../lang/stringbuilder.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════


// ═════════════════════════════ Global Variables ═════════════════════════════


// ═════════════════════════ Function Implementations ═════════════════════════

// ~~~~~~~~~~~~~~~~~~~~~~~~~ Create/Destroy Functions ~~~~~~~~~~~~~~~~~~~~~~~~~

NetworkDevice *f0185083_createNetworkDevice(char* deviceName) {
	NetworkDevice *networkDevice = malloc(sizeof(NetworkDevice));

	networkDevice->name = deviceName;
	networkDevice->index = 0;

	return networkDevice;
}

void f0185083_destroyNetworkDevice(NetworkDevice *networkDevice) {
	free(networkDevice);
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~ Initialization Functions ~~~~~~~~~~~~~~~~~~~~~~~~~

void f0185083_initNetworkDevice(NetworkDevice *networkDevice, char* deviceName) {
	networkDevice->name = deviceName;
	networkDevice->index = 0;
}

void f0185083_initNetworkDeviceRequest(NetworkDevice *networkDevice, NetworkDeviceRequest *request) {
	f668c4bd_meminit(request, sizeof(NetworkDeviceRequest));

	int status = f6215943_copy_to_buffer(networkDevice->name, request->ifr_name, IFNAMSIZ);

	if (status == SYSTEM_ERROR_CODE) {
		StringBuilder errorMessage;
		c598a24c_initStringBuilder(&errorMessage);

		c598a24c_append_string(&errorMessage, "Invalid network device name '");
		c598a24c_append_string(&errorMessage, networkDevice->name);
		c598a24c_append_char(&errorMessage, '\'');

		c7c88e52_printError_string(errorMessage.buffer);
		free(errorMessage.buffer);
		exit(EXIT_FAILURE);
	}
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Utility Functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void f0185083_getIPv4Address(NetworkDevice *networkDevice, NetlinkSocket *netlinkSocket) {
	NetlinkAddressRequest request;
	ReceiveMessageHeader response;
	ssize_t msgLen;

	// Initialize and send NetlinkAddressRequest
	e7173ad4_initNetlinkAddressRequest(&request, AF_INET);
	a36b5966_sendMessage(netlinkSocket->fd, &request, sizeof(NetlinkAddressRequest), 0);

	// Initialize and receive ReceiveMessageHeader response
	e7173ad4_initReceiveMessageHeader(&response, netlinkSocket);
	msgLen = a36b5966_receiveMessage(netlinkSocket->fd, &response, 0);

	NetlinkMessageHeader *nlMsgHeader = (NetlinkMessageHeader *) netlinkSocket->ioBuffer->iov_base;
	NetlinkAddressMessage *nlAddressMsg;
	NetlinkAttribute *nlAttribute;
	int nlAddressMsgLen;

	while (nlMsgHeader->nlmsg_type != NLMSG_DONE) {
		for(; NLMSG_OK(nlMsgHeader, msgLen); nlMsgHeader = NLMSG_NEXT(nlMsgHeader, msgLen)) {
			nlAddressMsg = (NetlinkAddressMessage *) NLMSG_DATA(nlMsgHeader);

			if (nlAddressMsg->ifa_index == networkDevice->index) {
				nlAttribute = (NetlinkAttribute *) IFA_RTA(nlAddressMsg);
				nlAddressMsgLen = IFA_PAYLOAD(nlMsgHeader);

				for(; RTA_OK(nlAttribute, nlAddressMsgLen); nlAttribute = RTA_NEXT(nlAttribute, nlAddressMsgLen)) {
					if (nlAttribute->rta_type == IFA_ADDRESS) {
						if (nlAddressMsg->ifa_scope == RT_SCOPE_UNIVERSE) {
							networkDevice->ipv4Address.address =  *((int *) RTA_DATA(nlAttribute));
							networkDevice->ipv4Address.cidrSuffix = nlAddressMsg->ifa_prefixlen;
							break;
						}
					}
				}
			}
		}

		msgLen = a36b5966_receiveMessage(netlinkSocket->fd, &response, 0);
		nlMsgHeader = (NetlinkMessageHeader *) netlinkSocket->ioBuffer->iov_base;
	}
}

void f0185083_getIPv6Addresses(NetworkDevice *networkDevice, NetlinkSocket *netlinkSocket) {
	NetlinkAddressRequest request;
	ReceiveMessageHeader response;
	ssize_t msgLen;

	// Initialize and send NetlinkAddressRequest
	e7173ad4_initNetlinkAddressRequest(&request, AF_INET6);
	a36b5966_sendMessage(netlinkSocket->fd, &request, sizeof(NetlinkAddressRequest), 0);

	// Initialize and receive ReceiveMessageHeader response
	e7173ad4_initReceiveMessageHeader(&response, netlinkSocket);
	msgLen = a36b5966_receiveMessage(netlinkSocket->fd, &response, 0);

	NetlinkMessageHeader *nlMsgHeader = (NetlinkMessageHeader *) netlinkSocket->ioBuffer->iov_base;
	NetlinkAddressMessage *nlAddressMsg;
	NetlinkAttribute *nlAttribute;
	int nlAddressMsgLen;

	while (nlMsgHeader->nlmsg_type != NLMSG_DONE) {
		for(; NLMSG_OK(nlMsgHeader, msgLen); nlMsgHeader = NLMSG_NEXT(nlMsgHeader, msgLen)) {
			nlAddressMsg = (NetlinkAddressMessage *) NLMSG_DATA(nlMsgHeader);

			if (nlAddressMsg->ifa_index == networkDevice->index) {
				nlAttribute = (NetlinkAttribute *) IFA_RTA(nlAddressMsg);
				nlAddressMsgLen = IFA_PAYLOAD(nlMsgHeader);

				for(; RTA_OK(nlAttribute, nlAddressMsgLen); nlAttribute = RTA_NEXT(nlAttribute, nlAddressMsgLen)) {
					if (nlAttribute->rta_type == IFA_ADDRESS) {
						if (nlAddressMsg->ifa_scope == RT_SCOPE_UNIVERSE) {
							f668c4bd_memcopy(RTA_DATA(nlAttribute), networkDevice->ipv6Global.address, RTA_PAYLOAD(nlAttribute));
							networkDevice->ipv6Global.cidrSuffix = nlAddressMsg->ifa_prefixlen;
							break;
						} else if (nlAddressMsg->ifa_scope == RT_SCOPE_LINK) {
							f668c4bd_memcopy(RTA_DATA(nlAttribute), networkDevice->ipv6Local.address, RTA_PAYLOAD(nlAttribute));
							networkDevice->ipv6Local.cidrSuffix = nlAddressMsg->ifa_prefixlen;
							break;
						}
					}
				}
			}
		}

		msgLen = a36b5966_receiveMessage(netlinkSocket->fd, &response, 0);
		nlMsgHeader = (NetlinkMessageHeader *) netlinkSocket->ioBuffer->iov_base;
	}
}

void f0185083_getNetworkDeviceIndex(NetworkDevice *networkDevice, NetworkDeviceRequest *request, UnixSocket *unixSocket) {
	int status = ioctl(unixSocket->fd, SIOCGIFINDEX, request);

	if (status == SYSTEM_ERROR_CODE) {
		StringBuilder errorMessage;
		c598a24c_initStringBuilder(&errorMessage);

		c598a24c_append_string(&errorMessage, "Failure retrieving network device index for '");
		c598a24c_append_string(&errorMessage, networkDevice->name);
		c598a24c_append_char(&errorMessage, '\'');

		c7c88e52_printError_string_int(errorMessage.buffer, errno);
		free(errorMessage.buffer);
		exit(EXIT_FAILURE);
	}

	networkDevice->index = request->ifr_ifindex;
}
