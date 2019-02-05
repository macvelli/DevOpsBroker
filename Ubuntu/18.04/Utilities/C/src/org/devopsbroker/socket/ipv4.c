/*
 * ipv4.c - DevOpsBroker C source file for the org.devopsbroker.socket.IPv4Socket struct
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
 * -----------------------------------------------------------------------------
 */

// ════════════════════════════ Feature Test Macros ═══════════════════════════

#define _DEFAULT_SOURCE

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <unistd.h>
#include <netinet/in.h>

#include "ipv4.h"

#include "../lang/error.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════


// ═════════════════════════════ Global Variables ═════════════════════════════


// ═════════════════════════ Function Implementations ═════════════════════════

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Socket Functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void a34d4619_open(IPv4Socket *ipv4Socket, IPv4SocketType socketType) {
	ipv4Socket->fd = socket(AF_INET, socketType, IPPROTO_IP);

	if (ipv4Socket->fd == SYSTEM_ERROR_CODE) {
		c7c88e52_printError_string_int("Cannot open IPv4 socket", errno);
		exit(EXIT_FAILURE);
	}

	ipv4Socket->type = socketType;
}

void a34d4619_close(IPv4Socket *ipv4Socket) {

	if (close(ipv4Socket->fd) == SYSTEM_ERROR_CODE) {
		c7c88e52_printError_string_int("Cannot close IPv4 socket", errno);
		exit(EXIT_FAILURE);
	}

}
