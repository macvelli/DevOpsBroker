/*
 * between.c - DevOpsBroker utility for extracting the string in between the
 *	       START and END parameters. Can either read from stdin or a file
 *	       specified on the command-line.
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
 * Developed on Ubuntu 16.04.4 LTS running kernel.osrelease = 4.13.0-43
 *
 * -----------------------------------------------------------------------------
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ansi.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════

// Default buffer size
#define DEFAULT_BUFFER_SIZE 1024

// Default line length
#define DEFAULT_LINE_LENGTH 512

// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ════════════════════════════════ Structures ════════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════

void append(char *line, ssize_t len);

// ═════════════════════════════ Global Variables ═════════════════════════════

// Buffer string variables
int bufSize = DEFAULT_BUFFER_SIZE;
int bufLen = 0;

char *buffer = NULL;
char *startSubstr = NULL;
char *endSubstr = NULL;

// ══════════════════════════════════ main() ══════════════════════════════════

int main(int argc, char *argv[]) {
  if (argc == 1) {
    printUsage("between START END [input-file]");
    exit(EXIT_FAILURE);
  }

  if (argv[1][0] == '\0') {
    printError("between", "START parameter is missing\n\n");
    printUsage("between START END [input-file]");
    exit(EXIT_FAILURE);
  }

  if (argc == 2 || argv[2][0] == '\0') {
    printError("between", "END parameter is missing\n\n");
    printf(BOLD "Usage: " YELLOW "between %s END [input-file]" RESET "\n", argv[1]);
    exit(EXIT_FAILURE);
  }

  // Start parameter
  const char *start = argv[1];
  const size_t startLen = strlen(start);

  // End parameter
  const char *end = argv[2];

  // File-related variables
  FILE *fp = NULL;
  char *line = NULL;
  size_t lineLen = DEFAULT_LINE_LENGTH;
  ssize_t read;

  if (argc > 3) {
    fp = fopen(argv[3], "r");

    if (fp == NULL) {
      printf(BOLD "between: " RED "Cannot open '%s': No such file" RESET "\n", argv[3]);
      exit(EXIT_FAILURE);
    }
  } else {
    fp = stdin;
  }

  line = malloc( sizeof(char) * ( DEFAULT_LINE_LENGTH ) );
  buffer = malloc( sizeof(char) * ( DEFAULT_BUFFER_SIZE ) );

  while ((read = getline(&line, &lineLen, fp)) != -1) {

    // We have not yet found the start of the substring
    if (startSubstr == NULL) {
      startSubstr = strstr(line, start);

      if (startSubstr != NULL) {
	startSubstr += startLen;

	endSubstr = strstr(startSubstr, end);

	// Print substring and break from while loop for exit
	if (endSubstr != NULL) {
	  if (startSubstr != endSubstr) {
	    *(endSubstr) = '\0';
	    printf("%s\n", startSubstr);
	  }

	  break;
	}

	// Append start of substring
	append(startSubstr, read - (startSubstr - line));
      }

    // We now need to find the end of the substring
    } else {
      endSubstr = strstr(line, end);

      if (endSubstr == NULL) {
	// Append entire line
	append(line, read);

      } else {
	if (endSubstr != line) {
	  // Append end of substring
	  *(endSubstr) = '\0';
	  append(line, read - (endSubstr - line));
	}

	// Remove trailing newline and carriage return
	char *ptr = buffer + bufLen - 1;
	while (*(ptr) == '\n' || *(ptr) == '\r') {
	  *(ptr--) = '\0';
	}

	// Print substring and break from while loop for exit
	printf("%s\n", buffer);

	break;
      }
    }
  }

  // Close the file (if not stdin)
  if (fp != NULL && fp != stdin) {
    fclose(fp);
  }

  // Free the line buffer
  if (line) {
    free(line);
  }

  // Free the string buffer
  if (buffer) {
    free(buffer);
  }

  // Exit with success
  exit(EXIT_SUCCESS);
}

// ═════════════════════════ Function Implementations ═════════════════════════

void append(char *line, ssize_t len) {
  const ssize_t newLen = bufLen + len;

  if (newLen >= bufSize) {
    bufSize = newLen << 1;

    buffer = realloc(buffer, bufSize);
  }

  char *ptr = buffer + bufLen;

  while ( (len--) > 0 ) {
    *(ptr++) = *(line++);
  }

  bufLen = newLen;
  ptr = '\0';
}
