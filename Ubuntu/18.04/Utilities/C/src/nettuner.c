/*
 * nettuner.c - DevOpsBroker utility for tuning /etc/sysctl.conf and ethtool
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
 * Developed on Ubuntu 18.04.1 LTS running kernel.osrelease = 4.15.0-43
 *
 * TODO: The Realtek RTL8168 does not support:
 *   o Changing Frame Ring Buffers
 *   o Changing flow control
 *   o Changing Interrupt Coalescing
 *
 * Linux FAQ Information
 * ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Routing tables under /proc:
 *   o /proc/net/route
 *   o /proc/net/ipv6_route
 *
 * Useful Linux Command-Line Utilities
 * ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Query system configuration variables:
 *   o getconf -a
 *   o getconf LEVEL1_DCACHE_SIZE
 *   o getconf PAGE_SIZE
 *
 * Query network device for state of protocol offload and other features:
 *   o ethtool -k enp31s0
 *
 * Query ethernet interface ring parameters:
 *   o ethtool -g enp31s0
 *
 * Query ethernet interface interrupt coalesce parameters:
 *   o ethtool -c enp31s0
 *
 * Query ethernet link parameters including txqueuelen:
 *   o ip link show enp31s0
 *
 * TODO: Need to check for virtual network device
 *
 # Exit if default interface is a virtual network device (i.e. bridge, tap, etc)
 if [[ "$($EXEC_READLINK /sys/class/net/$NIC)" == *"/devices/virtual/"* ]]; then
 	printInfo "Default network interface '$NIC' is virtual"
 	printInfo 'Exiting'

 	exit 0
 fi
 * -----------------------------------------------------------------------------
 */

// ════════════════════════════ Feature Test Macros ═══════════════════════════

#define _DEFAULT_SOURCE

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdbool.h>
#include <stdint.h>

#include <assert.h>
#include <unistd.h>

#include "org/devopsbroker/info/systeminfo.h"
#include "org/devopsbroker/lang/error.h"
#include "org/devopsbroker/lang/float.h"
#include "org/devopsbroker/lang/integer.h"
#include "org/devopsbroker/lang/memory.h"
#include "org/devopsbroker/lang/string.h"
#include "org/devopsbroker/net/ethernet.h"
#include "org/devopsbroker/socket/ipv4.h"
#include "org/devopsbroker/terminal/commandline.h"
#include "org/devopsbroker/time/time.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════

#define DEFAULT_LATENCY 0.1f

#define ONE_MEGABIT_BYTES 125000
#define ONE_GIGABYTE 1073741824

#define USAGE_MSG "nettuner " ANSI_GOLD "{ -d dlSpeed | -u ulSpeed | -s speed | -l latency | -g type | -h }" ANSI_YELLOW " IF_NAME"

// ═════════════════════════════════ Typedefs ═════════════════════════════════

typedef struct TuningParams {
	char*    deviceName;
	uint32_t levelOneDCacheSize;
	uint32_t pageSize;
	float    downloadSpeed;
	float    uploadSpeed;
	float    acceptableLatency;
	uint32_t mtu;
	uint32_t ramInGB;
	bool     generateIfaceScript;
	bool     generateNMScript;
} TuningParams;

static_assert(sizeof(TuningParams) == 40, "Check your assumptions");

typedef struct TuningCalcs {
	uint32_t tcp_mss;             // TCP Maximum Segment Size
	uint32_t udp_mss;             // UDP Maximum Segment Size
	uint32_t aligned_tcp_mss;     // TCP MSS aligned to Level 1 Data Cache Size
	uint32_t aligned_udp_mss;     // UDP MSS aligned to Level 1 Data Cache Size
	uint32_t dlFramesPerSecond;   // Maximum download frames per second
	uint32_t ulFramesPerSecond;   // Maximum upload frames per second
} TuningCalcs;

static_assert(sizeof(TuningCalcs) == 24, "Check your assumptions");

typedef struct EthtoolSettings {
	uint32_t txqueuelen;              // Maximum number of packets stored in transmission queue
	uint32_t rxFrameRingBufferSize;   // RX frame ring buffer size
	uint32_t txFrameRingBufferSize;   // TX frame ring buffer size
	uint32_t rxIntCoalescing;         // RX interrupt coalesce setting
	uint32_t txIntCoalescing;         // TX interrupt coalesce setting
} EthtoolSettings;

static_assert(sizeof(EthtoolSettings) == 20, "Check your assumptions");

