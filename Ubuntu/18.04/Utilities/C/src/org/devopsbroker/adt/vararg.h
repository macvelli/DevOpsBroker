/*
 * vararg.h - DevOpsBroker C header file for the org.devopsbroker.adt.Vararg struct
 *
 * Copyright (C) 2019 Edward Smith <edwardsmith@devopsbroker.org>
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
 * echo ORG_DEVOPSBROKER_ADT_VARARG | md5sum | cut -c 25-32
 * -----------------------------------------------------------------------------
 */

#ifndef ORG_DEVOPSBROKER_ADT_VARARG_H
#define ORG_DEVOPSBROKER_ADT_VARARG_H

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdint.h>

#include <assert.h>

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════

typedef struct Vararg {
	uint32_t size;
	void *list[];
} __attribute__ ((aligned (16))) Vararg;

static_assert(sizeof(Vararg) == 16, "Check your assumptions");

// ═════════════════════════════ Global Variables ═════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════

// ~~~~~~~~~~~~~~~~~~~~~~~~~ Create/Destroy Functions ~~~~~~~~~~~~~~~~~~~~~~~~~

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f590a9e5_createVararg
 * Description: Creates a Vararg struct instance
 *
 * Parameters:
 *   numArgs    The number of variable arguments
 *   ...        The list of variable arguments
 *
 * Returns:     An initialized Vararg struct instance created with malloc()
 * ----------------------------------------------------------------------------
 */
Vararg *f590a9e5_createVararg(uint32_t numArgs, ...);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f590a9e5_destroyVararg
 * Description: Frees the memory allocated to the Vararg struct pointer
 *
 * Parameters:
 *   vararg     A pointer to the Vararg instance to destroy
 * ----------------------------------------------------------------------------
 */
void f590a9e5_destroyVararg(Vararg *vararg);

#endif /* ORG_DEVOPSBROKER_ADT_VARARG_H */
