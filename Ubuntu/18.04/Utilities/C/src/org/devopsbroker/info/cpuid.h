/*
 * cpuid.h - DevOpsBroker C header file for the org.devopsbroker.info.CPUID struct
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
 * echo ORG_DEVOPSBROKER_INFO_CPUID | md5sum | cut -c 17-24
 * -----------------------------------------------------------------------------
 */

#ifndef ORG_DEVOPSBROKER_INFO_CPUID_H
#define ORG_DEVOPSBROKER_INFO_CPUID_H

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdbool.h>
#include <stdint.h>

#include <assert.h>

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════

typedef struct CPUID {
	char modelName[48];
	char vendorId[16];
	int maxCpuIdLevel;
	int family;
	int model;
	int steppingId;
	int brandIndex;
	int clflushSize;
	int numLogicalProcs;
	int numPhysicalCores;
	bool hasx87Fpu;
	bool hasVirtual8086Mode;
	bool hasDebugExtensions;
	bool hasPageSizeExtension;
	bool hasTimeStampCounter;
	bool hasModelSpecificRegs;
	bool hasPhysAddrExtension;
	bool hasMachineCheckException;
	bool hasCompareAndSwap;
	bool hasAPIC;
	bool boolReserved1;
	bool hasSysEnter;
	bool hasMemTypeRangeRegs;
	bool hasPageGlobalEnableBit;
	bool hasMachineCheckArchitecture;
	bool hasConditionalMove;
	bool hasPageAttrTable;
	bool hasPageSizeExtension36bit;
	bool hasProcSerialNumber;
	bool hasClflush;
	bool boolReserved2;
	bool hasDebugStore;
	bool hasACPI;
	bool hasMMX;
	bool hasFXSAVE;
	bool hasSSE;
	bool hasSSE2;
	bool hasSelfSnoopCache;
	bool hasHyperThreading;
	bool hasThermalMonitor;
	bool hasIA64Emulator;
	bool hasPendingBreakEnable;
	bool hasSSE3;
	bool hasPCLMULQDQ;
	bool hasDebugStore64bit;
	bool hasMonitor;
	bool hasDebugStoreCPL;
	bool hasVirtualMachineExtensions;
	bool hasSaferModeExtensions;
	bool hasEnhancedSpeedStep;
	bool hasThermalMonitor2;
	bool hasSupplementalSSE3;
	bool hasL1ContextID;
	bool hasSiliconDebug;
	bool hasFusedMultiplyAdd;
	bool hasCMPXCHG16B;
	bool hasDisableTaskPriorityMsgs;
	bool hasPerfmonDebug;
	bool boolReserved3;
	bool hasProcessContextIds;
	bool hasDirectCacheAccess;
	bool hasSSE4_1;
	bool hasSSE4_2;
	bool hasx2APIC;
	bool hasMOVBE;
	bool hasPOPCNT;
	bool hasTSCDeadline;
	bool hasAES;
	bool hasXSAVE;
	bool hasOSXSAVE;
	bool hasAVX;
	bool hasF16C;
	bool hasRDRAND;
	bool alwaysZero;
} __attribute__ ((aligned (16))) CPUID;

static_assert(sizeof(CPUID) == 160, "Check your assumptions");

// ═════════════════════════════ Global Variables ═════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Utility Functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f618482d_getCoreTopology
 * Description: Populates the CPUID struct with the number of physical and
 *              logical cores in the CPU
 *
 * Parameters:
 *   cpuid      A pointer to the CPUID struct instance to populate
 * ----------------------------------------------------------------------------
 */
void f618482d_getCoreTopology(CPUID *cpuid);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f618482d_getModelName
 * Description: Populates the CPUID struct with the CPU model name
 *
 * Parameters:
 *   cpuid      A pointer to the CPUID struct instance to populate
 * ----------------------------------------------------------------------------
 */
void f618482d_getModelName(CPUID *cpuid);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f618482d_getProcessorInfo
 * Description: Populates the CPUID struct with the CPU processor information
 *              and feature flags
 *
 * Parameters:
 *   cpuid      A pointer to the CPUID struct instance to populate
 * ----------------------------------------------------------------------------
 */
void f618482d_getProcessorInfo(CPUID *cpuid);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f618482d_getVendorID
 * Description: Populates the CPUID struct with the CPU vendor string and the
 *              maximum basic leaf available for the CPUID instruction
 *
 * Parameters:
 *   cpuid      A pointer to the CPUID struct instance to populate
 * ----------------------------------------------------------------------------
 */
void f618482d_getVendorID(CPUID *cpuid);

#endif /* ORG_DEVOPSBROKER_INFO_CPUID_H */
