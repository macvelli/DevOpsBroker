/*
 * system.c - Description goes here
 *
 * Copyright (C) 2018 AUTHOR_NAME <email@address.com>
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
#include <sys/types.h>

#include "system.h"
#include "error.h"
#include "stringbuilder.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════

/*
 * Static functions in C restrict their scope to the file where they are declared
 */
static void printErrorMessage(register const size_t size) {
	register StringBuilder *errorMessage = c598a24c_createStringBuilder();

	c598a24c_append_string(errorMessage, "Cannot allocate buffer of size '");
	c598a24c_append_uint64(errorMessage, size);
	c598a24c_append_char(errorMessage, '\'');

	c7c88e52_printError_string_int(errorMessage->buffer, errno);
	c598a24c_destroyStringBuilder(errorMessage);
}

// ═════════════════════════════ Global Variables ═════════════════════════════


// ═════════════════════════ Function Implementations ═════════════════════════

void* c16819a0_malloc_size(const size_t size) {
	void *buffer = malloc(size);

	if (buffer == NULL && size != 0) {
		printErrorMessage(size);
		abort();
	}

	return buffer;
}

void *c16819a0_malloc_size_size(const size_t typeSize, const size_t numBlocks) {
	const size_t size = typeSize * numBlocks;
	void *buffer = malloc(size);

	if (buffer == NULL && size != 0) {
		printErrorMessage(size);
		abort();
	}

	return buffer;
}

void *c16819a0_realloc_void_size(void *ptr, const size_t newSize) {
	void *buffer = realloc(ptr, newSize);

	if (buffer == NULL && newSize != 0) {
		printErrorMessage(newSize);
		abort();
	}

	return buffer;
}

void *c16819a0_realloc_void_size_size(void *ptr, const size_t typeSize, const size_t numBlocks) {
	const size_t newSize = typeSize * numBlocks;
	void *buffer = realloc(ptr, newSize);

	if (buffer == NULL && newSize != 0) {
		printErrorMessage(newSize);
		abort();
	}

	return buffer;
}
