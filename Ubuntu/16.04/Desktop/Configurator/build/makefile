#
# makefile - DevOpsBroker makefile for Ubuntu 16.04 Desktop Configurator
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
# Developed on Ubuntu 16.04.5 LTS running kernel.osrelease = 4.15.0-33
#
# -----------------------------------------------------------------------------
#

################################## Variables ##################################

TMPDIR ?= /tmp
VERSION := 1.0.0
ARCH := amd64
PKG_NAME := desktop-config-xenial-$(VERSION)_$(ARCH)

BUILD_DIR := $(TMPDIR)/$(PKG_NAME)
APPLICATION_DIR = $(realpath $(CURDIR)/..)
UTILITIES_DIR = $(realpath $(CURDIR)/../../../Utilities)
RELEASE_DIR := $(CURDIR)

################################### Targets ###################################

.PHONY: default clean build package printenv

default: package

clean:
	/bin/rm -rf $(BUILD_DIR)
	/bin/rm -f $(TMPDIR)/$(PKG_NAME).tar.xz
	/bin/rm -f $(RELEASE_DIR)/$(PKG_NAME).tar.xz
	/bin/rm -f $(RELEASE_DIR)/SHA256SUM
	/bin/rm -f $(RELEASE_DIR)/fileinfo.html

build: clean
	/bin/mkdir -p --mode=0755 $(BUILD_DIR)
	/usr/bin/make TMPDIR=$(TMPDIR) --directory=$(UTILITIES_DIR)/C clean install

	/bin/cp -v $(APPLICATION_DIR)/configure-desktop.sh $(BUILD_DIR)
	/bin/cp -v $(APPLICATION_DIR)/device-drivers.sh $(BUILD_DIR)
	/bin/cp -v $(APPLICATION_DIR)/install.sh $(BUILD_DIR)
	/bin/cp -v $(APPLICATION_DIR)/ttf-msclearfonts.sh $(BUILD_DIR)
	/bin/cp -v $(APPLICATION_DIR)/update-utils.sh $(BUILD_DIR)

	/bin/mkdir -p --mode=0755 $(BUILD_DIR)/archives
	/bin/cp -v $(APPLICATION_DIR)/archives/tidy-5.6.0-64bit.deb $(BUILD_DIR)/archives

	/bin/cp -vr $(APPLICATION_DIR)/doc $(BUILD_DIR)
	/bin/cp -vr $(APPLICATION_DIR)/etc $(BUILD_DIR)
	/bin/cp -vr $(APPLICATION_DIR)/home $(BUILD_DIR)
	/bin/cp -vr $(APPLICATION_DIR)/perf $(BUILD_DIR)
	/bin/cp -vrL $(APPLICATION_DIR)/usr $(BUILD_DIR)

package: build
	/bin/mkdir -p --mode=0755 $(RELEASE_DIR)
	/bin/tar cJvf $(RELEASE_DIR)/$(PKG_NAME).tar.xz --directory $(TMPDIR) $(PKG_NAME)

	cd $(RELEASE_DIR) && \
	/usr/bin/sha256sum $(PKG_NAME).tar.xz > SHA256SUM && \
	/usr/local/bin/venture fileinfo $(PKG_NAME).tar.xz

	/bin/rm -rf $(BUILD_DIR)

printenv:
	@echo "MAKEFILE_LIST: $(MAKEFILE_LIST)"
	@echo "       TMPDIR: $(TMPDIR)"
	@echo "       CURDIR: $(CURDIR)"
	@echo "      VERSION: $(VERSION)"
	@echo "         ARCH: $(ARCH)"
	@echo "     PKG_NAME: $(PKG_NAME)"
	@echo "    BUILD_DIR: $(BUILD_DIR)"
	@echo "UTILITIES_DIR: $(UTILITIES_DIR)"
	@echo "  RELEASE_DIR: $(RELEASE_DIR)"
