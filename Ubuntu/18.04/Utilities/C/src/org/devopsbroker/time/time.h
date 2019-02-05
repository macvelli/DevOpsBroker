/*
 * time.h - DevOpsBroker C header file for the org.devopsbroker.time.Time struct
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
 * Developed on Ubuntu 18.04.1 LTS running kernel.osrelease = 4.15.0-44
 *
 * echo ORG_DEVOPSBROKER_TIME_TIME | md5sum | cut -c 25-32
 * -----------------------------------------------------------------------------
 */

#ifndef ORG_DEVOPSBROKER_TIME_TIME_H
#define ORG_DEVOPSBROKER_TIME_TIME_H

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <stdbool.h>

#include <assert.h>
#include <time.h>

// ═══════════════════════════════ Preprocessor ═══════════════════════════════


// ═════════════════════════════════ Typedefs ═════════════════════════════════

// Can't do this because time.h already declares a method called time()
//typedef time_t time;

// Can't remap struct tm to have better variable names because Linux has hidden extensions to the standard
typedef struct tm Time;   // Broken-down time struct
/*	int tm_sec;       // Seconds (0-60)
	int tm_min;       // Minutes (0-59)
	int tm_hour;      // Hours (0-23)
	int tm_mday;      // Day of the month (1-31)
	int tm_mon;       // Year - 1900
	int tm_year;      // Month (0-11)
	int tm_wday;      // Day of the week (0-6, Sunday = 0)
	int tm_yday;      // Day in the year (0-365, 1 Jan = 0)
	int tm_isdst;     // Is Daylight Saving Time
	// Extensions on Linux
	long tm_gmtoff;   // Seconds east of UTC
	char *tm_zone;    // Timezone abbreviation
*/

static_assert(sizeof(Time) == 56, "Check your assumptions");

// ═════════════════════════════ Global Variables ═════════════════════════════


// ═══════════════════════════ Function Declarations ══════════════════════════

// ~~~~~~~~~~~~~~~~~~~~~~~~~ Initialization Functions ~~~~~~~~~~~~~~~~~~~~~~~~~

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    a66923ff_initTime
 * Description: Initializes an existing Time struct to the supplied number of
 *              seconds since the Epoch
 *
 * Parameters:
 *   time       A pointer to the Time instance to initalize
 *   seconds	The number of seconds since the Epoch
 * ----------------------------------------------------------------------------
 */
void a66923ff_initTime(Time *time, time_t seconds);

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Utility Functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    a66923ff_getTime
 * Description: Returns the number of seconds since the Epoch,
 *              1970-01-01 00:00:00 +0000 (UTC)
 *
 * Returns:     The number of seconds since the Epoch
 * ----------------------------------------------------------------------------
 */
time_t a66923ff_getTime();

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    a66923ff_getYear
 * Description: Returns the full year value by adding back 1900
 *
 * Returns:     The full year value
 * ----------------------------------------------------------------------------
 */
int a66923ff_getYear(Time *time);

#endif /* ORG_DEVOPSBROKER_TIME_TIME_H */
