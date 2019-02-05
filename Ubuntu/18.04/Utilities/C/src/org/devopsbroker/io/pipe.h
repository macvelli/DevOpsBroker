/*
 * pipe.h - DevOpsBroker C header file for providing a unidirectional data channel used for interprocess communication
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
 * Developed on Ubuntu 16.04.5 LTS running kernel.osrelease = 4.15.0-36
 *
 * echo ORG_DEVOPSBROKER_IO_PIPE | md5sum | cut -c 25-32
 * -----------------------------------------------------------------------------
 */

#ifndef ORG_DEVOPSBROKER_IO_PIPE_H
#define ORG_DEVOPSBROKER_IO_PIPE_H

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

#include <linux/limits.h>

#include "file.h"
#include "../lang/error.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════

#define PIPE_IO_SIZE 2
#define PIPE_BUFFER_LENGTH PIPE_BUF

// ═════════════════════════════════ Typedefs ═════════════════════════════════

typedef struct Pipe {
	int io[PIPE_IO_SIZE];
	int *read;
	int *write;
} Pipe;

// ═════════════════════════════ Global Variables ═════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c31ab0c3_closePipe
 * Description: Closes both the read and write ends of the pipe()
 *
 * Parameters:
 *   pipe	A pointer to the Pipe instance to modify
 * ----------------------------------------------------------------------------
 */
static inline void c31ab0c3_closePipe(register Pipe *pipe) {
	// Close the read end of the pipe
	if (close(*pipe->read) == SYSTEM_ERROR_CODE) {
		c7c88e52_printLibError("Attempt to close read end of pipe() failed", errno);
		exit(EXIT_FAILURE);
	}

	// Close the write end of the pipe
	if (close(*pipe->write) == SYSTEM_ERROR_CODE) {
		c7c88e52_printLibError("Attempt to close write end of pipe() failed", errno);
		exit(EXIT_FAILURE);
	}
}

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c31ab0c3_closeRead
 * Description: Closes the read end of the pipe()
 *
 * Parameters:
 *   pipe	A pointer to the Pipe instance to modify
 * ----------------------------------------------------------------------------
 */
static inline void c31ab0c3_closeRead(register Pipe *pipe) {
	// Close the read end of the pipe
	if (close(*pipe->read) == SYSTEM_ERROR_CODE) {
		c7c88e52_printLibError("Attempt to close read end of pipe() failed", errno);
		exit(EXIT_FAILURE);
	}
}

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c31ab0c3_closeWrite
 * Description: Closes the write end of the pipe()
 *
 * Parameters:
 *   pipe	A pointer to the Pipe instance to modify
 * ----------------------------------------------------------------------------
 */
static inline void c31ab0c3_closeWrite(register Pipe *pipe) {
	// Close the write end of the pipe
	if (close(*pipe->write) == SYSTEM_ERROR_CODE) {
		c7c88e52_printLibError("Attempt to close write end of pipe() failed", errno);
		exit(EXIT_FAILURE);
	}
}

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c31ab0c3_createPipe
 * Description: Initializes an existing Pipe struct by creating a pipe()
 *
 * Parameters:
 *   pipeObj    A pointer to the Pipe instance to initalize
 * ----------------------------------------------------------------------------
 */
static inline void c31ab0c3_createPipe(register Pipe *pipeObj) {
	// Create the pipe
	if (pipe(pipeObj->io) == SYSTEM_ERROR_CODE) {
		c7c88e52_printLibError("Attempt to create pipe() failed", errno);
		exit(EXIT_FAILURE);
	}

	// Initialize the read/write attributes
	int *ptr = pipeObj->io;
	pipeObj->read = ptr++;
	pipeObj->write = ptr;
}

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c31ab0c3_redirectToStdout
 * Description: Redirects the write end of the pipe() to STDOUT
 *
 * Parameters:
 *   pipe	A pointer to the Pipe instance to redirect
 * ----------------------------------------------------------------------------
 */
static inline void c31ab0c3_redirectToStdout(register Pipe *pipe) {
	// Redirect the pipe to STDOUT
	if (dup2(*pipe->write, STDOUT_FILENO) == SYSTEM_ERROR_CODE) {
		c7c88e52_printLibError("Attempt to redirect pipe() to STDOUT failed", errno);
		exit(EXIT_FAILURE);
	}
}

#endif /* ORG_DEVOPSBROKER_IO_PIPE_H */
