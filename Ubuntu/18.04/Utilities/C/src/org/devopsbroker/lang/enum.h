/*
 * enum.h - DevOpsBroker C header file for enum-related functionality
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
 * Developed on Ubuntu 18.04.2 LTS running kernel.osrelease = 4.18.0-17
 *
 * echo ORG_DEVOPSBROKER_LANG_ENUM | md5sum | cut -c 25-32
 * -----------------------------------------------------------------------------
 */

#ifndef ORG_DEVOPSBROKER_LANG_ENUM_H
#define ORG_DEVOPSBROKER_LANG_ENUM_H

// ═════════════════════════════════ Includes ═════════════════════════════════


// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ═════════════════════════════ Global Variables ═════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    c5033972_toStringEnum
 * Description: Returns the string associated with the given enum value
 *
 * Parameters:
 *   enumStringList   A packed string with enum string values at given offsets
 *   enumValue        The enum value is used as the offset to calculate the return string
 * Returns:           The string representation of the enum value
 * ----------------------------------------------------------------------------
 */
char *c5033972_toStringEnum(char *enumStringList, int enumValue);

#endif /* ORG_DEVOPSBROKER_LANG_ENUM_H */