typedef struct SysctlSettings {
	uint32_t netdev_max_backlog;       // Maximum number of packets stored in receive queue
	uint32_t somaxconn;                // Maximum number of backlogged not-yet-accpeted connections
	uint32_t ip_no_pmtu_disc;          // Disables Path MTU discovery if enabled
	uint32_t tcp_limit_output_bytes;   // Limits the output bytes on the device
	uint32_t tcp_max_orphans;          // Maximum number of unattached TCP sockets for the kernel to maintain
	uint32_t tcp_max_tw_buckets;       // Maximum number of sockets in TIME-WAIT state
	uint32_t tcp_max_syn_backlog;      // Maximum ength of pending connections 'Waiting Acknowledgment'
	uint32_t rmem_default;             // RX memory default for all protocols except TCP
	uint32_t rmem_max;                 // RX memory maximum for all protocols except TCP
	uint32_t wmem_default;             // TX memory default for all protocols except TCP
	uint32_t wmem_max;                 // TX memory maximum for all protocols except TCP
	uint32_t optmem_max;               // Maximum memory allocated to the cmsg list maintained by the kernel that contains "extra" packet information for all protocols
	uint32_t tcp_rmem_min;             // RX memory minimum for TCP
	uint32_t tcp_rmem_default;         // RX memory default for TCP
	uint32_t tcp_rmem_max;             // RX memory maximum for TCP
	uint32_t tcp_wmem_min;             // TX memory minimum for TCP
	uint32_t tcp_wmem_default;         // TX memory default for TCP
	uint32_t tcp_wmem_max;             // TX memory maximum for TCP
	uint32_t udp_rmem_min;             // RX memory minimum for UDP
	uint32_t udp_wmem_min;             // TX memory minimum for UDP
	uint32_t tcp_mem_low;              // Number of memory pages allocated to TCP (low threshold)
	uint32_t tcp_mem_mid;              // Number of memory pages allocated to TCP (medium threshold)
	uint32_t tcp_mem_max;              // Maximum number of memory pages allocated to TCP
	uint32_t udp_mem_low;              // Number of memory pages allocated to UDP (low threshold)
	uint32_t udp_mem_mid;              // Number of memory pages allocated to UDP (medium threshold)
	uint32_t udp_mem_max;              // Maximum number of memory pages allocated to UDP
} SysctlSettings;

static_assert(sizeof(SysctlSettings) == 104, "Check your assumptions");

// ═════════════════════════════ Global Variables ═════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════

static void calcEthtoolSettings(EthtoolSettings *ethtoolSettings, TuningCalcs *tuningCalcs, TuningParams *tuningParams);

static void calcSysctlSettings(SysctlSettings *sysctlSettings, EthtoolSettings *ethtoolSettings, TuningCalcs *tuningCalcs, TuningParams *tuningParams);

static void performTuningCalcs(TuningCalcs *tuningCalcs, TuningParams *tuningParams);

static void setTuningParams(TuningParams *tuningParams, Ethernet *ethDevice);

static void generateIfaceTuningScript(char *deviceName, EthtoolSettings *ethtoolSettings);

static void generateNetworkManagerTuningScript(char *deviceName, EthtoolSettings *ethtoolSettings);

static void printNetworkKernelTuningConfig(SysctlSettings *sysctlSettings);

static void printHelp();

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
static void processCmdLine(CmdLineParam *cmdLineParm, TuningParams *tuningParams) {
	register int argc = cmdLineParm->argc;
	register char **argv = cmdLineParm->argv;

	// Perform initializations
	f668c4bd_meminit(tuningParams, sizeof(TuningParams));

	for (int i = 1; i < argc; i++) {
		if (argv[i][0] == '-') {
			if (argv[i][1] == 'd') {
				tuningParams->downloadSpeed = d7ad7024_getFloat(cmdLineParm, "download speed", i);
			} else if (argv[i][1] == 'u') {
				tuningParams->uploadSpeed = d7ad7024_getFloat(cmdLineParm, "upload speed", i);
			} else if (argv[i][1] == 's') {
				tuningParams->downloadSpeed = d7ad7024_getFloat(cmdLineParm, "upload/download speed", i);
				tuningParams->uploadSpeed = tuningParams->downloadSpeed;
			} else if (argv[i][1] == 'l') {
				tuningParams->acceptableLatency = d7ad7024_getFloat(cmdLineParm, "acceptable latency", i);
			} else if (argv[i][1] == 'g') {
				char *tuningScript = d7ad7024_getString(cmdLineParm, "tuning script type", i);

				if (f6215943_isEqual("iface", tuningScript)) {
					tuningParams->generateIfaceScript = true;
				} else if (f6215943_isEqual("nm", tuningScript)) {
					tuningParams->generateNMScript = true;
				} else {
					c7c88e52_invalidValue("tuning script type", tuningScript);
					c7c88e52_printUsage(USAGE_MSG);
					exit(EXIT_FAILURE);
				}
			} else if (argv[i][1] == 'h') {
				printHelp();
				exit(EXIT_SUCCESS);
			} else {
				c7c88e52_invalidOption(argv[i]);
				c7c88e52_printUsage(USAGE_MSG);
				exit(EXIT_FAILURE);
			}
		} else {
			tuningParams->deviceName = argv[i];
		}
	}

	if (tuningParams->deviceName == NULL) {
		c7c88e52_missingParam("device name");
		c7c88e52_printUsage(USAGE_MSG);
		exit(EXIT_FAILURE);
	}
}

// ══════════════════════════════════ main() ══════════════════════════════════

