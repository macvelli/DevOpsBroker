/*
 * vararg.c - C source file for the org.devopsbroker.adt.Vararg struct
 *
 * Copyright (C) 2019 AUTHOR_NAME <email@address.com>
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
 * Developed on Ubuntu 18.04.2 LTS running kernel.osrelease = 4.18.0-16
 *
 * -----------------------------------------------------------------------------
 */

// ════════════════════════════ Feature Test Macros ═══════════════════════════

#define _DEFAULT_SOURCE

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdarg.h>
#include <stdlib.h>

#include "vararg.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ═════════════════════════════ Global Variables ═════════════════════════════


// ════════════════════════════ Function Prototypes ═══════════════════════════


// ═════════════════════════ Function Implementations ═════════════════════════

// ~~~~~~~~~~~~~~~~~~~~~~~~~ Create/Destroy Functions ~~~~~~~~~~~~~~~~~~~~~~~~~

Vararg *f590a9e5_createVararg(uint32_t numArgs, ...) {
	Vararg *vararg = malloc(sizeof(Vararg) + numArgs*sizeof(void*));
	va_list vargList;

	va_start(vargList, numArgs);
	for (int i=0; i < numArgs; i++) {
		vararg->list[i] = va_arg(vargList, void*);
	}
	va_end(vargList);

	return vararg;
}

void f590a9e5_destroyVararg(Vararg *vararg) {
	free(vararg);
}
