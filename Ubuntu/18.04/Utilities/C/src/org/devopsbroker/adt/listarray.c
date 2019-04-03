/*
 * listarray.c - DevOpsBroker C source file for providing array-based dynamic list functionality
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
 *
 * -----------------------------------------------------------------------------
 * Developed on Ubuntu 16.04.5 LTS running kernel.osrelease = 4.15.0-34
 *
 * -----------------------------------------------------------------------------
 */

// ════════════════════════════ Feature Test Macros ═══════════════════════════

#define _DEFAULT_SOURCE

// ═════════════════════════════════ Includes ═════════════════════════════════

#include "listarray.h"

#include "../lang/memory.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════

#define B196167F_DEFAULT_SIZE 8

// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════


// ═════════════════════════════ Global Variables ═════════════════════════════


// ═════════════════════════ Function Implementations ═════════════════════════

// ~~~~~~~~~~~~~~~~~~~~~~~~~ Create/Destroy Functions ~~~~~~~~~~~~~~~~~~~~~~~~~

ListArray *b196167f_createListArray() {
	ListArray *listArray = f668c4bd_malloc(sizeof(ListArray));

	listArray->values = f668c4bd_malloc(sizeof(void*) * B196167F_DEFAULT_SIZE);
	listArray->size = B196167F_DEFAULT_SIZE;
	listArray->length = 0;

	return listArray;
}

ListArray *b196167f_createListArray_uint32(const uint32_t size) {
	ListArray *listArray = f668c4bd_malloc(sizeof(ListArray));

	listArray->values = f668c4bd_malloc(sizeof(void*) * size);
	listArray->size = size;
	listArray->length = 0;

	return listArray;
}

void b196167f_destroyListArray(ListArray *listArray) {
	f668c4bd_free(listArray->values);
	f668c4bd_free(listArray);
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~ Init/Clean Up Functions ~~~~~~~~~~~~~~~~~~~~~~~~~~

void b196167f_initListArray_uint32(ListArray *listArray, const uint32_t size) {
	listArray->values = f668c4bd_malloc(sizeof(void*) * size);
	listArray->size = size;
	listArray->length = 0;
}
