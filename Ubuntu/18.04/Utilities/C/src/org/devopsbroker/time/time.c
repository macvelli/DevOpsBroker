/*
 * time.c - C source file for the org.devopsbroker.time.Time struct
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
 * Developed on Ubuntu 18.04.1 LTS running kernel.osrelease = 4.15.0-44
 *
 * -----------------------------------------------------------------------------
 */

// ════════════════════════════ Feature Test Macros ═══════════════════════════

#define _DEFAULT_SOURCE

// ═════════════════════════════════ Includes ═════════════════════════════════

#include "time.h"

#include "../lang/error.h"
#include "../lang/stringbuilder.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════


// ═════════════════════════════ Global Variables ═════════════════════════════


// ═════════════════════════ Function Implementations ═════════════════════════

void a66923ff_initTime(Time *time, time_t seconds) {
	void *retVal = gmtime_r(&seconds, time);

	if (retVal == NULL) {
		StringBuilder errorMessage;
		c598a24c_initStringBuilder_uint32(&errorMessage, 128);

		c598a24c_append_string(&errorMessage, "Error converting time_t '");
		c598a24c_append_int32(&errorMessage, seconds);
		c598a24c_append_char(&errorMessage, '\'');

		c7c88e52_printLibError(errorMessage.buffer, errno);
		free(errorMessage.buffer);
		exit(EXIT_FAILURE);
	}
}

time_t a66923ff_getTime() {
	return time(NULL);
}

int a66923ff_getYear(Time *time) {
	return time->tm_year + 1900;
}
