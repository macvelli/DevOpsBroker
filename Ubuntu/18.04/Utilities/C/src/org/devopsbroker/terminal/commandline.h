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

#include <stdbool.h>
#include <stdint.h>

#include <assert.h>

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════

typedef struct CmdLineParam {
	char *usageMsg;
	char **argv;
	int  argc;
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
 *   cmdLineParam   A pointer to the CmdLineParam instance to initalize
 *   argc           The number of command-line arguments
 *   argv           The command-line argument array
 *   usageMsg       The usage message to use when there is an issue with a command-line parameter
 * ----------------------------------------------------------------------------
 */
void d7ad7024_initCmdLineParam(CmdLineParam *cmdLineParam, int argc, char **argv, char *usageMsg);

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Utility Functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    d7ad7024_getFloat
 * Description: Retrieves a float value from the information in CmdLineParam at index i
 *
 * Parameters:
 *   cmdLineParam   A pointer to the CmdLineParam instance
 *   paramName      The name of the parameter
 *   i              The current command-line parameter index
 * Returns:         The float command-line parameter value
 * ----------------------------------------------------------------------------
 */
float d7ad7024_getFloat(CmdLineParam *cmdLineParam, char *paramName, int i);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    d7ad7024_getString
 * Description: Retrieves a string value from the information in CmdLineParam at index i
 *
 * Parameters:
 *   cmdLineParam   A pointer to the CmdLineParam instance
 *   paramName      The name of the parameter
 *   i              The current command-line parameter index
 * Returns:         The string command-line parameter value
 * ----------------------------------------------------------------------------
 */
char *d7ad7024_getString(CmdLineParam *cmdLineParam, char *paramName, int i);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    d7ad7024_getUint32
 * Description: Retrieves an unsigned int value from the information in CmdLineParam at index i
 *
 * Parameters:
 *   cmdLineParam   A pointer to the CmdLineParam instance
 *   paramName      The name of the parameter
 *   argIndex       The current command-line parameter index
 * Returns:         The unsigned int command-line parameter value
 * ----------------------------------------------------------------------------
 */
uint32_t d7ad7024_getUint32(CmdLineParam *cmdLineParam, char *paramName, int argIndex);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    d7ad7024_getUint64
 * Description: Retrieves an unsigned long value from the information in CmdLineParam at index i
 *
 * Parameters:
 *   cmdLineParam   A pointer to the CmdLineParam instance
 *   paramName      The name of the parameter
 *   i              The current command-line parameter index
 * Returns:         The unsigned long command-line parameter value
 * ----------------------------------------------------------------------------
 */
uint64_t d7ad7024_getUint64(CmdLineParam *cmdLineParam, char *paramName, int i);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    d7ad7024_isEqual
 * Description: Determines if the argument at argIndex is equal to the char *value
 *
 * Parameters:
 *   cmdLineParam   A pointer to the CmdLineParam instance
 *   value          The value to compare for equality
 *   argIndex       The current command-line parameter index
 * Returns:         True if the argument equals the value, false otherwise
 * ----------------------------------------------------------------------------
 */
bool d7ad7024_isEqual(CmdLineParam *cmdLineParam, char *value, int argIndex);

#endif /* ORG_DEVOPSBROKER_TERMINAL_COMMANDLINE_H */
