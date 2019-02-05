/*
 * file.c - DevOpsBroker C source file for providing file-handling functionality
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
 *
 * -----------------------------------------------------------------------------
 * Developed on Ubuntu 16.04.5 LTS running kernel.osrelease = 4.15.0-34
 *
 * -----------------------------------------------------------------------------
 */

// ════════════════════════════ Feature Test Macros ═══════════════════════════

#define _DEFAULT_SOURCE

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>

#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <unistd.h>
#include <sys/stat.h>

#include "file.h"

#include "../lang/error.h"
#include "../lang/long.h"
#include "../lang/memory.h"
#include "../lang/stringbuilder.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════


// ═════════════════════════════ Global Variables ═════════════════════════════


// ═════════════════════════ Function Implementations ═════════════════════════

int e2f74138_openFile(const char *pathName, const int flags) {
	const int fd = open(pathName, flags);

	if (fd == SYSTEM_ERROR_CODE) {
		if (errno == EISDIR) {
			c7c88e52_printLibError(pathName, errno);
		} else {
			StringBuilder *errorMessage = c598a24c_createStringBuilder();

			c598a24c_append_string(errorMessage, "Cannot open '");
			c598a24c_append_string(errorMessage, pathName);
			c598a24c_append_char(errorMessage, '\'');

			c7c88e52_printLibError(errorMessage->buffer, errno);
			c598a24c_destroyStringBuilder(errorMessage);
		}

		exit(EXIT_FAILURE);
	}

	return fd;
}

void e2f74138_closeFile(const int fd, const char *pathName) {
	if (close(fd) == SYSTEM_ERROR_CODE) {
		StringBuilder *errorMessage = c598a24c_createStringBuilder();

		c598a24c_append_string(errorMessage, "Cannot close '");
		c598a24c_append_string(errorMessage, pathName);
		c598a24c_append_char(errorMessage, '\'');

		c7c88e52_printLibError(errorMessage->buffer, errno);
		c598a24c_destroyStringBuilder(errorMessage);
		exit(EXIT_FAILURE);
	}
}

bool e2f74138_fileExists(const char *pathName) {
	return access(pathName, F_OK) == 0;
}

bool e2f74138_isReadable(const char *pathName) {
	return access(pathName, R_OK) == 0;
}

bool e2f74138_isWritable(const char *pathName) {
	return access(pathName, W_OK) == 0;
}

bool e2f74138_isExecutable(const char *pathName) {
	return access(pathName, X_OK) == 0;
}

bool e2f74138_isAccessible(const char *pathName, int mode) {
	return access(pathName, mode) == 0;
}

void e2f74138_getFileStatus(const char *pathName, FileStatus* fileStatus) {
	if (stat(pathName, fileStatus) == SYSTEM_ERROR_CODE) {
		StringBuilder *errorMessage = c598a24c_createStringBuilder();

		c598a24c_append_string(errorMessage, "Cannot stat '");
		c598a24c_append_string(errorMessage, pathName);
		c598a24c_append_char(errorMessage, '\'');

		c7c88e52_printLibError(errorMessage->buffer, errno);
		c598a24c_destroyStringBuilder(errorMessage);
		exit(EXIT_FAILURE);
	}
}

void e2f74138_getLinkStatus(const char *pathName, FileStatus* fileStatus) {
	if (lstat(pathName, fileStatus) == SYSTEM_ERROR_CODE) {
		StringBuilder *errorMessage = c598a24c_createStringBuilder();

		c598a24c_append_string(errorMessage, "Cannot stat '");
		c598a24c_append_string(errorMessage, pathName);
		c598a24c_append_char(errorMessage, '\'');

		c7c88e52_printLibError(errorMessage->buffer, errno);
		c598a24c_destroyStringBuilder(errorMessage);
		exit(EXIT_FAILURE);
	}
}

ssize_t e2f74138_readFile(const int fd, void *buffer, size_t count, const char *pathName) {
	const ssize_t numBytes = read(fd, buffer, count);

	if (numBytes == SYSTEM_ERROR_CODE) {
		StringBuilder *errorMessage = c598a24c_createStringBuilder();

		c598a24c_append_string(errorMessage, "Cannot read from file '");
		c598a24c_append_string(errorMessage, pathName);
		c598a24c_append_char(errorMessage, '\'');

		c7c88e52_printLibError(errorMessage->buffer, errno);
		c598a24c_destroyStringBuilder(errorMessage);

		exit(EXIT_FAILURE);
	}

	return numBytes;
}

char *e2f74138_readlink(const char *pathName, const ssize_t fileSize) {
	const ssize_t bufSize = (fileSize == 0) ? PATH_MAX : fileSize;

	char *realPathName = f668c4bd_malloc_size_size(sizeof(char), bufSize + 1);

	if (readlink(pathName, realPathName, bufSize) == SYSTEM_ERROR_CODE) {
		StringBuilder *errorMessage = c598a24c_createStringBuilder();

		c598a24c_append_string(errorMessage, "Cannot read link '");
		c598a24c_append_string(errorMessage, pathName);
		c598a24c_append_char(errorMessage, '\'');

		c7c88e52_printLibError(errorMessage->buffer, errno);
		c598a24c_destroyStringBuilder(errorMessage);
		exit(EXIT_FAILURE);
	}

	// readlink does not perform null termination
	realPathName[fileSize] = '\0';

	return realPathName;
}

uint64_t e2f74138_read_uint64(register const char *pathName) {
	register int fileDescriptor;
	register ssize_t numBytes;
	char buffer[32];

	fileDescriptor = e2f74138_openFile(pathName, O_RDONLY);
	numBytes = e2f74138_readFile(fileDescriptor, buffer, 32, pathName);
	e2f74138_closeFile(fileDescriptor, pathName);

	if (numBytes != END_OF_FILE) {
		return db0acb04_parse_uint64_ssize(buffer, numBytes - 1);
	}

	return 0UL;
}

char *e2f74138_realpath(const char *pathName) {
	char *realPathName = realpath(pathName, NULL);

	if (realPathName == NULL) {
		StringBuilder *errorMessage = c598a24c_createStringBuilder();

		c598a24c_append_string(errorMessage, "Cannot find absolute pathname for '");
		c598a24c_append_string(errorMessage, pathName);
		c598a24c_append_char(errorMessage, '\'');

		c7c88e52_printLibError(errorMessage->buffer, errno);
		c598a24c_destroyStringBuilder(errorMessage);
		exit(EXIT_FAILURE);
	}

	return realPathName;
}
