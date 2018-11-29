/*
 * ansi.c - DevOpsBroker C source file for providing ANSI escape sequence functionality
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

#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>

#include <wchar.h>

#include "ansi.h"
#include "../lang/string.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ═════════════════════════════ Global Variables ═════════════════════════════

const wchar_t singleLineList[] = { L'┌', L'─', L'┐', L'│', L'└', L'┘' };
const wchar_t doubleLineList[] = { L'╔', L'═', L'╗', L'║', L'╚', L'╝' };

// ═══════════════════════════ Function Declarations ══════════════════════════


// ═════════════════════════ Function Implementations ═════════════════════════

void d99c60f5_printBox(const char *message, const bool useDoubleLine) {
	register const wchar_t *lineList = (useDoubleLine) ? doubleLineList : singleLineList;
	register const uint32_t msgLength = f6215943_getLength(message) + 2;
	wchar_t boxLine[msgLength + 1];

	register uint32_t i = 0;
	for (; i < msgLength; i++) {
		boxLine[i] = lineList[1];
	}
	boxLine[i] = L'\0';

	printf(ANSI_BOLD ANSI_PURPLE "\n");
	printf("%lc%ls%lc\n", lineList[0], boxLine, lineList[2]);
	printf("%lc " ANSI_WHITE "%s" ANSI_PURPLE " %lc\n", lineList[3], message, lineList[3]);
	printf("%lc%ls%lc\n" ANSI_RESET "\n", lineList[4], boxLine, lineList[5]);
}