int main(int argc, char *argv[]) {

	programName = "nettuner";

	TuningParams tuningParams;
	CmdLineParam cmdLineParm;

	d7ad7024_initCmdLineParam(&cmdLineParm, argc, argv, USAGE_MSG);
	processCmdLine(&cmdLineParm, &tuningParams);

	IPv4Socket ipv4Socket;
	Ethernet ethDevice;
	EthernetRequest ethRequest;

	d3843373_initEthernetRequest(&ethRequest, tuningParams.deviceName);

	a34d4619_open(&ipv4Socket, IPV4_SOCKET_UDP);
	d3843373_getEthernetStatus(&ethDevice, &ethRequest, &ipv4Socket);
	d3843373_getEthernetMTU(&ethDevice, &ethRequest, &ipv4Socket);
	a34d4619_close(&ipv4Socket);

	setTuningParams(&tuningParams, &ethDevice);

	TuningCalcs tuningCalcs;
	EthtoolSettings ethtoolSettings;

	performTuningCalcs(&tuningCalcs, &tuningParams);
	calcEthtoolSettings(&ethtoolSettings, &tuningCalcs, &tuningParams);

	if (tuningParams.generateIfaceScript) {
		generateIfaceTuningScript(tuningParams.deviceName, &ethtoolSettings);
	} else if (tuningParams.generateNMScript) {
		generateNetworkManagerTuningScript(tuningParams.deviceName, &ethtoolSettings);
	} else {
		SysctlSettings sysctlSettings;

		calcSysctlSettings(&sysctlSettings, &ethtoolSettings, &tuningCalcs, &tuningParams);
		printNetworkKernelTuningConfig(&sysctlSettings);
	}

	// Exit with success
	exit(EXIT_SUCCESS);
}

// ═════════════════════════ Function Implementations ═════════════════════════

static void calcEthtoolSettings(EthtoolSettings *ethtoolSettings, TuningCalcs *tuningCalcs, TuningParams *tuningParams) {
	ethtoolSettings->rxFrameRingBufferSize = tuningCalcs->dlFramesPerSecond >> 6;
	ethtoolSettings->rxFrameRingBufferSize >>= 5;
	ethtoolSettings->rxFrameRingBufferSize <<= 5;
	ethtoolSettings->rxFrameRingBufferSize = f45efac2_max_uint32(ethtoolSettings->rxFrameRingBufferSize, 32);

	ethtoolSettings->txFrameRingBufferSize = tuningCalcs->ulFramesPerSecond >> 6;
	ethtoolSettings->txFrameRingBufferSize >>= 5;
	ethtoolSettings->txFrameRingBufferSize <<= 5;
	ethtoolSettings->txFrameRingBufferSize = f45efac2_max_uint32(ethtoolSettings->txFrameRingBufferSize, 32);

	ethtoolSettings->rxIntCoalescing = 5000000 / tuningCalcs->dlFramesPerSecond;
	ethtoolSettings->rxIntCoalescing >>= 3;
	ethtoolSettings->rxIntCoalescing <<= 3;
	ethtoolSettings->rxIntCoalescing = f45efac2_max_uint32(ethtoolSettings->rxIntCoalescing, 8);
	ethtoolSettings->rxIntCoalescing = f45efac2_min_uint32(ethtoolSettings->rxIntCoalescing, 2000);

	ethtoolSettings->txIntCoalescing = 200000 / tuningCalcs->ulFramesPerSecond;
	ethtoolSettings->txIntCoalescing >>= 3;
	ethtoolSettings->txIntCoalescing <<= 3;
	ethtoolSettings->txIntCoalescing = f45efac2_max_uint32(ethtoolSettings->txIntCoalescing, 8);
	ethtoolSettings->txIntCoalescing = f45efac2_min_uint32(ethtoolSettings->txIntCoalescing, 2000);

	ethtoolSettings->txqueuelen = (tuningCalcs->ulFramesPerSecond * tuningParams->acceptableLatency);

	if (ethtoolSettings->txqueuelen <= ethtoolSettings->txFrameRingBufferSize) {
		ethtoolSettings->txFrameRingBufferSize = ethtoolSettings->txqueuelen;
		ethtoolSettings->txqueuelen = 32;
	} else {
		ethtoolSettings->txqueuelen >>= 5;
		if (tuningCalcs->ulFramesPerSecond < 1440) {
			if (ethtoolSettings->txqueuelen == 0) {
				ethtoolSettings->txqueuelen++;
			}
			ethtoolSettings->txqueuelen <<= 5;
		} else {
			ethtoolSettings->txqueuelen <<= 5;
			ethtoolSettings->txqueuelen = ethtoolSettings->txqueuelen - ethtoolSettings->txFrameRingBufferSize;
		}
	}
}

