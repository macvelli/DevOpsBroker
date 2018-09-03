/*
 * firelog.c - DevOpsBroker utility for parsing and filtering firewall logs
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

#include <regex.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ansi.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════

// Default input and output list array sizes
#define DEFAULT_LIST_SIZE 32

// Default line length
#define DEFAULT_LINE_LENGTH 512

// Empty IN record length
#define EMPTY_IN_LEN 4

// ═════════════════════════════════ Typedefs ═════════════════════════════════

typedef struct LogLine {
  char *buffer;
  char *blockHeader;
  char *in;
  char *out;
  char *macAddress;
  char *sourceIPAddr;
  char *destIPAddr;
  char *protocol;
  char *sourcePort;
  char *destPort;
  int inLen;
  int outLen;
  int count;
} LogLine;

// ═══════════════════════════ Function Declarations ══════════════════════════

void populateLogLine(LogLine *logLine, char *line);
void filterInputLogLine(LogLine logLine, ssize_t length);
void filterOutputLogLine(LogLine logLine, ssize_t length);

// ═════════════════════════════ Global Variables ═════════════════════════════

// File-related variables
FILE *fp = NULL;
char *line = NULL;
size_t lineLen = DEFAULT_LINE_LENGTH;
ssize_t read;

// Regular expression variables
regex_t regex;
int regexValue;

// LogLine input/output arrays
int inputSize = DEFAULT_LIST_SIZE;
int inputLen = 0;

int outputSize = DEFAULT_LIST_SIZE;
int outputLen = 0;

LogLine **inputList;
LogLine **outputList;

// ══════════════════════════════════ main() ══════════════════════════════════

int main(int argc, char *argv[]) {

  if (argc > 1) {
    fp = fopen(argv[1], "r");

    if (fp == NULL) {
      printf(BOLD "firelog: " RED "Cannot open '%s': No such file" RESET "\n", argv[1]);
      exit(EXIT_FAILURE);
    }
  } else {
    fp = stdin;
  }

  // Compile the BLOCK header regular expression
  regexValue = regcomp(&regex, "^\\[.* BLOCK\\] ", REG_EXTENDED);
  if (regexValue) {
    fprintf(stderr, "Could not compile regex\n");
    exit(EXIT_FAILURE);
  }

  line = malloc( sizeof(char) * ( DEFAULT_LINE_LENGTH ) );
  inputList = malloc(DEFAULT_LIST_SIZE * sizeof(LogLine*));
  outputList = malloc(DEFAULT_LIST_SIZE * sizeof(LogLine*));
  LogLine logLine;

  while ((read = getline(&line, &lineLen, fp)) != EOF) {

    // Check for a firewall BLOCK header
    regexValue = regexec(&regex, line, 0, NULL, 0);

    if (!regexValue) {
      populateLogLine(&logLine, line);

      if (logLine.inLen > EMPTY_IN_LEN) {
	filterInputLogLine(logLine, read);
      } else {
	filterOutputLogLine(logLine, read);
      }
    }
  }

  // Close the file (if not stdin)
  if (fp != NULL && fp != stdin) {
    fclose(fp);
  }

  // Free memory allocated for the regular expression
  regfree(&regex);

  // Free the line buffer
  if (line) {
    free(line);
  }

  // Free the inputList
  if (inputList) {
    LogLine *entry = NULL;

    if (inputLen > 0) {
      printf("[1;38;2;127;186;147m");
      printf("┌─────────────────────────────────┐\n");
      printf("│[38;5;231m");
      printf( " firelog INPUT BLOCK Log Entries ");
      printf("[38;2;127;186;147m│\n");
      printf("└─────────────────────────────────┘[0m\n");

      // Loop over the inputList entries and free the LogLine buffers and instances
      for (int i=0; i < inputLen; i++) {
	entry = inputList[i];
	printf("Count: %i %s %s %s %s %s %s %s %s\n", entry->count, entry->in, entry->out, entry->macAddress, entry->sourceIPAddr, entry->destIPAddr, entry->protocol, entry->sourcePort, entry->destPort);
	free(entry->buffer);
	free(entry);
      }
    }

    free(inputList);
    printf("\n");
  }

  // Free the outputList
  if (outputList) {
    LogLine *entry = NULL;

    if (outputLen > 0) {
      printf("[1;38;2;127;186;147m");
      printf("┌──────────────────────────────────┐\n");
      printf("│[38;5;231m");
      printf( " firelog OUTPUT BLOCK Log Entries ");
      printf("[38;2;127;186;147m│\n");
      printf("└──────────────────────────────────┘[0m\n");

      // Loop over the outputList entries and free the LogLine buffers and instances
      for (int i=0; i < outputLen; i++) {
	entry = outputList[i];
	printf("Count: %i %s %s %s %s %s %s %s\n", entry->count, entry->in, entry->out, entry->sourceIPAddr, entry->destIPAddr, entry->protocol, entry->sourcePort, entry->destPort);
	entry = outputList[i];
	free(entry->buffer);
	free(entry);
      }
    }

    free(outputList);
    printf("\n");
  }

  // Exit with success
  exit(EXIT_SUCCESS);
}

// ═════════════════════════ Function Implementations ═════════════════════════

void populateLogLine(LogLine *logLine, char *line) {
  // Set the LogLine attributes
  char *ptr = line;

  // buffer
  logLine->buffer = line;

  // blockHeader
  logLine->blockHeader = ptr;
  while (*(++ptr) != ']');
  *(++ptr) = '\0';

  // in
  logLine->in = ++ptr;
  while (*(++ptr) != ' ' && *(ptr) != '\0');
  *(ptr++) = '\0';
  logLine->inLen = ptr - logLine->in;

  // out
  logLine->out = ptr;
  while (*(++ptr) != ' ' && *(ptr) != '\0');
  *(ptr++) = '\0';
  logLine->outLen = ptr - logLine->out;

  // macAddress
  if (*(ptr) == 'M') {
    logLine->macAddress = ptr;
    while (*(++ptr) != ' ' && *(ptr) != '\0');
    *(ptr++) = '\0';
  } else {
    logLine->macAddress = NULL;
  }

  // sourceIPAddr
  logLine->sourceIPAddr = ptr;
  while (*(++ptr) != ' ' && *(ptr) != '\0');
  *(ptr++) = '\0';

  // destIPAddr
  logLine->destIPAddr = ptr;
  while (*(++ptr) != ' ' && *(ptr) != '\0');
  *(ptr++) = '\0';

  // protocol
  ptr = strstr(ptr, "PROTO=");
  logLine->protocol = ptr;
  while (*(++ptr) != ' ' && *(ptr) != '\0');
  *(ptr++) = '\0';

  // sourcePort
  logLine->sourcePort = ptr;
  while (*(++ptr) != ' ' && *(ptr) != '\0');
  *(ptr++) = '\0';

  // destPort
  logLine->destPort = ptr;
  while (*(++ptr) != ' ' && *(ptr) != '\0');
  *(ptr) = '\0';
}

/*
 * IN=enp4s0 OUT= MAC=ff:ff:ff:ff:ff:ff:aa:bb:cc:dd:ee:ff:11:00 SRC=192.168.1.110 DST=192.168.1.255 PROTO=UDP SPT=59391 DPT=15600
 *
 * If an input rule triggered:
 *   o Use MAC Address filtering
 *   o Ignore changes in SRC
 *   o Ignore changes in SPT and/or DPT
 */
