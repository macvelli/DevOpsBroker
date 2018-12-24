/*
 * socket.c - DevOpsBroker C source file for socket-related functionality
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
 *
 * -----------------------------------------------------------------------------
 * Developed on Ubuntu 18.04.1 LTS running kernel.osrelease = 4.15.0-42
 *
 * -----------------------------------------------------------------------------
 */

// ════════════════════════════ Feature Test Macros ═══════════════════════════

#define _DEFAULT_SOURCE

// ═════════════════════════════════ Includes ═════════════════════════════════

#include "socket.h"

#include "../lang/error.h"
#include "../lang/memory.h"
#include "../lang/stringbuilder.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ═════════════════════════════ Global Variables ═════════════════════════════


// ════════════════════════════ Function Prototypes ═══════════════════════════


// ═════════════════════════ Function Implementations ═════════════════════════

// ~~~~~~~~~~~~~~~~~~~~~~~~~ Create/Destroy Functions ~~~~~~~~~~~~~~~~~~~~~~~~~

IOBuffer *a36b5966_createIOBuffer(size_t bufLen) {
	IOBuffer *ioBuffer = f668c4bd_malloc_size(sizeof(IOBuffer));

	ioBuffer->iov_base = f668c4bd_malloc_size(bufLen);
	ioBuffer->iov_len = bufLen;

	return ioBuffer;
}

void a36b5966_destroyIOBuffer(IOBuffer *ioBuffer) {
	free(ioBuffer->iov_base);
	free(ioBuffer);
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Socket Functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void a36b5966_setMaxSendBufferSize(int sockfd, uint32_t bufSize) {
	int status = setsockopt(sockfd, SOL_SOCKET, SO_SNDBUF, &bufSize, 4);

	if (status == SYSTEM_ERROR_CODE) {
		StringBuilder errorMessage;
		c598a24c_initStringBuilder(&errorMessage);

		c598a24c_append_string(&errorMessage, "Cannot set max send buffer size '");
		c598a24c_append_uint32(&errorMessage, bufSize);
		c598a24c_append_char(&errorMessage, '\'');

		c7c88e52_printError_string_int(errorMessage.buffer, errno);
		free(errorMessage.buffer);
		exit(EXIT_FAILURE);
	}
}

void a36b5966_setMaxRecvBufferSize(int sockfd, uint32_t bufSize) {
	int status = setsockopt(sockfd, SOL_SOCKET, SO_RCVBUF, &bufSize, 4);

	if (status == SYSTEM_ERROR_CODE) {
		StringBuilder errorMessage;
		c598a24c_initStringBuilder(&errorMessage);

		c598a24c_append_string(&errorMessage, "Cannot set max receive buffer size '");
		c598a24c_append_uint32(&errorMessage, bufSize);
		c598a24c_append_char(&errorMessage, '\'');

		c7c88e52_printError_string_int(errorMessage.buffer, errno);
		free(errorMessage.buffer);
		exit(EXIT_FAILURE);
	}
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Utility Functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ssize_t a36b5966_receiveMessage(int sockfd, ReceiveMessageHeader *msg, int flags) {
	ssize_t msgLen = recvmsg(sockfd, msg, 0);

	if (msgLen == SYSTEM_ERROR_CODE) {
		c7c88e52_printError_string_int("Cannot receive socket message", errno);
		exit(EXIT_FAILURE);
	}

	return msgLen;
}

ssize_t a36b5966_sendMessage(int sockfd, const void *buf, size_t bufSize, int flags) {
	ssize_t msgLen = sendto(sockfd, buf, bufSize, flags, NULL, 0);

	if (msgLen == SYSTEM_ERROR_CODE) {
		c7c88e52_printError_string_int("Cannot send socket message", errno);
		exit(EXIT_FAILURE);
	}

	return msgLen;
}
