/*
 * system.c - DevOpsBroker C source file for providing system-level functionality
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
 * Developed on Ubuntu 16.04.5 LTS running kernel.osrelease = 4.15.0-34
 *
 * -----------------------------------------------------------------------------
 */

// ════════════════════════════ Feature Test Macros ═══════════════════════════

#define _DEFAULT_SOURCE

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdlib.h>
#include <unistd.h>

#include <sys/types.h>
#include <sys/wait.h>

#include "system.h"
#include "error.h"
#include "stringbuilder.h"
#include "../io/file.h"
#include "../io/pipe.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════


// ═════════════════════════════ Global Variables ═════════════════════════════


// ═════════════════════════ Function Implementations ═════════════════════════

StringBuilder *c16819a0_execute(const char *path, char *const argv[]) {
	// First configure the pipe to caputre output from the process execution
	Pipe pipe;
	c31ab0c3_createPipe(&pipe);

	pid_t child = fork();

	if (child == SYSTEM_ERROR_CODE) {
		c7c88e52_printError_string_int("Attempt to fork() child process failed", errno);
		exit(EXIT_FAILURE);
	} else if (child > 0) {
		// We are actually in the "parent"
		c31ab0c3_closeWrite(&pipe);

		StringBuilder *execOutput = c598a24c_createStringBuilder_uint32(PIPE_BUFFER_LENGTH);
		char buffer[PIPE_BUFFER_LENGTH];
		register ssize_t numBytes;

		numBytes = e2f74138_readFile(*pipe.read, buffer, PIPE_BUFFER_LENGTH, path);
		while (numBytes != END_OF_FILE) {
			c598a24c_append_string_uint32(execOutput, buffer, numBytes);
			numBytes = e2f74138_readFile(*pipe.read, buffer, PIPE_BUFFER_LENGTH, path);
		}
		c31ab0c3_closeRead(&pipe);

		int status;
		pid_t pid = waitpid(child, &status, 0);

		if (pid == SYSTEM_ERROR_CODE) {
			register StringBuilder *errorMessage = c598a24c_createStringBuilder();

			c598a24c_append_string(errorMessage, "Attempt to wait() on child process '");
			c598a24c_append_int32(errorMessage, child);
			c598a24c_append_string(errorMessage, "' failed");

			c7c88e52_printError_string_int(errorMessage->buffer, errno);
			c598a24c_destroyStringBuilder(errorMessage);

			exit(EXIT_FAILURE);
		}

		if (!WIFEXITED(status) || WEXITSTATUS(status) != EXIT_SUCCESS) {
			register StringBuilder *errorMessage = c598a24c_createStringBuilder();

			c598a24c_append_string(errorMessage, "Invalid child process exit status '");
			c598a24c_append_int32(errorMessage, status);
			c598a24c_append_char(errorMessage, '\'');

			c7c88e52_printError_string(errorMessage->buffer);
			c598a24c_destroyStringBuilder(errorMessage);

			exit(EXIT_FAILURE);
		}

		// Program execution succeeded
		return execOutput;

	} else {
		// We are actually in the "child"
		c31ab0c3_redirectToStdout(&pipe);
		c31ab0c3_closeRead(&pipe);
		if (execv(path, argv) == SYSTEM_ERROR_CODE) {
			register StringBuilder *errorMessage = c598a24c_createStringBuilder_uint32(256);

			c598a24c_append_string(errorMessage, "Attempt to execute() child process '");
			c598a24c_append_string(errorMessage, path);
			c598a24c_append_string(errorMessage, "' with arguments '");
			c598a24c_append_stringArray(errorMessage, argv);
			c598a24c_append_string(errorMessage, "' failed");

			c7c88e52_printError_string_int(errorMessage->buffer, errno);
			c598a24c_destroyStringBuilder(errorMessage);

			exit(EXIT_FAILURE);
		}
	}

	return NULL;
}
