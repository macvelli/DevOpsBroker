/*
 * long.c - DevOpsBroker C source file for signed long and unsigned long values
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
#include <stdbool.h>
#include <stdint.h>

#include "long.h"
#include "memory.h"
#include "string.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ═════════════════════════════ Global Variables ═════════════════════════════


// ═════════════════════════ Function Implementations ═════════════════════════

uint32_t db0acb04_getStringSize_int64(const int64_t value) {
	if (value >= 0) {
		return db0acb04_getStringSize_uint64(value);
	}

	return db0acb04_getStringSize_uint64(-value) + 1;
}

uint32_t db0acb04_getStringSize_uint64(register const uint64_t value) {
	if (value < 10000000000UL) {
		if (value < 100000UL) {
			if (value < 10UL) {
				return 2;
			}
			if (value < 100UL) {
				return 3;
			}
			if (value < 1000UL) {
				return 4;
			}
			if (value < 10000UL) {
				return 5;
			}

			return 6;
		}

		if (value < 1000000UL) {
			return 7;
		}
		if (value < 10000000UL) {
			return 8;
		}
		if (value < 100000000UL) {
			return 9;
		}
		if (value < 1000000000UL) {
			return 10;
		}

		return 11;

	} else if (value < 1000000000000000UL) {
		if (value < 100000000000UL) {
			return 12;
		}
		if (value < 1000000000000UL) {
			return 13;
		}
		if (value < 10000000000000UL) {
			return 14;
		}
		if (value < 100000000000000UL) {
			return 15;
		}

		return 16;
	}

	if (value < 10000000000000000UL) {
		return 17;
	}
	if (value < 100000000000000000UL) {
		return 18;
	}
	if (value < 1000000000000000000UL) {
		return 19;
	}
	if (value < 10000000000000000000UL) {
		return 20;
	}

	return 21;
}

uint64_t db0acb04_parse_uint64(register const char *source) {
	register char ch = *source;
	register uint64_t value = 0UL;
	register int digit;

	while (ch) {
		digit = ch - '0';

		// Bomb out if digit is not a number
		if (digit < 0 || digit > 9) {
			abort();
		}

		value *= 10UL;
		value += digit;
		ch = *(++source);
	}

	return value;
}

uint64_t db0acb04_parse_uint64_ssize(register const char *source, register ssize_t length) {
	register char ch = *source;
	register uint64_t value = 0UL;
	register int digit;
	register int i = 0;

	while (i < length) {
		digit = ch - '0';

		// Bomb out if digit is not a number
		if (digit < 0 || digit > 9) {
			abort();
		}

		value *= 10UL;
		value += digit;
		ch = *(++source);
		i++;
	}

	return value;
}

char* db0acb04_toString_uint64(register uint64_t value) {
	const int mallocSize = sizeof(char) * db0acb04_getStringSize_uint64(value);
	register int remainder;

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

char* db0acb04_toString_int64(register int64_t value) {
	// Return the int64_t minimum value string
	if (value == INT64_MIN) {
		return "-9223372036854775808";
	}

	const int mallocSize = sizeof(char) * db0acb04_getStringSize_int64(value);
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