static void calcSysctlSettings(SysctlSettings *sysctlSettings, EthtoolSettings *ethtoolSettings, TuningCalcs *tuningCalcs, TuningParams *tuningParams) {
	sysctlSettings->netdev_max_backlog = (tuningCalcs->dlFramesPerSecond * tuningParams->acceptableLatency);

	sysctlSettings->netdev_max_backlog >>= 5;
	if (tuningCalcs->dlFramesPerSecond < 1440) {
		if (sysctlSettings->netdev_max_backlog == 0) {
			sysctlSettings->netdev_max_backlog++;
		}
		sysctlSettings->netdev_max_backlog <<= 5;
	} else {
		sysctlSettings->netdev_max_backlog <<= 5;
		sysctlSettings->netdev_max_backlog = sysctlSettings->netdev_max_backlog - ethtoolSettings->rxFrameRingBufferSize;
	}

	sysctlSettings->somaxconn = (tuningParams->ramInGB << 7);
	sysctlSettings->ip_no_pmtu_disc = (tuningParams->mtu > 1500 ? 0 : 1);
	sysctlSettings->tcp_limit_output_bytes = (ethtoolSettings->txqueuelen * tuningCalcs->tcp_mss);
	sysctlSettings->tcp_max_orphans = (tuningParams->ramInGB << 6);
	sysctlSettings->tcp_max_tw_buckets = (tuningParams->ramInGB << 14);
	sysctlSettings->tcp_max_syn_backlog = (tuningParams->ramInGB << 6);

	uint32_t rx_factor = ((sysctlSettings->netdev_max_backlog * tuningCalcs->udp_mss) >> 4) / tuningCalcs->aligned_udp_mss;

	if (rx_factor == 0 || (rx_factor & 0x01) == 1) {
		rx_factor++;
	}

	sysctlSettings->rmem_default = rx_factor * tuningCalcs->aligned_udp_mss;
	sysctlSettings->rmem_max = sysctlSettings->rmem_default << 1;
	sysctlSettings->udp_rmem_min = sysctlSettings->rmem_default >> 1;

	uint32_t tx_factor = ((ethtoolSettings->txqueuelen * tuningCalcs->udp_mss) >> 4) / tuningCalcs->aligned_udp_mss;

	if (tx_factor == 0 || (tx_factor & 0x01) == 1) {
		tx_factor++;
	}

	sysctlSettings->wmem_default = tx_factor * tuningCalcs->aligned_udp_mss;
	sysctlSettings->wmem_max = sysctlSettings->wmem_default << 1;
	sysctlSettings->udp_wmem_min = sysctlSettings->wmem_default >> 1;

	sysctlSettings->optmem_max = tuningParams->levelOneDCacheSize;

	sysctlSettings->tcp_rmem_default = rx_factor * tuningCalcs->aligned_tcp_mss;
	sysctlSettings->tcp_rmem_min = sysctlSettings->tcp_rmem_default >> 1;
	sysctlSettings->tcp_rmem_max = sysctlSettings->tcp_rmem_default << 1;

	sysctlSettings->tcp_wmem_default = tx_factor * tuningCalcs->aligned_tcp_mss;
	sysctlSettings->tcp_wmem_min = sysctlSettings->tcp_wmem_default >> 1;
	sysctlSettings->tcp_wmem_max = sysctlSettings->tcp_wmem_default << 1;

	sysctlSettings->tcp_mem_low = ((sysctlSettings->tcp_rmem_max + sysctlSettings->tcp_wmem_max + sysctlSettings->optmem_max) / tuningParams->pageSize) << 6;
	sysctlSettings->tcp_mem_mid = sysctlSettings->tcp_mem_low * 1.375f;
	sysctlSettings->tcp_mem_max = sysctlSettings->tcp_mem_low << 1;

	sysctlSettings->udp_mem_low = ((sysctlSettings->rmem_max + sysctlSettings->wmem_max + sysctlSettings->optmem_max) / tuningParams->pageSize) << 6;
	sysctlSettings->udp_mem_mid = sysctlSettings->udp_mem_low * 1.375f;
	sysctlSettings->udp_mem_max = sysctlSettings->udp_mem_low << 1;
}

static void setTuningParams(TuningParams *tuningParams, Ethernet *ethDevice) {
	tuningParams->levelOneDCacheSize = sysconf(_SC_LEVEL1_DCACHE_SIZE);
	tuningParams->pageSize = sysconf(_SC_PAGE_SIZE);

	if (tuningParams->downloadSpeed == 0) {
		tuningParams->downloadSpeed = ethDevice->speed;
	}

	if (tuningParams->uploadSpeed == 0) {
		tuningParams->uploadSpeed = ethDevice->speed;
	}

	if (tuningParams->acceptableLatency == 0.0f) {
		tuningParams->acceptableLatency = DEFAULT_LATENCY;
	}

	tuningParams->mtu = ethDevice->mtu;

	SystemInfo systemInfo;
	c6059903_initSystemInfo(&systemInfo);
	tuningParams->ramInGB = (systemInfo.totalram / ONE_GIGABYTE) + 1;
}

