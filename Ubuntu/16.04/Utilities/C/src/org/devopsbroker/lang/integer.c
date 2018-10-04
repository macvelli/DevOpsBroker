/*
 * integer.c - DevOpsBroker C source file for providing integer-related functionality
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
 * -----------------------------------------------------------------------------
 */

// ════════════════════════════ Feature Test Macros ═══════════════════════════

#define _DEFAULT_SOURCE

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdlib.h>
#include <stdint.h>

#include "integer.h"
#include "string.h"
#include "system.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════


// ═════════════════════════════ Global Variables ═════════════════════════════


// ═════════════════════════ Function Implementations ═════════════════════════

uint32_t f45efac2_getStringSize_uint32(const uint32_t value) {
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

		// Bomb out if digit is not a number
		if (digit < 0 || digit > 9) {
			abort();
		}

		value *= 10;
		value += digit;
		ch = *(++source);
	}

	return value;
}

char *f45efac2_toString_uint32(uint32_t value) {
	const size_t mallocSize = sizeof(char) * f45efac2_getStringSize_uint32(value);
	uint32_t remainder;

	char* target = c16819a0_malloc_size(mallocSize);
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
