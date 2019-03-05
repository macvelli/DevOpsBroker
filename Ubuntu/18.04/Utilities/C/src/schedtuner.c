/*
 * schedtuner.c - DevOpsBroker utility for tuning the Completely Fair Scheduler
 *
 * Copyright (C) 2018-2019 Edward Smith <edwardsmith@devopsbroker.org>
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

#include <assert.h>
#include <unistd.h>

#include "org/devopsbroker/info/cpuid.h"
#include "org/devopsbroker/io/file.h"
#include "org/devopsbroker/lang/error.h"
#include "org/devopsbroker/lang/integer.h"
#include "org/devopsbroker/lang/memory.h"
#include "org/devopsbroker/lang/string.h"
#include "org/devopsbroker/lang/units.h"
#include "org/devopsbroker/sysfs/memoryarray.h"
#include "org/devopsbroker/terminal/commandline.h"
#include "org/devopsbroker/text/linebuffer.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════

#define BASE_CPU_CLOCK_SPEED 2200000000.0
#define BASE_RAM_CLOCK_SPEED 800000000.0
#define BASE_MCC 5.5

#define HYPERTHREAD_FACTOR 1.3125
#define MIN_GRANULARITY_FACTOR 0.65625
#define WAKEUP_GRANULARITY_FACTOR 0.40625

#define USAGE_MSG "schedtuner " ANSI_GOLD "{ -c cpuMaxFreq | -m memBusSpeed | -h }"

// ═════════════════════════════════ Typedefs ═════════════════════════════════

typedef struct TuningParams {
	uint64_t cpuMaxFreq;
	uint64_t memoryBusSpeed;
} TuningParams;

static_assert(sizeof(TuningParams) == 16, "Check your assumptions");

// ═════════════════════════════ Global Variables ═════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════

static uint64_t getCPUMaxFrequency(TuningParams *tuningParams);

static uint64_t getMemoryBusSpeed(TuningParams *tuningParams);

static void printHelp();

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Possible command-line options:
 *
 *   -c -> CPU Max Frequency
 *   -m -> Memory Bus Speed
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
			if (argv[i][1] == 'c') {
				tuningParams->cpuMaxFreq = d7ad7024_getUint64(cmdLineParm, "CPU maximum frequency", i++);
			} else if (argv[i][1] == 'm') {
				tuningParams->memoryBusSpeed = d7ad7024_getUint64(cmdLineParm, "memory bus speed", i++);
			} else if (argv[i][1] == 'h') {
				printHelp();
				exit(EXIT_SUCCESS);
			} else {
				c7c88e52_invalidOption(argv[i]);
				c7c88e52_printUsage(USAGE_MSG);
				exit(EXIT_FAILURE);
			}
		} else {
			c7c88e52_invalidOption(argv[i]);
			c7c88e52_printUsage(USAGE_MSG);
			exit(EXIT_FAILURE);
		}
	}
}

// ══════════════════════════════════ main() ══════════════════════════════════

int main(int argc, char *argv[]) {

	CPUID cpuid;
	f618482d_getCoreTopology(&cpuid);
//	f618482d_getModelName(&cpuid);
//	f618482d_getVendorID(&cpuid);
//	f618482d_getProcessorInfo(&cpuid);

//	printf("CPU Model Name: %s\n", cpuid.modelName);
//	printf("CPU Vendor ID: %s\n", cpuid.vendorId);
//	printf("Max CPUID Level: %d\n", cpuid.maxCpuIdLevel);
//	printf("CPU Family: %d\n", cpuid.family);
//	printf("Model: %d\n", cpuid.model);
//	printf("Stepping ID: %d\n", cpuid.steppingId);
//	printf("Brand Index: %d\n", cpuid.brandIndex);
//	printf("CLFLUSH Size: %d\n", cpuid.clflushSize);
	printf("Number of Logical Processors: %d\n", cpuid.numLogicalProcs);
//	printf("Local APIC ID: %d\n", cpuid.localAPICId);
	printf("Number of Physical Cores: %d\n", cpuid.numPhysicalCores);
/*
	printf("Has x87 FPU: %d\n", cpuid.hasx87Fpu);
	printf("Has virtual 8086 mode extensions: %d\n", cpuid.hasVirtual8086Mode);
	printf("Has debugging extensions: %d\n", cpuid.hasDebugExtensions);
	printf("Has Page Size Extension: %d\n", cpuid.hasPageSizeExtension);
	printf("Has Time Stamp Counter: %d\n", cpuid.hasTimeStampCounter);
	printf("Has Model-Specific Registers: %d\n", cpuid.hasModelSpecificRegs);
	printf("Has Physical Address Extension: %d\n", cpuid.hasPhysAddrExtension);
	printf("Has Machine Check Exception: %d\n", cpuid.hasMachineCheckException);
	printf("Has CMPXCHG8: %d\n", cpuid.hasCompareAndSwap);
	printf("Has Onboard APIC: %d\n", cpuid.hasAPIC);
	printf("Has SYSENTER and SYSEXIT: %d\n", cpuid.hasSysEnter);
	printf("Has Memory Type Range Registers: %d\n", cpuid.hasMemTypeRangeRegs);
	printf("Has Page Global Enable Bit: %d\n", cpuid.hasPageGlobalEnableBit);
	printf("Has Machine Check Architecture: %d\n", cpuid.hasMachineCheckArchitecture);
	printf("Has Conditional Move: %d\n", cpuid.hasConditionalMove);
	printf("Has Page Attribute Table: %d\n", cpuid.hasPageAttrTable);
	printf("Has 36-bit Page Size Extension: %d\n", cpuid.hasPageSizeExtension36bit);
	printf("Has Processor Serial Number: %d\n", cpuid.hasProcSerialNumber);
	printf("Has CLFLUSH: %d\n", cpuid.hasClflush);
	printf("Has Debug Store: %d\n", cpuid.hasDebugStore);
	printf("Has Onboard Thermal Control MSRs for ACPI: %d\n", cpuid.hasACPI);
	printf("Has MMX: %d\n", cpuid.hasMMX);
	printf("Has FXSAVE/FXRESTOR: %d\n", cpuid.hasFXSAVE);
	printf("Has SSE: %d\n", cpuid.hasSSE);
	printf("Has SSE2: %d\n", cpuid.hasSSE2);
	printf("Has Self-Snoop CPU Cache: %d\n", cpuid.hasSelfSnoopCache);
	printf("Has Hyper-Threading: %d\n", cpuid.hasHyperThreading);
	printf("Has Thermal Monitor: %d\n", cpuid.hasThermalMonitor);
	printf("Has IA64 Emulator: %d\n", cpuid.hasIA64Emulator);
	printf("Has Pending Break Enable: %d\n", cpuid.hasPendingBreakEnable);
	printf("Has SSE3: %d\n", cpuid.hasSSE3);
	printf("Has Carry-Less Multiplication: %d\n", cpuid.hasPCLMULQDQ);
	printf("Has 64-bit Debug Store: %d\n", cpuid.hasDebugStore64bit);
	printf("Has MONITOR and MWAIT: %d\n", cpuid.hasMonitor);
	printf("Has CPL-Qualified Debug Store: %d\n", cpuid.hasDebugStoreCPL);
	printf("Has Virtual Machine eXtensions: %d\n", cpuid.hasVirtualMachineExtensions);
	printf("Has Safer Mode Extensions: %d\n", cpuid.hasSaferModeExtensions);
	printf("Has Enhanced SpeedStep: %d\n", cpuid.hasEnhancedSpeedStep);
	printf("Has Thermal Monitor 2: %d\n", cpuid.hasThermalMonitor2);
	printf("Has Supplemental SSE3: %d\n", cpuid.hasSupplementalSSE3);
	printf("Has L1 Context ID: %d\n", cpuid.hasL1ContextID);
	printf("Has Silicon Debug Interface: %d\n", cpuid.hasSiliconDebug);
	printf("Has Fused Multiply-Add: %d\n", cpuid.hasFusedMultiplyAdd);
	printf("Has CMPXCHG16B: %d\n", cpuid.hasCMPXCHG16B);
	printf("Has Disable Task Priority Messages: %d\n", cpuid.hasDisableTaskPriorityMsgs);
	printf("Has Perfmon & Debug Capability: %d\n", cpuid.hasPerfmonDebug);
	printf("Has Process Context Identifiers: %d\n", cpuid.hasProcessContextIds);
	printf("Has Direct Cache Access for DMA Writes: %d\n", cpuid.hasDirectCacheAccess);
	printf("Has SSE4.1: %d\n", cpuid.hasSSE4_1);
	printf("Has SSE4.2: %d\n", cpuid.hasSSE4_2);
	printf("Has x2APIC: %d\n", cpuid.hasx2APIC);
	printf("Has MOVBE: %d\n", cpuid.hasMOVBE);
	printf("Has POPCNT: %d\n", cpuid.hasPOPCNT);
	printf("Has APIC TSC Deadline: %d\n", cpuid.hasTSCDeadline);
	printf("Has AES: %d\n", cpuid.hasAES);
	printf("Has XSAVE: %d\n", cpuid.hasXSAVE);
	printf("Has XSAVE Enabled By OS: %d\n", cpuid.hasOSXSAVE);
	printf("Has Advanced Vector Extensions: %d\n", cpuid.hasAVX);
	printf("Has F16C: %d\n", cpuid.hasF16C);
	printf("Has RDRAND: %d\n", cpuid.hasRDRAND);
*/
	programName = "schedtuner";
	c7c88e52_ensureUserIsRoot();

	TuningParams tuningParams;
	CmdLineParam cmdLineParm;

	d7ad7024_initCmdLineParam(&cmdLineParm, argc, argv, USAGE_MSG);
	processCmdLine(&cmdLineParm, &tuningParams);

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

		uint64_t cpuMaxFreq = getCPUMaxFrequency(&tuningParams);
		uint64_t memoryBusSpeed = getMemoryBusSpeed(&tuningParams);
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