static void performTuningCalcs(TuningCalcs *tuningCalcs, TuningParams *tuningParams) {
	tuningCalcs->tcp_mss = tuningParams->mtu - TCP_OVERHEAD;
	tuningCalcs->udp_mss = tuningParams->mtu - UDP_OVERHEAD;
	tuningCalcs->aligned_tcp_mss = (tuningParams->levelOneDCacheSize / tuningCalcs->tcp_mss) * tuningCalcs->tcp_mss;
	tuningCalcs->aligned_udp_mss = (tuningParams->levelOneDCacheSize / tuningCalcs->udp_mss) * tuningCalcs->udp_mss;
	tuningCalcs->dlFramesPerSecond = (tuningParams->downloadSpeed * ONE_MEGABIT_BYTES) / tuningParams->mtu;
	tuningCalcs->ulFramesPerSecond = (tuningParams->uploadSpeed * ONE_MEGABIT_BYTES) / tuningParams->mtu;
}

static void generateIfaceTuningScript(char * deviceName, EthtoolSettings *ethtoolSettings) {
	Time time;
	a66923ff_initTime(&time, a66923ff_getTime());

	puts(  "#!/bin/bash");
	puts(  "#");
	printf("# tune-%s - DevOpsBroker network interface tuning script\n", deviceName);
	puts(  "#");
	printf("# Copyright (C) %d Edward Smith <edwardsmith@devopsbroker.org>\n", a66923ff_getYear(&time));
	puts(  "#");
	puts(  "# This program is free software: you can redistribute it and/or modify it under");
	puts(  "# the terms of the GNU General Public License as published by the Free Software");
	puts(  "# Foundation, either version 3 of the License, or (at your option) any later");
	puts(  "# version.");
	puts(  "#");
	puts(  "# This program is distributed in the hope that it will be useful, but WITHOUT");
	puts(  "# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS");
	puts(  "# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more");
	puts(  "# details.");
	puts(  "#");
	puts(  "# You should have received a copy of the GNU General Public License along with");
	puts(  "# this program.  If not, see <http://www.gnu.org/licenses/>.");
	puts(  "#");
	puts(  "# -----------------------------------------------------------------------------");
	printf("# Configuration file for optimizing %s:\n", deviceName);
	printf("#   o TX Queue Length = %u\n", ethtoolSettings->txqueuelen);
	printf("#   o RX Frame Ring Buffer Size = %u\n", ethtoolSettings->rxFrameRingBufferSize);
	printf("#   o TX Frame Ring Buffer Size = %u\n", ethtoolSettings->txFrameRingBufferSize);
	printf("#   o RX Interrput Coalescing = %u\n", ethtoolSettings->rxIntCoalescing);
	printf("#   o TX Interrput Coalescing = %u\n", ethtoolSettings->txIntCoalescing);
	puts(  "# -----------------------------------------------------------------------------");
	puts(  "#\n");

	puts(  "################################## Variables ##################################\n");

	puts(  "if [ -z \"$IFACE\" ] && [ -z \"$MODE\" ] && [ -z \"$PHASE\" ]; then");
	printf("	IFACE='%s'\n", deviceName);
	puts(  "	MODE='start'");
	puts(  "	PHASE='post-up'");
	puts(  "fi\n");

	puts(  "################################### Actions ###################################\n");

	printf("/usr/bin/logger -p syslog.notice -i Called /etc/network/if-up.d/tune-%s with interface \"$IFACE\" mode \"$MODE\" and phase \"$PHASE\";\n\n", deviceName);

	printf("if [ \"$IFACE\" == '%s' ] && [ \"$MODE\" == 'start' ] && [ \"$PHASE\" == 'post-up' ]; then\n", deviceName);
	puts(  "	# Optimize TX Queue Length");
	printf("	/sbin/ip link set %s txqueuelen %u\n\n", deviceName, ethtoolSettings->txqueuelen);

	puts(  "	# Optimize RX and TX Frame Ring Buffers");
	printf("	/sbin/ethtool -G %s rx %u tx %u\n\n", deviceName, ethtoolSettings->rxFrameRingBufferSize, ethtoolSettings->txFrameRingBufferSize);

	puts(  "	# Enable Flow Control");
	printf("	/sbin/ethtool -A %s rx on tx on\n\n", deviceName);

	puts(  "	# Enable IPv4/IPv6 RX and TX checksum offload");
	printf("	/sbin/ethtool -K %s tx-checksum-ipv4 on tx-checksum-ipv6 on\n\n", deviceName);

	puts(  "	# Disable TSO/USO/LSO/GSO Processing");
	printf("	/sbin/ethtool -K %s sg off tso off ufo off gso off gro off lro off\n\n", deviceName);

	puts(  "	# Configure RX and TX Interrput Coalescing");
	printf("	/sbin/ethtool -C %s adaptive-rx off rx-usecs %u rx-frames 0\n", deviceName, ethtoolSettings->rxIntCoalescing);
	printf("	/sbin/ethtool -C %s adaptive-tx off tx-usecs %u tx-frames 0\n", deviceName, ethtoolSettings->txIntCoalescing);
	puts(  "fi\n");

	puts(  "exit 0\n");
}

