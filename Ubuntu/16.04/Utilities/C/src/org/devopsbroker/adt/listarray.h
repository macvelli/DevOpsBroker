/*
 * listarray.h - DevOpsBroker C header file for providing array-based dynamic list functionality
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
 * echo ORG_DEVOPSBROKER_ADT_LISTARRAY | md5sum | cut -c 25-32
 * -----------------------------------------------------------------------------
 */

#ifndef ORG_DEVOPSBROKER_ADT_LISTARRAY_H
#define ORG_DEVOPSBROKER_ADT_LISTARRAY_H

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdlib.h>
#include <stdint.h>

#include "../lang/system.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════

// Global Constants
#define LISTARRAY_DEFAULT_SIZE 8

// ═════════════════════════════════ Typedefs ═════════════════════════════════

typedef struct ListArray {
	void **values;
	uint32_t length;
	uint32_t size;
} ListArray;

// ═════════════════════════════ Global Variables ═════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    b196167f_add
 * Description: Adds an element to the ListArray instance
 *
 * Parameters:
 *   listArray  The ListArray instance
 *   element    The element to add to the ListArray
 * ----------------------------------------------------------------------------
 */
void b196167f_add(ListArray *listArray, void *element);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    b196167f_createListArray
 * Description: Creates a ListArray struct with the default list size
 *
 * Returns:     A ListArray struct with the default list size
 * ----------------------------------------------------------------------------
 */
static inline ListArray *b196167f_createListArray() {
	ListArray *listArray = c16819a0_malloc_size(sizeof(ListArray));

	listArray->values = c16819a0_malloc_size_size(sizeof(void*), LISTARRAY_DEFAULT_SIZE);
	listArray->size = LISTARRAY_DEFAULT_SIZE;
	listArray->length = 0;

	return listArray;
}

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    b196167f_createListArray_uint32
 * Description: Creates a ListArray struct with the specified list size
 *
 * Parameters:
 *   size       The size of the list to allocate
 * Returns:     A ListArray struct with the specified list size
 * ----------------------------------------------------------------------------
 */
static inline ListArray *b196167f_createListArray_uint32(const uint32_t size) {
	ListArray *listArray = c16819a0_malloc_size(sizeof(ListArray));

	listArray->values = c16819a0_malloc_size_size(sizeof(void*), size);
	listArray->size = size;
	listArray->length = 0;

	return listArray;
}

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    b196167f_destroyListArray
 * Description: Frees the memory allocated to the ListArray struct pointer
 *
 * Parameters:
 *   listArray     A pointer to the ListArray instance to destroy
 * ----------------------------------------------------------------------------
 */
static inline void b196167f_destroyListArray(ListArray *listArray) {
	c16819a0_free(listArray->values);
	c16819a0_free(listArray);
}

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    b196167f_initListArray
 * Description: Initializes a ListArray struct with the default list size
 *
 * Parameters:
 *   listArray      A pointer to the ListArray instance to initalize
 * ----------------------------------------------------------------------------
 */
static inline void b196167f_initListArray(ListArray *listArray) {
	listArray->values = c16819a0_malloc_size_size(sizeof(void*), LISTARRAY_DEFAULT_SIZE);
	listArray->size = LISTARRAY_DEFAULT_SIZE;
	listArray->length = 0;
}

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    b196167f_initListArray_uint32
 * Description: Initializes a ListArray struct with the specified list size
 *
 * Parameters:
 *   listArray  A pointer to the ListArray instance to initalize
 *   size       The size of the list to allocate
 * ----------------------------------------------------------------------------
 */
static inline void b196167f_initListArray_uint32(ListArray *listArray, const uint32_t size) {
	listArray->values = c16819a0_malloc_size_size(sizeof(void*), size);
	listArray->size = size;
	listArray->length = 0;
}

#endif /* ORG_DEVOPSBROKER_ADT_LISTARRAY_H */
