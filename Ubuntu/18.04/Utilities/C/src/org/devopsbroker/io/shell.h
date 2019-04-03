/*
 * shell.h - DevOpsBroker C header file for the org.devopsbroker.io.Shell struct
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
 * echo ORG_DEVOPSBROKER_IO_SHELL | md5sum | cut -c 17-24
 * -----------------------------------------------------------------------------
 */

#ifndef ORG_DEVOPSBROKER_IO_SHELL_H
#define ORG_DEVOPSBROKER_IO_SHELL_H

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdio.h>

#include <assert.h>

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════

typedef struct Shell {
	FILE *file;
	int fd;
} Shell;

static_assert(sizeof(Shell) == 16, "Check your assumptions");

// ═════════════════════════════ Global Variables ═════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f6843e7e_openShellForRead
 * Description: Opens the shell for reading using the specified command
 *
 * Parameters:
 *   shell	    A pointer to the Shell instance to initalize
 *   command    The shell command line to execute
 * ----------------------------------------------------------------------------
 */
void f6843e7e_openShellForRead(Shell *shell, const char *command);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f6843e7e_closeShell
 * Description: Closes the shell pipe
 *
 * Parameters:
 *   shell	    A pointer to the Shell instance
 * ----------------------------------------------------------------------------
 */
void f6843e7e_closeShell(Shell *shell);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f6843e7e_readInt
 * Description: Reads an integer from the Shell
 *
 * Parameters:
 *   shell	    A pointer to the Shell instance
 * Returns:     An integer read from the Shell pipe
 * ----------------------------------------------------------------------------
 */
int f6843e7e_readInt(Shell *shell);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f6843e7e_readString
 * Description: Reads a string from the Shell
 *
 * Parameters:
 *   shell      A pointer to the Shell instance
 *   buffer     A pointer to the char *buffer to populate
 * ----------------------------------------------------------------------------
 */
void f6843e7e_readString(Shell *shell, char *buffer);

#endif /* ORG_DEVOPSBROKER_IO_SHELL_H */
