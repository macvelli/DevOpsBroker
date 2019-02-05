/*
 * float.c - DevOpsBroker C source file for providing float-related functionality
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
 * Developed on Ubuntu 16.04.5 LTS running kernel.osrelease = 4.15.0-36
 *
 * -----------------------------------------------------------------------------
 */

// ════════════════════════════ Feature Test Macros ═══════════════════════════

#define _DEFAULT_SOURCE

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdlib.h>
#include <stdint.h>

#include "float.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════

#define Float_SIGN_MASK 0x80000000
#define Float_EXPONENT_MASK 0x7f800000
#define Float_SIGNIFICAND_MASK 0x7fffff

#define Float_EXPONENT_BIAS 127
#define Float_IMPLICIT_BIT 0x800000

// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════


// ═════════════════════════════ Global Variables ═════════════════════════════


// ═════════════════════════ Function Implementations ═════════════════════════

char *b08dcfcc_toString_float(float value) {
	// TODO
	return NULL;
}

/*
float b08dcfcc_parse_float(register const char *source) {
	register char ch = *source;
	register float value = 0.0f;
	register int digit;

	// Calculate the integer portion of the float
	while (ch) {
		if (ch == '.') {
			ch = *(++source);
			break;
		}

		digit = ch - '0';

		// Bomb out if digit is not a number
		if (digit < 0 || digit > 9) {
			abort();
		}

		value *= 10;
		value += digit;
		ch = *(++source);
	}

	// Calculate the fractional portion of the float
	if (ch) {
		register uint32_t magnitude = 10U;

		do {
			digit = ch - '0';

			// Bomb out if digit is not a number
			if (digit < 0 || digit > 9) {
				abort();
			}

			value += ( ((float) digit) / magnitude );
			magnitude++;
			ch = *(++source);
		} while (ch);
	}

	return value;
}
*/
