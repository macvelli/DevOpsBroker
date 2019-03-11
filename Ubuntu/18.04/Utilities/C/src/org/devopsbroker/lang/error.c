/*
 * error.c - DevOpsBroker C source file for providing error-handling functionality
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
 *
 * -----------------------------------------------------------------------------
 * Developed on Ubuntu 18.04.1 LTS running kernel.osrelease = 4.15.0-44
 *
 * -----------------------------------------------------------------------------
 */

// ════════════════════════════ Feature Test Macros ═══════════════════════════

#define _DEFAULT_SOURCE

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdio.h>

#include "error.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ═════════════════════════════ Global Variables ═════════════════════════════


// ════════════════════════════ Function Prototypes ═══════════════════════════


// ═════════════════════════ Function Implementations ═════════════════════════

void c7c88e52_cannotPerformAction(const char *actionName, const char *option, const char *noSuchDesc) {
	fprintf(stderr, ANSI_BOLD "%s: " ANSI_RED "Cannot %s '%s': No such %s\n\n" ANSI_RESET, programName, actionName, option, noSuchDesc);
}

void c7c88e52_invalidOption(const char *option) {
	fprintf(stderr, ANSI_BOLD "%s: " ANSI_RED "Invalid option: '%s'\n\n" ANSI_RESET, programName, option);
}

void c7c88e52_invalidValue(const char *paramName, const char *paramValue) {
	fprintf(stderr, ANSI_BOLD "%s: " ANSI_RED "Invalid %s: '%s'\n\n" ANSI_RESET, programName, paramName, paramValue);
}

void c7c88e52_missingParam(const char *paramName) {
	fprintf(stderr, ANSI_BOLD "%s: " ANSI_RED "Missing %s\n\n" ANSI_RESET, programName, paramName);
}

void c7c88e52_printLibError(const char* errorMessage, int errorNumber) {
	const char *errorStr = strerror(errorNumber);
	fprintf(stderr, ANSI_BOLD "%s: " ANSI_RED "%s: %s\n" ANSI_RESET, programName, errorMessage, errorStr);
}

void c7c88e52_printNotice(const char* message) {
	fprintf(stderr, ANSI_BOLD "%s: " ANSI_AQUA "%s\n" ANSI_RESET, programName, message);
}

void c7c88e52_printUsage(const char* message) {
	fprintf(stderr, ANSI_BOLD "Usage: " ANSI_YELLOW "%s\n" ANSI_RESET, message);
}
