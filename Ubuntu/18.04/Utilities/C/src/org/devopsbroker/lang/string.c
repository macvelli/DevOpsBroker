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

#include "error.h"
#include "memory.h"
#include "string.h"
#include "stringbuilder.h"

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

const char f6215943_digitHex[16] = { '0', '1', '2', '3', '4', '5', '6', '7',
	'8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };

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
	StringBuilder strBuilder;
	c598a24c_initStringBuilder(&strBuilder);
	c598a24c_append_string(&strBuilder, string);

	// Initialize the varargs argument list
	va_list ap;
	va_start(ap, string);

	c598a24c_append_string_va_list(&strBuilder, &ap);

	// Clean up varargs
	va_end(ap);

	return strBuilder.buffer;
}

uint32_t f6215943_copy_to_buffer(register const char *source, register char *buffer, register const uint32_t bufSize) {
	register uint32_t i = 0;
	register char ch = *source;

	do {
		if (i == bufSize) {
			return SYSTEM_ERROR_CODE;
		}

		if (ch == '\0') {
			*buffer = '\0';
			return i;
		}

		*(buffer++) = ch;
		ch = *(++source);
		i++;
	} while (true);
}

bool f6215943_isNotEqual(register const char *foo, register const char *bar) {
	if (foo == bar) {
		return false;
	}

	if (foo == NULL || bar == NULL) {
		return true;
	}

	register char fooCh = *foo;
	register char barCh = *bar;

	while (fooCh && barCh && fooCh == barCh) {
		foo++;
		bar++;

		fooCh = *foo;
		barCh = *bar;
	}

	return (fooCh != barCh);
}

char *f6215943_startsWith(register const char *pattern, register char *text) {
	register char ch = *pattern;

	while (ch && ch == *text) {
		text++;
		ch = *(++pattern);
	}

	return (ch == '\0') ? text : NULL;
}
