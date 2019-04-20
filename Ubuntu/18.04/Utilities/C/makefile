#
# makefile - DevOpsBroker configuration for the GNU make utility
#
# Copyright (C) 2018-2019 Edward Smith <edwardsmith@devopsbroker.org>
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program.  If not, see <http://www.gnu.org/licenses/>.
#
# -----------------------------------------------------------------------------
# Developed on Ubuntu 16.04.4 LTS running kernel.osrelease = 4.13.0-43
#
# -----------------------------------------------------------------------------
#

################################### Includes ##################################

include /etc/devops/globals.mk

################################## Variables ##################################

ASM := /usr/bin/nasm
CC := /usr/bin/gcc
LDFLAGS := -m64

ifeq ($(DEBUG), 1)
    ASMFLAGS := -felf64 -gdwarf
    CFLAGS := -Wall -gdwarf -m64 -Og -fdiagnostics-color=always -DDEBUG
else
    ASMFLAGS := -felf64
    CFLAGS := -Wall -m64 -O2 -fdiagnostics-color=always -DNDEBUG
endif

BIN_DIR := bin
SRC_DIR := src
OBJ_DIR := obj

C_SOURCES := $(shell /bin/ls $(SRC_DIR)/*.c)
C_BINARIES := $(subst src/,bin/,$(C_SOURCES:.c=))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Exports ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

export ASM
export ASMFLAGS
export CC
export CFLAGS

################################### Targets ###################################

.ONESHELL:
.PHONY: default clean install library ls

default: $(C_BINARIES)

clean:
	$(call printInfo,Cleaning $(OBJ_DIR) directory)
	/bin/rm -fv $(OBJ_DIR)/*

	/bin/rm -rfv bin/*
	/bin/rm -fv lib/*.a
	echo

prepare:
	/bin/mkdir -p --mode=750 $(OBJ_DIRS)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Library ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

library:
	@umask $(UMASK) && $(MAKE) -f libdevopsbroker.mk default

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Utilities ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Obtain object files for the C utilities
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	$(call printInfo,Compiling $(@F))
	$(CC) $(CFLAGS) -c $< -o $@

# Obtain object files for the ASM libraries
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.asm
	$(call printInfo,Compiling $(@F))
	$(ASM) $(ASMFLAGS) $< -o $@

# Have to put the library at the end else the linker blows chunks
bin/between: obj/between.o lib/libdevopsbroker.a
	$(call printInfo,Creating $(@) executable)
	$(CC) $(LDFLAGS) $^ -o $@
	$(call printInfo,Testing $(@) executable)
	test/testBetween.sh

# Have to put the library at the end else the linker blows chunks
bin/convert-temp: obj/convert-temp.o obj/convert-temp.linux.o lib/libdevopsbroker.a
	$(call printInfo,Creating $(@) executable)
	$(CC) $(LDFLAGS) $^ -o $@
	/usr/bin/strip -s $@

# Have to put the library at the end else the linker blows chunks
bin/derivesubnet: obj/derivesubnet.o lib/libdevopsbroker.a
	$(call printInfo,Creating $(@) executable)
	$(CC) $(LDFLAGS) $^ -o $@

# Have to put the library at the end else the linker blows chunks
bin/firechain: obj/firechain.o lib/libdevopsbroker.a
	$(call printInfo,Creating $(@) executable)
	$(CC) $(LDFLAGS) $^ -o $@

# Have to put the library at the end else the linker blows chunks
bin/firelog: obj/firelog.o lib/libdevopsbroker.a
	$(call printInfo,Creating $(@) executable)
	$(CC) $(LDFLAGS) $^ -o $@

# Have to put the library at the end else the linker blows chunks
bin/nettuner: obj/nettuner.o lib/libdevopsbroker.a
	$(call printInfo,Creating $(@) executable)
	$(CC) $(LDFLAGS) $^ -o $@

# Have to put the library at the end else the linker blows chunks
bin/schedtuner: obj/schedtuner.o lib/libdevopsbroker.a
	$(call printInfo,Creating $(@) executable)
	$(CC) $(LDFLAGS) $^ -o $@

# Have to put the library at the end else the linker blows chunks
bin/scriptinfo: obj/scriptinfo.o obj/scriptinfo.linux.o lib/libdevopsbroker.a
	$(call printInfo,Creating $(@) executable)
	$(CC) $(LDFLAGS) $^ -o $@
	/usr/bin/strip -s $@

# Have to put the library at the end else the linker blows chunks
bin/trim: obj/trim.o lib/libdevopsbroker.a
	$(call printInfo,Creating $(@) executable)
	$(CC) $(LDFLAGS) $^ -o $@

# Have to put the library at the end else the linker blows chunks
bin/verifyclass: obj/verifyclass.o lib/libdevopsbroker.a
	$(call printInfo,Creating $(@) executable)
	$(CC) $(LDFLAGS) $^ -o $@

# Have to put the library at the end else the linker blows chunks
bin/verifyip: obj/verifyip.o obj/verifyip.linux.o lib/libdevopsbroker.a
	$(call printInfo,Creating $(@) executable)
	$(CC) $(LDFLAGS) $^ -o $@
	/usr/bin/strip -s $@
	$(call printInfo,Testing $(@) executable)
	test/testVerifyIP.sh

install: all
	/bin/cp -uv bin/between ../usr/local/bin
	/bin/cp -uv bin/convert-temp ../usr/local/bin
	/bin/cp -uv bin/derivesubnet ../usr/local/bin
	/bin/cp -uv bin/firechain ../usr/local/sbin
	/bin/cp -uv bin/firelog ../usr/local/bin
	/bin/cp -uv bin/nettuner ../usr/local/bin
	/bin/cp -uv bin/schedtuner ../usr/local/sbin
	/bin/cp -uv bin/scriptinfo ../usr/local/bin
	/bin/cp -uv bin/verifyclass ../usr/local/bin
	/bin/cp -uv bin/verifyip ../usr/local/bin

ls:
	echo "Phony Targets:"
	echo "  default"
	echo "  clean"
	echo "  install"
	echo "  library"
	echo "  ls"
	echo
	echo "Executable Targets:"
	echo "  between"
	echo "  convert-temp"
	echo "  derivesubnet"
	echo "  firelog"
	echo "  nettuner"
	echo "  schedtuner"
	echo "  scriptinfo"
	echo "  verifyclass"
	echo "  verifyip"
	echo

printenv:
	echo "  MAKEFILE_LIST: $(MAKEFILE_LIST)"
	echo "   MAKECMDGOALS: $(MAKECMDGOALS)"
	echo "          DEBUG: $(DEBUG)"
	echo "         TMPDIR: $(TMPDIR)"
	echo "         CURDIR: $(CURDIR)"
	echo "            ASM: $(ASM)"
	echo "       ASMFLAGS: $(ASMFLAGS)"
	echo "             CC: $(CC)"
	echo "         CFLAGS: $(CFLAGS)"
	echo "        LDFLAGS: $(LDFLAGS)"
	echo "     C_BINARIES: $(C_BINARIES)"
	echo
