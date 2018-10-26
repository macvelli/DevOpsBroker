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


// ═════════════════════════════ Global Variables ═════════════════════════════


// ═════════════════════════ Function Implementations ═════════════════════════

String *c196bc72_getLine(LineBuffer *lineBuffer, const ssize_t numBytes) {
	register char* newline = lineBuffer->buffer + lineBuffer->length;
	register uint32_t lineLength = lineBuffer->length;
	register char ch = *newline;

	lineBuffer->line.value = newline;
	while (ch && lineLength < numBytes) {
		if (ch == '\n') {
			*newline = '\0';

			lineBuffer->line.length = lineLength - lineBuffer->length;
			lineBuffer->length = (lineLength + 1);

			if (lineBuffer->bufferTail.length > 0) {
				c598a24c_append_string(&lineBuffer->bufferTail, lineBuffer->line.value);
				lineBuffer->line.value = lineBuffer->bufferTail.buffer;
				lineBuffer->bufferTail.length = 0;
			}

			return &lineBuffer->line;
		}

		ch = *(++newline);
		lineLength++;
	}

	if (ch == '\0' || lineLength != lineBuffer->length) {
		c598a24c_append_string_uint32(&lineBuffer->bufferTail, lineBuffer->line.value, lineLength - lineBuffer->length);

		// Reset LineBuffer
		c196bc72_resetLineBuffer(lineBuffer);
	}

	return NULL;
}
