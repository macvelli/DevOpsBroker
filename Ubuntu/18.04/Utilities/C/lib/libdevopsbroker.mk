#
# libdevopsbroker.mk - DevOpsBroker makefile for generating the libdevopsbroker.a static library
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
# Developed on Ubuntu 18.04.1 LTS running kernel.osrelease = 4.15.0-39
#
# NOTE: Deterministic archives do not store file timestamps, so the /usr/bin/ar
# 'u' option to only replace newer files cannot work
# -----------------------------------------------------------------------------
#

################################### Includes ##################################

include /etc/devops/globals.mk

################################## Variables ##################################

LIB_NAME := libdevopsbroker.a
LIB_OBJ := $(shell /usr/bin/find obj/org/devopsbroker -type f -name "*.o")

################################### Targets ###################################

.PHONY: default clean printenv

default: lib/$(LIB_NAME)

lib/$(LIB_NAME): $(LIB_OBJ)
	$(call printInfo,Building $(LIB_NAME) static library)
	/bin/rm -f lib/$(LIB_NAME)
	/usr/bin/ar cr lib/$(LIB_NAME) $(LIB_OBJ)
	/usr/bin/ranlib lib/$(LIB_NAME)

clean:
	$(call printInfo,Cleaning $(LIB_NAME) static library)
	/bin/rm -f lib/$(LIB_NAME)

printenv:
	@echo "MAKEFILE_LIST: $(MAKEFILE_LIST)"
	@echo "       TMPDIR: $(TMPDIR)"
	@echo "       CURDIR: $(CURDIR)"
	@echo "     LIB_NAME: $(LIB_NAME)"
	@echo
