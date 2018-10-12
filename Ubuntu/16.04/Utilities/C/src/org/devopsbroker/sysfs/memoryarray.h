/*
 * memoryarray.h - DevOpsBroker C header file for the org.devopsbroker.sysfs.MemoryArray struct
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
 * -----------------------------------------------------------------------------
 * Developed on Ubuntu 16.04.5 LTS running kernel.osrelease = 4.15.0-36
 *
 * echo ORG_DEVOPSBROKER_SYSFS_MEMORYARRAY | md5sum | cut -c 25-32
 * -----------------------------------------------------------------------------
 */

#ifndef ORG_DEVOPSBROKER_SYSFS_MEMORYARRAY_H
#define ORG_DEVOPSBROKER_SYSFS_MEMORYARRAY_H

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdlib.h>
#include <stdint.h>

#include <assert.h>

#include "errorcorrectiontype.h"
#include "formfactor.h"
#include "memorytype.h"

#include "../lang/memory.h"
#include "../lang/stringbuilder.h"

// ═════════════════════════════════ Typedefs ═════════════════════════════════

typedef struct MemoryDevice {
	char *assetTag;
	char *bankLocator;
	char *locator;
	char *manufacturer;
	char *partNumber;
	char *serialNumber;
	char *set;
	char *typeDetail;
	uint64_t configClockSpeed;
	uint64_t size;
	uint64_t speed;
	uint32_t arrayHandle;
	uint32_t dataWidth;
	uint32_t errorInfoHandle;
	uint32_t rank;
	uint32_t totalWidth;
	FormFactor formFactor;
	MemoryType type;
	float configVoltage;
	float maxVoltage;
	float minVoltage;
} MemoryDevice;

static_assert(sizeof(MemoryDevice) == 128, "Check your assumptions");

typedef struct MemoryArray {
	StringBuilder *dmidecodeData;
	char *location;
	char *use;
	uint64_t minSpeed;
	ErrorCorrectionType errorCorrectionType;
	uint32_t errorInfoHandle;
	uint32_t maxCapacity;
	uint32_t numChannelsInUse;
	uint32_t numDevices;
	uint32_t numInstalled;
	char slop[8];
	MemoryDevice memoryDeviceList[];
} MemoryArray;

static_assert(sizeof(MemoryArray) == 64, "Check your assumptions");

// ═══════════════════════════ Function Declarations ══════════════════════════

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f004d1bd_destroyMemoryArray
 * Description: Destroys all dynamically allocated memory of the MemoryArray struct pointer
 *
 * Parameters:
 *   memoryArray	A pointer to the MemoryArray instance to destroy
 * ----------------------------------------------------------------------------
 */
static inline void f004d1bd_destroyMemoryArray(MemoryArray *memoryArray) {
	c598a24c_destroyStringBuilder(memoryArray->dmidecodeData);
	f668c4bd_free(memoryArray);
}

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f004d1bd_createMemoryArray
 * Description: Creates a MemoryArray struct instance
 *
 * Returns:     A MemoryArray struct instance
 * ----------------------------------------------------------------------------
 */
MemoryArray *f004d1bd_createMemoryArray();

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    f004d1bd_toStringMemoryArray
 * Description: Generates a string from the MemoryArray instance
 *
 * Parameters:
 *   memoryArray    A pointer to the MemoryArray instance
 * Returns:         A pointer to the populated StringBuilder instance
 * ----------------------------------------------------------------------------
 */
StringBuilder *f004d1bd_toStringMemoryArray(MemoryArray *memoryArray);

#endif /* ORG_DEVOPSBROKER_SYSFS_MEMORYARRAY_H */
