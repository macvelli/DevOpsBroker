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

ASM := /usr/bin/nasm
ASMFLAGS := -felf64 -gdwarf

CC := /usr/bin/gcc
CFLAGS := -Wall -gdwarf -m64 -fdiagnostics-color=always
LDFLAGS := -m64

LIB_DIR := src/org/devopsbroker
OBJ_DIR := obj/org/devopsbroker

INC :=	-I$(LIB_DIR)/adt -I$(LIB_DIR)/firelog -I$(LIB_DIR)/io -I$(LIB_DIR)/lang \
	-I$(LIB_DIR)/net -I$(LIB_DIR)/sysfs -I$(LIB_DIR)/terminal -I$(LIB_DIR)/text

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Exports ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

export ASM
export ASMFLAGS
export CC
export CFLAGS

################################### Targets ###################################

.ONESHELL:
.PHONY: default all clean install lib-adt lib-firelog lib-io lib-lang lib-net \
	lib-sysfs lib-terminal lib-text library ls

default: all

all: between firelog schedtuner scriptinfo verifyclass verifyip

clean:
	/bin/rm -f between obj/between.o
	/bin/rm -f firelog obj/firelog.o
	/bin/rm -f schedtuner obj/schedtuner.o
	/bin/rm -f scriptinfo obj/scriptinfo.o
	/bin/rm -f verifyclass obj/verifyclass.o
	/bin/rm -f verifyip obj/verifyip.o
	$(MAKE) -f lib/libdevopsbroker.mk clean
	$(MAKE) -f src/org/devopsbroker/adt/adt.mk clean
	$(MAKE) -f src/org/devopsbroker/firelog/firelog.mk clean
	$(MAKE) -f src/org/devopsbroker/io/io.mk clean
	$(MAKE) -f src/org/devopsbroker/lang/lang.mk clean
	$(MAKE) -f src/org/devopsbroker/net/net.mk clean
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
	$(MAKE) -f src/org/devopsbroker/firelog/firelog.mk $(filter-out $@ install firelog,$(MAKECMDGOALS))

lib-io:
	@umask $(UMASK) && \
	source /etc/devops/ansi.conf && \
	$(MAKE) -f src/org/devopsbroker/io/io.mk $(filter-out $@ library,$(MAKECMDGOALS))

lib-lang:
	@umask $(UMASK) && \
	source /etc/devops/ansi.conf && \
	$(MAKE) -f src/org/devopsbroker/lang/lang.mk $(filter-out $@ library,$(MAKECMDGOALS))

lib-net:
	@umask $(UMASK) && \
	source /etc/devops/ansi.conf && \
	$(MAKE) -f src/org/devopsbroker/net/net.mk $(filter-out $@ library,$(MAKECMDGOALS))

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

library: lib-adt lib-io lib-lang lib-net lib-sysfs lib-terminal lib-text
	@umask $(UMASK) && \
	source /etc/devops/ansi.conf && \
	$(MAKE) -f lib/libdevopsbroker.mk $(filter-out $@ library,$(MAKECMDGOALS))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Utilities ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Obtain object files for the C utilities
obj/%.o: src/%.c
	$(call printInfo,Compiling $(@F))
	$(CC) $(CFLAGS) -c $< -o $@

obj/%.o: src/%.asm
	$(call printInfo,Compiling $(@F))
	$(ASM) $(ASMFLAGS) $< -o $@

# Have to put the library at the end else the linker blows chunks
between: obj/between.o
	$(call printInfo,Creating $(@) executable)
	$(CC) $(LDFLAGS) $< lib/libdevopsbroker.a -o $@
	$(call printInfo,Testing $(@) executable)
	test/testBetween.sh

# Have to put the library at the end else the linker blows chunks
convert-temp: obj/convert-temp.o obj/convert-temp.linux.o
	$(call printInfo,Creating $(@) executable)
	$(CC) $(LDFLAGS) $^ lib/libdevopsbroker.a -o $@
	/usr/bin/strip -s $@

# Have to put the library at the end else the linker blows chunks
derivesubnet: obj/derivesubnet.o
	$(call printInfo,Creating $(@) executable)
	$(CC) $(LDFLAGS) $< lib/libdevopsbroker.a -o $@

# Have to put the library at the end else the linker blows chunks
firelog: obj/firelog.o | lib-firelog
	$(call printInfo,Creating $(@) executable)
	$(CC) $(LDFLAGS) $< $(OBJ_DIR)/firelog/logline.o lib/libdevopsbroker.a -o $@

# Have to put the library at the end else the linker blows chunks
schedtuner: obj/schedtuner.o
	$(call printInfo,Creating $(@) executable)
	$(CC) $(LDFLAGS) $< lib/libdevopsbroker.a -o $@

# Have to put the library at the end else the linker blows chunks
scriptinfo: obj/scriptinfo.o
	$(call printInfo,Creating $(@) executable)
	$(CC) $(LDFLAGS) $< lib/libdevopsbroker.a -o $@

# Have to put the library at the end else the linker blows chunks
verifyclass: obj/verifyclass.o
	$(call printInfo,Creating $(@) executable)
	$(CC) $(LDFLAGS) $< -o $@

# Have to put the library at the end else the linker blows chunks
verifyip: obj/verifyip.o
	$(call printInfo,Creating $(@) executable)
	$(CC) $(LDFLAGS) $< lib/libdevopsbroker.a -o $@
	$(call printInfo,Testing $(@) executable)
	test/testVerifyIP.sh

install: all
	/bin/cp between ../usr/local/bin
	/bin/cp convert-temp ../usr/local/bin
	/bin/cp firelog ../usr/local/bin
	/bin/cp schedtuner ../usr/local/sbin
	/bin/cp scriptinfo ../usr/local/bin
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
	echo "  lib-net"
	echo "  lib-sysfs"
	echo "  lib-terminal"
	echo "  lib-text"
	echo "  library"
	echo
	echo "Executable Targets:"
	echo "  between"
	echo "  convert-temp"
	echo "  firelog"
	echo "  schedtuner"
	echo "  scriptinfo"
	echo "  verifyclass"
	echo "  verifyip"
	echo

printenv:
	echo "  MAKEFILE_LIST: $(MAKEFILE_LIST)"
	echo "         TMPDIR: $(TMPDIR)"
	echo "         CURDIR: $(CURDIR)"
	echo "             CC: $(CC)"
	echo "         CFLAGS: $(CFLAGS)"
	echo "        LDFLAGS: $(LDFLAGS)"
	echo "            INC: $(INC)"
	echo
