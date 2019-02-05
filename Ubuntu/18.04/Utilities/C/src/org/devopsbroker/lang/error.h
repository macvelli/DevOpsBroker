/*
 * error.h - DevOpsBroker C header file for providing error-handling functionality
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
 * Developed on Ubuntu 16.04.5 LTS running kernel.osrelease = 4.15.0-34
 *
 * echo ORG_DEVOPSBROKER_LANG_ERROR | md5sum | cut -c 25-32
 * -----------------------------------------------------------------------------
 */

#ifndef ORG_DEVOPSBROKER_LANG_ERROR_H
#define ORG_DEVOPSBROKER_LANG_ERROR_H

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <errno.h>

#include "string.h"
#include "../terminal/ansi.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════

#define SYSTEM_ERROR_CODE -1

// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ════════════════════════════════ Structures ════════════════════════════════


// ═════════════════════════════ Global Variables ═════════════════════════════

char* programName;

// ═══════════════════════════ Function Declarations ══════════════════════════

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c7c88e52_ensureUserIsRoot
 * Description: Ensures the executing user is root
 * ----------------------------------------------------------------------------
 */
static inline void c7c88e52_ensureUserIsRoot() {
	// Display error if not running as root
	const char* user = getenv("USER");

	if (f6215943_isNotEqual(user, "root")) {
		fprintf(stderr, ANSI_BOLD "%s: " ANSI_RED "Permission denied (you must be root)\n" ANSI_RESET, programName);
		exit(EXIT_FAILURE);
	}
}

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c7c88e52_invalidOption
 * Description: Prints invalid option error message
 *
 * Parameters:
 *   option     The invalid command-line option
 * ----------------------------------------------------------------------------
 */
void c7c88e52_invalidOption(const char *option);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c7c88e52_invalidValue
 * Description: Prints invalid value error message
 *
 * Parameters:
 *   paramName      The name of the parameter with the invalid value
 *   paramValue     The invalid value of the parameter
 * ----------------------------------------------------------------------------
 */
void c7c88e52_invalidValue(const char *paramName, const char *paramValue);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c7c88e52_missingParam
 * Description: Prints missing parameter error message
 *
 * Parameters:
 *   paramName      The name of the missing parameter
 * ----------------------------------------------------------------------------
 */
void c7c88e52_missingParam(const char *paramName);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c7c88e52_printError_string
 * Description: Prints error message for the given executable
 *
 * Parameters:
 *   errorMessage   The error message to print
 * ----------------------------------------------------------------------------
 */
static inline void c7c88e52_printError_string(const char* errorMessage) {
	fprintf(stderr, ANSI_BOLD "%s: " ANSI_RED "%s\n" ANSI_RESET, programName, errorMessage);
}

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c7c88e52_printLibError
 * Description: Prints error message generated by a C library call
 *
 * Parameters:
 *   errorMessage   The error message to display from the program
 *   errorNumber    The error number generated by the C library call
 * ----------------------------------------------------------------------------
 */
void c7c88e52_printLibError(const char* errorMessage, int errorNumber);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c7c88e52_printUsage
 * Description: Prints usage information message
 *
 * Parameters:
 *   message    The usage message to print
 * ----------------------------------------------------------------------------
 */
void c7c88e52_printUsage(const char* message);

#endif /* ORG_DEVOPSBROKER_LANG_ERROR_H */
