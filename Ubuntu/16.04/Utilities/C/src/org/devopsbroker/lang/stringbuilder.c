/*
 * stringbuilder.c - DevOpsBroker C source file for the StringBuilder struct
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
#include <stdint.h>
#include <stdio.h>

#include "long.h"
#include "stringbuilder.h"
#include "system.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ════════════════════════════════ Structures ════════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════

/*
 * Static functions in C restrict their scope to the file where they are declared
 */
static inline void resizeStringBuilder(StringBuilder* strBuilder) {
	strBuilder->size <<= 1;
	strBuilder->buffer = c16819a0_realloc_void_size_size(strBuilder->buffer, sizeof(char), strBuilder->size);
}

static inline void appendNull(StringBuilder* strBuilder) {
	// Resize strBuilder->string if necessary
	if (strBuilder->length == strBuilder->size) {
		resizeStringBuilder(strBuilder);
	}

	strBuilder->buffer[strBuilder->length] = '\0';
}

// ═════════════════════════════ Global Variables ═════════════════════════════


// ═════════════════════════ Function Implementations ═════════════════════════

void c598a24c_append_char(register StringBuilder *strBuilder, const char ch) {
	uint32_t length = strBuilder->length;
	strBuilder->length++;

	// Resize strBuilder->buffer if necessary
	if (strBuilder->length >= strBuilder->size) {
		resizeStringBuilder(strBuilder);
	}

	strBuilder->buffer[length++] = ch;
	strBuilder->buffer[length] = '\0';
}

void c598a24c_append_int64(StringBuilder *strBuilder, const int64_t signedLong) {
	char* signedLongStr = db0acb04_toString_int64(signedLong);

	c598a24c_append_string(strBuilder, signedLongStr);

	c16819a0_free(signedLongStr);
}

void c598a24c_append_uint64(StringBuilder *strBuilder, const uint64_t unsignedLong) {
	char* unsignedLongStr = db0acb04_toString_uint64(unsignedLong);

	c598a24c_append_string(strBuilder, unsignedLongStr);

	c16819a0_free(unsignedLongStr);
}

void c598a24c_append_string(StringBuilder *strBuilder, const char *source) {
	char* target = strBuilder->buffer + strBuilder->length;

	while (*source) {
		// Resize strBuilder->string if necessary
		if (strBuilder->length == strBuilder->size) {
			resizeStringBuilder(strBuilder);
		}

		*target = *source;
		source++;
		target++;
		strBuilder->length++;
	}

	appendNull(strBuilder);
}

void c598a24c_append_string_uint32(StringBuilder *strBuilder, const char *source, const uint32_t length) {
	char* target = strBuilder->buffer + strBuilder->length;
	const char* end = source + length;

	while (source != end) {
		// Resize strBuilder->string if necessary
		if (strBuilder->length == strBuilder->size) {
			resizeStringBuilder(strBuilder);
		}

		*target = *source;
		source++;
		target++;
		strBuilder->length++;
	}

	appendNull(strBuilder);
}
