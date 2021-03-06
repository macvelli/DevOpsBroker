/*
 * file.h - DevOpsBroker C header file for providing file-handling functionality
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
 * Developed on Ubuntu 16.04.5 LTS running kernel.osrelease = 4.15.0-34
 *
 * echo ORG_DEVOPSBROKER_IO_FILE | md5sum | cut -c 25-32
 * -----------------------------------------------------------------------------
 */

#ifndef ORG_DEVOPSBROKER_IO_FILE_H
#define ORG_DEVOPSBROKER_IO_FILE_H

// ═════════════════════════════════ Includes ═════════════════════════════════

#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>

// ═══════════════════════════════ Preprocessor ═══════════════════════════════

#define END_OF_FILE 0
#define START_OF_HEADING 1

#define LOGICAL_BLOCK_SIZE 512
#define PHYSICAL_BLOCK_SIZE 4096

// ═════════════════════════════════ Typedefs ═════════════════════════════════

// sys/stat.h
typedef struct stat FileStatus;

// ═══════════════════════════ Function Declarations ══════════════════════════

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    e2f74138_openFile
 * Description: Opens the file using the specified pathName and flags
 *
 * Parameters:
 *   pathName       The name of the file to open
 *   flags          Specifies the file access mode, creation mode, and file status
 * Returns:         The opened file descriptor
 * ----------------------------------------------------------------------------
 */
int e2f74138_openFile(const char *pathName, const int flags);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    e2f74138_closeFile
 * Description: Closes the file referenced by the file descriptor
 *
 * Parameters:
 *   fd             The file descriptor
 *   pathName       The name of the file to close (used for error handling)
 * ----------------------------------------------------------------------------
 */
void e2f74138_closeFile(const int fd, const char *pathName);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    e2f74138_getFileStatus
 * Description: Populates the FileStatus struct with information about the file
 *
 * Parameters:
 *   pathName       The name of the file to get the file status on
 *   fileStatus     The FileStatus struct to populate
 * ----------------------------------------------------------------------------
 */
void e2f74138_getFileStatus(const char *pathName, FileStatus* fileStatus);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    e2f74138_getLinkStatus
 * Description: Populates the FileStatus struct with information about either a
 *              file or a symbolic link to a file
 *
 * Parameters:
 *   pathName       The name of the file or symbolic link to get status on
 *   fileStatus     The FileStatus struct to populate
 * ----------------------------------------------------------------------------
 */
void e2f74138_getLinkStatus(const char *pathName, FileStatus* fileStatus);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    e2f74138_readFile
 * Description: Reads up to count bytes from the file descriptor into the buffer
 *
 * Parameters:
 *   fd             The file descriptor of the file to read
 *   buffer         The buffer to read into
 *   count          The maximum number of bytes to read
 *   pathName       The name of the file to read (used for error handling)
 * Returns:         The actual number of bytes read
 * ----------------------------------------------------------------------------
 */
ssize_t e2f74138_readFile(const int fd, void *buffer, size_t count, const char *pathName);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    e2f74138_readlink
 * Description: Reads the value of a symbolic link
 *
 * Parameters:
 *   pathName       The path name of the symbolic link
 *   fileSize       The size of the symbolic link
 * Returns:         The real path name of the file referenced by the symbolic link
 * ----------------------------------------------------------------------------
 */
char *e2f74138_readlink(const char *pathName, const ssize_t fileSize);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    e2f74138_read_uint64
 * Description: Returns the unsigned long int value in the specified file
 *
 * Parameters:
 *   pathName       The path name of the file
 * Returns:         The unsigned long int value contained within the file
 * ----------------------------------------------------------------------------
 */
uint64_t e2f74138_read_uint64(const char *pathName);

/* ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 * Function:    e2f74138_realpath
 * Description: Returns the canonicalized absolute pathname
 *
 * Parameters:
 *   pathName       The path name of the file to evaluate
 * Returns:         The canonicalized absolute pathname
 * ----------------------------------------------------------------------------
 */
char *e2f74138_realpath(const char *pathName);

#endif /* ORG_DEVOPSBROKER_IO_FILE_H */
