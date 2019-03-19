/*
 * integer.c - DevOpsBroker C source file for providing integer-related functionality
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
 * -----------------------------------------------------------------------------
 */

// ════════════════════════════ Feature Test Macros ═══════════════════════════

#define _DEFAULT_SOURCE

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdlib.h>
#include <stdint.h>

#include "error.h"
#include "integer.h"
#include "memory.h"
#include "string.h"
#include "stringbuilder.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════


// ═════════════════════════════ Global Variables ═════════════════════════════


// ═════════════════════════ Function Implementations ═════════════════════════

uint32_t f45efac2_getStringSize_int32(register const int32_t value) {
	if (value >= 0) {
		return f45efac2_getStringSize_uint32(value);
	}

	return f45efac2_getStringSize_uint32(-value) + 1;
}

uint32_t f45efac2_getStringSize_uint32(register const uint32_t value) {
	if (value < 100000) {
		if (value < 10) {
			return 2;
		}
		if (value < 100) {
			return 3;
		}
		if (value < 1000) {
			return 4;
		}
		if (value < 10000) {
			return 5;
		}

		return 6;

	}

	if (value < 1000000) {
		return 7;
	}
	if (value < 10000000) {
		return 8;
	}
	if (value < 100000000) {
		return 9;
	}
	if (value < 1000000000) {
		return 10;
	}

	return 11;
}

uint32_t f45efac2_parse_uint32(register const char *source) {
	register char ch = *source;
	register uint32_t value = 0;
	register int digit;

	while (ch) {
		digit = ch - '0';

		// Display error if digit is not a number
		if (digit < 0 || digit > 9) {
			StringBuilder errorMessage;
			c598a24c_initStringBuilder(&errorMessage);

			c598a24c_append_string(&errorMessage, "Invalid unsigned integer: '");
			c598a24c_append_string(&errorMessage, source);
			c598a24c_append_char(&errorMessage, '\'');

			c7c88e52_printError_string(errorMessage.buffer);
			free(errorMessage.buffer);
			exit(EXIT_FAILURE);
		}

		value *= 10;
		value += digit;
		ch = *(++source);
	}

	return value;
}

uint32_t f45efac2_parseHex_uint32(register const char *source) {
	register char ch = *source | 0x20;
	register uint32_t value = 0;
	register int digit;

	// Skip 0x00 portion of hexadecimal value, if present
	while (ch == '0' || ch == 'x') {
		ch = *(++source) | 0x20;
	}

	while (ch != ' ') {
		digit = (ch >= 'a') ? (ch - 'a') + 10 : ch - '0';

		// Bomb out if digit is not a hexadecimal number
		if (digit < 0 || digit > 15) {
			abort();
		}

		value <<= 4;
		value += digit;
		ch = *(++source) | 0x20;
	}

	return value;
}

char *f45efac2_toString_int32(register int32_t value) {
	// Return the int32_t minimum value string
	if (value == INT32_MIN) {
		return "-2147483648";
	}

	const int mallocSize = sizeof(char) * f45efac2_getStringSize_int32(value);
	const bool sign = (value < 0);
	register int remainder;

	if (sign) {
		value = -value;
	}

	register char* target = f668c4bd_malloc(mallocSize);
	target += mallocSize;
	(*--target) = '\0';

	while (value >= 100) {
		remainder = value % 100;
		value /= 100;
		(*--target) = f6215943_digitOnes[remainder];
		(*--target) = f6215943_digitTens[remainder];
	}

	if (value < 10) {
		(*--target) = '0' + value;
	} else {
		(*--target) = f6215943_digitOnes[value];
		(*--target) = f6215943_digitTens[value];
	}

	if (sign) {
		(*--target) = '-';
	}

	return target;
}

char *f45efac2_toString_uint32(register uint32_t value) {
	const size_t mallocSize = sizeof(char) * f45efac2_getStringSize_uint32(value);
	register uint32_t remainder;

	register char* target = f668c4bd_malloc(mallocSize);
	target += mallocSize;
	(*--target) = '\0';

	while (value >= 100) {
		remainder = value % 100;
		value /= 100;
		(*--target) = f6215943_digitOnes[remainder];
		(*--target) = f6215943_digitTens[remainder];
	}

	if (value < 10) {
		(*--target) = '0' + value;
	} else {
		(*--target) = f6215943_digitOnes[value];
		(*--target) = f6215943_digitTens[value];
	}

	return target;
}

char *f45efac2_toStringHex_uint32(register uint32_t value, const uint32_t precision) {
	size_t mallocSize = sizeof(char) * (f45efac2_max_uint32(precision + 1, f45efac2_getStringSize_uint32(value)) + 2);
	register uint32_t remainder;

	register char *target = f668c4bd_malloc(mallocSize);
	register const char *end = (target + 2);
	target += mallocSize;
	(*--target) = '\0';

	while (value >= 256) {
		remainder = value % 16;
		value >>= 4;

		(*--target) = f6215943_digitHex[remainder];

		remainder = value % 16;
		value >>= 4;
		(*--target) = f6215943_digitHex[remainder];
	}

	if (value < 16) {
		(*--target) = f6215943_digitHex[value];
	} else {
		remainder = value % 16;
		value >>= 4;
		(*--target) = f6215943_digitHex[remainder];
		(*--target) = f6215943_digitHex[value];
	}

	// Add leading zeros according to the precision argument
	while (target != end) {
		*(--target) = '0';
	}

	// Add 0x prefix
	*(--target) = 'x';
	*(--target) = '0';

	return target;
}
