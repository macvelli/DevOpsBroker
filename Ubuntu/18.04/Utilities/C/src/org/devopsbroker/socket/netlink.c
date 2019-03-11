/*
 * netlink.c - DevOpsBroker C source file for the org.devopsbroker.socket.Netlink struct
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
 * Developed on Ubuntu 18.04.1 LTS running kernel.osrelease = 4.15.0-42
 *
 * -----------------------------------------------------------------------------
 */

// ════════════════════════════ Feature Test Macros ═══════════════════════════

#define _DEFAULT_SOURCE

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdio.h>

#include <unistd.h>

#include <arpa/inet.h>

#include "netlink.h"
#include "socket.h"

#include "../lang/error.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════

typedef struct DebugNetlinkAttribute {
	unsigned char dataBuffer[128];
	char strBuffer[128];
	NetlinkAttribute *attribute;
	unsigned char rtm_family;
} DebugNetlinkAttribute;

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

void e7173ad4_initNetlinkInfoRequest(NetlinkInfoRequest *infoRequest, int ifaceIndex) {
	infoRequest->msgHeader.nlmsg_len = NLMSG_LENGTH(sizeof(NetlinkInfoMessage));
	infoRequest->msgHeader.nlmsg_type = RTM_GETLINK;
	infoRequest->msgHeader.nlmsg_flags = NLM_F_REQUEST;

	f668c4bd_meminit(&infoRequest->msgBody, sizeof(NetlinkInfoMessage));
	infoRequest->msgBody.ifi_family = AF_UNSPEC;
	infoRequest->msgBody.ifi_index = ifaceIndex;
	infoRequest->msgBody.ifi_change = 0xffffffff;
}

void e7173ad4_initNetlinkRouteRequest(NetlinkRouteRequest *request, SocketProtocol addressType) {
	request->msgHeader.nlmsg_len = NLMSG_LENGTH(sizeof(NetlinkRouteMessage));
	request->msgHeader.nlmsg_type = RTM_GETROUTE;
	request->msgHeader.nlmsg_flags = NLM_F_REQUEST | NLM_F_ROOT;

	f668c4bd_meminit(&request->msgBody, sizeof(NetlinkRouteMessage));
	request->msgBody.rtm_family = addressType;
	request->msgBody.rtm_table = UNK_ROUTE_TABLE;
	request->msgBody.rtm_protocol = UNK_ROUTE_ORIGIN;
	request->msgBody.rtm_scope = GLOBAL_ROUTE_SCOPE;
	request->msgBody.rtm_type = UNK_ROUTE_TYPE;
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
		c7c88e52_printLibError("Cannot bind Netlink socket", errno);
		exit(EXIT_FAILURE);
	}

	status = getsockname(netlinkSocket->fd, (struct sockaddr *) &netlinkSocket->addr, &addrLen);

	if (status == SYSTEM_ERROR_CODE) {
		c7c88e52_printLibError("Cannot get Netlink socket name", errno);
		exit(EXIT_FAILURE);
	}
}

void e7173ad4_close(NetlinkSocket *netlinkSocket) {

	if (close(netlinkSocket->fd) == SYSTEM_ERROR_CODE) {
		c7c88e52_printLibError("Cannot close Netlink socket", errno);
		exit(EXIT_FAILURE);
	}

}

void e7173ad4_open(NetlinkSocket *netlinkSocket) {
	netlinkSocket->fd = socket(AF_NETLINK, SOCK_RAW|SOCK_CLOEXEC, netlinkSocket->family);

	if (netlinkSocket->fd == SYSTEM_ERROR_CODE) {
		c7c88e52_printLibError("Cannot open Netlink socket", errno);
		exit(EXIT_FAILURE);
	}
}

