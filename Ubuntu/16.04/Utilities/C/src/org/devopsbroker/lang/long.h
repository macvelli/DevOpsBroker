/*
 * long.h - DevOpsBroker C header file for signed long and unsigned long values
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
 * echo ORG_DEVOPSBROKER_LANG_LONG | md5sum | cut -c 25-32
 * -----------------------------------------------------------------------------
 */

#ifndef ORG_DEVOPSBROKER_LANG_LONG_H
#define ORG_DEVOPSBROKER_LANG_LONG_H

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdint.h>

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ═════════════════════════════ Global Variables ═════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    db0acb04_getStringSize_int64
 * Description: Calculates the string size of a signed long int value
 *
 * Parameters:
 *   value      The signed long int value to evaluate
 * Returns:     The size of the string including null termination
 * ----------------------------------------------------------------------------
 */
uint32_t db0acb04_getStringSize_int64(const int64_t value);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    db0acb04_getStringSize_uint64
 * Description: Calculates the string size of an unsigned long int value
 *
 * Parameters:
 *   value      The unsigned long int value to evaluate
 * Returns:     The size of the string including null termination
 * ----------------------------------------------------------------------------
 */
uint32_t db0acb04_getStringSize_uint64(const uint64_t value);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    db0acb04_min_uint64
 * Description: Returns the minimum unsigned long int value
 *
 * Parameters:
 *   foo        An unsigned long int value to evaluate
 *   bar        An unsigned long int value to evaluate
 * Returns:     The minimum unsigned long int value
 * ----------------------------------------------------------------------------
 */
static inline uint64_t db0acb04_min_uint64(register const uint64_t foo, register const uint64_t bar) {
	return (foo < bar) ? foo : bar;
}

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    db0acb04_parse_uint64
 * Description: Converts a char* to an unsigned long integer
 *
 * Parameters:
 *   source     A char* representation of an unsigned long integer
 * Returns:     The unsigned long integer value
 * ----------------------------------------------------------------------------
 */
uint64_t db0acb04_parse_uint64(const char *source);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    db0acb04_parse_uint64_ssize
 * Description: Converts a char* to an unsigned long integer
 *
 * Parameters:
 *   source     A char* representation of an unsigned long integer
 *   length     The length of the char* to convert
 * Returns:     The unsigned long integer value
 * ----------------------------------------------------------------------------
 */
uint64_t db0acb04_parse_uint64_ssize(const char *source, ssize_t length);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    db0acb04_toString_uint64
 * Description: Returns a char* representation of the unsigned long int value
 *
 * Parameters:
 *   value      The unsigned long int value
 * Returns:     A char* representation of the unsigned long int value
 * ----------------------------------------------------------------------------
 */
char* db0acb04_toString_uint64(uint64_t value);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    db0acb04_toString_int64
 * Description: Returns a char* representation of the signed long int value
 *
 * Parameters:
 *   value      The signed long int value
 * Returns:     A char* representation of the signed long int value
 * ----------------------------------------------------------------------------
 */
char* db0acb04_toString_int64(int64_t value);

#endif /* ORG_DEVOPSBROKER_LANG_LONG_H */