static void generateNetworkManagerTuningScript(char * deviceName, EthtoolSettings *ethtoolSettings) {
	Time time;
	a66923ff_initTime(&time, a66923ff_getTime());

	puts(  "#!/bin/bash");
	puts(  "#");
	printf("# tune-%s - DevOpsBroker network interface tuning script\n", deviceName);
	puts(  "#");
	printf("# Copyright (C) %d Edward Smith <edwardsmith@devopsbroker.org>\n", a66923ff_getYear(&time));
	puts(  "#");
	puts(  "# This program is free software: you can redistribute it and/or modify it under");
	puts(  "# the terms of the GNU General Public License as published by the Free Software");
	puts(  "# Foundation, either version 3 of the License, or (at your option) any later");
	puts(  "# version.");
	puts(  "#");
	puts(  "# This program is distributed in the hope that it will be useful, but WITHOUT");
	puts(  "# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS");
	puts(  "# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more");
	puts(  "# details.");
	puts(  "#");
	puts(  "# You should have received a copy of the GNU General Public License along with");
	puts(  "# this program.  If not, see <http://www.gnu.org/licenses/>.");
	puts(  "#");
	puts(  "# -----------------------------------------------------------------------------");
	printf("# Configuration file for optimizing %s:\n", deviceName);
	printf("#   o TX Queue Length = %u\n", ethtoolSettings->txqueuelen);
	printf("#   o RX Frame Ring Buffer Size = %u\n", ethtoolSettings->rxFrameRingBufferSize);
	printf("#   o TX Frame Ring Buffer Size = %u\n", ethtoolSettings->txFrameRingBufferSize);
	printf("#   o RX Interrput Coalescing = %u\n", ethtoolSettings->rxIntCoalescing);
	printf("#   o TX Interrput Coalescing = %u\n", ethtoolSettings->txIntCoalescing);
	puts(  "# -----------------------------------------------------------------------------");
	puts(  "#\n");

	puts(  "################################## Variables ##################################\n");

	puts(  "## Options");
	puts(  "IFACE=\"$1\"");
	puts(  "ACTION=\"$2\"\n");

	puts(  "if [ -z \"$IFACE\" ] && [ -z \"$ACTION\" ]; then");
	printf("	IFACE='%s'\n", deviceName);
	puts(  "	ACTION='up'");
	puts(  "fi\n");

	puts(  "################################### Actions ###################################\n");

	printf("/usr/bin/logger -p syslog.notice -i Called /etc/NetworkManager/dispatcher.d/tune-%s with interface \"$IFACE\" and action \"$ACTION\";\n\n", deviceName);

	printf("if [ \"$IFACE\" == '%s' ] && [ \"$ACTION\" == 'up' ]; then\n", deviceName);
	puts(  "	# Optimize TX Queue Length");
	printf("	/sbin/ip link set %s txqueuelen %u\n\n", deviceName, ethtoolSettings->txqueuelen);

	puts(  "	# Optimize RX and TX Frame Ring Buffers");
	printf("	/sbin/ethtool -G %s rx %u tx %u\n\n", deviceName, ethtoolSettings->rxFrameRingBufferSize, ethtoolSettings->txFrameRingBufferSize);

	puts(  "	# Enable Flow Control");
	printf("	/sbin/ethtool -A %s rx on tx on\n\n", deviceName);

	puts(  "	# Enable IPv4/IPv6 RX and TX checksum offload");
	printf("	/sbin/ethtool -K %s tx-checksum-ipv4 on tx-checksum-ipv6 on\n\n", deviceName);

	puts(  "	# Disable TSO/USO/LSO/GSO Processing");
	printf("	/sbin/ethtool -K %s sg off tso off ufo off gso off gro off lro off\n\n", deviceName);

	puts(  "	# Configure RX and TX Interrput Coalescing");
	printf("	/sbin/ethtool -C %s adaptive-rx off rx-usecs %u rx-frames 0\n", deviceName, ethtoolSettings->rxIntCoalescing);
	printf("	/sbin/ethtool -C %s adaptive-tx off tx-usecs %u tx-frames 0\n", deviceName, ethtoolSettings->txIntCoalescing);
	puts(  "fi\n");

	puts(  "exit 0\n");
}

