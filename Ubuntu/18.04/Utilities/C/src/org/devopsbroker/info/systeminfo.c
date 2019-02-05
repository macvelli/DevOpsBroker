/*
 * systeminfo.c - C source file for the org.devopsbroker.info.SystemInfo struct
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
 * Developed on Ubuntu 18.04.1 LTS running kernel.osrelease = 4.15.0-45
 *
 * -----------------------------------------------------------------------------
 */

// ════════════════════════════ Feature Test Macros ═══════════════════════════

#define _DEFAULT_SOURCE

// ═════════════════════════════════ Includes ═════════════════════════════════

#include "systeminfo.h"

#include "../lang/error.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════


// ═════════════════════════════ Global Variables ═════════════════════════════


// ═════════════════════════ Function Implementations ═════════════════════════

void c6059903_initSystemInfo(SystemInfo *systemInfo) {
	int status = sysinfo(systemInfo);

	if (status == SYSTEM_ERROR_CODE) {
		c7c88e52_printLibError("c6059903_initSystemInfo error: ", errno);
		exit(EXIT_FAILURE);
	}
}
