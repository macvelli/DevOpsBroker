/*
 * linebuffer.c - DevOpsBroker C source file for providing text line-processing functionality
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

#include "linebuffer.h"

#include "../io/file.h"
#include "../lang/string.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════

/*
 * The SOH character apparently is the Linux way of saying read() filled the
 * buffer and has more data to read.
 */
static inline void processEndOfBuffer(LineBuffer *lineBuffer, const char *newline) {
	// Append end of buffer to the StringBuilder buffer tail
	register const uint32_t length = (newline - lineBuffer->line.value - 1);
	c598a24c_append_string_uint32(&lineBuffer->bufferTail, lineBuffer->line.value, length);

	// Reset LineBuffer
	c196bc72_resetLineBuffer(lineBuffer);
}

// ═════════════════════════════ Global Variables ═════════════════════════════


// ═════════════════════════ Function Implementations ═════════════════════════

String *c196bc72_getLine(LineBuffer *lineBuffer, const ssize_t numBytes) {
	// Return NULL if we reached the end of the buffer
	if (lineBuffer->length == numBytes) {
		return NULL;
	}

	register char* newline = lineBuffer->buffer + lineBuffer->length;
	register char ch = *newline;

	lineBuffer->line.value = newline;
	while (ch && ch != START_OF_HEADING) {
		if (ch == '\n') {
			*newline = '\0';

			lineBuffer->line.length = (newline - lineBuffer->line.value - 1);
			lineBuffer->length += (lineBuffer->line.length + 2);

			if (lineBuffer->bufferTail.length > 0) {
				c598a24c_append_string(&lineBuffer->bufferTail, lineBuffer->line.value);
				lineBuffer->line.value = lineBuffer->bufferTail.buffer;
				lineBuffer->bufferTail.length = 0;
			}

			return &lineBuffer->line;
		}

		newline++;
		ch = *newline;
	}

	if ((ch == '\0' || ch == START_OF_HEADING) && newline != lineBuffer->line.value) {
		processEndOfBuffer(lineBuffer, newline);
	}

	return NULL;
}
