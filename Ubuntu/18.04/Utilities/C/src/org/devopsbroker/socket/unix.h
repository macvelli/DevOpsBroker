/*
 * unix.h - DevOpsBroker C header file for the org.devopsbroker.socket.UnixSocket struct
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
 * echo ORG_DEVOPSBROKER_SOCKET_UNIX | md5sum | cut -c 25-32
 *
 * Unix sockets are for efficient interprocess communication between processes
 * on the same machine.
 *
 * UNIX domain sockets can either be:
 *   o Unnamed
 *   o Bound to a filesystem pathname (marked as being of type socket)
 *   o Abstract namespace independent of the filesystem (Linux only)
 *
 * UNIX domain sockets support passing file descriptors or process credentials
 * to other processes using ancillary data.
 * -----------------------------------------------------------------------------
 */

#ifndef ORG_DEVOPSBROKER_SOCKET_UNIX_H
#define ORG_DEVOPSBROKER_SOCKET_UNIX_H

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdlib.h>

#include <assert.h>

#include <asm/types.h>
#include <sys/socket.h>
#include <sys/un.h>

// ═══════════════════════════════ Preprocessor ═══════════════════════════════

#define USOCK_MAX_PATH_LEN   108

// ═════════════════════════════════ Typedefs ═════════════════════════════════

typedef enum UnixSocketType {                                       // unix(7)
	UNIX_SOCK_STREAM = SOCK_STREAM,        // Stream-oriented socket
	UNIX_SOCK_DGRAM = SOCK_DGRAM,          // Datagram-oriented socket that preserves message boundaries (always reliable and don't reorder datagrams)
	UNIX_SOCK_SEQPACKET = SOCK_SEQPACKET   // Sequenced-packet socket that is connection-oriented, preserves message boundaries, and delivers messages in the order that they were sent
} UnixSocketType;

typedef struct sockaddr_un UnixSocketAddress;                       // unix(7)
//	sa_family_t sun_family;                // AF_UNIX
//	char        sun_path[108];             // pathname

static_assert(sizeof(UnixSocketAddress) == 110, "Check your assumptions");

typedef struct UnixSocket {
	int fd;
	UnixSocketType type;
} UnixSocket;

static_assert(sizeof(UnixSocket) == 8, "Check your assumptions");

// ═════════════════════════════ Global Variables ═════════════════════════════


// ════════════════════════════ Function Prototypes ═══════════════════════════

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Socket Functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    bfdb2c2a_open
 * Description: Opens the Unix socket for an existing UnixSocket struct
 *
 * Parameters:
 *   unixSocket     A pointer to the UnixSocket instance to open
 *   socketType     The Unix socket type to open
 * ----------------------------------------------------------------------------
 */
void bfdb2c2a_open(UnixSocket *unixSocket, UnixSocketType socketType);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    bfdb2c2a_close
 * Description: Closes the Unix socket for an existing UnixSocket struct
 *
 * Parameters:
 *   unixSocket     A pointer to the UnixSocket instance to close
 * ----------------------------------------------------------------------------
 */
void bfdb2c2a_close(UnixSocket *unixSocket);

#endif /* ORG_DEVOPSBROKER_SOCKET_UNIX_H */
