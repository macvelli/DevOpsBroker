/*
 * string.h - DevOpsBroker C header file for string constants and functions
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
 * echo ORG_DEVOPSBROKER_LANG_STRING | md5sum | cut -c 25-32
 * -----------------------------------------------------------------------------
 */

#ifndef ORG_DEVOPSBROKER_LANG_STRING_H
#define ORG_DEVOPSBROKER_LANG_STRING_H

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdbool.h>
#include <stdint.h>

#include <assert.h>

#include <sys/types.h>

#include "memory.h"
#include "../adt/listarray.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════

typedef struct String {
	char *value;
	uint32_t length;
	uint32_t size;
} String;

static_assert(sizeof(String) == 16, "Check your assumptions");

// ═════════════════════════════ Global Variables ═════════════════════════════

/*
 * Can't define constants here because the linker will complain of multiple
 * definitions. Using extern only declares the variable which is then actually
 * defined in string.c <bleh>.
 *
 * C would be a much better language if the preprocessor/compiler/linker didn't
 * suck so bad.
 */
extern const char f6215943_digitOnes[128];

extern const char f6215943_digitTens[128];

extern const char f6215943_digitHex[16];

// ═══════════════════════════ Function Declarations ══════════════════════════

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f6215943_cloneString
 * Description: Clones the String contents contained within the pointer
 *
 * Parameters:
 *   string     The String instance to clone
 * Returns:     A cloned instance of the String
 * ----------------------------------------------------------------------------
 */
String *f6215943_cloneString(String *string);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f6215943_concatenate
 * Description: Concatenates the char* strings into one char* string
 *        NOTE: Use NULL as the last parameter to indicate the end of the varargs
 *
 * Parameters:
 *   string     The char* instance to concatenate
 * Returns:     A concatenate char* instance of all char* string parameters
 * ----------------------------------------------------------------------------
 */
char *f6215943_concatenate(char *string, ...);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f6215943_createString
 * Description: Creates a String struct with the specified length
 *
 * Parameters:
 *   length     The length of the String to create, not including null-termination
 * Returns:     A String instance of the specified length
 * ----------------------------------------------------------------------------
 */
static inline String *f6215943_createString(const size_t length) {
	String *string = malloc(sizeof(String));

	string->value = f668c4bd_malloc_size_size(sizeof(char), length + 1);
	string->length = length;

	return string;
}

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f6215943_copy
 * Description: Copies the char* contents up to the length value
 *
 * Parameters:
 *   source     The char* instance to copy
 *   length     The number of characters to copy
 * Returns:     A copied instance of the char* and of the specified length
 * ----------------------------------------------------------------------------
 */
char *f6215943_copy(char *source, uint32_t length);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f6215943_copy_to_buffer
 * Description: Copies the char* source contents into the buffer
 *
 * Parameters:
 *   source     The char* instance to copy
 *   buffer     The buffer to copy into
 *   bufSize    The size of the buffer
 * Returns:     On success, the actual length copied into the buffer. If the
 *              source string is longer than the buffer size, -1 is returned
 * ----------------------------------------------------------------------------
 */
uint32_t f6215943_copy_to_buffer(const char *source, char *buffer, const uint32_t bufSize);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f6215943_destroyString
 * Description: Frees the memory allocated to the String struct pointer
 *
 * Parameters:
 *   string     A pointer to the String instance to destroy
 * ----------------------------------------------------------------------------
 */
static inline void f6215943_destroyString(String *string) {
	f668c4bd_free(string->value);
	f668c4bd_free(string);
}

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f6215943_getLength
 * Description: Determines the length of the char* contents
 *
 * Parameters:
 *   string     The char* instance to examine
 * Returns:     The length of the char* instance, excluding the null-termination character
 * ----------------------------------------------------------------------------
 */
static inline uint32_t f6215943_getLength(register const char *string) {
	register const char *startPos = string;

	while (*string) {
		string++;
	}

	return (string - startPos);
}

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f6215943_isEqual
 * Description: Compares the two strings for equality
 *
 * Parameters:
 *   foo        The first string instance to check for equality
 *   bar        The second string instance to check for equality
 * Returns:     True if the two string instances are equal, false otherwise
 * ----------------------------------------------------------------------------
 */
bool f6215943_isEqual(char *foo, char *bar);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f6215943_isNotEqual
 * Description: Compares the two strings for inequality
 *
 * Parameters:
 *   foo        The first string instance to check for inequality
 *   bar        The second string instance to check for inequality
 * Returns:     True if the two string instances are not equal, false otherwise
 * ----------------------------------------------------------------------------
 */
bool f6215943_isNotEqual(const char *foo, const char *bar);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f6215943_search
 * Description: Searches the text parameter for the pattern parameter
 *
 * Parameters:
 *   pattern    The pattern to search for in the text
 *   text       The text to search
 * Returns:     A char* pointer to the character immediately after the found pattern,
 *              or NULL if the pattern was not found
 * ----------------------------------------------------------------------------
 */
char *f6215943_search(char *pattern, char *text);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f6215943_splitWithChar
 * Description: Split a string into a substring array
 *
 * Parameters:
 *   string       The string to split
 *   delimiter    The character delimiter to split by
 *   substrList   The list to populate with the char *substring references
 * ----------------------------------------------------------------------------
 */
void f6215943_splitWithChar(char *string, char delimiter, ListArray *substrList);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f6215943_startsWith
 * Description: Determines if text starts with the pattern
 *
 * Parameters:
 *   pattern    The pattern to search for at the beginning of the text
 *   text       The text to search
 * Returns:     A char* pointer to the character immediately after the found pattern,
 *              or NULL if the pattern was not found
 * ----------------------------------------------------------------------------
 */
char *f6215943_startsWith(const char *pattern, char *text);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f6215943_trim
 * Description: Trims whitespace from the beginning and end of the specified string
 *
 * Parameters:
 *   string     The string to trim
 * Returns:     The trimmed string
 * ----------------------------------------------------------------------------
 */
char *f6215943_trim(char *string);

#endif /* ORG_DEVOPSBROKER_LANG_STRING_H */
