/*
 * logline.h - DevOpsBroker C header file for the org.devopsbroker.firelog.LogLine struct
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
 * Developed on Ubuntu 16.04.5 LTS running kernel.osrelease = 4.15.0-34
 *
 * echo ORG_DEVOPSBROKER_FIRELOG_LOGLINE | md5sum | cut -c 25-32
 * -----------------------------------------------------------------------------
 */

#ifndef ORG_DEVOPSBROKER_FIRELOG_LOGLINE_H
#define ORG_DEVOPSBROKER_FIRELOG_LOGLINE_H

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdlib.h>
#include <stdint.h>

#include "../lang/string.h"
#include "../lang/system.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════

typedef struct LogLine {
	char *in;
	char *out;
	char *macAddress;
	char *sourceIPAddr;
	char *destIPAddr;
	char *protocol;
	uint32_t sourcePort;
	uint32_t destPort;
	uint32_t count;
	uint32_t lineLength;
} LogLine;

// ═════════════════════════════ Global Variables ═════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    e88eda74_cloneLogLine
 * Description: Clones the LogLine contents contained within the pointer
 *
 * Parameters:
 *   logLine    The LogLine instance to clone
 * Returns:     A cloned instance of the LogLine
 * ----------------------------------------------------------------------------
 */
LogLine *e88eda74_cloneLogLine(LogLine *logLine);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    e88eda74_createLogLine
 * Description: Creates a LogLine struct instance
 *
 * Returns:     A LogLine struct instance
 * ----------------------------------------------------------------------------
 */
static inline LogLine *e88eda74_createLogLine() {
	LogLine *logLine = c16819a0_malloc_size(sizeof(LogLine));

	logLine->in = NULL;
	logLine->out = NULL;
	logLine->macAddress = NULL;
	logLine->sourceIPAddr = NULL;
	logLine->destIPAddr = NULL;
	logLine->protocol = NULL;
	logLine->sourcePort = 0;
	logLine->destPort = 0;
	logLine->count = 0;

	return logLine;
}

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    e88eda74_destroyLogLine
 * Description: Frees the memory allocated to the LogLine struct pointer
 *
 * Parameters:
 *   logLine	A pointer to the LogLine instance to destroy
 * ----------------------------------------------------------------------------
 */
static inline void e88eda74_destroyLogLine(LogLine *logLine) {
	c16819a0_free(logLine->in);
	c16819a0_free(logLine);
}

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    e88eda74_initLogLine
 * Description: Initializes an existing LogLine struct
 *
 * Parameters:
 *   logLine	A pointer to the LogLine instance to initalize
 *   line       A pointer reference to the line data
 * ----------------------------------------------------------------------------
 */
void e88eda74_initLogLine(LogLine *logLine, String *line);

#endif /* ORG_DEVOPSBROKER_FIRELOG_LOGLINE_H */
