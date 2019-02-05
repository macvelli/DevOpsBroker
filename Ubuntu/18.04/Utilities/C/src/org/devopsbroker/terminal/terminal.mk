#
# terminal.mk - DevOpsBroker makefile for compiling the org.devopsbroker.terminal package
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
# Developed on Ubuntu 16.04.5 LTS running kernel.osrelease = 4.15.0-34
#
# -----------------------------------------------------------------------------
#

################################### Includes ##################################

include /etc/devops/globals.mk

################################## Variables ##################################

ifndef ASM
	ASM := /usr/bin/nasm
	ASMFLAGS := -felf64 -gdwarf

	CC := /usr/bin/gcc
	CFLAGS := -Wall -gdwarf -m64 -fdiagnostics-color=always

	BASEDIR := $(shell /usr/bin/realpath $(CURDIR)/../../../..)
else
	BASEDIR := $(CURDIR)
endif

SRC_DIR := $(BASEDIR)/src/org/devopsbroker/terminal
OBJ_DIR := $(BASEDIR)/obj/org/devopsbroker/terminal

C_SOURCES := $(wildcard $(SRC_DIR)/*.c)
C_OBJECTS := $(subst /src/,/obj/,$(C_SOURCES:.c=.o))

ASM_SOURCES := $(wildcard $(SRC_DIR)/*.asm)
ASM_OBJECTS := $(subst /src/,/obj/,$(ASM_SOURCES:.asm=.o))

################################### Targets ###################################

.ONESHELL:
.PHONY: default all clean prepare printenv

default: all

all:	$(C_OBJECTS) $(ASM_OBJECTS)

clean:
	$(call printInfo,Cleaning $(OBJ_DIR) directory)
	/bin/rm -rf $(OBJ_DIR)

prepare:
	/bin/mkdir -p --mode=750 $(OBJ_DIR)

# Obtain object files for the C utilities
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c $(SRC_DIR)/%.h | prepare
	$(call printInfo,Compiling $(@F))
	$(CC) $(CFLAGS) -c $< -o $@

# Obtain object files for the ASM libraries
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.asm | prepare
	$(call printInfo,Compiling $(@F))
	$(ASM) $(ASMFLAGS) $< -o $@

printenv:
	echo "  MAKEFILE_LIST: $(MAKEFILE_LIST)"
	echo "         TMPDIR: $(TMPDIR)"
	echo "        BASEDIR: $(BASEDIR)"
	echo "         CURDIR: $(CURDIR)"
	echo "            ASM: $(ASM)"
	echo "       ASMFLAGS: $(ASMFLAGS)"
	echo "             CC: $(CC)"
	echo "         CFLAGS: $(CFLAGS)"
	echo "        SRC_DIR: $(SRC_DIR)"
	echo "        OBJ_DIR: $(OBJ_DIR)"
	echo
