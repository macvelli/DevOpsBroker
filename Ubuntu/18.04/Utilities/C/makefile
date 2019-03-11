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
ASMFLAGS := -felf64 -gdwarf

CC := /usr/bin/gcc
CFLAGS := -Wall -gdwarf -m64 -fdiagnostics-color=always
LDFLAGS := -m64

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Exports ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

export ASM
export ASMFLAGS
export CC
export CFLAGS

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Dependencies ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

OBJ_TERMINAL := obj/org/devopsbroker/terminal

NETTUNER_DEPS := $(OBJ_TERMINAL)/commandline.linux.o

################################### Targets ###################################

.ONESHELL:
.PHONY: default all clean library install ls \
	lib-adt lib-firelog lib-info lib-io lib-lang lib-net lib-socket \
	lib-sysfs lib-terminal lib-text lib-time

default: all

all:	bin/between bin/convert-temp bin/derivesubnet bin/firelog bin/nettuner \
	bin/schedtuner bin/scriptinfo bin/verifyclass bin/verifyip

clean:
	/bin/rm -rfv bin/*
	/bin/rm -rfv obj/*
	/bin/rm -fv lib/*.a
	echo

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Library ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

lib-adt:
	@umask $(UMASK) && \
	$(MAKE) -f src/org/devopsbroker/adt/adt.mk $(filter-out $@ install library,$(MAKECMDGOALS))

lib-firelog:
	@umask $(UMASK) && \
	$(MAKE) -f src/org/devopsbroker/firelog/firelog.mk $(filter-out $@ install firelog,$(MAKECMDGOALS))

lib-info:
	@umask $(UMASK) && \
	$(MAKE) -f src/org/devopsbroker/info/info.mk $(filter-out $@ install library,$(MAKECMDGOALS))

lib-io:
	@umask $(UMASK) && \
	$(MAKE) -f src/org/devopsbroker/io/io.mk $(filter-out $@ install library,$(MAKECMDGOALS))

lib-lang:
	@umask $(UMASK) && \
	$(MAKE) -f src/org/devopsbroker/lang/lang.mk $(filter-out $@ install library,$(MAKECMDGOALS))

lib-net:
	@umask $(UMASK) && \
	$(MAKE) -f src/org/devopsbroker/net/net.mk $(filter-out $@ install library,$(MAKECMDGOALS))

lib-socket:
	@umask $(UMASK) && \
	$(MAKE) -f src/org/devopsbroker/socket/socket.mk $(filter-out $@ install library,$(MAKECMDGOALS))

lib-sysfs:
	@umask $(UMASK) && \
	$(MAKE) -f src/org/devopsbroker/sysfs/sysfs.mk $(filter-out $@ install library,$(MAKECMDGOALS))

lib-terminal:
	@umask $(UMASK) && \
	$(MAKE) -f src/org/devopsbroker/terminal/terminal.mk $(filter-out $@ install library,$(MAKECMDGOALS))

lib-text:
	@umask $(UMASK) && \
	$(MAKE) -f src/org/devopsbroker/text/text.mk $(filter-out $@ install library,$(MAKECMDGOALS))

lib-time:
	@umask $(UMASK) && \
	$(MAKE) -f src/org/devopsbroker/time/time.mk $(filter-out $@ install library,$(MAKECMDGOALS))

library: lib-adt lib-info lib-io lib-lang lib-net lib-socket lib-sysfs lib-terminal lib-text lib-time
	@umask $(UMASK) && \
	$(MAKE) -f lib/libdevopsbroker.mk $(filter-out $@ install library,$(MAKECMDGOALS))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Utilities ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Obtain object files for the C utilities
obj/%.o: src/%.c
	$(call printInfo,Compiling $(@F))
	$(CC) $(CFLAGS) -c $< -o $@

# Obtain object files for the ASM libraries
obj/%.o: src/%.asm
	$(call printInfo,Compiling $(@F))
	$(ASM) $(ASMFLAGS) $< -o $@

# Have to put the library at the end else the linker blows chunks
bin/between: obj/between.o
	$(call printInfo,Creating $(@) executable)
	$(CC) $(LDFLAGS) $< lib/libdevopsbroker.a -o $@
	$(call printInfo,Testing $(@) executable)
	test/testBetween.sh

# Have to put the library at the end else the linker blows chunks
bin/convert-temp: obj/convert-temp.o obj/convert-temp.linux.o
	$(call printInfo,Creating $(@) executable)
	$(CC) $(LDFLAGS) $^ lib/libdevopsbroker.a -o $@
	/usr/bin/strip -s $@

# Have to put the library at the end else the linker blows chunks
bin/derivesubnet: obj/derivesubnet.o
	$(call printInfo,Creating $(@) executable)
	$(CC) $(LDFLAGS) $< lib/libdevopsbroker.a -o $@

# Have to put the library at the end else the linker blows chunks
bin/firelog: obj/firelog.o obj/org/devopsbroker/firelog/logline.o | lib-firelog
	$(call printInfo,Creating $(@) executable)
	$(CC) $(LDFLAGS) $^ lib/libdevopsbroker.a -o $@

# Have to put the library at the end else the linker blows chunks
bin/nettuner: obj/nettuner.o $(NETTUNER_DEPS)
	$(call printInfo,Creating $(@) executable)
	$(CC) $(LDFLAGS) $< lib/libdevopsbroker.a -o $@

# Have to put the library at the end else the linker blows chunks
bin/schedtuner: obj/schedtuner.o
	$(call printInfo,Creating $(@) executable)
	$(CC) $(LDFLAGS) $< lib/libdevopsbroker.a -o $@

# Have to put the library at the end else the linker blows chunks
bin/scriptinfo: obj/scriptinfo.o obj/scriptinfo.linux.o
	$(call printInfo,Creating $(@) executable)
	$(CC) $(LDFLAGS) $^ lib/libdevopsbroker.a -o $@
	/usr/bin/strip -s $@

# Have to put the library at the end else the linker blows chunks
bin/verifyclass: obj/verifyclass.o
	$(call printInfo,Creating $(@) executable)
	$(CC) $(LDFLAGS) $< lib/libdevopsbroker.a -o $@

# Have to put the library at the end else the linker blows chunks
bin/verifyip: obj/verifyip.o obj/verifyip.linux.o
	$(call printInfo,Creating $(@) executable)
	$(CC) $(LDFLAGS) $^ lib/libdevopsbroker.a -o $@
	/usr/bin/strip -s $@
	$(call printInfo,Testing $(@) executable)
	test/testVerifyIP.sh

install: all
	/bin/cp -uv bin/between ../usr/local/bin
	/bin/cp -uv bin/convert-temp ../usr/local/bin
	/bin/cp -uv bin/derivesubnet ../usr/local/bin
	/bin/cp -uv bin/firelog ../usr/local/bin
	/bin/cp -uv bin/nettuner ../usr/local/bin
	/bin/cp -uv bin/schedtuner ../usr/local/sbin
	/bin/cp -uv bin/scriptinfo ../usr/local/bin
	/bin/cp -uv bin/verifyclass ../usr/local/bin
	/bin/cp -uv bin/verifyip ../usr/local/bin

ls:
	echo "Phony Targets:"
	echo "  default"
	echo "  all"
	echo "  clean"
	echo "  install"
	echo "  lib-adt"
	echo "  lib-firelog"
	echo "  lib-info"
	echo "  lib-io"
	echo "  lib-lang"
	echo "  lib-net"
	echo "  lib-sysfs"
	echo "  lib-terminal"
	echo "  lib-text"
	echo "  lib-time"
	echo "  library"
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
	echo "         TMPDIR: $(TMPDIR)"
	echo "         CURDIR: $(CURDIR)"
	echo "            ASM: $(ASM)"
	echo "       ASMFLAGS: $(ASMFLAGS)"
	echo "             CC: $(CC)"
	echo "         CFLAGS: $(CFLAGS)"
	echo "        LDFLAGS: $(LDFLAGS)"
	echo
