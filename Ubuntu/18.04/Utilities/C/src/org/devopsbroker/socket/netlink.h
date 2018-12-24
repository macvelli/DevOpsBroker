/*
 * netlink.h - DevOpsBroker C header file for the org.devopsbroker.socket.Netlink struct
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
 * echo ORG_DEVOPSBROKER_SOCKET_NETLINK | md5sum | cut -c 25-32
 * -----------------------------------------------------------------------------
 */

#ifndef ORG_DEVOPSBROKER_SOCKET_NETLINK_H
#define ORG_DEVOPSBROKER_SOCKET_NETLINK_H

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdlib.h>
#include <stdbool.h>

#include <assert.h>

#include <asm/types.h>
#include <linux/netlink.h>
#include <linux/rtnetlink.h>
#include <sys/socket.h>

#include "socket.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════

#define NETLINK_BUF_SIZE   32768

// ═════════════════════════════════ Typedefs ═════════════════════════════════

typedef enum NetlinkFamily {                                        // netlink(7)
	NETLINK_ROUTE_ENUM = NETLINK_ROUTE,
	NETLINK_USERSOCK_ENUM = NETLINK_USERSOCK,
	NETLINK_INET_DIAG_ENUM = NETLINK_INET_DIAG,
	NETLINK_SOCK_DIAG_ENUM = NETLINK_SOCK_DIAG,
	NETLINK_XFRM_ENUM = NETLINK_XFRM,
	NETLINK_SELINUX_ENUM = NETLINK_SELINUX,
	NETLINK_ISCSI_ENUM = NETLINK_ISCSI,
	NETLINK_AUDIT_ENUM = NETLINK_AUDIT,
	NETLINK_FIB_LOOKUP_ENUM = NETLINK_FIB_LOOKUP,
	NETLINK_CONNECTOR_ENUM = NETLINK_CONNECTOR,
	NETLINK_NETFILTER_ENUM = NETLINK_NETFILTER,
	NETLINK_SCSITRANSPORT_ENUM = NETLINK_SCSITRANSPORT,
	NETLINK_RDMA_ENUM = NETLINK_RDMA,
	NETLINK_DNRTMSG_ENUM = NETLINK_DNRTMSG,
	NETLINK_KOBJECT_UEVENT_ENUM = NETLINK_KOBJECT_UEVENT,
	NETLINK_GENERIC_ENUM = NETLINK_GENERIC,
	NETLINK_CRYPTO_ENUM = NETLINK_CRYPTO
} NetlinkFamily;

typedef enum NetlinkFlag {                                          // netlink(7)
	// Standard flag bits in nlmsg_flags
	NLF_ACK = NLM_F_ACK,           // Request for ACK on success
	NLF_ECHO = NLM_F_ECHO,         // Echo this request
	NLF_MULTI = NLM_F_MULTI,       // Multipart message
	NLF_REQUEST = NLM_F_REQUEST,   // Must be set on all request messages
	// GET requests
	NLF_ATOMIC = NLM_F_ATOMIC,     // Return an atomic snapshot of the table
	NLF_DUMP = NLM_F_DUMP,         // Equivalent to (NLF_ROOT|NLF_MATCH)
	NLF_MATCH = NLM_F_MATCH,       // Return all entries matching criteria passed in message content. Not implemented yet
	NLF_ROOT = NLM_F_ROOT,         // Return complete table instead of single entry
	// NEW requests
	NLF_APPEND = NLM_F_APPEND,     // Add to the end of the object list
	NLF_CREATE = NLM_F_CREATE,     // Create object if it doesn't already exist
	NLF_EXCL = NLM_F_EXCL,         // Don't replace if the object already exists
	NLF_REPLACE = NLM_F_REPLACE    // Replace existing matching object
} NetlinkFlag;

