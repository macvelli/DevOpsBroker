#
# lang.mk - DevOpsBroker makefile for compiling the org.devopsbroker.lang package
#
# Copyright (C) 2018 Edward Smith <edwardsmith@devopsbroker.org>
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

SRC_DIR := $(CURDIR)/src/org/devopsbroker/lang
OBJ_DIR := $(CURDIR)/obj/org/devopsbroker/lang

################################### Targets ###################################

.ONESHELL:
.PHONY: default all clean prepare printenv

default: all

all: $(OBJ_DIR)/integer.o $(OBJ_DIR)/long.o $(OBJ_DIR)/stringbuilder.o $(OBJ_DIR)/string.o $(OBJ_DIR)/system.o

clean:
	$(call printInfo,Cleaning $(OBJ_DIR) directory)
	/bin/rm -rf $(OBJ_DIR)

prepare:
	/bin/mkdir -p --mode=750 $(OBJ_DIR)

# For some reason I have to put "| prepare" else this target is rebuilt all the time
$(OBJ_DIR)/integer.o: $(SRC_DIR)/integer.c $(SRC_DIR)/integer.h $(SRC_DIR)/string.h $(SRC_DIR)/system.h | prepare
	$(call printInfo,Compiling $(@F))
	$(CC) $(CFLAGS) -c $(SRC_DIR)/integer.c -o $(OBJ_DIR)/integer.o

# For some reason I have to put "| prepare" else this target is rebuilt all the time
$(OBJ_DIR)/long.o: $(SRC_DIR)/long.c $(SRC_DIR)/long.h $(SRC_DIR)/string.h $(SRC_DIR)/system.h | prepare
	$(call printInfo,Compiling $(@F))
	$(CC) $(CFLAGS) -c $(SRC_DIR)/long.c -o $(OBJ_DIR)/long.o

# For some reason I have to put "| prepare" else this target is rebuilt all the time
$(OBJ_DIR)/string.o: $(SRC_DIR)/string.c $(SRC_DIR)/string.h $(SRC_DIR)/stringbuilder.h $(SRC_DIR)/system.h | prepare
	$(call printInfo,Compiling $(@F))
	$(CC) $(CFLAGS) -c $(SRC_DIR)/string.c -o $(OBJ_DIR)/string.o

# For some reason I have to put "| prepare" else this target is rebuilt all the time
$(OBJ_DIR)/stringbuilder.o: $(SRC_DIR)/stringbuilder.c $(SRC_DIR)/stringbuilder.h $(SRC_DIR)/long.h $(SRC_DIR)/system.h | prepare
	$(call printInfo,Compiling $(@F))
	$(CC) $(CFLAGS) -c $(SRC_DIR)/stringbuilder.c -o $(OBJ_DIR)/stringbuilder.o

# For some reason I have to put "| prepare" else this target is rebuilt all the time
$(OBJ_DIR)/system.o: $(SRC_DIR)/system.c $(SRC_DIR)/system.h $(SRC_DIR)/error.h $(SRC_DIR)/stringbuilder.h | prepare
	$(call printInfo,Compiling $(@F))
	$(CC) $(CFLAGS) -c $(SRC_DIR)/system.c -o $(OBJ_DIR)/system.o

printenv:
	echo "  MAKEFILE_LIST: $(MAKEFILE_LIST)"
	echo "         TMPDIR: $(TMPDIR)"
	echo "         CURDIR: $(CURDIR)"
	echo "             CC: $(CC)"
	echo "         CFLAGS: $(CFLAGS)"
	echo "        SRC_DIR: $(SRC_DIR)"
	echo "        OBJ_DIR: $(OBJ_DIR)"
	echo
