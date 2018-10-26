/*
 * units.h - DevOpsBroker C header file for common size-related constants
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
 * echo ORG_DEVOPSBROKER_LANG_UNITS | md5sum | cut -c 25-32
 * -----------------------------------------------------------------------------
 */

#ifndef ORG_DEVOPSBROKER_LANG_UNITS_H
#define ORG_DEVOPSBROKER_LANG_UNITS_H

// ═════════════════════════════════ Includes ═════════════════════════════════


// ═══════════════════════════════ Preprocessor ═══════════════════════════════

#define UNITS_KHz 1000U
#define UNITS_MHz 1000000U
#define UNITS_GHz 1000000000U

#define UNITS_KB 1000U
#define UNITS_MB 1000000U
#define UNITS_GB 1000000000U
#define UNITS_TB 1000000000000UL

#define UNITS_KiB 1024U
#define UNITS_MiB 1048576U
#define UNITS_GiB 1073741824U
#define UNITS_TiB 1099511627776UL

// ═════════════════════════════════ Typedefs ═════════════════════════════════


// ════════════════════════════════ Structures ════════════════════════════════


// ═════════════════════════════ Global Variables ═════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════


#endif /* ORG_DEVOPSBROKER_LANG_UNITS_H */