typedef enum NetlinkMessageType {                                   // netlink(7)
	// Standard message types
	NLMT_DONE = NLMSG_DONE,             // Terminates a multipart message
	NLMT_ERROR = NLMSG_ERROR,           // Signals an error and the payload contains an nlmsgerr structure
	NLMT_NOOP = NLMSG_NOOP,             // Message is to be ignored
	// Rtnetlink message types                                      // rtnetlink(7)
	NLMT_DELLINK = RTM_DELLINK,         // Remove a specific network interface
	NLMT_GETLINK = RTM_GETLINK,         // Retrieve link configuration and statistics
	NLMT_NEWLINK = RTM_NEWLINK,         // Create a specific network interface
	// IP address message types
	NLMT_DELADDR = RTM_DELADDR,         // Remove an IP address associated with an interface
	NLMT_GETADDR = RTM_GETADDR,         // Get information about IP addresses associated with an interface
	NLMT_NEWADDR = RTM_NEWADDR,         // Add an IP address to an interface
	// Route message types
	NLMT_DELROUTE = RTM_DELROUTE,       // Remove a network route
	NLMT_GETROUTE = RTM_GETROUTE,       // Get information about a network route
	NLMT_NEWROUTE = RTM_NEWROUTE,       // Create a new network route
	// ARP message types
	NLMT_DELNEIGH = RTM_DELNEIGH,       // Remove a neighbor table entry (ARP entry)
	NLMT_GETNEIGH = RTM_GETNEIGH,       // Get information about a neighbor table entry (ARP entry)
	NLMT_NEWNEIGH = RTM_NEWNEIGH,       // Add a new neighbor table entry (ARP entry)
	// Routing rule message types (Carries a struct rtmsg)
	NLMT_DELRULE = RTM_DELRULE,         // Delete a routing rule
	NLMT_GETRULE = RTM_GETRULE,         // Retrieve a routing rule
	NLMT_NEWRULE = RTM_NEWRULE,         // Add a routing rule
	// Queueing discipline message types
	NLMT_DELQDISC = RTM_DELQDISC,       // Remove a queueing discipline
	NLMT_GETQDISC = RTM_GETQDISC,       // Get a queueing discipline
	NLMT_NEWQDISC = RTM_NEWQDISC,       // Add a queueing discipline
	// Traffic class message types
	NLMT_DELTCLASS = RTM_DELTCLASS,     // Remove a traffic class
	NLMT_GETTCLASS = RTM_GETTCLASS,     // Get a traffic class
	NLMT_NEWTCLASS = RTM_NEWTCLASS,     // Add a traffic class
	// Traffic filter message types
	NLMT_DELTFILTER = RTM_DELTFILTER,   // Remove a traffic filter
	NLMT_GETTFILTER = RTM_GETTFILTER,   // Get information about a traffic filter
	NLMT_NEWTFILTER = RTM_NEWTFILTER    // Add a new traffic filter
} NetlinkMessageType;

typedef struct sockaddr_nl NetlinkAddress;
/*	sa_family_t     nl_family;   // AF_NETLINK
	unsigned short  nl_pad;      // Zero
	pid_t           nl_pid;      // Port ID
	__u32           nl_groups;   // Multicast groups mask
*/

static_assert(sizeof(NetlinkAddress) == 12, "Check your assumptions");

typedef struct rtattr NetlinkAttribute;
/*	unsigned short rta_len;    // Length of option
	unsigned short rta_type;   // Type of option
	// Data follows
*/

static_assert(sizeof(NetlinkAttribute) == 4, "Check your assumptions");

typedef struct nlmsghdr NetlinkMessageHeader;
/*	__u32		nlmsg_len;     // Length of message including header
	__u16		nlmsg_type;    // Message content
	__u16		nlmsg_flags;   // Additional flags
	__u32		nlmsg_seq;     // Sequence number
	__u32		nlmsg_pid;     // Sending process port number
*/

static_assert(sizeof(NetlinkMessageHeader) == 16, "Check your assumptions");

typedef struct ifaddrmsg NetlinkAddressMessage;
/*	unsigned char ifa_family;      // Address type
	unsigned char ifa_prefixlen;   // Prefix length of address
	unsigned char ifa_flags;       // Address flags
	unsigned char ifa_scope;       // Address scope
	int           ifa_index;       // Interface index
*/

static_assert(sizeof(NetlinkAddressMessage) == 8, "Check your assumptions");

typedef struct NetlinkAddressRequest {
	NetlinkMessageHeader msgHeader;
	NetlinkAddressMessage msgBody;
} NetlinkAddressRequest;

static_assert(sizeof(NetlinkAddressRequest) == 24, "Check your assumptions");

typedef struct ifinfomsg NetlinkInfoMessage;
/*	unsigned char  ifi_family;   // AF_UNSPEC
	unsigned short ifi_type;     // Device type
	int            ifi_index;    // Interface index
	unsigned int   ifi_flags;    // Device flags
	unsigned int   ifi_change;   // change mask
*/

