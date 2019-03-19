/*
 * memoryarray.c - DevOpsBroker C source file for the org.devopsbroker.sysfs.MemoryArray struct
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
 * -----------------------------------------------------------------------------
 * Developed on Ubuntu 16.04.5 LTS running kernel.osrelease = 4.15.0-36
 *
 * -----------------------------------------------------------------------------
 */

// ════════════════════════════ Feature Test Macros ═══════════════════════════

#define _DEFAULT_SOURCE

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdbool.h>
#include <stdint.h>
#include <limits.h>

#include "errorcorrectiontype.h"
#include "formfactor.h"
#include "memoryarray.h"
#include "memorytype.h"

#include "../adt/listarray.h"
#include "../lang/float.h"
#include "../lang/integer.h"
#include "../lang/long.h"
#include "../lang/memory.h"
#include "../lang/string.h"
#include "../lang/system.h"
#include "../lang/units.h"

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════

static inline char *terminate(register char *line, register const char endChar) {
	while (*line != endChar) {
		line++;
	}

	*line = '\0';

	return ++line;
}

static inline ErrorCorrectionType getErrorCorrectionType(register char *attrName, register char **data) {
	register char *attrValue = f6215943_search(attrName, *data);
	*data = terminate(attrValue, '\n');

	return d485dfa0_getErrorCorrectionType(attrValue);
}

static inline void setFloat(register float *attribute, register char *attrName, register char **data, register const char endChar) {
	char *attrValue = f6215943_search(attrName, *data);
	*data = terminate(attrValue, endChar);
	*attribute = b08dcfcc_parseFloat(attrValue);
}

static inline void setFormFactor(register FormFactor *attribute, register char *attrName, register char **data) {
	register char *attrValue = f6215943_search(attrName, *data);
	*data = terminate(attrValue, '\n');
	*attribute = a88c5c62_getFormFactor(attrValue);
}

static inline uint32_t getHexValue(register char *attrName, register char **data) {
	register char *attrValue = f6215943_search(attrName, *data);
	*data = terminate(attrValue, '\n');

	if (f6215943_isNotEqual(attrValue, "Not Provided")) {
		return f45efac2_parseHex_uint32(attrValue);
	}

	return 0;
}

static inline void setHexValue(register uint32_t *attribute, register char *attrName, register char **data) {
	register char *attrValue = f6215943_search(attrName, *data);
	*data = terminate(attrValue, '\n');

	if (f6215943_isNotEqual(attrValue, "Not Provided")) {
		*attribute = f45efac2_parseHex_uint32(attrValue);
	} else {
		*attribute = 0;
	}
}

static inline uint32_t getMaximumCapacity(register char *attrName, register char **data) {
	register char *attrValue = f6215943_search(attrName, *data);
	*data = terminate(attrValue, ' ');

	return f45efac2_parse_uint32(attrValue);
}

static inline void setMemoryType(register MemoryType *attribute, register char *attrName, register char **data) {
	register char *attrValue = f6215943_search(attrName, *data);
	*data = terminate(attrValue, '\n');
	*attribute = c8391d73_getMemoryType(attrValue);
}

static inline void setSize(register uint64_t *attribute, register char *attrName, register char **data) {
	char *attrValue = f6215943_search(attrName, *data);
	*data = terminate(attrValue, ' ');
	*attribute = db0acb04_parse_uint64(attrValue);

	if (f6215943_startsWith("MB", *data)) {
		*attribute *= UNITS_MiB;
	} else if (f6215943_startsWith("GB", *data)) {
		*attribute *= UNITS_GiB;
	}
}

static inline void setSpeed(register uint64_t *attribute, register char *attrName, register char **data) {
	char *attrValue = f6215943_search(attrName, *data);
	*data = terminate(attrValue, ' ');
	*attribute = db0acb04_parse_uint64(attrValue);
}

static inline char *getStringValue(register char *attrName,register char **data) {
	register char *attribute = f6215943_search(attrName, *data);
	*data = terminate(attribute, '\n');

	return attribute;
}

static inline void setStringValue(register char **attribute, register char *attrName, register char **data) {
	*attribute = f6215943_search(attrName, *data);
	*data = terminate(*attribute, '\n');
}

static inline uint32_t getUInt32Value(register char *attrName, register char **data, register const char endChar) {
	register char *attrValue = f6215943_search(attrName, *data);
	*data = terminate(attrValue, endChar);

	return f45efac2_parse_uint32(attrValue);
}

