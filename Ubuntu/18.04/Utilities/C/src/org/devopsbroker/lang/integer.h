/*
 * integer.h - DevOpsBroker C header file for providing integer-related functionality
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
 * echo ORG_DEVOPSBROKER_LANG_INTEGER | md5sum | cut -c 25-32
 * -----------------------------------------------------------------------------
 */

#ifndef ORG_DEVOPSBROKER_LANG_INTEGER_H
#define ORG_DEVOPSBROKER_LANG_INTEGER_H

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdint.h>

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ═════════════════════════════ Global Variables ═════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f45efac2_getStringSize_int32
 * Description: Calculates the string size of a signed integer value
 *
 * Parameters:
 *   value      The signed integer value to evaluate
 * Returns:     The size of the string including null termination
 * ----------------------------------------------------------------------------
 */
uint32_t f45efac2_getStringSize_int32(const int32_t value);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f45efac2_getStringSize_uint32
 * Description: Calculates the string size of an unsigned integer value
 *
 * Parameters:
 *   value      The unsigned integer value to evaluate
 * Returns:     The size of the string including null termination
 * ----------------------------------------------------------------------------
 */
uint32_t f45efac2_getStringSize_uint32(const uint32_t value);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f45efac2_max_uint32
 * Description: Returns the maximum unsigned integer value
 *
 * Parameters:
 *   foo        An unsigned integer value to evaluate
 *   bar        An unsigned integer value to evaluate
 * Returns:     The maximum unsigned integer value
 * ----------------------------------------------------------------------------
 */
static inline uint32_t f45efac2_max_uint32(register const uint32_t foo, register const uint32_t bar) {
	return (foo > bar) ? foo : bar;
}

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f45efac2_min_uint32
 * Description: Returns the minimum unsigned integer value
 *
 * Parameters:
 *   foo        An unsigned integer value to evaluate
 *   bar        An unsigned integer value to evaluate
 * Returns:     The minimum unsigned integer value
 * ----------------------------------------------------------------------------
 */
static inline uint32_t f45efac2_min_uint32(register const uint32_t foo, register const uint32_t bar) {
	return (foo < bar) ? foo : bar;
}

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f45efac2_parse_uint32
 * Description: Converts a char* to an unsigned integer
 *
 * Parameters:
 *   source     A char* representation of an unsigned integer
 * Returns:     The unsigned integer value
 * ----------------------------------------------------------------------------
 */
uint32_t f45efac2_parse_uint32(const char *source);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f45efac2_parseHex_uint32
 * Description: Converts a hexadecimal char* to an unsigned integer
 *
 * Parameters:
 *   source     A hexadecimal char* representation of an unsigned integer
 * Returns:     The unsigned integer value
 * ----------------------------------------------------------------------------
 */
uint32_t f45efac2_parseHex_uint32(const char *source);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f45efac2_toString_int32
 * Description: Converts a signed integer to a string
 *
 * Parameters:
 *   value      An signed integer value
 * Returns:     The string representation of the signed integer value
 * ----------------------------------------------------------------------------
 */
char *f45efac2_toString_int32(int32_t value);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f45efac2_toString_uint32
 * Description: Converts an unsigned integer to a string
 *
 * Parameters:
 *   value      An unsigned integer value
 * Returns:     The string representation of the unsigned integer value
 * ----------------------------------------------------------------------------
 */
char *f45efac2_toString_uint32(uint32_t value);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f45efac2_toStringHex_uint32
 * Description: Converts an unsigned integer to a hexadecimal string
 *
 * Parameters:
 *   value      An unsigned integer value
 *   precision  The minimum number of hexadecimal characters required
 * Returns:     The hexadecimal string representation of the unsigned integer value
 * ----------------------------------------------------------------------------
 */
char *f45efac2_toStringHex_uint32(uint32_t value, const uint32_t precision);

#endif /* ORG_DEVOPSBROKER_LANG_INTEGER_H */
