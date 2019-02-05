/*
 * ethernet.c - DevOpsBroker C source file for the org.devopsbroker.net.Ethernet struct
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
 * Developed on Ubuntu 18.04.1 LTS running kernel.osrelease = 4.15.0-43
 *
 * -----------------------------------------------------------------------------
 */

// ════════════════════════════ Feature Test Macros ═══════════════════════════

#define _DEFAULT_SOURCE

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <sys/ioctl.h>
#include <linux/sockios.h>

#include "ethernet.h"

#include "../lang/error.h"
#include "../lang/memory.h"
#include "../lang/stringbuilder.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════


// ═════════════════════════════ Global Variables ═════════════════════════════


// ═════════════════════════ Function Implementations ═════════════════════════

// ~~~~~~~~~~~~~~~~~~~~~~~~~ Initialization Functions ~~~~~~~~~~~~~~~~~~~~~~~~~

void d3843373_initEthernetRequest(EthernetRequest *request, char *deviceName) {
	f668c4bd_meminit(request, sizeof(EthernetRequest));

	int status = f6215943_copy_to_buffer(deviceName, request->ifr_name, IFNAMSIZ);

	if (status == SYSTEM_ERROR_CODE) {
		StringBuilder errorMessage;
		c598a24c_initStringBuilder(&errorMessage);

		c598a24c_append_string(&errorMessage, "Invalid network device name '");
		c598a24c_append_string(&errorMessage, deviceName);
		c598a24c_append_char(&errorMessage, '\'');

		c7c88e52_printError_string(errorMessage.buffer);
		free(errorMessage.buffer);
		exit(EXIT_FAILURE);
	}
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Utility Functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void d3843373_getEthernetMTU(Ethernet *ethernet, EthernetRequest *request, IPv4Socket *ipv4Socket) {
	int status = ioctl(ipv4Socket->fd, SIOCGIFMTU, request);

	if (status == SYSTEM_ERROR_CODE) {
		StringBuilder errorMessage;
		c598a24c_initStringBuilder(&errorMessage);

		c598a24c_append_string(&errorMessage, "Failure retrieving MTU for ethernet device '");
		c598a24c_append_string(&errorMessage, request->ifr_name);
		c598a24c_append_char(&errorMessage, '\'');

		c7c88e52_printLibError(errorMessage.buffer, errno);
		free(errorMessage.buffer);
		exit(EXIT_FAILURE);
	}

	ethernet->mtu = request->ifr_mtu;
}

void d3843373_getEthernetStatus(Ethernet *ethernet, EthernetRequest *request, IPv4Socket *ipv4Socket) {
	// Setup Ethernet and EthernetRequest for retrieving the status
	ethernet->status.cmd = ETHTOOL_GSET;
	request->ifr_data = (char *) &ethernet->status;

	int status = ioctl(ipv4Socket->fd, SIOCETHTOOL, request);

	if (status == SYSTEM_ERROR_CODE) {
		StringBuilder errorMessage;
		c598a24c_initStringBuilder(&errorMessage);

		c598a24c_append_string(&errorMessage, "Failure retrieving status for ethernet device '");
		c598a24c_append_string(&errorMessage, request->ifr_name);
		c598a24c_append_char(&errorMessage, '\'');

		c7c88e52_printLibError(errorMessage.buffer, errno);
		free(errorMessage.buffer);
		exit(EXIT_FAILURE);
	}

	ethernet->speed = ethtool_cmd_speed(&ethernet->status);
}
