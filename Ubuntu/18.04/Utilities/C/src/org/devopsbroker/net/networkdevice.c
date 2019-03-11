/*
 * networkdevice.c - DevOpsBroker C source file for the org.devopsbroker.net.NetworkDevice struct
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

	NetlinkMessageHeader *msgHeader = (NetlinkMessageHeader *) netlinkSocket->ioBuffer->iov_base;
	NetlinkAddressMessage *addrMessage;
	NetlinkAttribute *attribute;
	int messageLen;

	while (msgHeader->nlmsg_type != NLMSG_DONE) {
		for(; NLMSG_OK(msgHeader, msgLen); msgHeader = NLMSG_NEXT(msgHeader, msgLen)) {
			addrMessage = (NetlinkAddressMessage *) NLMSG_DATA(msgHeader);

			if (addrMessage->ifa_index == networkDevice->index) {
				attribute = (NetlinkAttribute *) IFA_RTA(addrMessage);
				messageLen = IFA_PAYLOAD(msgHeader);

				for(; RTA_OK(attribute, messageLen); attribute = RTA_NEXT(attribute, messageLen)) {
					if (attribute->rta_type == IFA_ADDRESS) {
						if (addrMessage->ifa_scope == RT_SCOPE_UNIVERSE) {
							networkDevice->ipv4Address.address =  *((int *) RTA_DATA(attribute));
							networkDevice->ipv4Address.cidrSuffix = addrMessage->ifa_prefixlen;
							break;
						}
					}
				}
			}
		}

		msgLen = a36b5966_receiveMessage(netlinkSocket->fd, &response, 0);
		msgHeader = (NetlinkMessageHeader *) netlinkSocket->ioBuffer->iov_base;
	}
}

void f0185083_getIPv4Gateway(NetworkDevice *networkDevice, NetlinkSocket *netlinkSocket) {
	NetlinkRouteRequest request;
	ReceiveMessageHeader response;
	ssize_t msgLen;

	// Initialize and send NetlinkRouteRequest
	e7173ad4_initNetlinkRouteRequest(&request, IPV4_PROTOCOL);
	request.msgBody.rtm_table = DEFAULT_ROUTE_TABLE;
	a36b5966_sendMessage(netlinkSocket->fd, &request, sizeof(NetlinkRouteRequest), 0);

	// Initialize and receive ReceiveMessageHeader response
	e7173ad4_initReceiveMessageHeader(&response, netlinkSocket);
	msgLen = a36b5966_receiveMessage(netlinkSocket->fd, &response, 0);

	NetlinkMessageHeader *nlMsgHeader = (NetlinkMessageHeader *) netlinkSocket->ioBuffer->iov_base;
	NetlinkRouteMessage *nlRouteMessage;
	NetlinkAttribute *nlAttribute;

	int msgLength;
	bool foundGateway;
	int outputDeviceIndex;

	while (nlMsgHeader->nlmsg_type != NLMSG_DONE) {
		for(; NLMSG_OK(nlMsgHeader, msgLen); nlMsgHeader = NLMSG_NEXT(nlMsgHeader, msgLen)) {
			nlRouteMessage = (NetlinkRouteMessage *) NLMSG_DATA(nlMsgHeader);

			if (nlRouteMessage->rtm_table == RT_TABLE_MAIN && nlRouteMessage->rtm_type == RTN_UNICAST) {
				nlAttribute = (NetlinkAttribute *) RTM_RTA(nlRouteMessage);
				msgLength = RTM_PAYLOAD(nlMsgHeader);
				foundGateway = false;
				outputDeviceIndex = -1;

				for(; RTA_OK(nlAttribute, msgLength); nlAttribute = RTA_NEXT(nlAttribute, msgLength)) {
					if (nlAttribute->rta_type == RTA_GATEWAY) {
						networkDevice->ipv4Gateway = *((int *) RTA_DATA(nlAttribute));
						foundGateway = true;
					} else if (nlAttribute->rta_type == RTA_OIF) {
						outputDeviceIndex = *((int *) RTA_DATA(nlAttribute));

						if (outputDeviceIndex != networkDevice->index) {
							break;
						}
					}
				}

				if (foundGateway && outputDeviceIndex == networkDevice->index) {
					break;
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

void f0185083_getIPv6Gateway(NetworkDevice *networkDevice, NetlinkSocket *netlinkSocket) {
	NetlinkRouteRequest request;
	ReceiveMessageHeader response;
	ssize_t msgLen;

	// Initialize and send NetlinkRouteRequest
	e7173ad4_initNetlinkRouteRequest(&request, IPV6_PROTOCOL);
	request.msgBody.rtm_table = DEFAULT_ROUTE_TABLE;
	a36b5966_sendMessage(netlinkSocket->fd, &request, sizeof(NetlinkRouteRequest), 0);

	// Initialize and receive ReceiveMessageHeader response
	e7173ad4_initReceiveMessageHeader(&response, netlinkSocket);
	msgLen = a36b5966_receiveMessage(netlinkSocket->fd, &response, 0);

	NetlinkMessageHeader *nlMsgHeader = (NetlinkMessageHeader *) netlinkSocket->ioBuffer->iov_base;
	NetlinkRouteMessage *nlRouteMessage;
	NetlinkAttribute *nlAttribute;

	int msgLength;
	bool foundGateway;
	int outputDeviceIndex;

	while (nlMsgHeader->nlmsg_type != NLMSG_DONE) {
		for(; NLMSG_OK(nlMsgHeader, msgLen); nlMsgHeader = NLMSG_NEXT(nlMsgHeader, msgLen)) {
			nlRouteMessage = (NetlinkRouteMessage *) NLMSG_DATA(nlMsgHeader);

			if (nlRouteMessage->rtm_table == RT_TABLE_MAIN && nlRouteMessage->rtm_type == RTN_UNICAST) {
				nlAttribute = (NetlinkAttribute *) RTM_RTA(nlRouteMessage);
				msgLength = RTM_PAYLOAD(nlMsgHeader);
				foundGateway = false;
				outputDeviceIndex = -1;

				for(; RTA_OK(nlAttribute, msgLength); nlAttribute = RTA_NEXT(nlAttribute, msgLength)) {
					if (nlAttribute->rta_type == RTA_GATEWAY) {
						f668c4bd_memcopy(RTA_DATA(nlAttribute), networkDevice->ipv6Gateway.address, RTA_PAYLOAD(nlAttribute));
						networkDevice->ipv6Gateway.cidrSuffix = 0;
						foundGateway = true;
					} else if (nlAttribute->rta_type == RTA_OIF) {
						outputDeviceIndex = *((int *) RTA_DATA(nlAttribute));

						if (outputDeviceIndex != networkDevice->index) {
							break;
						}
					}
				}

				if (foundGateway && outputDeviceIndex == networkDevice->index) {
					break;
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

		c7c88e52_printLibError(errorMessage.buffer, errno);
		free(errorMessage.buffer);
		exit(EXIT_FAILURE);
	}

	networkDevice->index = request->ifr_ifindex;
}