static inline void setUInt32Value(register uint32_t *attribute, register char *attrName, register char **data, register const char endChar) {
	char *attrValue = f6215943_search(attrName, *data);
	*data = terminate(attrValue, endChar);
	*attribute = f45efac2_parse_uint32(attrValue);
}

static inline void setVoltage(register float *attribute, register char *attrName, register char **data) {
	char *attrValue = f6215943_search(attrName, *data);
	*data = terminate(attrValue, ' ');
	*attribute = db0acb04_parse_uint64(attrValue);
}

// ═════════════════════════════ Global Variables ═════════════════════════════

char *const argList[] = { "/usr/sbin/dmidecode", "--type", "memory", NULL };

// ═════════════════════════ Function Implementations ═════════════════════════

MemoryArray *f004d1bd_createMemoryArray() {
	char *memoryArrayData, *location, *use, *totalWidth;
	uint32_t maxCapacity, errorInfoHandle;
	register uint32_t numDevices;
	ErrorCorrectionType ect;

	// Execute dmidecode to get the memory information
	StringBuilder *dmidecodeData = c16819a0_execute("/usr/sbin/dmidecode", argList);

	// Process the data for the MemoryArray struct
	memoryArrayData = f6215943_search("Physical Memory Array", dmidecodeData->buffer);
	location = getStringValue(                    "\tLocation: ", &memoryArrayData);
	use = getStringValue(                              "\tUse: ", &memoryArrayData);
	ect = getErrorCorrectionType(    "\tError Correction Type: ", &memoryArrayData);
	maxCapacity = getMaximumCapacity(     "\tMaximum Capacity: ", &memoryArrayData);
	errorInfoHandle = getHexValue("\tError Information Handle: ", &memoryArrayData);
	numDevices = getUInt32Value(         "\tNumber Of Devices: ", &memoryArrayData, '\n');

	// Allocate memory for the MemoryArray struct
	register MemoryArray *memoryArray = f668c4bd_malloc(sizeof(MemoryArray) + sizeof(MemoryDevice[numDevices]));

	// Fill in the MemoryArray struct
	memoryArray->dmidecodeData = dmidecodeData;
	memoryArray->location = location;
	memoryArray->use = use;
	memoryArray->errorCorrectionType = ect;
	memoryArray->maxCapacity = maxCapacity;
	memoryArray->errorInfoHandle = errorInfoHandle;
	memoryArray->numDevices = numDevices;
	memoryArray->numChannelsInUse = 0;
	memoryArray->numInstalled = 0;
	memoryArray->minSpeed = ULONG_MAX;

	// Build the MemoryDevice list
	ListArray channelsInUse;
	b196167f_initListArray(&channelsInUse);
	register MemoryDevice *memoryDevice;
	register uint32_t j;
	for (register uint32_t i = 0; i < numDevices; i++) {
		memoryDevice = &memoryArray->memoryDeviceList[i];

		memoryArrayData = f6215943_search("Memory Device", memoryArrayData);
		setHexValue(&memoryDevice->arrayHandle,                 "\tArray Handle: ", &memoryArrayData);
		setHexValue(&memoryDevice->errorInfoHandle, "\tError Information Handle: ", &memoryArrayData);

		totalWidth = getStringValue("\tTotal Width: ", &memoryArrayData);
		if (f6215943_startsWith("Unknown", totalWidth)) {
			memoryDevice->totalWidth = 0;
			memoryDevice->dataWidth = 0;
			memoryDevice->size = 0UL;
			memoryDevice->formFactor = FormFactor_UNKNOWN;
			memoryDevice->set = NULL;

			setStringValue(&memoryDevice->locator,          "\tLocator: ", &memoryArrayData);
			setStringValue(&memoryDevice->bankLocator, "\tBank Locator: ", &memoryArrayData);

			memoryDevice->type = MemoryType_UNKNOWN;
			memoryDevice->typeDetail = NULL;
			memoryDevice->speed = 0UL;
			memoryDevice->manufacturer = NULL;
			memoryDevice->serialNumber = NULL;
			memoryDevice->assetTag = NULL;
			memoryDevice->partNumber = NULL;
			memoryDevice->rank = 0;
			memoryDevice->configClockSpeed = 0;
			memoryDevice->minVoltage = 0.0f;
			memoryDevice->maxVoltage = 0.0f;
			memoryDevice->configVoltage = 0.0f;
		} else {
			terminate(totalWidth, ' ');
			memoryDevice->totalWidth = f45efac2_parse_uint32(totalWidth);

			setUInt32Value(&memoryDevice->dataWidth,              "\tData Width: ", &memoryArrayData, ' ');
			setSize(&memoryDevice->size,                                "\tSize: ", &memoryArrayData);
			setFormFactor(&memoryDevice->formFactor,             "\tForm Factor: ", &memoryArrayData);
			setStringValue(&memoryDevice->set,                           "\tSet: ", &memoryArrayData);
			setStringValue(&memoryDevice->locator,                   "\tLocator: ", &memoryArrayData);
			setStringValue(&memoryDevice->bankLocator,          "\tBank Locator: ", &memoryArrayData);
			setMemoryType(&memoryDevice->type,                          "\tType: ", &memoryArrayData);
			setStringValue(&memoryDevice->typeDetail,            "\tType Detail: ", &memoryArrayData);
			setSpeed(&memoryDevice->speed,                             "\tSpeed: ", &memoryArrayData);
			setStringValue(&memoryDevice->manufacturer,         "\tManufacturer: ", &memoryArrayData);
			setStringValue(&memoryDevice->serialNumber,        "\tSerial Number: ", &memoryArrayData);
			setStringValue(&memoryDevice->assetTag,                "\tAsset Tag: ", &memoryArrayData);
			setStringValue(&memoryDevice->partNumber,            "\tPart Number: ", &memoryArrayData);
			setUInt32Value(&memoryDevice->rank,                         "\tRank: ", &memoryArrayData, '\n');
			setSpeed(&memoryDevice->configClockSpeed, "\tConfigured Clock Speed: ", &memoryArrayData);
			setFloat(&memoryDevice->minVoltage,              "\tMinimum Voltage: ", &memoryArrayData, ' ');
			setFloat(&memoryDevice->maxVoltage,              "\tMaximum Voltage: ", &memoryArrayData, ' ');
			setFloat(&memoryDevice->configVoltage,        "\tConfigured Voltage: ", &memoryArrayData, ' ');

			memoryArray->minSpeed = db0acb04_min_uint64(memoryArray->minSpeed, memoryDevice->speed);
			memoryArray->numInstalled++;

			bool channelInUse = false;
			for (j = 0; j < channelsInUse.length; j++) {
				if (f6215943_isEqual(memoryDevice->bankLocator, channelsInUse.values[j])) {
					channelInUse = true;
					break;
				}
			}

			if (!channelInUse) {
				b196167f_add(&channelsInUse, memoryDevice->bankLocator);
				memoryArray->numChannelsInUse++;
			}
		}
	}

	return memoryArray;
}

