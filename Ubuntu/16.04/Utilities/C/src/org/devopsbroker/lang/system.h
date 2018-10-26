/*
 * system.h - DevOpsBroker C header file for providing system-level functionality
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
 * echo ORG_DEVOPSBROKER_LANG_SYSTEM | md5sum | cut -c 25-32
 * -----------------------------------------------------------------------------
 */

#ifndef ORG_DEVOPSBROKER_LANG_SYSTEM_H
#define ORG_DEVOPSBROKER_LANG_SYSTEM_H

// ═════════════════════════════════ Includes ═════════════════════════════════

#include "stringbuilder.h"

#include "../io/pipe.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ═════════════════════════════ Global Variables ═════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c16819a0_execute
 * Description: Executes the specified file with the specified arguments
 *        NOTE: Terminate the argv[] array with NULL as the last value
 *
 * Parameters:
 *   path       The name of the file to execute
 *   argv       The argument list available to the new program
 * Returns:     A StringBuilder containing the STDOUT output from the program execution
 * ----------------------------------------------------------------------------
 */
StringBuilder *c16819a0_execute(const char *path, char *const argv[]);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c16819a0_execute_pipe
 * Description: Executes the specified file with the specified arguments
 *        NOTE: Terminate the argv[] array with NULL as the last value
 *
 * Parameters:
 *   path       The name of the file to execute
 *   argv       The argument list available to the new program
 *   pipe       The Pipe struct instance to utilize
 * Returns:     The PID of the child process
 * ----------------------------------------------------------------------------
 */
pid_t c16819a0_execute_pipe(const char *path, char *const argv[], Pipe *pipe);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c16819a0_waitForChild
 * Description: Waits for the child process with PID to complete
 *
 * Parameters:
 *   path       The name of the file to execute
 *   argv       The argument list available to the new program
 *   pipe       The Pipe struct instance to utilize
 * ----------------------------------------------------------------------------
 */
void c16819a0_waitForChild(const pid_t child);

#endif /* ORG_DEVOPSBROKER_LANG_SYSTEM_H */
