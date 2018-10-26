/*
 * regex.h - DevOpsBroker C header file for providing regular expression functionality
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
 * echo ORG_DEVOPSBROKER_TEXT_REGEX | md5sum | cut -c 25-32
 * -----------------------------------------------------------------------------
 */

#ifndef ORG_DEVOPSBROKER_TEXT_REGEX_H
#define ORG_DEVOPSBROKER_TEXT_REGEX_H

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdlib.h>
#include <stdbool.h>
#include <regex.h>
#include <sys/types.h>

// ═══════════════════════════════ Preprocessor ═══════════════════════════════

#define REG_MATCH 0

// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ═════════════════════════════ Global Variables ═════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    b395ed5f_compileRegExpr
 * Description: Compiles a regular expression into a suitable form for regexec() searchess
 *
 * Parameters:
 *   patternBuf     A pointer to a pattern buffer storage area
 *   regExpr        The null-terminated regular expression to compile
 *   flags          Flags used to determine the type of compilation
 * ----------------------------------------------------------------------------
 */
void b395ed5f_compileRegExpr(regex_t *patternBuf, const char *regExpr, const int flags);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    b395ed5f_compileRegExpr
 * Description: Free memory allocated for the regular expression
 *
 * Parameters:
 *   patternBuf     A pointer to a pattern buffer storage area to free
 * ----------------------------------------------------------------------------
 */
static inline void b395ed5f_freeRegExpr(regex_t *patternBuf) {
	regfree(patternBuf);
}

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    b395ed5f_matchRegExpr
 * Description: Matches a null-terminated string against the precompiled pattern buffer
 *
 * Parameters:
 *   patternBuf     A pointer to the precompiled regular expression pattern buffer
 *   string         The null-terminated string to search for the regular expression
 *   flags          Flags used to change the matching behavior of the regular expression
  * Returns:        True if a match was found, false otherwise
 * ----------------------------------------------------------------------------
 */
static inline bool b395ed5f_matchRegExpr(regex_t *patternBuf, const char *string, const int flags) {
	return (regexec(patternBuf, string, 0, NULL, flags) == REG_MATCH) ? true : false;
}

#endif /* ORG_DEVOPSBROKER_TEXT_REGEX_H */
