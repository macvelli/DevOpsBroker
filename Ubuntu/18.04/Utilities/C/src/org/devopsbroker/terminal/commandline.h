/*
 * commandline.h - DevOpsBroker C header file for providing command line-related functionality
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
 * Developed on Ubuntu 18.04.1 LTS running kernel.osrelease = 4.15.0-44
 *
 * echo ORG_DEVOPSBROKER_TERMINAL_COMMANDLINE | md5sum | cut -c 25-32
 * -----------------------------------------------------------------------------
 */

#ifndef ORG_DEVOPSBROKER_TERMINAL_COMMANDLINE_H
#define ORG_DEVOPSBROKER_TERMINAL_COMMANDLINE_H

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <assert.h>

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════

typedef struct CmdLineParam {
	char *usageMsg;
	char **argv;
	int   argc;
} CmdLineParam;

static_assert(sizeof(CmdLineParam) == 24, "Check your assumptions");

// ═════════════════════════════ Global Variables ═════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════

// ~~~~~~~~~~~~~~~~~~~~~~~~~ Initialization Functions ~~~~~~~~~~~~~~~~~~~~~~~~~

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    d7ad7024_initCmdLineParam
 * Description: Initializes an existing CmdLineParam struct
 *
 * Parameters:
 *   cmdLineParm    A pointer to the CmdLineParam instance to initalize
 *   argc           The number of command-line arguments
 *   argv           The command-line argument array
 *   usageMsg       The usage message to use when there is an issue with a command-line parameter
 * ----------------------------------------------------------------------------
 */
void d7ad7024_initCmdLineParam(CmdLineParam *cmdLineParm, int argc, char **argv, char *usageMsg);

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Utility Functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    d7ad7024_getFloat
 * Description: Retrieves a float value from the information in CmdLineParam at index i
 *
 * Parameters:
 *   cmdLineParm    A pointer to the CmdLineParam instance
 *   paramName      The name of the parameter
 *   i              The current command-line parameter index
 * ----------------------------------------------------------------------------
 */
float d7ad7024_getFloat(CmdLineParam *cmdLineParm, char *paramName, int i);

#endif /* ORG_DEVOPSBROKER_TERMINAL_COMMANDLINE_H */