/*
 * stringbuilder.h - DevOpsBroker C header file for the StringBuilder struct
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
 * echo ORG_DEVOPSBROKER_LANG_STRINGBUILDER | md5sum | cut -c 25-32
 * -----------------------------------------------------------------------------
 */

#ifndef ORG_DEVOPSBROKER_LANG_STRINGBUILDER_H
#define ORG_DEVOPSBROKER_LANG_STRINGBUILDER_H

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdlib.h>
#include <stdint.h>

#include "system.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════

// Global Constants
#define STRINGBUILDER_DEFAULT_SIZE 64

// ═════════════════════════════════ Typedefs ═════════════════════════════════

typedef struct StringBuilder {
	char *buffer;
	uint32_t length;
	uint32_t size;
} StringBuilder;

// ════════════════════════════════ Structures ════════════════════════════════


// ═════════════════════════════ Global Variables ═════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════

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
 * Function:    c598a24c_append_int64
 * Description: Appends an signed long int to the StringBuilder instance
 *
 * Parameters:
 *   signedLong     The signed long int to append
 * ----------------------------------------------------------------------------
 */
void c598a24c_append_int64(StringBuilder *strBuilder, const int64_t signedLong);

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

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c598a24c_createStringBuilder
 * Description: Creates a StringBuilder struct with the default buffer size
 *
 * Returns:     A StringBuilder struct with the default buffer size
 * ----------------------------------------------------------------------------
 */
static inline StringBuilder *c598a24c_createStringBuilder() {
	StringBuilder *strBuilder = c16819a0_malloc_size(sizeof(StringBuilder));

	strBuilder->buffer = c16819a0_malloc_size_size(sizeof(char), STRINGBUILDER_DEFAULT_SIZE);
	strBuilder->buffer[0] = '\0';
	strBuilder->size = STRINGBUILDER_DEFAULT_SIZE;
	strBuilder->length = 0;

	return strBuilder;
}

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c598a24c_createStringBuilder_uint32
 * Description: Creates a StringBuilder struct with the specifed buffer size
 *
 * Parameters:
 *   bufSize    The buffer size to allocate
 * Returns:     A StringBuilder struct with the specifed buffer size
 * ----------------------------------------------------------------------------
 */
static inline StringBuilder *c598a24c_createStringBuilder_uint32(const uint32_t bufSize) {
	StringBuilder *strBuilder = c16819a0_malloc_size(sizeof(StringBuilder));

	strBuilder->buffer = c16819a0_malloc_size_size(sizeof(char), bufSize);
	strBuilder->buffer[0] = '\0';
	strBuilder->size = bufSize;
	strBuilder->length = 0;

	return strBuilder;
}

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c598a24c_destroyStringBuilder
 * Description: Frees the memory allocated to the StringBuilder struct pointer
 *              and its char* string attribute
 *
 * Parameters:
 *   strBuilder     A pointer to the StringBuilder instance to destroy
 * ----------------------------------------------------------------------------
 */
static inline void c598a24c_destroyStringBuilder(StringBuilder *strBuilder) {
	c16819a0_free(strBuilder->buffer);
	c16819a0_free(strBuilder);
}

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c598a24c_freeStringBuilder
 * Description: Frees only the memory allocated to the StringBuilder struct pointer.
 *              The char* string attribute must be freed at a later time.
 *
 * Parameters:
 *   strBuilder     A pointer to the StringBuilder instance to free
 * ----------------------------------------------------------------------------
 */
static inline void c598a24c_freeStringBuilder(StringBuilder *strBuilder) {
	c16819a0_free(strBuilder);
}

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c598a24c_initStringBuilder
 * Description: Initializes an existing StringBuilder struct with the default buffer size
 *
 * Parameters:
 *   strBuilder     A pointer to the StringBuilder instance to initalize
 * ----------------------------------------------------------------------------
 */
static inline void c598a24c_initStringBuilder(StringBuilder *strBuilder) {
	strBuilder->buffer = c16819a0_malloc_size_size(sizeof(char), STRINGBUILDER_DEFAULT_SIZE);
	strBuilder->buffer[0] = '\0';
	strBuilder->size = STRINGBUILDER_DEFAULT_SIZE;
	strBuilder->length = 0;
}

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c598a24c_initStringBuilder_uint32
 * Description: Initializes an existing StringBuilder struct with the specifed buffer size
 *
 * Parameters:
 *   strBuilder     A pointer to the StringBuilder instance to initalize
 *   bufSize        The buffer size to allocate
 * ----------------------------------------------------------------------------
 */
static inline void c598a24c_initStringBuilder_uint32(StringBuilder *strBuilder, const uint32_t bufSize) {
	strBuilder->buffer = c16819a0_malloc_size_size(sizeof(char), bufSize);
	strBuilder->buffer[0] = '\0';
	strBuilder->size = bufSize;
	strBuilder->length = 0;
}

#endif /* ORG_DEVOPSBROKER_LANG_STRINGBUILDER_H */