void filterInputLogLine(LogLine logLine, ssize_t length) {
  LogLine *entry = NULL;

  // 1. Loop over the existing inputList entries
  for (int i=0; i < inputLen; i++) {
    entry = inputList[i];

    if (strcmp(entry->in, logLine.in) == 0
	&& strcmp(entry->out, logLine.out) == 0
	&& strcmp(entry->macAddress, logLine.macAddress) == 0
	&& strcmp(entry->destIPAddr, logLine.destIPAddr) == 0
	&& strcmp(entry->protocol, logLine.protocol) == 0) {

      if (strcmp(entry->sourcePort, logLine.sourcePort) == 0
	|| strcmp(entry->destPort, logLine.destPort) == 0) {

	entry->count++;
	return;
      }
    }
  }

  // 2. Manage the size of the inputList
  if (inputLen == inputSize) {
    inputSize <<= 1;

    inputList = realloc(inputList, inputSize);
  }

  // 3. Add LogLine to the inputList
  LogLine *newListItem = malloc(sizeof(LogLine));
  char *lineBuf = malloc(length + 1);
  memcpy(lineBuf, logLine.buffer, length + 1);

  populateLogLine(newListItem, lineBuf);

  newListItem->count = 1;

  inputList[inputLen++] = newListItem;
}

/*
 * IN= OUT=enp4s0 SRC=2001:db8:85a3:8d3:1319:8a2e:370:7348 DST=2607:f8b0:4003:0c0c:0000:0000:0000:007f PROTO=UDP SPT=45771 DPT=19302
 *
 * If an output rule triggered:
 *   o Ignore changes in SPT
 */
void filterOutputLogLine(LogLine logLine, ssize_t length) {
  LogLine *entry = NULL;

  // 1. Loop over the existing outputList entries
  for (int i=0; i < outputLen; i++) {
    entry = outputList[i];

    if (strcmp(entry->in, logLine.in) == 0
	&& strcmp(entry->out, logLine.out) == 0
	&& strcmp(entry->sourceIPAddr, logLine.sourceIPAddr) == 0
	&& strcmp(entry->destIPAddr, logLine.destIPAddr) == 0
	&& strcmp(entry->protocol, logLine.protocol) == 0
	&& strcmp(entry->destPort, logLine.destPort) == 0) {

      entry->count++;
      return;

    }
  }

  // 2. Manage the size of the outputList
  if (outputLen == outputSize) {
    outputSize <<= 1;

    outputList = realloc(outputList, outputSize);
  }

  // 3. Add LogLine to the outputList
  LogLine *newListItem = malloc(sizeof(LogLine));
  char *lineBuf = malloc(length + 1);
  memcpy(lineBuf, logLine.buffer, length + 1);

  populateLogLine(newListItem, lineBuf);

  newListItem->count = 1;

  outputList[outputLen++] = newListItem;
}