StringBuilder *f004d1bd_toStringMemoryArray(MemoryArray *memoryArray) {
	StringBuilder *strBuilder = c598a24c_createStringBuilder_uint32(1536);

	const char *errorCorrectionType = d485dfa0_toStringErrorCorrectionType(memoryArray->errorCorrectionType);
	char *maxCapacity = f45efac2_toString_uint32(memoryArray->maxCapacity);
	char *errorInfoHandle = f45efac2_toStringHex_uint32(memoryArray->errorInfoHandle, 4);
	char *numDevices = f45efac2_toString_uint32(memoryArray->numDevices);
	char *numInstalled = f45efac2_toString_uint32(memoryArray->numInstalled);
	char *speed = db0acb04_toString_uint64(memoryArray->minSpeed);
	char *numChannelsInUse = f45efac2_toString_uint32(memoryArray->numChannelsInUse);

	c598a24c_append_string(strBuilder, "Physical Memory Array");
	c598a24c_append_string_varg(strBuilder, "\n\tLocation: ",                 memoryArray->location, NULL);
	c598a24c_append_string_varg(strBuilder, "\n\tUse: ",                      memoryArray->use, NULL);
	c598a24c_append_string_varg(strBuilder, "\n\tError Correction Type: ",    errorCorrectionType , NULL);
	c598a24c_append_string_varg(strBuilder, "\n\tMaximum Capacity: ",         maxCapacity, " GB", NULL);
	c598a24c_append_string_varg(strBuilder, "\n\tError Information Handle: ", errorInfoHandle, NULL);
	c598a24c_append_string_varg(strBuilder, "\n\tNumber Of Devices: ",        numDevices, NULL);
	c598a24c_append_string_varg(strBuilder, "\n\tNumber Installed: ",         numInstalled, NULL);
	c598a24c_append_string_varg(strBuilder, "\n\tMinimum Speed: ",            speed, NULL);
	c598a24c_append_string_varg(strBuilder, "\n\tChannels In Use: ",          numChannelsInUse, NULL);


	free(maxCapacity);
	free(errorInfoHandle);
	free(numDevices);
	free(numInstalled);
	free(speed);
	free(numChannelsInUse);

	// Append the MemoryDevice list
	char floatString[32];
	register MemoryDevice *memoryDevice;
	for (register uint32_t i = 0; i < memoryArray->numDevices; i++) {
		memoryDevice = &memoryArray->memoryDeviceList[i];

		char *arrayHandle = f45efac2_toStringHex_uint32(memoryDevice->arrayHandle, 4);
		errorInfoHandle = f45efac2_toStringHex_uint32(memoryDevice->errorInfoHandle, 4);

		c598a24c_append_string(strBuilder, "\n\nMemory Device");
		c598a24c_append_string_varg(strBuilder, "\n\tArray Handle: ", arrayHandle, NULL);
		c598a24c_append_string_varg(strBuilder, "\n\tError Information Handle: ", errorInfoHandle, NULL);

		if (memoryDevice->totalWidth == 0) {
			c598a24c_append_string(strBuilder, "\n\tSize: No Module Installed");
			c598a24c_append_string_varg(strBuilder, "\n\tLocator: ", memoryDevice->locator, NULL);
			c598a24c_append_string_varg(strBuilder, "\n\tBank Locator: ", memoryDevice->bankLocator, NULL);
		} else {
			const char *formFactor = a88c5c62_toStringFormFactor(memoryDevice->formFactor);
			const char *memoryType = c8391d73_toStringMemoryType(memoryDevice->type);
			char *totalWidth = f45efac2_toString_uint32(memoryDevice->totalWidth);
			char *dataWidth = f45efac2_toString_uint32(memoryDevice->dataWidth);
			char *size = db0acb04_toString_uint64(memoryDevice->size / UNITS_MiB);
			speed = db0acb04_toString_uint64(memoryDevice->speed);
			char *rank = f45efac2_toString_uint32(memoryDevice->rank);
			char *configClockSpeed = db0acb04_toString_uint64(memoryDevice->configClockSpeed);

			c598a24c_append_string_varg(strBuilder, "\n\tTotal Width: ", totalWidth, " bits", NULL);
			c598a24c_append_string_varg(strBuilder, "\n\tData Width: ", dataWidth, " bits", NULL);
			c598a24c_append_string_varg(strBuilder, "\n\tSize: ", size, " MB", NULL);
			c598a24c_append_string_varg(strBuilder, "\n\tForm Factor: ", formFactor, NULL);
			c598a24c_append_string_varg(strBuilder, "\n\tSet: ", memoryDevice->set, NULL);
			c598a24c_append_string_varg(strBuilder, "\n\tLocator: ", memoryDevice->locator, NULL);
			c598a24c_append_string_varg(strBuilder, "\n\tBank Locator: ", memoryDevice->bankLocator, NULL);
			c598a24c_append_string_varg(strBuilder, "\n\tType: ", memoryType, NULL);
			c598a24c_append_string_varg(strBuilder, "\n\tType Detail: ", memoryDevice->typeDetail, NULL);
			c598a24c_append_string_varg(strBuilder, "\n\tSpeed: ", speed, " MHz", NULL);
			c598a24c_append_string_varg(strBuilder, "\n\tManufacturer: ", memoryDevice->manufacturer, NULL);
			c598a24c_append_string_varg(strBuilder, "\n\tSerial Number: ", memoryDevice->serialNumber, NULL);
			c598a24c_append_string_varg(strBuilder, "\n\tAsset Tag: ", memoryDevice->assetTag, NULL);
			c598a24c_append_string_varg(strBuilder, "\n\tPart Number: ", memoryDevice->partNumber, NULL);
			c598a24c_append_string_varg(strBuilder, "\n\tRank: ", rank, NULL);
			c598a24c_append_string_varg(strBuilder, "\n\tConfigured Clock Speed: ", configClockSpeed, " MHz", NULL);

			sprintf(floatString, "\n\tMinimum Voltage: %0.2f V", memoryDevice->minVoltage);
			c598a24c_append_string(strBuilder, floatString);

			sprintf(floatString, "\n\tMaximum Voltage: %0.2f V", memoryDevice->maxVoltage);
			c598a24c_append_string(strBuilder, floatString);

			sprintf(floatString, "\n\tConfigured Voltage: %0.2f V", memoryDevice->configVoltage);
			c598a24c_append_string(strBuilder, floatString);

			free(totalWidth);
			free(dataWidth);
			free(size);
			free(speed);
			free(rank);
			free(configClockSpeed);
		}

		free(arrayHandle);
		free(errorInfoHandle);
	}

	return strBuilder;
}
