/*
 * ipv4.h - DevOpsBroker C header file for the org.devopsbroker.socket.IPv4Socket struct
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
 * Developed on Ubuntu 18.04.1 LTS running kernel.osrelease = 4.15.0-44
 *
 * echo ORG_DEVOPSBROKER_SOCKET_IPV4 | md5sum | cut -c 25-32
 *
 * IPv4 sockets use the AF_INET address family for socket communication.
 * -----------------------------------------------------------------------------
 */

#ifndef ORG_DEVOPSBROKER_SOCKET_IPV4_H
#define ORG_DEVOPSBROKER_SOCKET_IPV4_H

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <assert.h>
#include <sys/socket.h>

// ═══════════════════════════════ Preprocessor ═══════════════════════════════

#define TCP_OVERHEAD 40
#define UDP_OVERHEAD 28

// ═════════════════════════════════ Typedefs ═════════════════════════════════

typedef enum IPv4SocketType {                                       // ip(7)
	IPV4_SOCKET_TCP = SOCK_STREAM,   // TCP socket
	IPV4_SOCKET_UDP = SOCK_DGRAM,    // UDP socket
	IPV4_SOCKET_RAW = SOCK_RAW       // Raw socket to access IP protocol directly
} IPv4SocketType;

typedef struct IPv4Socket {
	int fd;
	IPv4SocketType type;
} IPv4Socket;

static_assert(sizeof(IPv4Socket) == 8, "Check your assumptions");

// ═════════════════════════════ Global Variables ═════════════════════════════


// ════════════════════════════ Function Prototypes ═══════════════════════════

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Socket Functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    a34d4619_open
 * Description: Opens the IPv4 socket for an existing IPv4Socket struct
 *
 * Parameters:
 *   ipv4Socket     A pointer to the IPv4Socket instance to open
 *   socketType     The IPv4 socket type to open
 * ----------------------------------------------------------------------------
 */
void a34d4619_open(IPv4Socket *ipv4Socket, IPv4SocketType socketType);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    a34d4619_close
 * Description: Closes the IPv4 socket for an existing IPv4Socket struct
 *
 * Parameters:
 *   ipv4Socket     A pointer to the IPv4Socket instance to close
 * ----------------------------------------------------------------------------
 */
void a34d4619_close(IPv4Socket *ipv4Socket);

#endif /* ORG_DEVOPSBROKER_SOCKET_IPV4_H */
