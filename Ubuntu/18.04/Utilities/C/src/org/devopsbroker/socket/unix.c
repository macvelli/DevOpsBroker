/*
 * unix.c - DevOpsBroker C source file for the org.devopsbroker.socket.UnixSocket struct
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

#include <unistd.h>

#include <sys/socket.h>

#include "unix.h"

#include "../lang/error.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════


// ═════════════════════════════ Global Variables ═════════════════════════════


// ═════════════════════════ Function Implementations ═════════════════════════

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Socket Functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void bfdb2c2a_open(UnixSocket *unixSocket, UnixSocketType socketType) {
	unixSocket->fd = socket(AF_UNIX, socketType | SOCK_CLOEXEC, 0);

	if (unixSocket->fd == SYSTEM_ERROR_CODE) {
		c7c88e52_printLibError("Cannot open Unix socket", errno);
		exit(EXIT_FAILURE);
	}

	unixSocket->type = socketType;
}

void bfdb2c2a_close(UnixSocket *unixSocket) {

	if (close(unixSocket->fd) == SYSTEM_ERROR_CODE) {
		c7c88e52_printLibError("Cannot close Unix socket", errno);
		exit(EXIT_FAILURE);
	}

}
