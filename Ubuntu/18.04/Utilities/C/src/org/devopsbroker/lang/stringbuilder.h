/*
 * stringbuilder.h - DevOpsBroker C header file for the StringBuilder struct
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
 * echo ORG_DEVOPSBROKER_LANG_STRINGBUILDER | md5sum | cut -c 25-32
 * -----------------------------------------------------------------------------
 */

#ifndef ORG_DEVOPSBROKER_LANG_STRINGBUILDER_H
#define ORG_DEVOPSBROKER_LANG_STRINGBUILDER_H

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdlib.h>
#include <stdint.h>

#include <assert.h>

#include "memory.h"

#include "../adt/vararg.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════

typedef struct StringBuilder {
	char *buffer;                              // Glibc provides aligned_alloc()
	uint32_t length;
	uint32_t size;
} StringBuilder;

static_assert(sizeof(StringBuilder) == 16, "Check your assumptions");

// ════════════════════════════════ Structures ════════════════════════════════


// ═════════════════════════════ Global Variables ═════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════

// ~~~~~~~~~~~~~~~~~~~~~~~~~ Create/Destroy Functions ~~~~~~~~~~~~~~~~~~~~~~~~~

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c598a24c_createStringBuilder
 * Description: Creates a StringBuilder struct with the default buffer size
 *
 * Returns:     A StringBuilder struct with the default buffer size
 * ----------------------------------------------------------------------------
 */
StringBuilder *c598a24c_createStringBuilder();

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c598a24c_createStringBuilder_uint32
 * Description: Creates a StringBuilder struct with the specifed buffer size
 *
 * Parameters:
 *   bufSize    The buffer size to allocate
 * Returns:     A StringBuilder struct with the specifed buffer size
 * ----------------------------------------------------------------------------
 */
StringBuilder *c598a24c_createStringBuilder_uint32(const uint32_t bufSize);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c598a24c_destroyStringBuilder
 * Description: Frees the memory allocated to the StringBuilder struct pointer
 *              and its char* string attribute
 *
 * Parameters:
 *   strBuilder     A pointer to the StringBuilder instance to destroy
 * ----------------------------------------------------------------------------
 */
void c598a24c_destroyStringBuilder(StringBuilder *strBuilder);

// ~~~~~~~~~~~~~~~~~~~~~~~~~ Init/Clean Up Functions ~~~~~~~~~~~~~~~~~~~~~~~~~~

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c598a24c_cleanUpStringBuilder
 * Description: Frees dynamically allocated memory within the StringBuilder instance
 *
 * Parameters:
 *   strBuilder     A pointer to the StringBuilder instance to clean up
 * ----------------------------------------------------------------------------
 */
void c598a24c_cleanUpStringBuilder(StringBuilder *strBuilder);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c598a24c_initStringBuilder
 * Description: Initializes an existing StringBuilder struct with the default buffer size
 *
 * Parameters:
 *   strBuilder     A pointer to the StringBuilder instance to initalize
 * ----------------------------------------------------------------------------
 */
void c598a24c_initStringBuilder(StringBuilder *strBuilder);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c598a24c_initStringBuilder_uint32
 * Description: Initializes an existing StringBuilder struct with the specifed buffer size
 *
 * Parameters:
 *   strBuilder     A pointer to the StringBuilder instance to initalize
 *   bufSize        The buffer size to allocate
 * ----------------------------------------------------------------------------
 */
void c598a24c_initStringBuilder_uint32(StringBuilder *strBuilder, const uint32_t bufSize);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c598a24c_resetStringBuilder
 * Description: Resets an existing StringBuilder instance to the empty state
 *
 * Parameters:
 *   strBuilder   A pointer to the StringBuilder instance to reset
 * ----------------------------------------------------------------------------
 */
void c598a24c_resetStringBuilder(StringBuilder *strBuilder);

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Utility Functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c598a24c_append_char
 * Description: Appends a char to the StringBuilder instance
 *
 * Parameters:
 *   ch         The char to append
 * ----------------------------------------------------------------------------
 */
void c598a24c_append_char(StringBuilder *strBuilder, const char ch);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c598a24c_append_format
 * Description: Appends a formatted string to the StringBuilder instance
 *
 * Parameters:
 *   format     The string format to append
 *   varargs    The list of variable arguments to the string format
 * ----------------------------------------------------------------------------
 */
//void c598a24c_append_format(StringBuilder *strBuilder, char *format, Vararg *varargs);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c598a24c_append_int
 * Description: Appends an signed int to the StringBuilder instance
 *
 * Parameters:
 *   signedInt      The signed int to append
 * ----------------------------------------------------------------------------
 */
void c598a24c_append_int(StringBuilder *strBuilder, int signedInt);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c598a24c_append_int64
 * Description: Appends an signed long int to the StringBuilder instance
 *
 * Parameters:
 *   signedLong     The signed long int to append
 * ----------------------------------------------------------------------------
 */
void c598a24c_append_int64(StringBuilder *strBuilder, const int64_t signedLong);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c598a24c_append_uint
 * Description: Appends an unsigned int to the StringBuilder instance
 *
 * Parameters:
 *   unsignedInt   The unsigned int to append
 * ----------------------------------------------------------------------------
 */
void c598a24c_append_uint(StringBuilder *strBuilder, uint32_t unsignedInt);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c598a24c_append_uint64
 * Description: Appends an unsigned long int to the StringBuilder instance
 *
 * Parameters:
 *   unsignedLong   The unsigned long int to append
 * ----------------------------------------------------------------------------
 */
void c598a24c_append_uint64(StringBuilder *strBuilder, const uint64_t unsignedLong);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c598a24c_append_string
 * Description: Appends a char* string to the StringBuilder instance
 *
 * Parameters:
 *   source     The char* string to append
 * ----------------------------------------------------------------------------
 */
void c598a24c_append_string(StringBuilder *strBuilder, const char *source);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c598a24c_append_string_varg
 * Description: Appends a variable number of strings to the StringBuilder instance
 *        NOTE: Use NULL as the last parameter to indicate the end of the varargs
 *
 * Parameters:
 *   string      The char* instance to append
 *   ...         Varargs
 * ----------------------------------------------------------------------------
 */
void c598a24c_append_string_varg(StringBuilder *strBuilder, char *string, ...);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c598a24c_append_string_va_list
 * Description: Appends a variable number of strings to the StringBuilder instance
 *        NOTE: Use NULL as the last parameter to indicate the end of the va_list
 *
 * Parameters:
 *   argList     The variable argument list to append
 * ----------------------------------------------------------------------------
 */
void c598a24c_append_string_va_list(StringBuilder *strBuilder, va_list *argList);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c598a24c_append_stringArray
 * Description: Appends a char*[] string array to the StringBuilder instance
 *        NOTE: The char*[] array is expected to be terminated with NULL as the last value
 *
 * Parameters:
 *   array      The char*[] string array to append
 * ----------------------------------------------------------------------------
 */
void c598a24c_append_stringArray(StringBuilder *strBuilder, char *const array[]);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c598a24c_append_string_uint32
 * Description: Appends length number of characters from the char* string to the
 *              StringBuilder instance
 *
 * Parameters:
 *   source     The char* string to append
 *   length     The number of characters to append
 * ----------------------------------------------------------------------------
 */
void c598a24c_append_string_uint32(StringBuilder *strBuilder, const char *source, const uint32_t length);

#endif /* ORG_DEVOPSBROKER_LANG_STRINGBUILDER_H */
