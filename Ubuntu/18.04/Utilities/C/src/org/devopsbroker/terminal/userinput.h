/*
 * userinput.h - DevOpsBroker C header file for the org.devopsbroker.terminal.UserInput struct
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
 * Developed on Ubuntu 18.04.2 LTS running kernel.osrelease = 4.18.0-15
 *
 * echo ORG_DEVOPSBROKER_TERMINAL_USERINPUT | md5sum | cut -c 25-32
 * -----------------------------------------------------------------------------
 */

#ifndef ORG_DEVOPSBROKER_TERMINAL_USERINPUT_H
#define ORG_DEVOPSBROKER_TERMINAL_USERINPUT_H

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdio.h>
#include <stdint.h>

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ═════════════════════════════ Global Variables ═════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Utility Functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    a5c0506e_read_uint64
 * Description: Reads an unsigned long value from STDIN
 *
 * Parameters:
 *   line       The char buffer to use for capturing user input
 *   answer     The unsigned long variable to populate with the user input
 * Returns:     The status of the read result (0 = empty string / EOF = invalid value)
 * ----------------------------------------------------------------------------
 */
int a5c0506e_read_uint64(char *line, uint64_t *answer);

#endif /* ORG_DEVOPSBROKER_TERMINAL_USERINPUT_H */
