/*
 * logline.c - Description goes here
 *
 * Copyright (C) 2018 AUTHOR_NAME <email@address.com>
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
 * -----------------------------------------------------------------------------
 */

// ════════════════════════════ Feature Test Macros ═══════════════════════════

#define _DEFAULT_SOURCE

// ═════════════════════════════════ Includes ═════════════════════════════════

#include "logline.h"

#include "../lang/integer.h"
#include "../lang/memory.h"
#include "../lang/string.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════

static inline char *terminateField(char *field) {
	register char ch = *field;

	while (ch && ch != ' ') {
		field++;
		ch = *field;
	}

	(*field++) = '\0';

	return field;
}

// ═════════════════════════════ Global Variables ═════════════════════════════


// ═════════════════════════ Function Implementations ═════════════════════════

LogLine *e88eda74_cloneLogLine(LogLine *logLine) {
	register LogLine *clone = f668c4bd_malloc_size(sizeof(LogLine));

	// in
	clone->in = f6215943_copy(logLine->in, logLine->lineLength);

	// out
	clone->out = (clone->in + (logLine->out - logLine->in));

	// macAddress
	if (logLine->macAddress != NULL) {
		clone->macAddress = (clone->in + (logLine->macAddress - logLine->in));
	}

	// sourceIPAddr
	clone->sourceIPAddr = (clone->in + (logLine->sourceIPAddr - logLine->in));

	// destIPAddr
	clone->destIPAddr = (clone->in + (logLine->destIPAddr - logLine->in));

	// protocol
	clone->protocol = (clone->in + (logLine->protocol - logLine->in));

	// lineLength
	clone->lineLength = logLine->lineLength;

	// sourcePort
	clone->sourcePort = logLine->sourcePort;

	// destPort
	clone->destPort = logLine->destPort;

	// count
	clone->count = logLine->count;

	return clone;
}

void e88eda74_initLogLine(LogLine *logLine, String *line) {
	char *position = line->value;

	// in
	logLine->in = f6215943_search("IN=", position);
	position = terminateField(logLine->in);

	// out
	logLine->out = f6215943_search("OUT=", position);
	position = terminateField(logLine->out);

	// macAddress
	logLine->macAddress = f6215943_search("MAC=", position);

	if (logLine->macAddress != NULL) {
		position = terminateField(logLine->macAddress);
	}

	// sourceIPAddr
	logLine->sourceIPAddr = f6215943_search("SRC=", position);
	position = terminateField(logLine->sourceIPAddr);

	// destIPAddr
	logLine->destIPAddr = f6215943_search("DST=", position);
	position = terminateField(logLine->destIPAddr);

	// protocol
	logLine->protocol = f6215943_search("PROTO=", position);
	position = terminateField(logLine->protocol);

	// lineLength
	logLine->lineLength = position - logLine->in;

	if (f6215943_startsWith("ICMP", logLine->protocol)) {
		// ICMP Type
		char *icmpType = f6215943_search("TYPE=", position);
		position = terminateField(icmpType);
		logLine->sourcePort = f45efac2_parse_uint32(icmpType);
		logLine->destPort = 0;
	} else {
		// sourcePort
		char *port = f6215943_search("SPT=", position);
		position = terminateField(port);
		logLine->sourcePort = f45efac2_parse_uint32(port);

		// destPort
		port = f6215943_search("DPT=", position);
		position = terminateField(port);
		logLine->destPort = f45efac2_parse_uint32(port);
	}

	// count
	logLine->count = 1;
}
