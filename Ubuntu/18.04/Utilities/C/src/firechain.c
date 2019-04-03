/*
 * firechain.c - DevOpsBroker utility for modifying iptables/ip6tables firewall chain rules
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
 *
 * -----------------------------------------------------------------------------
 * Developed on Ubuntu 18.04.2 LTS running kernel.osrelease = 4.18.0-16
 *
 * -----------------------------------------------------------------------------
 */

// ════════════════════════════ Feature Test Macros ═══════════════════════════

#define _DEFAULT_SOURCE

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdbool.h>
#include <stdio.h>

#include "org/devopsbroker/adt/listarray.h"
#include "org/devopsbroker/io/shell.h"
#include "org/devopsbroker/lang/error.h"
#include "org/devopsbroker/lang/memory.h"
#include "org/devopsbroker/lang/stringbuilder.h"
#include "org/devopsbroker/terminal/commandline.h"
#include "org/devopsbroker/text/linebuffer.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════

#define END_OF_FILE 0

#define USAGE_MSG "firechain { add | delete } { raw | mangle | nat | filter } CHAIN_NAME { tcp | udp } { source | dest } PORT_NUM ACTION"

// ═════════════════════════════════ Typedefs ═════════════════════════════════

typedef struct FirewallParams {
	char *action;
	char *tableName;
	char *chainName;
	char *protocol;
	char *ruleAction;
	int sourcePort;
	int destPort;
	ListArray ruleList;
} FirewallParams;

static_assert(sizeof(FirewallParams) == 64, "Check your assumptions");

// ═════════════════════════════ Global Variables ═════════════════════════════


// ════════════════════════════ Function Prototypes ═══════════════════════════

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Possible command-line options:
 *
 *   -d -> Download speed
 *   -u -> Upload speed
 *   -s -> Speed
 *   -l -> Acceptable latency
 *   -g -> Generate tuning script
 *   -h -> Help
 * ----------------------------------------------------------------------------
 */
