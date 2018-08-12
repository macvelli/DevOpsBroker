/*
 * scriptinfo.c - Description goes here
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
 * -----------------------------------------------------------------------------
 */

// ════════════════════════════ Feature Test Macros ═══════════════════════════


// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>

#include <sys/stat.h>
#include <limits.h>
#include <unistd.h>

#include "ansi.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════

// Global Constants
#define ALL_VARS 0
#define SCRIPT_DIR 1
#define SCRIPT_EXEC 2

// ═════════════════════════════════ Typedefs ═════════════════════════════════

// sys/stat.h
typedef struct stat Stat;

// ════════════════════════════════ Structures ════════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════

void setEnvironmentVar(int envVarTypeCode, char *pathName);

// ═════════════════════════════ Global Variables ═════════════════════════════

char *realPathName = NULL;
char *scriptDir = NULL;
char *scriptExec = NULL;

// ══════════════════════════════════ main() ══════════════════════════════════

int main(int argc, char *argv[]) {
    if (argc == 1) {
	printUsage("scriptinfo SCRIPT_NAME");
	exit(EXIT_FAILURE);
    }

    if (argv[1][0] == '\0') {
	printError("scriptinfo", "SCRIPT_NAME parameter is missing\n\n");
	printUsage("scriptinfo SCRIPT_NAME");
	exit(EXIT_FAILURE);
    }

    char *pathName = argv[1];

    // Stat the script
    Stat fileStat;
    if (lstat(pathName, &fileStat) == SYS_ERROR) {
	char messageLabel[PATH_MAX];

	snprintf(messageLabel, PATH_MAX, "Cannot stat '%s'", pathName);
	printSystemError("scriptinfo", messageLabel, errno);
	exit(EXIT_FAILURE);
    }

    // Handle symbolic links
    if (S_ISLNK(fileStat.st_mode)) {
	ssize_t bufSize;

	if (fileStat.st_size == 0) {
	    bufSize = PATH_MAX;
	} else {
	    bufSize = fileStat.st_size + 1;
	}

	realPathName = malloc(bufSize);
	if (realPathName == NULL) {
	    char messageLabel[64];

	    snprintf(messageLabel, 64, "Cannot allocate buffer of size '%ld'", bufSize);
	    printSystemError("scriptinfo", messageLabel, errno);
	    exit(EXIT_FAILURE);
	}

	if (readlink(pathName, realPathName, bufSize) == SYS_ERROR) {
	    char messageLabel[PATH_MAX];

    	    snprintf(messageLabel, PATH_MAX, "Cannot read link '%s'", pathName);
    	    printSystemError("scriptinfo", messageLabel, errno);
    	    exit(EXIT_FAILURE);
	}

	setEnvironmentVar(SCRIPT_DIR, realPathName);
	setEnvironmentVar(SCRIPT_EXEC, pathName);

    // Handle regular files
    } else if (S_ISREG(fileStat.st_mode)) {

	setEnvironmentVar(ALL_VARS, pathName);

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

void setEnvironmentVar(int envVarTypeCode, char *pathName) {
    char *scriptName = pathName;

    for (char *ptr = pathName; (*ptr) != '\0'; ptr++) {
	if ((*ptr) == '/') {
	    scriptName = ptr;
	}
    }

    if ((*scriptName) == '/') {
	(*scriptName) = '\0';
	scriptName++;
    } else {
	pathName = ".";
    }

    if (envVarTypeCode == ALL_VARS || envVarTypeCode == SCRIPT_DIR) {
	scriptDir = pathName;
    }

    if (envVarTypeCode == ALL_VARS || envVarTypeCode == SCRIPT_EXEC) {
	scriptExec = scriptName;
    }

/*
    if ((envVarTypeCode == ALL_VARS || envVarTypeCode == SCRIPT_DIR) && setenv("SCRIPT_DIR", pathName, 1) == SYS_ERROR) {
	printSystemError("scriptinfo", "Cannot set environment variable 'SCRIPT_DIR'", errno);
	exit(EXIT_FAILURE);
    }

    if ((envVarTypeCode == ALL_VARS || envVarTypeCode == SCRIPT_EXEC) && setenv("SCRIPT_EXEC", scriptName, 1) == SYS_ERROR) {
	printSystemError("scriptinfo", "Cannot set environment variable 'SCRIPT_EXEC'", errno);
	exit(EXIT_FAILURE);
    }
*/
}
