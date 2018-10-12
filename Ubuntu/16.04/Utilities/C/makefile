#
# makefile - DevOpsBroker configuration for the GNU make utility
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
# Developed on Ubuntu 16.04.4 LTS running kernel.osrelease = 4.13.0-43
#
# -----------------------------------------------------------------------------
#

################################### Includes ##################################

include /etc/devops/globals.mk

################################## Variables ##################################

CC := /usr/bin/gcc
CFLAGS := -Wall -g -m64 -fdiagnostics-color=always
LDFLAGS := -m64

LIB_DIR := src/org/devopsbroker
OBJ_DIR := obj/org/devopsbroker

LIB_SRC := $(wildcard $(LIB_DIR)/adt/*.c) \
	   $(wildcard $(LIB_DIR)/io/*.c) \
	   $(wildcard $(LIB_DIR)/lang/*.c) \
	   $(wildcard $(LIB_DIR)/sysfs/*.c) \
	   $(wildcard $(LIB_DIR)/terminal/*.c) \
	   $(wildcard $(LIB_DIR)/text/*.c)

LIB_OBJ := $(subst src/,obj/,$(LIB_SRC:.c=.o))

INC :=	-I$(LIB_DIR)/adt -I$(LIB_DIR)/firelog -I$(LIB_DIR)/io -I$(LIB_DIR)/lang \
	-I$(LIB_DIR)/sysfs -I$(LIB_DIR)/terminal -I$(LIB_DIR)/text

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Exports ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

export CC
export CFLAGS

################################### Targets ###################################

.ONESHELL:
.PHONY: default all clean install lib-adt lib-firelog lib-io lib-lang lib-sysfs lib-terminal lib-text library ls

default: all

all: between firelog scriptinfo verifyclass verifyip

clean:
	/bin/rm -f between obj/between.o
	/bin/rm -f firelog obj/firelog.o
	/bin/rm -f schedtuner obj/schedtuner.o
	/bin/rm -f scriptinfo obj/scriptinfo.o
	/bin/rm -f verifyclass obj/verifyclass.o
	/bin/rm -f verifyip obj/verifyip.o
	/bin/rm -f lib/libdevopsbroker.a
	$(MAKE) -f src/org/devopsbroker/adt/adt.mk clean
	$(MAKE) -f src/org/devopsbroker/firelog/firelog.mk clean
	$(MAKE) -f src/org/devopsbroker/io/io.mk clean
	$(MAKE) -f src/org/devopsbroker/lang/lang.mk clean
	$(MAKE) -f src/org/devopsbroker/sysfs/sysfs.mk clean
	$(MAKE) -f src/org/devopsbroker/terminal/terminal.mk clean
	$(MAKE) -f src/org/devopsbroker/text/text.mk clean

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Library ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

lib-adt:
	@umask $(UMASK) && \
	source /etc/devops/ansi.conf && \
	$(MAKE) -f src/org/devopsbroker/adt/adt.mk $(filter-out $@ library,$(MAKECMDGOALS))

lib-firelog:
	@umask $(UMASK) && \
	source /etc/devops/ansi.conf && \
	$(MAKE) -f src/org/devopsbroker/firelog/firelog.mk $(filter-out $@ firelog,$(MAKECMDGOALS))

lib-io:
	@umask $(UMASK) && \
	source /etc/devops/ansi.conf && \
	$(MAKE) -f src/org/devopsbroker/io/io.mk $(filter-out $@ library,$(MAKECMDGOALS))

lib-lang:
	@umask $(UMASK) && \
	source /etc/devops/ansi.conf && \
	$(MAKE) -f src/org/devopsbroker/lang/lang.mk $(filter-out $@ library,$(MAKECMDGOALS))

lib-sysfs:
	@umask $(UMASK) && \
	source /etc/devops/ansi.conf && \
	$(MAKE) -f src/org/devopsbroker/sysfs/sysfs.mk $(filter-out $@ library,$(MAKECMDGOALS))

lib-terminal:
	@umask $(UMASK) && \
	source /etc/devops/ansi.conf && \
	$(MAKE) -f src/org/devopsbroker/terminal/terminal.mk $(filter-out $@ library,$(MAKECMDGOALS))

lib-text:
	@umask $(UMASK) && \
	source /etc/devops/ansi.conf && \
	$(MAKE) -f src/org/devopsbroker/text/text.mk $(filter-out $@ library,$(MAKECMDGOALS))

# Deterministic archives do not store file timestamps, so the 'u' option to only replace newer files cannot work
lib/libdevopsbroker.a: | lib-adt lib-io lib-lang lib-sysfs lib-terminal lib-text
	$(call printInfo,Building library $(@F))
	/usr/bin/ar cr lib/libdevopsbroker.a $(LIB_OBJ)
	/usr/bin/ranlib lib/libdevopsbroker.a

library: lib/libdevopsbroker.a

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Utilities ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

obj/between.o: src/between.c
	$(call printInfo,Compiling $(@F))
	$(CC) $(CFLAGS) -c src/between.c -o obj/between.o

# Have to put the library AFTER obj/between.o else the linker blows chunks
between: obj/between.o
	$(call printInfo,Creating $(@) executable)
	$(CC) $(LDFLAGS) obj/between.o lib/libdevopsbroker.a -o between
	$(call printInfo,Testing $(@) executable)
	test/testBetween.sh

obj/firelog.o: src/firelog.c
	$(call printInfo,Compiling $(@F))
	$(CC) $(CFLAGS) -c src/firelog.c -o obj/firelog.o

# Have to put the library AFTER obj/firelog.o else the linker blows chunks
firelog: obj/firelog.o | lib-firelog
	$(call printInfo,Creating $(@) executable)
	$(CC) $(LDFLAGS) $(INC) obj/firelog.o $(OBJ_DIR)/firelog/logline.o lib/libdevopsbroker.a -o firelog

obj/schedtuner.o: src/schedtuner.c
	$(call printInfo,Compiling $(@F))
	$(CC) $(CFLAGS) -c src/schedtuner.c -o obj/schedtuner.o

# Have to put the library AFTER obj/schedtuner.o else the linker blows chunks
schedtuner: obj/schedtuner.o
	$(call printInfo,Creating $(@) executable)
	$(CC) $(LDFLAGS) $(INC) obj/schedtuner.o lib/libdevopsbroker.a -o schedtuner

obj/scriptinfo.o: src/scriptinfo.c
	$(call printInfo,Compiling $(@F))
	$(CC) $(CFLAGS) -c src/scriptinfo.c -o obj/scriptinfo.o

scriptinfo: obj/scriptinfo.o
	$(call printInfo,Creating $(@) executable)
	$(CC) $(LDFLAGS) obj/scriptinfo.o lib/libdevopsbroker.a -o scriptinfo

obj/verifyclass.o: src/verifyclass.c
	$(call printInfo,Compiling $(@F))
	$(CC) $(CFLAGS) -c src/verifyclass.c -o obj/verifyclass.o

verifyclass: obj/verifyclass.o
	$(call printInfo,Creating $(@) executable)
	$(CC) $(LDFLAGS) obj/verifyclass.o -o verifyclass

obj/verifyip.o: src/verifyip.c
	$(call printInfo,Compiling $(@F))
	$(CC) $(CFLAGS) -c src/verifyip.c -o obj/verifyip.o

# Have to put the library AFTER obj/verifyip.o else the linker blows chunks
verifyip: obj/verifyip.o
	$(call printInfo,Creating $(@) executable)
	$(CC) $(LDFLAGS) obj/verifyip.o lib/libdevopsbroker.a -o verifyip
	$(call printInfo,Testing $(@) executable)
	test/testVerifyIP.sh

install: all
	/bin/cp between ../usr/local/bin
	/bin/cp firelog ../usr/local/bin
	/bin/cp scriptinfo ../usr/local/bin
	/bin/cp schedtuner ../usr/local/sbin
	/bin/cp verifyclass ../usr/local/bin
	/bin/cp verifyip ../usr/local/bin

ls:
	echo "Phony Targets:"
	echo "  default"
	echo "  all"
	echo "  clean"
	echo "  install"
	echo "  lib-adt"
	echo "  lib-firelog"
	echo "  lib-io"
	echo "  lib-lang"
	echo "  lib-terminal"
	echo "  lib-text"
	echo "  library"
	echo
	echo "Executable Targets:"
	echo "  between"
	echo "  firelog"
	echo "  scriptinfo"
	echo "  verifyip"
	echo

printenv:
	echo "  MAKEFILE_LIST: $(MAKEFILE_LIST)"
	echo "         TMPDIR: $(TMPDIR)"
	echo "         CURDIR: $(CURDIR)"
	echo "             CC: $(CC)"
	echo "         CFLAGS: $(CFLAGS)"
	echo "        LDFLAGS: $(LDFLAGS)"
	echo "        LIB_DIR: $(LIB_DIR)"
	echo
