/*
 * regex.c - DevOpsBroker C source file for providing regular expression functionality
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
 *
 * -----------------------------------------------------------------------------
 * Developed on Ubuntu 16.04.5 LTS running kernel.osrelease = 4.15.0-34
 *
 * -----------------------------------------------------------------------------
 */

// ════════════════════════════ Feature Test Macros ═══════════════════════════

#define _DEFAULT_SOURCE

// ═════════════════════════════════ Includes ═════════════════════════════════

#include "regex.h"
#include "../lang/error.h"
#include "../lang/stringbuilder.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ════════════════════════════════ Structures ════════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════


// ═════════════════════════════ Global Variables ═════════════════════════════


// ═════════════════════════ Function Implementations ═════════════════════════

void b395ed5f_compileRegExpr(regex_t *patternBuf, const char *regExpr, const int flags) {
	const int errorCode = regcomp(patternBuf, regExpr, flags | REG_NOSUB);

	if (errorCode) {
		size_t errorMsgSize = regerror(errorCode, patternBuf, NULL, 0);

		if (errorMsgSize) {
			char errorMessage[errorMsgSize];
			regerror(errorCode, patternBuf, errorMessage, errorMsgSize);

			c7c88e52_printError_string(errorMessage);
		} else {
			StringBuilder *errorMessage = c598a24c_createStringBuilder();

			c598a24c_append_string(errorMessage, "Could not compile regex '");
			c598a24c_append_string(errorMessage, regExpr);
			c598a24c_append_char(errorMessage, '\'');

			c7c88e52_printError_string(errorMessage->buffer);
			c598a24c_destroyStringBuilder(errorMessage);
		}

		exit(EXIT_FAILURE);
	}
}
