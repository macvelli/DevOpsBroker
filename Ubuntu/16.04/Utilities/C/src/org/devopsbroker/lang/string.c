/*
 * string.c - DevOpsBroker C source file for string constants and functions
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
 * Are you using the -O flag? If so, don't or set it to 0
 * -----------------------------------------------------------------------------
 */

// ════════════════════════════ Feature Test Macros ═══════════════════════════

#define _DEFAULT_SOURCE

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdlib.h>
#include <stdarg.h>
#include <stdint.h>

#include "string.h"
#include "stringbuilder.h"
#include "system.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════


// ═════════════════════════════ Global Variables ═════════════════════════════

const char f6215943_digitOnes[128] = { '0', '1', '2', '3', '4', '5', '6', '7',
	'8', '9', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '1', '2',
	'3', '4', '5', '6', '7', '8', '9', '0', '1', '2', '3', '4', '5', '6', '7',
	'8', '9', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '1', '2',
	'3', '4', '5', '6', '7', '8', '9', '0', '1', '2', '3', '4', '5', '6', '7',
	'8', '9', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '1', '2',
	'3', '4', '5', '6', '7', '8', '9', '0', '1', '2', '3', '4', '5', '6', '7',
	'8', '9' };

const char f6215943_digitTens[128] = { '0', '0', '0', '0', '0', '0', '0', '0',
	'0', '0', '1', '1', '1', '1', '1', '1', '1', '1', '1', '1', '2', '2', '2',
	'2', '2', '2', '2', '2', '2', '2', '3', '3', '3', '3', '3', '3', '3', '3',
	'3', '3', '4', '4', '4', '4', '4', '4', '4', '4', '4', '4', '5', '5', '5',
	'5', '5', '5', '5', '5', '5', '5', '6', '6', '6', '6', '6', '6', '6', '6',
	'6', '6', '7', '7', '7', '7', '7', '7', '7', '7', '7', '7', '8', '8', '8',
	'8', '8', '8', '8', '8', '8', '8', '9', '9', '9', '9', '9', '9', '9', '9',
	'9', '9' };

// ═════════════════════════ Function Implementations ═════════════════════════

String *f6215943_cloneString(String *string) {
	String *clone = f6215943_createString(string->length);

	register char *source = string->value;
	register char *target = clone->value;

	while (*source) {
		*target = *source;
		target++;
		source++;
	}

	*target = '\0';

	return clone;
}

char *f6215943_concatenate(char *string, ...) {
	// Append first string argument to the StringBuilder
	StringBuilder *strBuilder = c598a24c_createStringBuilder();
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

	string = strBuilder->buffer;
	c598a24c_freeStringBuilder(strBuilder);

	return string;
}

char *f6215943_copy(register const char *source, register const uint32_t length) {
	char *copy = c16819a0_malloc_size_size(sizeof(char), length + 1);

	register char *ptr = copy;
	register uint32_t i = 0;

	while (i < length) {
		*ptr = *source;
		ptr++;
		source++;
		i++;
	}

	*ptr = '\0';

	return copy;
}

bool f6215943_isEqual(register const char *foo, register const char *bar) {
	if (foo == bar) {
		return true;
	}

	if (foo == NULL || bar == NULL) {
		return false;
	}

	register char fooCh = *foo;
	register char barCh = *bar;

	while (fooCh && barCh && fooCh == barCh) {
		foo++;
		bar++;

		fooCh = *foo;
		barCh = *bar;
	}

	return (fooCh == barCh);
}

char *f6215943_search(char *pattern, char *text) {
	char *ptr = pattern;

	while (*text) {
		while (*ptr == *text || *ptr == '\0') {
			if (*ptr == '\0') {
				return text;
			}

			ptr++;
			text++;
		}

		if (ptr != pattern) {
			ptr = pattern;
		}

		text++;
	}

	return NULL;
}
