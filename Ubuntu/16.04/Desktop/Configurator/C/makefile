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


CC=gcc
CFLAGS=-Wall -g
BASH=/bin/bash

all: between firelog verifyip

.PHONY: all clean-all clean-between clean-firelog clean-verifyip

bin/between.o: src/between.c
	$(CC) $(CFLAGS) -c src/between.c -o bin/between.o

between: bin/between.o
	$(CC) bin/between.o -o between
	$(BASH) test/testBetween.sh

bin/firelog.o: src/firelog.c
	$(CC) $(CFLAGS) -c src/firelog.c -o bin/firelog.o

firelog: bin/firelog.o
	$(CC) bin/firelog.o -o firelog

bin/verifyip.o: src/verifyip.c
	$(CC) $(CFLAGS) -c src/verifyip.c -o bin/verifyip.o

verifyip: bin/verifyip.o
	$(CC) bin/verifyip.o -o verifyip
	$(BASH) test/testVerifyIP.sh

clean-all: clean-between clean-firelog clean-verifyip

clean-between:
	rm -f between bin/between.o

clean-firelog:
	rm -f firelog bin/firelog.o

clean-verifyip:
	rm -f verifyip bin/verifyip.o

