/*
 * linebuffer.h - DevOpsBroker C header file for providing text line-processing functionality
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
 * echo ORG_DEVOPSBROKER_TEXT_LINEBUFFER | md5sum | cut -c 25-32
 * -----------------------------------------------------------------------------
 */

#ifndef ORG_DEVOPSBROKER_TEXT_LINEBUFFER_H
#define ORG_DEVOPSBROKER_TEXT_LINEBUFFER_H

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdlib.h>
#include <stdint.h>

#include <assert.h>

#include "../io/file.h"
#include "../lang/memory.h"
#include "../lang/string.h"
#include "../lang/stringbuilder.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════

#define C196BC72_BUFFER_SIZE 4072                          // PAGESIZE - 24

// ═════════════════════════════════ Typedefs ═════════════════════════════════

typedef struct LineBuffer {
	char buffer[C196BC72_BUFFER_SIZE];
	uint32_t length;
	uint32_t size;
	String line;
} LineBuffer;

static_assert(sizeof(LineBuffer) == 4096, "Check your assumptions");

// ═════════════════════════════ Global Variables ═════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════

// ~~~~~~~~~~~~~~~~~~~~~~~~~ Create/Destroy Functions ~~~~~~~~~~~~~~~~~~~~~~~~~

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c196bc72_createLineBuffer
 * Description: Creates a LineBuffer struct
 *
 * Returns:     A LineBuffer struct
 * ----------------------------------------------------------------------------
 */
LineBuffer *c196bc72_createLineBuffer();

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c196bc72_destroyLineBuffer
 * Description: Frees the memory allocated to the LineBuffer struct pointer
 *
 * Parameters:
 *   lineBuffer     A pointer to the LineBuffer instance to destroy
 * ----------------------------------------------------------------------------
 */
void c196bc72_destroyLineBuffer(LineBuffer *lineBuffer);

// ~~~~~~~~~~~~~~~~~~~~~~~~~ Init/Clean Up Functions ~~~~~~~~~~~~~~~~~~~~~~~~~~

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c196bc72_initLineBuffer
 * Description: Initializes a LineBuffer struct
 *
 * Parameters:
 *   listArray      A pointer to the LineBuffer instance to initalize
 * ----------------------------------------------------------------------------
 */
void c196bc72_initLineBuffer(LineBuffer *lineBuffer);

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Utility Functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c196bc72_getLine
 * Description: Returns a String* to the next line in the LineBuffer
 *
 * Parameters:
 *   lineBuffer     A pointer to the LineBuffer instance
 * Returns:         A String* pointer to the next line, or NULL if no line found
 *
 * NOTE: This method will bomb out with a SIGSEGV Segmentation Fault if the
 *       char* buffer refers to data that resides within the read-only Data
 *       Segment area of your program.
 * ----------------------------------------------------------------------------
 */
String *c196bc72_getLine(LineBuffer *lineBuffer);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c196bc72_populateLineBuffer
 * Description: Populates the LineBuffer with data from the open file descriptor
 *
 * Parameters:
 *   lineBuffer     A pointer to the LineBuffer instance to populate
 *   fd             The open file descriptor to read from
 * Returns:         The number of bytes populated (zero == end of file)
 * ----------------------------------------------------------------------------
 */
int c196bc72_populateLineBuffer(LineBuffer *lineBuffer, int fd);

#endif /* ORG_DEVOPSBROKER_TEXT_LINEBUFFER_H */
