/*
 * system.h - DevOpsBroker C header file for providing system-level functionality
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
 * echo ORG_DEVOPSBROKER_LANG_SYSTEM | md5sum | cut -c 25-32
 * -----------------------------------------------------------------------------
 */

#ifndef ORG_DEVOPSBROKER_LANG_SYSTEM_H
#define ORG_DEVOPSBROKER_LANG_SYSTEM_H

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <malloc.h>
#include <sys/types.h>

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ═════════════════════════════ Global Variables ═════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c16819a0_free
 * Description: Performs the free() operation *only* on pointers with space to free
 *
 * Parameters:
 *   ptr        A pointer to the memory block to free
 * ----------------------------------------------------------------------------
 */
static inline void c16819a0_free(void *ptr) {
	if (malloc_usable_size(ptr) > 0) {
		free(ptr);
	}
}

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c16819a0_malloc_size
 * Description: Performs the malloc() operation along with error-checking
 *
 * Parameters:
 *   size       The size of the memory block to allocate
 * Returns:     A pointer to the allocated memory block
 * ----------------------------------------------------------------------------
 */
void *c16819a0_malloc_size(const size_t size);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c16819a0_malloc_size_size
 * Description: Performs the malloc() operation with error-checking and memory block calculation
 *
 * Parameters:
 *   typeSize       The size of the type being allocated (using sizeof())
 *   numBlocks      The number of blocks of type to allocate
 * Returns:         A pointer to the allocated memory block
 * ----------------------------------------------------------------------------
 */
void *c16819a0_malloc_size_size(const size_t typeSize, const size_t numBlocks);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c16819a0_realloc_void_size
 * Description: Performs the realloc() operation with error-checking
 *
 * Parameters:
 *   ptr            The pointer to the memory block to reallocate
 *   newSize        The new size of the memory block
 * Returns:         A pointer to the re-allocated memory block
 * ----------------------------------------------------------------------------
 */
void *c16819a0_realloc_void_size(void *ptr, const size_t newSize);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c16819a0_realloc_void_size_size
 * Description: Performs the realloc() operation with error-checking and memory block calculation
 *
 * Parameters:
 *   ptr            The pointer to the memory block to reallocate
 *   typeSize       The size of the type being allocated (using sizeof())
 *   numBlocks      The number of blocks of type to allocate
 * Returns:         A pointer to the re-allocated memory block
 * ----------------------------------------------------------------------------
 */
void *c16819a0_realloc_void_size_size(void *ptr, const size_t typeSize, const size_t numBlocks);

#endif /* ORG_DEVOPSBROKER_LANG_SYSTEM_H */
