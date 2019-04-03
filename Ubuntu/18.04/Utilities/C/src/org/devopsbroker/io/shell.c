/*
 * shell.c - DevOpsBroker C source file for the org.devopsbroker.io.Shell struct
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
 * -----------------------------------------------------------------------------
 */

// ════════════════════════════ Feature Test Macros ═══════════════════════════

#define _DEFAULT_SOURCE

// ═════════════════════════════════ Includes ═════════════════════════════════

#include "shell.h"

#include "../lang/error.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ═════════════════════════════ Global Variables ═════════════════════════════


// ════════════════════════════ Function Prototypes ═══════════════════════════


// ═════════════════════════ Function Implementations ═════════════════════════

void f6843e7e_openShellForRead(Shell *shell, const char *command) {
	shell->file = popen(command, "r");

	if (shell->file == NULL) {
		printf("Cannot open file\n");
		exit(EXIT_FAILURE);
	}

	// TODO: I can get the file descriptor for an existing stream, but not the existing stream from a file descriptor
	shell->fd = fileno(shell->file);
}

void f6843e7e_closeShell(Shell *shell) {
	pclose(shell->file);
}

int f6843e7e_readInt(Shell *shell) {
	int status, value;

	status = fscanf(shell->file, "%d", &value);

	if (status == EOF) {
		exit(EXIT_FAILURE);
	}

	return value;
}

void f6843e7e_readString(Shell *shell, char *buffer) {
	int status = fscanf(shell->file, "%s", buffer);

	if (status == EOF) {
		exit(EXIT_FAILURE);
	}
}