void printNetworkKernelTuningConfig(SysctlSettings *sysctlSettings) {
	puts(  "# Set Default Queuing Discipline");
	puts(  "net.core.default_qdisc = pfifo_fast\n");

	puts(  "# Optimize Maximum Number of Queued Incoming Packets");
	printf("net.core.netdev_max_backlog = %u\n\n", sysctlSettings->netdev_max_backlog);

	puts(  "# Optimize Maximum Amount of Option Memory Buffers");
	printf("net.core.optmem_max = %u\n\n", sysctlSettings->optmem_max);

	puts(  "# Optimize Connection Backlog");
	printf("net.core.somaxconn = %u\n\n", sysctlSettings->somaxconn);

	puts(  "# Optimize Non-TCP Receive/Send Socket Buffer Size");
	printf("net.core.rmem_default = %u\n", sysctlSettings->rmem_default);
	printf("net.core.rmem_max = %u\n", sysctlSettings->rmem_max);
	printf("net.core.wmem_default = %u\n", sysctlSettings->wmem_default);
	printf("net.core.wmem_max = %u\n\n", sysctlSettings->wmem_max);

	puts(  "# Accept IPv6 Router Advertisements");
	puts(  "net.ipv6.conf.all.accept_ra = 1");
	puts(  "net.ipv6.conf.all.autoconf = 1");
	puts(  "net.ipv6.conf.default.accept_ra = 1");
	puts(  "net.ipv6.conf.default.autoconf = 1\n");

	puts(  "# Do not accept source routed packets");
	puts(  "net.ipv4.conf.all.accept_source_route = 0");
	puts(  "net.ipv6.conf.all.accept_source_route = 0");
	puts(  "net.ipv4.conf.default.accept_source_route = 0");
	puts(  "net.ipv6.conf.default.accept_source_route = 0\n");

	puts(  "# Do not accept ICMP REDIRECT Messages");
	puts(  "net.ipv4.conf.all.accept_redirects = 0");
	puts(  "net.ipv6.conf.all.accept_redirects = 0");
	puts(  "net.ipv4.conf.default.accept_redirects = 0");
	puts(  "net.ipv6.conf.default.accept_redirects = 0\n");

	puts(  "# Disable logging packets with impossible addresses");
	puts(  "net.ipv4.conf.all.log_martians = 0");
	puts(  "net.ipv4.conf.default.log_martians = 0\n");

	puts(  "# Enable Source Address Verification");
	puts(  "net.ipv4.conf.all.rp_filter = 1");
	puts(  "net.ipv4.conf.default.rp_filter = 1\n");

	puts(  "# Do not send ICMP REDIRECT Messages");
	puts(  "net.ipv4.conf.all.send_redirects = 0");
	puts(  "net.ipv4.conf.default.send_redirects = 0\n");

	puts(  "# Allow ICMP ECHO Requests (Ping)");
	puts(  "net.ipv4.icmp_echo_ignore_all = 0\n");

	puts(  "# Drop BROADCAST/MULTICAST ICMP ECHO Requests");
	puts(  "net.ipv4.icmp_echo_ignore_broadcasts = 1\n");

	puts(  "# Ignore bogus ICMP error responses");
	puts(  "net.ipv4.icmp_ignore_bogus_error_responses = 1\n");

	puts(  "# Disable IP Forwarding");
	puts(  "net.ipv4.ip_forward = 0");
	puts(  "net.ipv4.conf.all.forwarding = 0");
	puts(  "net.ipv6.conf.all.forwarding = 0");
	puts(  "net.ipv4.conf.default.forwarding = 0");
	puts(  "net.ipv6.conf.default.forwarding = 0\n");

	puts(  "# Enable Path MTU Discovery if using Jumbo Frames");
	printf("net.ipv4.ip_no_pmtu_disc = %u\n\n", sysctlSettings->ip_no_pmtu_disc);

	puts(  "# Increase the total port range for both TCP and UDP connections");
	puts(  "net.ipv4.ip_local_port_range = 1500 65001\n");

	puts(  "# Divide socket receive buffer space evenly between TCP window and application");
	puts(  "net.ipv4.tcp_adv_win_scale = 1\n");

	puts(  "# Use TCP-LP Congestion Control Algorithm");
	puts(  "net.ipv4.tcp_congestion_control = lp\n");

	puts(  "# Enable TCP Explicit Congestion Notification (ECN)");
	puts(  "net.ipv4.tcp_ecn = 1\n");

	puts(  "# Enable TCP Fast Open (TFO)");
	puts(  "net.ipv4.tcp_fastopen = 3\n");

	puts(  "# Optimize TCP FIN Timeout");
	puts(  "net.ipv4.tcp_fin_timeout = 20\n");

	puts(  "# Optimize TCP Keepalive (Detect dead connections after 120s)");
	puts(  "net.ipv4.tcp_keepalive_time = 60");
	puts(  "net.ipv4.tcp_keepalive_intvl = 10");
	puts(  "net.ipv4.tcp_keepalive_probes = 6\n");

	puts(  "# Disable F-RTO enhanced recovery algorithm (no wireless network)");
	puts(  "net.ipv4.tcp_frto = 0\n");

	puts(  "# Optimize TCP Limits for Output Bytes on the Device");
	printf("net.ipv4.tcp_limit_output_bytes = %u\n\n", sysctlSettings->tcp_limit_output_bytes);

	puts(  "# Enable TCP Low Latency");
	puts(  "net.ipv4.tcp_low_latency = 1\n");

	puts(  "# Optimize TCP Max Orphans and TCP Max TIME_WAIT Buckets");
	printf("net.ipv4.tcp_max_orphans = %u\n", sysctlSettings->tcp_max_orphans);
	printf("net.ipv4.tcp_max_tw_buckets = %u\n\n", sysctlSettings->tcp_max_tw_buckets);

	puts(  "# Enable TCP Receive Buffer Auto-Tuning");
	puts(  "net.ipv4.tcp_moderate_rcvbuf = 1\n");

	puts(  "# Controls TCP Packetization-Layer Path MTU Discovery");
	puts(  "net.ipv4.tcp_mtu_probing = 1\n");

	puts(  "# Disable TCP Metrics Cache");
	puts(  "net.ipv4.tcp_no_metrics_save = 1\n");

	puts(  "# How may times to retry before killing TCP connection, closed by our side");
	puts(  "net.ipv4.tcp_orphan_retries = 1\n");

	puts(  "# Enable TCP Time-Wait Attack Protection");
	puts(  "net.ipv4.tcp_rfc1337 = 1\n");

	puts(  "# Enable TCP Select Acknowledgments");
	puts(  "net.ipv4.tcp_sack = 1");
	puts(  "net.ipv4.tcp_dsack = 1");
	puts(  "net.ipv4.tcp_fack = 1\n");

	puts(  "# Disable TCP Slow Start After Idle");
	puts(  "net.ipv4.tcp_slow_start_after_idle = 0\n");

	puts(  "# Enable SYN Flood Attack Protection");
	printf("net.ipv4.tcp_max_syn_backlog = %u\n", sysctlSettings->tcp_max_syn_backlog);
	puts(  "net.ipv4.tcp_synack_retries = 2");
	puts(  "net.ipv4.tcp_syncookies = 1\n");

	puts(  "# Optimize TCP SYN Retries");
	puts(  "net.ipv4.tcp_syn_retries = 2\n");

	puts(  "# Disable IPv4 TCP Timestamps");
	puts(  "net.ipv4.tcp_timestamps = 0\n");

	puts(  "# Enable TCP TIME_WAIT Socket Reuse");
	puts(  "net.ipv4.tcp_tw_reuse = 1\n");

	puts(  "# Enable TCP Window Scaling");
	puts(  "net.ipv4.tcp_window_scaling = 1\n");

	puts(  "# Optimize TCP Receive/Send Socket Buffer Size");
	printf("net.ipv4.tcp_rmem = %u %u %u\n", sysctlSettings->tcp_rmem_min, sysctlSettings->tcp_rmem_default, sysctlSettings->tcp_rmem_max);
	printf("net.ipv4.tcp_wmem = %u %u %u\n\n", sysctlSettings->tcp_wmem_min, sysctlSettings->tcp_wmem_default, sysctlSettings->tcp_wmem_max);

	puts(  "# Optimize UDP Socket Buffer Size");
	printf("net.ipv4.udp_rmem_min = %u\n", sysctlSettings->udp_rmem_min);
	printf("net.ipv4.udp_wmem_min = %u\n\n", sysctlSettings->udp_wmem_min);

	puts(  "# Optimize TCP/UDP Total Buffer Space");
	printf("net.ipv4.tcp_mem = %u %u %u\n", sysctlSettings->tcp_mem_low, sysctlSettings->tcp_mem_mid, sysctlSettings->tcp_mem_max);
	printf("net.ipv4.udp_mem = %u %u %u\n\n", sysctlSettings->udp_mem_low, sysctlSettings->udp_mem_mid, sysctlSettings->udp_mem_max);

	puts(  "# Set the IPv4 Route Minimum PMTU");
	puts(  "net.ipv4.route.min_pmtu = 552\n");

	puts(  "# Set the IPv4 Minimum Advertised MSS");
	puts(  "net.ipv4.route.min_adv_mss = 512");
}

