/*
 * errorcorrectiontype.h - DevOpsBroker C header file for the org.devopsbroker.sysfs.ErrorCorrectionType enum
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
 * echo ORG_DEVOPSBROKER_SYSFS_ERRORCORRECTIONTYPE | md5sum | cut -c 25-32
 * -----------------------------------------------------------------------------
 */

#ifndef ORG_DEVOPSBROKER_SYSFS_ERRORCORRECTIONTYPE_H
#define ORG_DEVOPSBROKER_SYSFS_ERRORCORRECTIONTYPE_H

// ═══════════════════════════════ Preprocessor ═══════════════════════════════

#define d485dfa0_NUM_VALUES 3

// ═════════════════════════════════ Typedefs ═════════════════════════════════

typedef enum ErrorCorrectionType {
	NONE = 0,
	ECC,
	MULTI_BIT_ECC
} ErrorCorrectionType;

// ═══════════════════════════ Function Declarations ══════════════════════════

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    d485dfa0_getErrorCorrectionType
 * Description: Returns the ErrorCorrectionType associated with the char* string
 *
 * Parameters:
 *   source     The char* pointer to convert to an ErrorCorrectionType value
 * Returns:     The associated ErrorCorrectionType value
 * ----------------------------------------------------------------------------
 */
ErrorCorrectionType d485dfa0_getErrorCorrectionType(char *source);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    d485dfa0_toStringErrorCorrectionType
 * Description: Returns the char* string representation of the ErrorCorrectionType value
 *
 * Parameters:
 *   ect        The ErrorCorrectionType value to convert to a char* string
 * Returns:     The char* string representation of the ErrorCorrectionType value
 * ----------------------------------------------------------------------------
 */
char *d485dfa0_toStringErrorCorrectionType(const ErrorCorrectionType ect);

#endif /* ORG_DEVOPSBROKER_SYSFS_ERRORCORRECTIONTYPE_H */
