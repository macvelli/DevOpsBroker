/*
 * netlink.c - DevOpsBroker C source file for the org.devopsbroker.socket.Netlink struct
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
 * Developed on Ubuntu 18.04.1 LTS running kernel.osrelease = 4.15.0-42
 *
 * -----------------------------------------------------------------------------
 */

// ════════════════════════════ Feature Test Macros ═══════════════════════════

#define _DEFAULT_SOURCE

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdio.h>

#include <unistd.h>

#include "netlink.h"
#include "socket.h"

#include "../lang/error.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════


// ═════════════════════════════ Global Variables ═════════════════════════════


// ═════════════════════════ Function Implementations ═════════════════════════

// ~~~~~~~~~~~~~~~~~~~~~~~~~ Create/Destroy Functions ~~~~~~~~~~~~~~~~~~~~~~~~~

NetlinkSocket *e7173ad4_createNetlinkSocket(NetlinkFamily family, size_t ioBufLen) {
	NetlinkSocket *netlinkSocket = malloc(sizeof(NetlinkSocket));

	f668c4bd_meminit(&netlinkSocket->addr, sizeof(NetlinkAddress));
	netlinkSocket->addr.nl_family = AF_NETLINK;
	netlinkSocket->ioBuffer = a36b5966_createIOBuffer(ioBufLen);
	netlinkSocket->family = family;
	netlinkSocket->fd = 0;

	return netlinkSocket;
}

void e7173ad4_destroyNetlinkSocket(NetlinkSocket *netlinkSocket) {
	a36b5966_destroyIOBuffer(netlinkSocket->ioBuffer);
	free(netlinkSocket);
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~ Initialization Functions ~~~~~~~~~~~~~~~~~~~~~~~~~

void e7173ad4_initNetlinkAddressRequest(NetlinkAddressRequest *nlRequest, unsigned char addressType) {
	nlRequest->msgHeader.nlmsg_len = NLMSG_LENGTH(sizeof(NetlinkAddressMessage));
	nlRequest->msgHeader.nlmsg_type = RTM_GETADDR;
	nlRequest->msgHeader.nlmsg_flags = NLM_F_REQUEST | NLM_F_ROOT;

	f668c4bd_meminit(&nlRequest->msgBody, sizeof(NetlinkAddressMessage));
	nlRequest->msgBody.ifa_family = addressType;
}

void e7173ad4_initReceiveMessageHeader(ReceiveMessageHeader *nlResponse, NetlinkSocket *netlinkSocket) {
	f668c4bd_meminit(nlResponse, sizeof(ReceiveMessageHeader));
	nlResponse->msg_name = &netlinkSocket->addr;
	nlResponse->msg_namelen = sizeof(NetlinkAddress);
	nlResponse->msg_iov = netlinkSocket->ioBuffer;
	nlResponse->msg_iovlen = 1;
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Socket Functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void e7173ad4_bind(NetlinkSocket *netlinkSocket) {
	uint32_t addrLen = sizeof(NetlinkAddress);
	int status = bind(netlinkSocket->fd, (struct sockaddr *) &netlinkSocket->addr, sizeof(NetlinkAddress));

	if (status == SYSTEM_ERROR_CODE) {
		c7c88e52_printError_string_int("Cannot bind Netlink socket", errno);
		exit(EXIT_FAILURE);
	}

	status = getsockname(netlinkSocket->fd, (struct sockaddr *) &netlinkSocket->addr, &addrLen);

	if (status == SYSTEM_ERROR_CODE) {
		c7c88e52_printError_string_int("Cannot get Netlink socket name", errno);
		exit(EXIT_FAILURE);
	}
}

void e7173ad4_close(NetlinkSocket *netlinkSocket) {

	if (close(netlinkSocket->fd) == SYSTEM_ERROR_CODE) {
		c7c88e52_printError_string_int("Cannot close Netlink socket", errno);
		exit(EXIT_FAILURE);
	}

}

void e7173ad4_open(NetlinkSocket *netlinkSocket) {
	netlinkSocket->fd = socket(AF_NETLINK, SOCK_RAW|SOCK_CLOEXEC, netlinkSocket->family);

	if (netlinkSocket->fd == SYSTEM_ERROR_CODE) {
		c7c88e52_printError_string_int("Cannot open Netlink socket", errno);
		exit(EXIT_FAILURE);
	}
}

void e7173ad4_setExtendedACKReporting(NetlinkSocket *netlinkSocket, bool extAckFlag) {
	int status = setsockopt(netlinkSocket->fd, SOL_NETLINK, NETLINK_EXT_ACK, &extAckFlag, 4);

	if (status == SYSTEM_ERROR_CODE) {
		c7c88e52_printError_string_int("Cannot set Netlink extended ACK reporting flag", errno);
		exit(EXIT_FAILURE);
	}
}
