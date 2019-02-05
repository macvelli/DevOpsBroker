/*
 * systeminfo.h - DevOpsBroker C header file for the org.devopsbroker.info.SystemInfo struct
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
 * Developed on Ubuntu 18.04.1 LTS running kernel.osrelease = 4.15.0-45
 *
 * echo ORG_DEVOPSBROKER_INFO_SYSTEMINFO | md5sum | cut -c 25-32
 * -----------------------------------------------------------------------------
 */

#ifndef ORG_DEVOPSBROKER_INFO_SYSTEMINFO_H
#define ORG_DEVOPSBROKER_INFO_SYSTEMINFO_H

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <assert.h>

#include <sys/sysinfo.h>

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════

typedef struct sysinfo SystemInfo;
/*	long uptime;               // Seconds since boot
	unsigned long loads[3];    // 1, 5, and 15 minute load averages
	unsigned long totalram;    // Total usable main memory size
	unsigned long freeram;     // Available memory size
	unsigned long sharedram;   // Amount of shared memory
	unsigned long bufferram;   // Memory used by buffers
	unsigned long totalswap;   // Total swap space size
	unsigned long freeswap;    // Swap space still available
	unsigned short procs;      // Number of current processes
	unsigned long totalhigh;   // Total high memory size
	unsigned long freehigh;    // Available high memory size
	unsigned int mem_unit;     // Memory unit size in bytes
	// Padding
	char _f[20-2*sizeof(long)-sizeof(int)];
*/

static_assert(sizeof(SystemInfo) == 112, "Check your assumptions");

// ═════════════════════════════ Global Variables ═════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════

// ~~~~~~~~~~~~~~~~~~~~~~~~~ Initialization Functions ~~~~~~~~~~~~~~~~~~~~~~~~~

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c6059903_initSystemInfo
 * Description: Initializes an existing SystemInfo struct
 *
 * Parameters:
 *   systemInfo     A pointer to the SystemInfo instance to initalize
 * ----------------------------------------------------------------------------
 */
void c6059903_initSystemInfo(SystemInfo *systemInfo);

#endif /* ORG_DEVOPSBROKER_INFO_SYSTEMINFO_H */
