/*
 * formfactor.h - DevOpsBroker C header file for the org.devopsbroker.sysfs.MemoryType enum
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
 * echo ORG_DEVOPSBROKER_SYSFS_FORMFACTOR | md5sum | cut -c 25-32
 * -----------------------------------------------------------------------------
 */

#ifndef ORG_DEVOPSBROKER_SYSFS_FORMFACTOR_H
#define ORG_DEVOPSBROKER_SYSFS_FORMFACTOR_H

// ═══════════════════════════════ Preprocessor ═══════════════════════════════

#define a88c5c62_NUM_VALUES 3

// ═════════════════════════════════ Typedefs ═════════════════════════════════

typedef enum FormFactor {
	FormFactor_UNKNOWN = 0,
	FormFactor_DIMM,
	FormFactor_SODIMM
} FormFactor;

// ═══════════════════════════ Function Declarations ══════════════════════════

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    a88c5c62_getFormFactor
 * Description: Returns the FormFactor associated with the char* string
 *
 * Parameters:
 *   source     The char* pointer to convert to an FormFactor value
 * Returns:     The associated FormFactor value
 * ----------------------------------------------------------------------------
 */
FormFactor a88c5c62_getFormFactor(char *source);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    a88c5c62_toStringFormFactor
 * Description: Returns the char* string representation of the FormFactor value
 *
 * Parameters:
 *   formFactor	The FormFactor value to convert to a char* string
 * Returns:     The char* string representation of the FormFactor value
 * ----------------------------------------------------------------------------
 */
char *a88c5c62_toStringFormFactor(const FormFactor formFactor);

#endif /* ORG_DEVOPSBROKER_SYSFS_FORMFACTOR_H */
