/*
 * ansi.h - DevOpsBroker C header file for ANSI escape sequences
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
 * Developed on Ubuntu 16.04.4 LTS running kernel.osrelease = 4.13.0-45
 *
 * echo ORG_DEVOPSBROKER_TERMINAL_ANSI | md5sum | cut -c 25-32
 * -----------------------------------------------------------------------------
 */

#ifndef ORG_DEVOPSBROKER_TERMINAL_ANSI_H
#define ORG_DEVOPSBROKER_TERMINAL_ANSI_H

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdbool.h>

// ═══════════════════════════════ Preprocessor ═══════════════════════════════

// Select Graphic Rendition (SGR) parameters
#define ANSI_BOLD "[1m"
#define ANSI_RESET "[0m"

// ANSI Color Codes
#define ANSI_AQUA "[96m"
#define ANSI_BLACK "[30m"
#define ANSI_BLUE "[94m"
#define ANSI_GOLD "[96m"
#define ANSI_GREEN "[92m"
#define ANSI_PURPLE "[95m"
#define ANSI_RED "[91m"
#define ANSI_YELLOW "[93m"
#define ANSI_WHITE "[97m"

#define ANSI_ROMANTIC "[0;33m"

// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ═════════════════════════════ Global Variables ═════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    d99c60f5_printBox
 * Description: Displays a box containing the given message
 *        NOTE: Make sure to set the appropriate locale in your program
 *              (e.g. setlocale(LC_ALL, "C.UTF-8");)
 *
 * Parameters:
 *   message    The message to print within the box
 *   double     True to print a double-line box, false to print a single-line box
 * ----------------------------------------------------------------------------
 */
void d99c60f5_printBox(const char *message, const bool useDoubleLine);

#endif /* ORG_DEVOPSBROKER_TERMINAL_ANSI_H */