static uint64_t getCPUMaxFrequency(TuningParams *tuningParams) {
	if (tuningParams->cpuMaxFreq == 0) {
		return e2f74138_read_uint64("/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq") * UNITS_KHz;
	}

	return tuningParams->cpuMaxFreq * UNITS_KHz;
}

static uint64_t getMemoryBusSpeed(TuningParams *tuningParams) {
	if (tuningParams->memoryBusSpeed == 0) {
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

	return tuningParams->memoryBusSpeed;
}

static void printHelp() {
	c7c88e52_printUsage(USAGE_MSG);

	puts("\nPerforms kernel process scheduler optimization calculations for /etc/sysctl.conf");

	puts(ANSI_BOLD "\nDefault Values:" ANSI_RESET);
	puts("  CPU Max Frequency\tsysfs value (if present)");
	puts("  Memory Bus Speed\tdmidecode value (if present)");

	puts(ANSI_BOLD "\nExamples:" ANSI_RESET);
	puts("  schedtuner -c 3400 -m 3200");

	puts(ANSI_BOLD "\nValid Options:\n");
	puts(ANSI_YELLOW "  -c\t" ANSI_ROMANTIC "Specify the CPU maximum frequency");
	puts(ANSI_BOLD ANSI_YELLOW "  -m\t" ANSI_ROMANTIC "Specify the memory bus speed");
	puts(ANSI_BOLD ANSI_YELLOW "  -h\t" ANSI_ROMANTIC "Print this help message\n");
}
