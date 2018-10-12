/*
 * schedtuner.c - DevOpsBroker utility for tuning the Completely Fair Scheduler
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
 * Developed on Ubuntu 16.04.5 LTS running kernel.osrelease = 4.15.0-34
 *
 * As the Completely Fair Scheduler was released in October 2007, I am using
 * the following hardware spec as a frame of reference for calculating the CFS
 * values:
 *
 * Intel Core 2 Duo E4500
 *   o Number of Cores: 2
 *   o Clock Speed: 2.2 GHz
 *   o Memory Bus Speed: DDR2 800 MHz
 *
 * Memory Contention Coefficient (MCC):
 *   o (Number of Cores * Clock Speed) / Memory Bus Speed
 *   o BASE_MCC = (2 * 2200000000) / 800000000 = 5.5
 * -----------------------------------------------------------------------------
 */

// ════════════════════════════ Feature Test Macros ═══════════════════════════

#define _DEFAULT_SOURCE

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>

#include "org/devopsbroker/io/file.h"
#include "org/devopsbroker/lang/error.h"
#include "org/devopsbroker/lang/integer.h"
#include "org/devopsbroker/lang/string.h"
#include "org/devopsbroker/lang/units.h"
#include "org/devopsbroker/sysfs/memoryarray.h"
#include "org/devopsbroker/text/linebuffer.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════

#define BASE_CPU_CLOCK_SPEED 2200000000.0
#define BASE_RAM_CLOCK_SPEED 800000000.0
#define BASE_MCC 5.5

#define HYPERTHREAD_FACTOR 1.3125
#define MIN_GRANULARITY_FACTOR 0.65625
#define WAKEUP_GRANULARITY_FACTOR 0.40625

// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════

uint64_t getMemoryBusSpeed();

// ═════════════════════════════ Global Variables ═════════════════════════════


// ══════════════════════════════════ main() ══════════════════════════════════

int main(int argc, char *argv[]) {

	programName = "schedtuner";
	c7c88e52_ensureUserIsRoot();

	// File-related variables
	int fileDescriptor;
	ssize_t numBytes;
	char *pathName = "/proc/cpuinfo";

	fileDescriptor = e2f74138_openFile(pathName, O_RDONLY);

	// Initialize the LineBuffer and the file data buffer
	register String *line = NULL;
	LineBuffer lineBuffer;
	char buffer[LOGICAL_BLOCK_SIZE];
	c196bc72_initLineBuffer(&lineBuffer, buffer);

	// Data Variables
	register char *siblings = NULL;
	register char *cpuCores = NULL;
	uint32_t numSiblings = 0;
	uint32_t numCpuCores = 0;

	numBytes = e2f74138_readFile(fileDescriptor, buffer, LOGICAL_BLOCK_SIZE, pathName);
	while (numBytes != END_OF_FILE) {

		line = c196bc72_getLine(&lineBuffer, numBytes);
		while (line != NULL) {
			if (siblings == NULL) {
				siblings = f6215943_startsWith("siblings	: ", line->value);

				if (siblings != NULL) {
					numSiblings = f45efac2_parse_uint32(siblings);
				}
			}

			if (cpuCores == NULL) {
				cpuCores = f6215943_startsWith("cpu cores	: ", line->value);

				if (cpuCores != NULL) {
					numCpuCores = f45efac2_parse_uint32(cpuCores);
				}
			}

			if (siblings != NULL && cpuCores != NULL) {
				break;
			}

			line = c196bc72_getLine(&lineBuffer, numBytes);
		}

		numBytes = e2f74138_readFile(fileDescriptor, buffer, LOGICAL_BLOCK_SIZE, pathName);
	}

	// Close the file
	e2f74138_closeFile(fileDescriptor, pathName);

	// Calcualte the CFS attributes
	uint32_t schedLatencyNs = 6000000U;;
	uint32_t schedMinGranularityNs = 4000000U;;
	uint32_t schedWakeupGranularityNs = 2400000U;;

	if (numCpuCores > 0 || numSiblings > 0) {
		double adjustedNumCpuCores;

		if (numCpuCores > 0 && numSiblings == 0) {
			adjustedNumCpuCores = numCpuCores;
		} else if (numCpuCores == 0 && numSiblings > 0) {
			adjustedNumCpuCores = numSiblings;
		} else if (numCpuCores == numSiblings) {
			adjustedNumCpuCores = numCpuCores;
		} else {
			// Adjust for hyperthreading
			adjustedNumCpuCores = numCpuCores * HYPERTHREAD_FACTOR;
		}

		uint64_t cpuMaxFreq = e2f74138_read_uint64("/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq") * UNITS_KHz;
		uint64_t memoryBusSpeed = getMemoryBusSpeed();
		double mcc = (adjustedNumCpuCores * cpuMaxFreq) / memoryBusSpeed;

		// Scale MCC according to the Base MCC
		mcc = BASE_MCC / mcc;

		// Adjust scheduled latency according to the scaled MCC
		schedLatencyNs /= mcc;

		// Calculate the CPU and memory clock speed percentages
		double clockSpeedPct = (cpuMaxFreq / BASE_CPU_CLOCK_SPEED);
		clockSpeedPct += (memoryBusSpeed / BASE_RAM_CLOCK_SPEED);

		// Adjust scheduled latency according to the clock speed percentage
		schedLatencyNs /= clockSpeedPct;

		// Calculate minimum granularity and wakeup granularity
		schedMinGranularityNs = (schedLatencyNs * MIN_GRANULARITY_FACTOR);
		schedWakeupGranularityNs = (schedLatencyNs * WAKEUP_GRANULARITY_FACTOR);
	}

	printf("kernel.sched_child_runs_first = 1\n");
	printf("kernel.sched_latency_ns = %u\n", schedLatencyNs);
	printf("kernel.sched_min_granularity_ns = %u\n", schedMinGranularityNs);
	printf("kernel.sched_schedstats = 0\n");
	printf("kernel.sched_tunable_scaling = 0\n");
	printf("kernel.sched_wakeup_granularity_ns = %u\n", schedWakeupGranularityNs);

	// Exit with success
	exit(EXIT_SUCCESS);
}

// ═════════════════════════ Function Implementations ═════════════════════════

uint64_t getMemoryBusSpeed() {
	register MemoryArray *memoryInfo = f004d1bd_createMemoryArray();
	register uint64_t memoryBusSpeed = memoryInfo->minSpeed;

	if (memoryInfo->numChannelsInUse == 4) {
		memoryBusSpeed <<= 1;
	} else if (memoryInfo->numChannelsInUse == 3) {
		memoryBusSpeed += (memoryBusSpeed >> 1);
	} else if (memoryInfo->numChannelsInUse == 1) {
		memoryBusSpeed >>= 1;
	}

	f004d1bd_destroyMemoryArray(memoryInfo);

	return memoryBusSpeed;
}
