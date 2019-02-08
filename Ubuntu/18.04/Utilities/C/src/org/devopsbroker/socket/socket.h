/*
 * socket.h - DevOpsBroker C header file for socket-related functionality
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
 * echo ORG_DEVOPSBROKER_SOCKET_SOCKET | md5sum | cut -c 25-32
 * -----------------------------------------------------------------------------
 */

#ifndef ORG_DEVOPSBROKER_SOCKET_SOCKET_H
#define ORG_DEVOPSBROKER_SOCKET_SOCKET_H

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdint.h>

#include <assert.h>

#include <asm/types.h>
#include <sys/socket.h>

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════

/******************************************************************************
 *
 * int socket(int domain, int type, int protocol);
 *
 * The domain argument specifies a communication domain; this selects the
 * protocol family which will be used for communication:
 *
 *  AF_UNIX             // Local communication              unix(7)
 *  AF_LOCAL            // Alias for AF_UNIX
 *  AF_INET             // IPv4 Internet protocols          ip(7)
 *  AF_INET6            // IPv6 Internet protocols          ipv6(7)
 *  AF_IPX              // IPX - Novell protocols
 *  AF_NETLINK          // Kernel user interface device     netlink(7)
 *  AF_X25              // ITU-T X.25 / ISO-8208 protocol   x25(7)
 *  AF_AX25             // Amateur radio AX.25 protocol
 *  AF_ATMPVC           // Access to raw ATM PVCs
 *  AF_APPLETALK        // AppleTalk                        ddp(7)
 *  AF_PACKET           // Low level packet interface       packet(7)
 *  AF_ALG              // Interface to kernel crypto API
 *
 * The socket has the indicated type, which specifies the communication
 * semantics:
 *
 *  SOCK_STREAM         // Provides sequenced, reliable, two-way, connection-
 *                         based byte streams. An out-of-band data transmission
 *                         mechanism may be supported
 *
 *  SOCK_DGRAM          // Supports datagrams (connectionless, unreliable
 *                         messages of a fixed maximum length)
 *
 *  SOCK_SEQPACKET      // Provides a sequenced, reliable, two-way connection-
 *                         based data transmission path for datagrams of fixed
 *                         maximum length; a consumer is required to read an
 *                         entire packet with each input system call
 *
 *	SOCK_RAW            // Provides raw network protocol access
 *
 *	SOCK_RDM            // Provides a reliable datagram layer that does not
 *                         guarantee ordering
 *
 * The socket type may include the bitwise OR of any of the following values,
 * to modify the behavior of socket():
 *
 *  SOCK_NONBLOCK       // Set the O_NONBLOCK file status flag on the new open
 *                         socket file descriptor. Using this flag saves extra
 *                         calls to fcntl(2) to achieve the same result
 *
 *  SOCK_CLOEXEC        // Set the close-on-exec (FD_CLOEXEC) flag on the new
 *                         open socket file descriptor. See the description of
 *                         the O_CLOEXEC flag in open(2) for reasons why this
 *                         may be useful
 *
 * int getsockopt(int sockfd, int level, int optname, void *optval, socklen_t *optlen);
 * int setsockopt(int sockfd, int level, int optname, const void *optval, socklen_t optlen);
 *
 * When manipulating socket options, the level at which the option resides and
 * the name of the option must be specified
 *
 *  SOL_SOCKET          // Manipulate options at the sockets API level
 *  SOL_NETLINK         // Manipulate options for the Netlink protocol
 *
 * Some of the available socket options include (see socket(7) for more options):
 *
 *  SO_KEEPALIVE        // When enabled on a SOCK_STREAM socket the protocol
 *                         checks in a protocol-specific manner if the other
 *                         end is still alive
 *
 *  SO_RCVBUF           // The maximum socket receive buffer in bytes.  The
 *                         kernel doubles this value (to allow space for
 *                         bookkeeping overhead) when it is set using setsockopt(2)
 *
 *  SO_SNDBUF           // The maximum socket send buffer in bytes.  The kernel
 *                         doubles this value (to allow space for bookkeeping
 *                         overhead) when it is set using setsockopt(2)
 *
 *****************************************************************************/

