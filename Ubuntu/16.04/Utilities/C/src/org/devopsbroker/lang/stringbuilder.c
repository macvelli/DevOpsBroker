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
#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>

#include "integer.h"
#include "long.h"
#include "memory.h"
#include "stringbuilder.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ════════════════════════════════ Structures ════════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════

/*
 * Static functions in C restrict their scope to the file where they are declared
 */
static inline char *resizeStringBuilder(register StringBuilder* strBuilder) {
	strBuilder->size <<= 1;
	strBuilder->buffer = f668c4bd_realloc_void_size_size(strBuilder->buffer, sizeof(char), strBuilder->size);

	return strBuilder->buffer + strBuilder->length;
}

static inline void appendNull(register StringBuilder* strBuilder, register char *target) {
	// Resize strBuilder->buffer if necessary
	if (strBuilder->length == strBuilder->size) {
		target = resizeStringBuilder(strBuilder);
	}

	*target = '\0';
}

// ═════════════════════════════ Global Variables ═════════════════════════════


// ═════════════════════════ Function Implementations ═════════════════════════

void c598a24c_append_char(register StringBuilder *strBuilder, register const char ch) {
	register char *target = strBuilder->buffer + strBuilder->length;

	// Resize strBuilder->buffer if necessary
	if ((strBuilder->length + 1) >= strBuilder->size) {
		target = resizeStringBuilder(strBuilder);
	}

	strBuilder->length++;
	*(target++) = ch;
	*target = '\0';
}

void c598a24c_append_int32(register StringBuilder *strBuilder, register const int32_t signedInt) {
	register char* signedIntStr = f45efac2_toString_int32(signedInt);

	c598a24c_append_string(strBuilder, signedIntStr);

	f668c4bd_free(signedIntStr);
}

void c598a24c_append_int64(register StringBuilder *strBuilder, register const int64_t signedLong) {
	register char* signedLongStr = db0acb04_toString_int64(signedLong);

	c598a24c_append_string(strBuilder, signedLongStr);

	f668c4bd_free(signedLongStr);
}

void c598a24c_append_uint64(register StringBuilder *strBuilder, register const uint64_t unsignedLong) {
	register char* unsignedLongStr = db0acb04_toString_uint64(unsignedLong);

	c598a24c_append_string(strBuilder, unsignedLongStr);

	f668c4bd_free(unsignedLongStr);
}

void c598a24c_append_string(register StringBuilder *strBuilder, register const char *source) {
	register char* target = strBuilder->buffer + strBuilder->length;
	register char ch = *source;

	while (ch) {
		// Resize strBuilder->buffer if necessary
		if (strBuilder->length == strBuilder->size) {
			target = resizeStringBuilder(strBuilder);
		}

		strBuilder->length++;
		*(target++) = ch;
		ch = *(++source);
	}

	appendNull(strBuilder, target);
}

void c598a24c_append_string_varg(StringBuilder *strBuilder, char *string, ...) {
	// Append first string argument to the StringBuilder
	c598a24c_append_string(strBuilder, string);

	// Initialize the varargs argument list
	va_list ap;
	va_start(ap, string);

	string = va_arg(ap, char*);
	while (string != NULL) {
		c598a24c_append_string(strBuilder, string);

		// Get the next argument value
		string = va_arg(ap, char*);
	}

	// Clean up varargs
	va_end(ap);
}

void c598a24c_append_string_va_list(StringBuilder *strBuilder, va_list *argList) {
	char *string = va_arg(*argList, char*);

	while (string != NULL) {
		c598a24c_append_string(strBuilder, string);

		// Get the next argument value
		string = va_arg(*argList, char*);
	}
}

void c598a24c_append_stringArray(register StringBuilder *strBuilder, register char *const array[]) {
	register char* target = strBuilder->buffer + strBuilder->length;

	// Resize strBuilder->buffer if necessary
	if ((strBuilder->length + 3) >= strBuilder->size) {
		target = resizeStringBuilder(strBuilder);
	}

	*(target++) = '[';
	strBuilder->length++;

	register char ch;
	register char *string = *array;
	if (string != NULL) {
		ch = *string;

		while (ch) {
			// Resize strBuilder->buffer if necessary
			if (strBuilder->length == strBuilder->size) {
				target = resizeStringBuilder(strBuilder);
			}

			strBuilder->length++;
			*(target++) = ch;
			ch = *(++string);
		}

		string = *(++array);
	}

	while (string != NULL) {
		// Resize strBuilder->buffer if necessary
		if (strBuilder->length == strBuilder->size) {
			target = resizeStringBuilder(strBuilder);
		}

		strBuilder->length++;
		*(target++) = ',';
		ch = *string;

		while (ch) {
			// Resize strBuilder->buffer if necessary
			if (strBuilder->length == strBuilder->size) {
				target = resizeStringBuilder(strBuilder);
			}

			strBuilder->length++;
			*(target++) = ch;
			ch = *(++string);
		}

		string = *(++array);
	}

	strBuilder->length++;
	*target = ']';

	appendNull(strBuilder, target);
}

void c598a24c_append_string_uint32(register StringBuilder *strBuilder, register const char *source, const uint32_t length) {
	register char* target = strBuilder->buffer + strBuilder->length;
	register const char* end = source + length;

	// Resize strBuilder->buffer if necessary
	const uint32_t newLength = strBuilder->length + length;
	if ((newLength + 1) >= strBuilder->size) {
		strBuilder->size = (newLength >> 2) * 3;
		target = resizeStringBuilder(strBuilder);
	}

	strBuilder->length += length;

	while (source != end) {
		*(target++) = *(source++);
	}

	*target = '\0';
}