static void processCmdLine(CmdLineParam *cmdLineParm, FirewallParams *firewallParams) {
	register int argc = cmdLineParm->argc;
	register char **argv = cmdLineParm->argv;
	StringBuilder strBuilder;
	bool isSourcePort = false;
	int portNum;

	if (argc == 1) {
		c7c88e52_printUsage(USAGE_MSG);
		exit(EXIT_FAILURE);
	}

	// Perform initializations
	f668c4bd_meminit(firewallParams, sizeof(FirewallParams));

	for (int i = 1; i <= 7; i++) {
		if (i == 1) {
			if (f6215943_isEqual("add", argv[i]) || f6215943_isEqual("delete", argv[i])) {
				firewallParams->action = argv[i];
			} else {
				c7c88e52_invalidValue("action", argv[i]);
				c7c88e52_printUsage(USAGE_MSG);
				exit(EXIT_FAILURE);
			}
		} else if (i == 2) {
			if (i == argc) {
				c7c88e52_missingParam("table name");
				c7c88e52_printUsage(USAGE_MSG);
				exit(EXIT_FAILURE);
			}

			if (f6215943_isEqual("raw", argv[i]) || f6215943_isEqual("mangle", argv[i]) ||
				f6215943_isEqual("nat", argv[i]) || f6215943_isEqual("filter", argv[i])) {
				firewallParams->tableName = argv[i];
			} else {
				c7c88e52_invalidValue("table name", argv[i]);
				c7c88e52_printUsage(USAGE_MSG);
				exit(EXIT_FAILURE);
			}
		} else if (i == 3) {
			if (i == argc) {
				c7c88e52_missingParam("chain name");
				c7c88e52_printUsage(USAGE_MSG);
				exit(EXIT_FAILURE);
			}

			// Initialize the LineBuffer
			String *line = NULL;
			LineBuffer lineBuffer;
			c196bc72_initLineBuffer(&lineBuffer);

			// Initialize the ListArray
			b196167f_initListArray(&firewallParams->ruleList);

			// Build the iptables command-line
			c598a24c_initStringBuilder(&strBuilder);
			c598a24c_append_string(&strBuilder, "/sbin/iptables -t ");
			c598a24c_append_string(&strBuilder, firewallParams->tableName);
			c598a24c_append_string(&strBuilder, " --line-numbers --numeric --list ");
			c598a24c_append_string(&strBuilder, argv[i]);

			Shell iptables;
			char *rule;

			f6843e7e_openShellForRead(&iptables, strBuilder.buffer);

			int numBytes = c196bc72_populateLineBuffer(&lineBuffer, iptables.fd);
			while (numBytes != END_OF_FILE) {
				line = c196bc72_getLine(&lineBuffer);

				while (line != NULL) {
					rule = f6215943_copy(line->value, line->length);
					b196167f_add(&firewallParams->ruleList, rule);

					line = c196bc72_getLine(&lineBuffer);
				}

				numBytes = c196bc72_populateLineBuffer(&lineBuffer, iptables.fd);
			}
			f6843e7e_closeShell(&iptables);

			firewallParams->chainName = argv[i];
		} else if (i == 4) {
			if (i == argc) {
				c7c88e52_missingParam("protocol");
				c7c88e52_printUsage(USAGE_MSG);
				exit(EXIT_FAILURE);
			}

			if (f6215943_isEqual("tcp", argv[i]) || f6215943_isEqual("udp", argv[i])) {
				firewallParams->protocol = argv[i];
			} else {
				c7c88e52_invalidValue("protocol", argv[i]);
				c7c88e52_printUsage(USAGE_MSG);
				exit(EXIT_FAILURE);
			}
		} else if (i == 5) {
			if (i == argc) {
				c7c88e52_missingParam("port type");
				c7c88e52_printUsage(USAGE_MSG);
				exit(EXIT_FAILURE);
			}

			if (f6215943_isEqual("source", argv[i])) {
				isSourcePort = true;
			} else if (f6215943_isEqual("dest", argv[i])) {
				isSourcePort = false;
			} else {
				c7c88e52_invalidValue("port type", argv[i]);
				c7c88e52_printUsage(USAGE_MSG);
				exit(EXIT_FAILURE);
			}
		} else if (i == 6) {
			if (i == argc) {
				c7c88e52_missingParam("port number");
				c7c88e52_printUsage(USAGE_MSG);
				exit(EXIT_FAILURE);
			}

			// Hack until I have time to fix the commanline routines
			portNum = d7ad7024_getUint32(cmdLineParm, "port number", --i);
			i++;

			// Need a range validation method
			if (portNum == 0 || portNum > 65535) {
				c7c88e52_invalidValue("port number", argv[i]);
				c7c88e52_printUsage(USAGE_MSG);
				exit(EXIT_FAILURE);
			}

			if (isSourcePort) {
				firewallParams->sourcePort = portNum;
			} else {
				firewallParams->destPort = portNum;
			}
		} else if (i == 7) {
			if (i == argc) {
				c7c88e52_missingParam("rule action");
				c7c88e52_printUsage(USAGE_MSG);
				exit(EXIT_FAILURE);
			}

			// TODO: Validate the rule action
			firewallParams->ruleAction = argv[i];
		}
	}
}

// ══════════════════════════════════ main() ══════════════════════════════════

int main(int argc, char *argv[]) {

	programName = "firechain";
	c7c88e52_ensureUserIsRoot();

	FirewallParams firewallParams;
	CmdLineParam cmdLineParm;

	d7ad7024_initCmdLineParam(&cmdLineParm, argc, argv, USAGE_MSG);
	processCmdLine(&cmdLineParm, &firewallParams);

	for (int i=0; i < firewallParams.ruleList.length; i++) {
		printf("%s\n", (char *) firewallParams.ruleList.values[i]);
	}

	b196167f_destroyAllElements(&firewallParams.ruleList);

	// Exit with success
	exit(EXIT_SUCCESS);
}

// ═════════════════════════ Function Implementations ═════════════════════════