typedef struct NetlinkSocket {
	NetlinkAddress addr;
	IOBuffer *ioBuffer;
	NetlinkFamily family;
	int fd;
} NetlinkSocket;

static_assert(sizeof(NetlinkSocket) == 32, "Check your assumptions");

/*
typedef struct Netlink {
	NetlinkMessageHeader msgHeader;
	NetlinkClient client;
	int fd;
} Netlink;
*/

//static_assert(sizeof(Netlink) == 64, "Check your assumptions");

// ═════════════════════════════ Global Variables ═════════════════════════════


// ════════════════════════════ Function Prototypes ═══════════════════════════

// ~~~~~~~~~~~~~~~~~~~~~~~~~ Create/Destroy Functions ~~~~~~~~~~~~~~~~~~~~~~~~~

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    e7173ad4_createNetlinkSocket
 * Description: Creates a NetlinkSocket struct instance
 *
 * Parameters:
 *   family     The NetlinkFamily (kernel module or netlink group) to communicate with
 *   ioBufLen   The length of the IOBuffer to create
 * Returns:     A NetlinkSocket struct instance
 * ----------------------------------------------------------------------------
 */
NetlinkSocket *e7173ad4_createNetlinkSocket(NetlinkFamily family, size_t ioBufLen);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    e7173ad4_destroyNetlinkSocket
 * Description: Frees the memory allocated to the NetlinkSocket struct pointer
 *
 * Parameters:
 *   netlinkSocket  A pointer to the NetlinkSocket instance to destroy
 * ----------------------------------------------------------------------------
 */
void e7173ad4_destroyNetlinkSocket(NetlinkSocket *netlinkSocket);

// ~~~~~~~~~~~~~~~~~~~~~~~~~ Initialization Functions ~~~~~~~~~~~~~~~~~~~~~~~~~

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    e7173ad4_initNetlinkAddressRequest
 * Description: Initializes an existing NetlinkAddressRequest struct
 *
 * Parameters:
 *   nlRequest      A pointer to the NetlinkAddressRequest instance to initialize
 *   addressType    The type of address to request (AF_INET or AF_INET6)
 * ----------------------------------------------------------------------------
 */
void e7173ad4_initNetlinkAddressRequest(NetlinkAddressRequest *nlRequest, unsigned char addressType);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    e7173ad4_initReceiveMessageHeader
 * Description: Initializes an existing ReceiveMessageHeader struct
 *
 * Parameters:
 *   nlResponse     A pointer to the ReceiveMessageHeader instance to initialize
 *   netlinkSocket  A pointer to a NetlinkSocket instance
 * ----------------------------------------------------------------------------
 */
void e7173ad4_initReceiveMessageHeader(ReceiveMessageHeader *nlResponse, NetlinkSocket *netlinkSocket);

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Socket Functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    e7173ad4_open
 * Description: Opens the socket for an existing NetlinkSocket struct
 *
 * Parameters:
 *   netlinkSocket  A pointer to the NetlinkSocket instance to initalize
 * ----------------------------------------------------------------------------
 */
void e7173ad4_open(NetlinkSocket *netlinkSocket);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    e7173ad4_bind
 * Description: Assigns a port number to the NetlinkSocket struct instance
 *
 * Parameters:
 *   netlinkSocket  A pointer to the NetlinkSocket instance
 * ----------------------------------------------------------------------------
 */
void e7173ad4_bind(NetlinkSocket *netlinkSocket);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    e7173ad4_close
 * Description: Closes the Netlink socket for an existing NetlinkSocket struct
 *
 * Parameters:
 *   netlinkSocket  A pointer to the NetlinkSocket instance to close
 * ----------------------------------------------------------------------------
 */
void e7173ad4_close(NetlinkSocket *netlinkSocket);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    e7173ad4_setExtendedACKReporting
 * Description: Enables or disables Netlink extended ACK reporting
 *
 * Parameters:
 *   netlinkSocket  A pointer to the NetlinkSocket instance
 *   extAckFlag     The extended ACK reporting flag value
 * ----------------------------------------------------------------------------
 */
void e7173ad4_setExtendedACKReporting(NetlinkSocket *netlinkSocket, bool extAckFlag);

#endif /* ORG_DEVOPSBROKER_SOCKET_NETLINK_H */
