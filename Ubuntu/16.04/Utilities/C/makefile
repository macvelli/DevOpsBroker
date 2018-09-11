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

################################## Variables ##################################

CC := /usr/bin/gcc
CFLAGS := -Wall -g

################################### Targets ###################################

.PHONY: clean clean-between clean-firelog clean-scriptinfo clean-verifyip install

default: install

bin/between.o: src/between.c
	$(CC) $(CFLAGS) -c src/between.c -o bin/between.o

between: bin/between.o
	$(CC) bin/between.o -o between
	@echo
	/bin/bash test/testBetween.sh

bin/firelog.o: src/firelog.c
	$(CC) $(CFLAGS) -c src/firelog.c -o bin/firelog.o

firelog: bin/firelog.o
	$(CC) bin/firelog.o -o firelog
	@echo

bin/scriptinfo.o: src/scriptinfo.c
	$(CC) $(CFLAGS) -c src/scriptinfo.c -o bin/scriptinfo.o

scriptinfo: bin/scriptinfo.o
	$(CC) bin/scriptinfo.o -o scriptinfo
	@echo

bin/verifyip.o: src/verifyip.c
	$(CC) $(CFLAGS) -c src/verifyip.c -o bin/verifyip.o

verifyip: bin/verifyip.o
	$(CC) bin/verifyip.o -o verifyip
	@echo
	/bin/bash test/testVerifyIP.sh

clean: clean-between clean-firelog clean-scriptinfo clean-verifyip

clean-between:
	/bin/rm -f between bin/between.o

clean-firelog:
	/bin/rm -f firelog bin/firelog.o

clean-scriptinfo:
	/bin/rm -f scriptinfo bin/scriptinfo.o

clean-verifyip:
	/bin/rm -f verifyip bin/verifyip.o

install: between firelog scriptinfo verifyip
	/bin/cp between ../usr/local/bin
	/bin/cp firelog ../usr/local/bin
	/bin/cp scriptinfo ../usr/local/bin
	/bin/cp verifyip ../usr/local/bin