void e7173ad4_setExtendedACKReporting(NetlinkSocket *netlinkSocket, bool extAckFlag) {
	int status = setsockopt(netlinkSocket->fd, SOL_NETLINK, NETLINK_EXT_ACK, &extAckFlag, 4);

	if (status == SYSTEM_ERROR_CODE) {
		c7c88e52_printLibError("Cannot set Netlink extended ACK reporting flag", errno);
		exit(EXIT_FAILURE);
	}
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Debug Functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

static char *getRoutingTable(unsigned char rtm_table) {
	switch(rtm_table) {
		case RT_TABLE_DEFAULT :
			return "RT_TABLE_DEFAULT";
			break;
		case RT_TABLE_LOCAL :
			return "RT_TABLE_LOCAL";
			break;
		case RT_TABLE_MAIN :
			return "RT_TABLE_MAIN";
			break;
		default :
			return "RT_TABLE_UNSPEC";
			break;
	}
}

void e7173ad4_debugNetlinkAttribute(DebugNetlinkAttribute *debugAttr) {
	char *attributeType;
	char *attributeValue;

	switch(debugAttr->attribute->rta_type) {
		case RTA_CACHEINFO :
			attributeType = "RTA_CACHEINFO";
			RouteCacheInfo cacheInfo;
			f668c4bd_memcopy(RTA_DATA(debugAttr->attribute), &cacheInfo, RTA_PAYLOAD(debugAttr->attribute));
			sprintf(debugAttr->strBuffer, "{rta_clntref=%u, rta_lastuse=%u, rta_expires=%d, rta_error=%u, rta_used=%u, rta_id=%u, rta_ts=%u, rta_tsage=%u}",
				cacheInfo.rta_clntref,
				cacheInfo.rta_lastuse,
				cacheInfo.rta_expires,
				cacheInfo.rta_error,
				cacheInfo.rta_used,
				cacheInfo.rta_id,
				cacheInfo.rta_ts,
				cacheInfo.rta_tsage);
			break;
		case RTA_DST :
			attributeType = "RTA_DST";
			f668c4bd_memcopy(RTA_DATA(debugAttr->attribute), debugAttr->dataBuffer, RTA_PAYLOAD(debugAttr->attribute));
			inet_ntop(debugAttr->rtm_family, debugAttr->dataBuffer, debugAttr->strBuffer, INET6_ADDRSTRLEN);
			attributeValue = debugAttr->strBuffer;
			break;
		case RTA_FLOW :
			attributeType = "RTA_FLOW";
			break;
		case RTA_GATEWAY :
			attributeType = "RTA_GATEWAY";
			f668c4bd_memcopy(RTA_DATA(debugAttr->attribute), debugAttr->dataBuffer, RTA_PAYLOAD(debugAttr->attribute));
			inet_ntop(debugAttr->rtm_family, debugAttr->dataBuffer, debugAttr->strBuffer, INET6_ADDRSTRLEN);
			attributeValue = debugAttr->strBuffer;
			break;
		case RTA_IIF :
			attributeType = "RTA_IIF";
			break;
		case RTA_METRICS :
			attributeType = "RTA_METRICS";
			break;
		case RTA_MULTIPATH :
			attributeType = "RTA_MULTIPATH";
			break;
		case RTA_OIF :
			attributeType = "RTA_OIF";
			int oif = *((int *) RTA_DATA(debugAttr->attribute));
			sprintf(debugAttr->strBuffer, "%d", oif);
			attributeValue = debugAttr->strBuffer;
			break;
		case RTA_PREF:
			attributeType = "RTA_PREF";
			unsigned char routePref = *((unsigned char *) RTA_DATA(debugAttr->attribute));
			sprintf(debugAttr->strBuffer, "%d", routePref);
			attributeValue = debugAttr->strBuffer;
			break;
		case RTA_PREFSRC :
			attributeType = "RTA_PREFSRC";
			break;
		case RTA_PRIORITY :
			attributeType = "RTA_PRIORITY";
			int priority = *((int *) RTA_DATA(debugAttr->attribute));
			sprintf(debugAttr->strBuffer, "%d", priority);
			attributeValue = debugAttr->strBuffer;
			break;
		case RTA_PROTOINFO :
			attributeType = "RTA_PROTOINFO";
			break;
		case RTA_SRC :
			attributeType = "RTA_SRC";
			break;
		case RTA_TABLE :
			attributeType = "RTA_TABLE";
			unsigned char table = *((unsigned char *) RTA_DATA(debugAttr->attribute));
			attributeValue = getRoutingTable(table);
			break;
		case RTA_UNSPEC :
			attributeType = "RTA_UNSPEC";
			break;
		default :
			attributeType = "UNKNOWN";
	}

	printf("\t\t{rta_len=%u, rta_type=%s}, %s}\n", debugAttr->attribute->rta_len, attributeType, attributeValue);
}

void e7173ad4_debugNetlinkRouteMessage(NetlinkRouteMessage *routeMessage, NetlinkMessageHeader *nlMsgHeader) {
	char *addressFamily;
	char *routingTable;
	char *routeProtocol;
	char *routeScope;
	char *routeType;

	switch(routeMessage->rtm_family) {
		case AF_INET :
			addressFamily = "AF_INET";
			break;
		case AF_INET6 :
			addressFamily = "AF_INET6";
			break;
		default :
			addressFamily = "INVALID";
	}

	routingTable = getRoutingTable(routeMessage->rtm_table);

	switch(routeMessage->rtm_protocol) {
		case RTPROT_BOOT :
			routeProtocol = "RTPROT_BOOT";
			break;
		case RTPROT_KERNEL :
			routeProtocol = "RTPROT_KERNEL";
			break;
		case RTPROT_REDIRECT :
			routeProtocol = "RTPROT_REDIRECT";
			break;
		case RTPROT_STATIC :
			routeProtocol = "RTPROT_STATIC";
			break;
		default :
			routeProtocol = "RTPROT_UNSPEC";
	}

	switch(routeMessage->rtm_scope) {
		case RT_SCOPE_UNIVERSE :
			routeScope = "RT_SCOPE_UNIVERSE";
			break;
		case RT_SCOPE_HOST :
			routeScope = "RT_SCOPE_HOST";
			break;
		case RT_SCOPE_LINK :
			routeScope = "RT_SCOPE_LINK";
			break;
		case RT_SCOPE_SITE :
			routeScope = "RT_SCOPE_SITE";
			break;
		default :
			routeScope = "RT_SCOPE_NOWHERE";
	}

	switch(routeMessage->rtm_type) {
		case RTN_ANYCAST :
			routeType = "RTN_ANYCAST";
			break;
		case RTN_BLACKHOLE :
			routeType = "RTN_BLACKHOLE";
			break;
		case RTN_BROADCAST :
			routeType = "RTN_BROADCAST";
			break;
		case RTN_LOCAL :
			routeType = "RTN_LOCAL";
			break;
		case RTN_MULTICAST :
			routeType = "RTN_MULTICAST";
			break;
		case RTN_NAT :
			routeType = "RTN_NAT";
			break;
		case RTN_PROHIBIT :
			routeType = "RTN_PROHIBIT";
			break;
		case RTN_THROW :
			routeType = "RTN_THROW";
			break;
		case RTN_UNICAST :
			routeType = "RTN_UNICAST";
			break;
		case RTN_UNREACHABLE :
			routeType = "RTN_UNREACHABLE";
			break;
		case RTN_XRESOLVE :
			routeType = "RTN_XRESOLVE";
			break;
		default :
			routeType = "RTN_UNSPEC";
	}

	printf("NetlinkRouteMessage (%p)\n", routeMessage);
	puts("{");

	printf("\trtm_family = %s\n", addressFamily);
	printf("\trtm_dst_len = %u\n", routeMessage->rtm_dst_len);
	printf("\trtm_src_len = %u\n", routeMessage->rtm_src_len);
	printf("\trtm_tos = %u\n", routeMessage->rtm_tos);
	printf("\trtm_table = %s\n", routingTable);
	printf("\trtm_protocol = %s\n", routeProtocol);
	printf("\trtm_scope = %s\n", routeScope);
	printf("\trtm_type = %s\n", routeType);
	printf("\trtm_flags = %u\n", routeMessage->rtm_flags);

	if (nlMsgHeader != NULL) {
		NetlinkAttribute *nlAttribute = (NetlinkAttribute *) RTM_RTA(routeMessage);
		int msgLength = RTM_PAYLOAD(nlMsgHeader);

		DebugNetlinkAttribute debugAttr;
		debugAttr.rtm_family = routeMessage->rtm_family;

		puts("\t{");
		for(; RTA_OK(nlAttribute, msgLength); nlAttribute = RTA_NEXT(nlAttribute, msgLength)) {
			debugAttr.attribute = nlAttribute;
			e7173ad4_debugNetlinkAttribute(&debugAttr);
		}
		puts("\t}");
	}

	puts("}");
}