static void printHelp() {
	c7c88e52_printUsage(USAGE_MSG);

	puts("\nPerforms network optimization calculations for both sysctl.conf and ethtool");

	puts(ANSI_BOLD "\nDefault Values:" ANSI_RESET);
	puts("  Download speed\tNetwork interface speed");
	puts("  Upload speed\t\tNetwork interface speed");
	puts("  Acceptable latency\t0.1 seconds");

	puts(ANSI_BOLD "\nExamples:" ANSI_RESET);
	puts("  nettuner -d 320.33 -u 23.98 enp31s0");
	puts("  nettuner -s 320.33 -l 0.05 enp31s0");
	puts("  nettuner -g iface enp31s0");

	puts(ANSI_BOLD "\nValid Options:\n");
	puts(ANSI_YELLOW "  -d\t" ANSI_ROMANTIC "Specify the download speed");
	puts(ANSI_BOLD ANSI_YELLOW "  -u\t" ANSI_ROMANTIC "Specify the upload speed");
	puts(ANSI_BOLD ANSI_YELLOW "  -s\t" ANSI_ROMANTIC "Specify both the upload and download speed");
	puts(ANSI_BOLD ANSI_YELLOW "  -l\t" ANSI_ROMANTIC "Specify the acceptable latency");
	puts(ANSI_BOLD ANSI_YELLOW "  -g\t" ANSI_ROMANTIC "Generate tuning script" ANSI_BOLD ANSI_YELLOW " { nm | iface }");
	puts(ANSI_BOLD ANSI_YELLOW "  -h\t" ANSI_ROMANTIC "Print this help message\n");
}