typedef enum SocketProtocol {                                 // socket(2)
	ALG_PROTOCOL = AF_ALG,               // Interface to kernel crypto API
	APPLETALK_PROTOCOL = AF_APPLETALK,   // AppleTalk                        ddp(7)
	ATMPVC_PROTOCOL = AF_ATMPVC,         // Access to raw ATM PVCs
	AX25_PROTOCOL = AF_AX25,             // Amateur radio AX.25 protocol
	IPV4_PROTOCOL = AF_INET,             // IPv4 Internet protocols          ip(7)
	IPV6_PROTOCOL = AF_INET6,            // IPv6 Internet protocols          ipv6(7)
	IPX_PROTOCOL = AF_IPX,               // IPX - Novell protocols
	LOCAL_PROTOCOL = AF_LOCAL,           // Alias for AF_UNIX
	NETLINK_PROTOCOL = AF_NETLINK,       // Kernel user interface device     netlink(7)
	PACKET_PROTOCOL = AF_PACKET,         // Low level packet interface       packet(7)
	UNIX_PROTOCOL = AF_UNIX,             // Local communication              unix(7)
	X25_PROTOCOL = AF_X25                // ITU-T X.25 / ISO-8208 protocol   x25(7)
} SocketProtocol;

typedef struct iovec IOBuffer;
/*	void  *iov_base;   // Starting address
	size_t iov_len;    // Number of bytes to transfer
*/

static_assert(sizeof(IOBuffer) == 16, "Check your assumptions");

typedef struct msghdr ReceiveMessageHeader;
/*	void         *msg_name;         // optional address
	socklen_t     msg_namelen;      // size of address
	struct iovec *msg_iov;          // scatter/gather array
	size_t        msg_iovlen;       // # elements in msg_iov
	void         *msg_control;      // ancillary data, see below
	size_t        msg_controllen;   // ancillary data buffer len
	int           msg_flags;        // flags on received message
*/

static_assert(sizeof(ReceiveMessageHeader) == 56, "Check your assumptions");

// ═════════════════════════════ Global Variables ═════════════════════════════


// ════════════════════════════ Function Prototypes ═══════════════════════════

// ~~~~~~~~~~~~~~~~~~~~~~~~~ Create/Destroy Functions ~~~~~~~~~~~~~~~~~~~~~~~~~

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    a36b5966_createIOBuffer
 * Description: Creates a IOBuffer struct instance initialized to bufLen
 *
 * Parameters:
 *   bufLen     The size of the buffer to create
 * Returns:     An IOBuffer struct instance initialized to bufLen
 * ----------------------------------------------------------------------------
 */
IOBuffer *a36b5966_createIOBuffer(size_t bufLen);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    a36b5966_destroyIOBuffer
 * Description: Frees the memory allocated to the IOBuffer struct pointer
 *
 * Parameters:
 *   ioBuffer   A pointer to the IOBuffer instance to destroy
 * ----------------------------------------------------------------------------
 */
void a36b5966_destroyIOBuffer(IOBuffer *ioBuffer);

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Socket Functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    a36b5966_setMaxSendBufferSize
 * Description: Sets the maximum socket send buffer size in bytes
 *              NOTE: The kernel doubles this value to allow space for bookkeeping overhead
 *
 * Parameters:
 *   sockfd     The socket file descriptor
 *   bufSize    The maximum socket send buffer size in bytes
 * ----------------------------------------------------------------------------
 */
void a36b5966_setMaxSendBufferSize(int sockfd, uint32_t bufSize);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    a36b5966_setMaxRecvBufferSize
 * Description: Sets the maximum socket receive buffer size in bytes
 *              NOTE: The kernel doubles this value to allow space for bookkeeping overhead
 *
 * Parameters:
 *   sockfd     The socket file descriptor
 *   bufSize    The maximum socket receive buffer size in bytes
 * ----------------------------------------------------------------------------
 */
void a36b5966_setMaxRecvBufferSize(int sockfd, uint32_t bufSize);

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Utility Functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    a36b5966_receiveMessage
 * Description: Receives a message from a socket
 *
 * Parameters:
 *   sockfd     The socket file descriptor
 *   msg        A pointer to the initialized ReceiveMessageHeader struct
 *   flags      A bitwise OR of one or more message flags
 * Returns:     The number of bytes received
 * ----------------------------------------------------------------------------
 */
ssize_t a36b5966_receiveMessage(int sockfd, ReceiveMessageHeader *msg, int flags);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    a36b5966_sendMessage
 * Description: Sends a message to a socket
 *
 * Parameters:
 *   sockfd     The socket file descriptor
 *   buf        A pointer to the message being sent over the socket
 *   bufSize    The size of the message
 *   flags      A bitwise OR of zero or more message flags
 * Returns:     The number of bytes sent
 * ----------------------------------------------------------------------------
 */
ssize_t a36b5966_sendMessage(int sockfd, const void *buf, size_t bufSize, int flags);

#endif /* ORG_DEVOPSBROKER_SOCKET_SOCKET_H */
