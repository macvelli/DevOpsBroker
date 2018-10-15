/*
 * scriptinfo.c - DevOpsBroker C source file for providing Bash script information
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
 * Developed on Ubuntu 16.04.5 LTS running kernel.osrelease = 4.15.0-29
 *
 * Emits values for the SCRIPT_DIR and SCRIPT_EXEC Bash variables.
 * -----------------------------------------------------------------------------
 */

// ════════════════════════════ Feature Test Macros ═══════════════════════════

#define _DEFAULT_SOURCE

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <errno.h>

#include <sys/stat.h>
#include <limits.h>
#include <unistd.h>

#include "org/devopsbroker/io/file.h"
#include "org/devopsbroker/lang/error.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════

// Global Constants
#define ALL_VARS 0
#define SCRIPT_DIR 1
#define SCRIPT_EXEC 2

// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ════════════════════════════════ Structures ════════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════

static char *setScriptDir(char *pathName);
static void setScriptExec(char *pathName);

// ═════════════════════════════ Global Variables ═════════════════════════════

char *realPathName = NULL;
char *scriptDir = NULL;
char *scriptExec = NULL;

// ══════════════════════════════════ main() ══════════════════════════════════

int main(int argc, char *argv[]) {

	programName = "scriptinfo";

	if (argc == 1) {
		c7c88e52_printUsage("scriptinfo SCRIPT_NAME");
		exit(EXIT_FAILURE);
	}

	if (argv[1][0] == '\0') {
		c7c88e52_printError_string("SCRIPT_NAME parameter is missing\n\n");
		c7c88e52_printUsage("scriptinfo SCRIPT_NAME");
		exit(EXIT_FAILURE);
	}

	char *pathName = argv[1];

	// Stat the script
	FileStatus fileStatus;
	e2f74138_getLinkStatus(pathName, &fileStatus);

	// Handle symbolic links
	if (S_ISLNK(fileStatus.st_mode)) {
		realPathName = e2f74138_readlink(pathName, fileStatus.st_size);

		setScriptDir(realPathName);
		setScriptExec(pathName);

	// Handle regular files
	} else if (S_ISREG(fileStatus.st_mode)) {
		realPathName = e2f74138_realpath(pathName);

		scriptExec = setScriptDir(realPathName);
	}

	// Cannot set environment variables in parent shell from binary executable
	printf("%s %s\n", scriptDir, scriptExec);

	if (realPathName != NULL) {
		free(realPathName);
	}

	// Exit with success
	exit(EXIT_SUCCESS);
}

// ═════════════════════════ Function Implementations ═════════════════════════

static char *setScriptDir(char *pathName) {
	char *scriptName = NULL;
	scriptDir = pathName;

	while (*pathName) {
		if (*pathName == '/') {
			scriptName = pathName;
		}

		pathName++;
	}

	if (scriptName != NULL) {
		(*scriptName) = '\0';
		scriptName++;
	}

	return scriptName;
}

static void setScriptExec(char *pathName) {
	scriptExec = pathName;

	while (*pathName) {
		if (*pathName == '/') {
			scriptExec = pathName;
		}

		pathName++;
	}

	if ((*scriptExec) == '/') {
		scriptExec++;
	}
}
