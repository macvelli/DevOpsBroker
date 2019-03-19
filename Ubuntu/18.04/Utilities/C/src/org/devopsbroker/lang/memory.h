/*
 * memory.h - DevOpsBroker C header file for providing memory management functionality
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
 * echo ORG_DEVOPSBROKER_LANG_MEMORY | md5sum | cut -c 25-32
 * -----------------------------------------------------------------------------
 */

#ifndef ORG_DEVOPSBROKER_LANG_MEMORY_H
#define ORG_DEVOPSBROKER_LANG_MEMORY_H

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <malloc.h>

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ═════════════════════════════ Global Variables ═════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f668c4bd_free
 * Description: Performs the free() operation *only* on pointers with space to free
 *
 * Parameters:
 *   ptr        A pointer to the memory block to free
 * ----------------------------------------------------------------------------
 */
void f668c4bd_free(void *ptr);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f668c4bd_meminit
 * Description: Initializes the block of memory to zeroes
 *
 * Parameters:
 *   ptr        A pointer to the memory block to initialize
 *   size       The size of the memory block to initialize
 * ----------------------------------------------------------------------------
 */
void f668c4bd_meminit(void *ptr, size_t size);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f668c4bd_memcopy
 * Description: Copies numBytes from source to destination
 *
 * Parameters:
 *   source     A pointer to the source memory block
 *   dest       A pointer to the destination memory block
 *   numBytes   The number of bytes to copy from source to destination
 * ----------------------------------------------------------------------------
 */
void f668c4bd_memcopy(void *source, void *dest, size_t numBytes);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f668c4bd_malloc
 * Description: Performs a 16-byte aligned malloc() operation
 *
 * Parameters:
 *   size       The size of the memory block to allocate
 * Returns:     A pointer to the allocated memory block
 * ----------------------------------------------------------------------------
 */
void *f668c4bd_malloc(size_t size);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f668c4bd_malloc_size_size
 * Description: Performs the malloc() operation with error-checking and memory block calculation
 *
 * Parameters:
 *   typeSize       The size of the type being allocated (using sizeof())
 *   numBlocks      The number of blocks of type to allocate
 * Returns:         A pointer to the allocated memory block
 * ----------------------------------------------------------------------------
 */
void *f668c4bd_malloc_size_size(const size_t typeSize, const size_t numBlocks);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f668c4bd_realloc
 * Description: Performs a 16-byte aligned realloc() operation
 *
 * Parameters:
 *   ptr            The pointer to the memory block to reallocate
 *   origSize       The original size of the memory block
 *   newSize        The new size of the memory block
 * Returns:         A pointer to the re-allocated memory block
 * ----------------------------------------------------------------------------
 */
void *f668c4bd_realloc(void *ptr, size_t origSize, size_t newSize);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f668c4bd_realloc_void_size
 * Description: Performs the realloc() operation with error-checking
 *
 * Parameters:
 *   ptr            The pointer to the memory block to reallocate
 *   newSize        The new size of the memory block
 * Returns:         A pointer to the re-allocated memory block
 * ----------------------------------------------------------------------------
 */
void *f668c4bd_realloc_void_size(void *ptr, const size_t newSize);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f668c4bd_realloc_void_size_size
 * Description: Performs the realloc() operation with error-checking and memory block calculation
 *
 * Parameters:
 *   ptr            The pointer to the memory block to reallocate
 *   typeSize       The size of the type being allocated (using sizeof())
 *   numBlocks      The number of blocks of type to allocate
 * Returns:         A pointer to the re-allocated memory block
 * ----------------------------------------------------------------------------
 */
void *f668c4bd_realloc_void_size_size(void *ptr, const size_t typeSize, const size_t numBlocks);

#endif /* ORG_DEVOPSBROKER_LANG_MEMORY_H */
