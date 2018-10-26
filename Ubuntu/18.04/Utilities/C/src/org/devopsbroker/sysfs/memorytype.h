/*
 * memorytype.h - DevOpsBroker C header file for the org.devopsbroker.sysfs.MemoryType enum
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
 * echo ORG_DEVOPSBROKER_SYSFS_MEMORYTYPE | md5sum | cut -c 25-32
 * -----------------------------------------------------------------------------
 */

#ifndef ORG_DEVOPSBROKER_SYSFS_MEMORYTYPE_H
#define ORG_DEVOPSBROKER_SYSFS_MEMORYTYPE_H

// ═══════════════════════════════ Preprocessor ═══════════════════════════════

#define c8391d73_NUM_VALUES 6

// ═════════════════════════════════ Typedefs ═════════════════════════════════

typedef enum MemoryType {
	MemoryType_UNKNOWN = 0,
	MemoryType_SDRAM,
	MemoryType_DDR,
	MemoryType_DDR2,
	MemoryType_DDR3,
	MemoryType_DDR4
} MemoryType;

// ═══════════════════════════ Function Declarations ══════════════════════════

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c8391d73_getMemoryType
 * Description: Returns the MemoryType associated with the char* string
 *
 * Parameters:
 *   source     The char* pointer to convert to an MemoryType value
 * Returns:     The associated MemoryType value
 * ----------------------------------------------------------------------------
 */
MemoryType c8391d73_getMemoryType(char *source);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c8391d73_toStringMemoryType
 * Description: Returns the char* string representation of the MemoryType value
 *
 * Parameters:
 *   memoryType	The MemoryType value to convert to a char* string
 * Returns:     The char* string representation of the MemoryType value
 * ----------------------------------------------------------------------------
 */
char *c8391d73_toStringMemoryType(const MemoryType memoryType);

#endif /* ORG_DEVOPSBROKER_SYSFS_MEMORYTYPE_H */
