/*
 * logline.h - DevOpsBroker C header file for the org.devopsbroker.firelog.LogLine struct
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
 * Developed on Ubuntu 16.04.5 LTS running kernel.osrelease = 4.15.0-34
 *
 * echo ORG_DEVOPSBROKER_LOG_LOGLINE | md5sum | cut -c 25-32
 * -----------------------------------------------------------------------------
 */

#ifndef ORG_DEVOPSBROKER_LOG_LOGLINE_H
#define ORG_DEVOPSBROKER_LOG_LOGLINE_H

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdint.h>

#include <assert.h>

#include "../lang/string.h"

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

static_assert(sizeof(LogLine) == 64, "Check your assumptions");

// ═════════════════════════════ Global Variables ═════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════

// ~~~~~~~~~~~~~~~~~~~~~~~~~ Create/Destroy Functions ~~~~~~~~~~~~~~~~~~~~~~~~~

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    b45c9f7e_createLogLine
 * Description: Creates a LogLine struct instance
 *
 * Returns:     A LogLine struct instance
 * ----------------------------------------------------------------------------
 */
LogLine *b45c9f7e_createLogLine();

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    b45c9f7e_destroyLogLine
 * Description: Frees the memory allocated to the LogLine struct pointer
 *
 * Parameters:
 *   logLine	A pointer to the LogLine instance to destroy
 * ----------------------------------------------------------------------------
 */
void b45c9f7e_destroyLogLine(LogLine *logLine);

// ~~~~~~~~~~~~~~~~~~~~~~~~~ Init/Clean Up Functions ~~~~~~~~~~~~~~~~~~~~~~~~~~

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    b45c9f7e_initLogLine
 * Description: Initializes an existing LogLine struct
 *
 * Parameters:
 *   logLine	A pointer to the LogLine instance to initalize
 *   line       A pointer reference to the line data
 * ----------------------------------------------------------------------------
 */
void b45c9f7e_initLogLine(LogLine *logLine, String *line);

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Utility Functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    b45c9f7e_cloneLogLine
 * Description: Clones the LogLine contents contained within the pointer
 *
 * Parameters:
 *   logLine    The LogLine instance to clone
 * Returns:     A cloned instance of the LogLine
 * ----------------------------------------------------------------------------
 */
LogLine *b45c9f7e_cloneLogLine(LogLine *logLine);

#endif /* ORG_DEVOPSBROKER_LOG_LOGLINE_H */
