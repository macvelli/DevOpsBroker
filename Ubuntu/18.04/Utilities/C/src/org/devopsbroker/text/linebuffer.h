/*
 * linebuffer.h - DevOpsBroker C header file for providing text line-processing functionality
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
 * echo ORG_DEVOPSBROKER_TEXT_LINEBUFFER | md5sum | cut -c 25-32
 * -----------------------------------------------------------------------------
 */

#ifndef ORG_DEVOPSBROKER_TEXT_LINEBUFFER_H
#define ORG_DEVOPSBROKER_TEXT_LINEBUFFER_H

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdlib.h>
#include <stdint.h>

#include "../io/file.h"
#include "../lang/memory.h"
#include "../lang/string.h"
#include "../lang/stringbuilder.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════

typedef struct LineBuffer {
	char *buffer;
	uint32_t length;
	String line;
	StringBuilder bufferTail;
} LineBuffer;

// ═════════════════════════════ Global Variables ═════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c196bc72_createLineBuffer
 * Description: Creates a LineBuffer struct with the specified char* buffer
 *
 * Parameters:
 *   buffer     A pointer to the char* buffer
 * Returns:     A LineBuffer struct with the specified char* buffer
 * ----------------------------------------------------------------------------
 */
static inline LineBuffer *c196bc72_createLineBuffer(char *buffer) {
	LineBuffer *lineBuffer = f668c4bd_malloc_size(sizeof(LineBuffer));

	lineBuffer->buffer = buffer;
	lineBuffer->length = 0;
	lineBuffer->line.value = buffer;
	lineBuffer->line.length = 0;

	c598a24c_initStringBuilder_uint32(&lineBuffer->bufferTail, LOGICAL_BLOCK_SIZE);

	return lineBuffer;
}

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c196bc72_destroyLineBuffer
 * Description: Frees the memory allocated to the LineBuffer struct pointer
 *
 * Parameters:
 *   lineBuffer     A pointer to the LineBuffer instance to destroy
 * ----------------------------------------------------------------------------
 */
static inline void c196bc72_destroyLineBuffer(LineBuffer *lineBuffer) {
	c598a24c_destroyStringBuilder(&lineBuffer->bufferTail);
	f668c4bd_free(lineBuffer);
}

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c196bc72_getLine
 * Description: Returns a String* to the next line in the LineBuffer
 *
 * Parameters:
 *   lineBuffer     A pointer to the LineBuffer instance
 *   numBytes       The number of bytes available in the buffer
 * Returns:         A String* pointer to the next line, or NULL if no line found
 *
 * NOTE: This method will bomb out with a SIGSEGV Segmentation Fault if the
 *       char* buffer refers to data that resides within the read-only Data
 *       Segment area of your program.
 * ----------------------------------------------------------------------------
 */
String *c196bc72_getLine(LineBuffer *lineBuffer, const ssize_t numBytes);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c196bc72_initLineBuffer
 * Description: Initializes an existing LineBuffer struct with the specified char* buffer
 *
 * Parameters:
 *   lineBuffer     A pointer to the LineBuffer instance to initalize
 *   buffer         A pointer to the char* buffer
 * ----------------------------------------------------------------------------
 */
static inline void c196bc72_initLineBuffer(LineBuffer *lineBuffer, char *buffer) {
	lineBuffer->buffer = buffer;
	lineBuffer->length = 0;
	lineBuffer->line.value = buffer;
	lineBuffer->line.length = 0;

	c598a24c_initStringBuilder_uint32(&lineBuffer->bufferTail, LOGICAL_BLOCK_SIZE);
}

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c196bc72_resetLineBuffer
 * Description: Resets an existing LineBuffer struct to its initial state
 *
 * Parameters:
 *   lineBuffer     A pointer to the LineBuffer instance to reset
 *   buffer         A pointer to the char* buffer
 * ----------------------------------------------------------------------------
 */
static inline void c196bc72_resetLineBuffer(LineBuffer *lineBuffer) {
	lineBuffer->length = 0;
	lineBuffer->line.value = lineBuffer->buffer;
	lineBuffer->line.length = 0;
}

#endif /* ORG_DEVOPSBROKER_TEXT_LINEBUFFER_H */
