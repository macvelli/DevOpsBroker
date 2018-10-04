#!/bin/bash

#
# configure-desktop.sh - DevOpsBroker configuration script for Ubuntu 16.04 Desktop
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
# Performs the following configurations:
#   o Configures IPv4 firewall and IPv6 firewall using iptables and ip6tables
#   o Installs all DevOpsBroker system administration and user utilities
#   o Installs a number of useful applications, libraries and utilities
#   o Installs any available proprietary drivers
#   o Configures and optimizes the filesystem
#   o Performs Linux kernel tuning optimizations
#   o Performs general system configuration
#   o Configures the fastest APT sources mirror
#   o Configures and optimizes GRUB
#   o Manages DevOpsBroker configuration files (e.g. ansi.conf)
#   o Tunes the default network interface card
#   o Performs Samba configuration and optimization
#   o Configures systemwide security configuration
#   o Configures the Disk I/O schedulers and tunes each disk independently
#   o Replaces dnsmasq with unbound for the local DNS cache server
#   o Performs user configuration
#
# Unnstalls the following packages:
#   o dnsmasq
#   o geoip-bin
#   o geoip-database
#   o irqbalance
#   o libc6-dbg
#
# Useful Linux Command-Line Utilities
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Dynamic real-time view of running processes:
#   o htop
#
# Snapshot view of active processes:
#   o ps
#
# Check Available RAM:
#   o free -h
#
# Report virtual memory statistics (PGPGIN/PGPGOUT):
#   o vmstat -s
#
# View USB Device Tree:
#   o lsusb -tv
#
# View PCI Device Tree:
#   o lspci -tv
#
# View Filesystem Types and Mountpoints:
#   o lsblk -o NAME,FSTYPE,LABEL,SIZE,UUID,MOUNTPOINT
#
# View status of Linux Kernel modules:
#   o lsmod
#
# View all available connection profiles for all network interfaces
#   o nmcli device show
#
# View which devices and handlers are currently active:
#   o cat /proc/bus/input/devices
#
# View every program which is listening on sockets for TCP/UDP traffic:
#   o sudo netstat -tulpn
#
# Scan the 192.168.0.0/24 subnet for every device with an open port 631:
#   o nmap -p T:631 192.168.0.0/24 | grep -B4 open
#
# View shared object dependencies
#   o ldd /usr/bin/glxgears
#
# TODO: Test everything...again!!!
# -----------------------------------------------------------------------------
#

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Preprocessing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Load /etc/devops/ansi.conf if ANSI_CONFIG is unset
if [ -z "$ANSI_CONFIG" ] && [ -f /etc/devops/ansi.conf ]; then
	source /etc/devops/ansi.conf
fi

${ANSI_CONFIG?"[1;91mCannot load '/etc/devops/ansi.conf': No such file[0m"}

# Load /etc/devops/exec.conf if EXEC_CONFIG is unset
if [ -z "$EXEC_CONFIG" ] && [ -f /etc/devops/exec.conf ]; then
	source /etc/devops/exec.conf
fi

${EXEC_CONFIG?"[1;91mCannot load '/etc/devops/exec.conf': No such file[0m"}

# Load /etc/devops/functions.conf if FUNC_CONFIG is unset
if [ -z "$FUNC_CONFIG" ] && [ -f /etc/devops/functions.conf ]; then
	source /etc/devops/functions.conf
fi

${FUNC_CONFIG?"[1;91mCannot load '/etc/devops/functions.conf': No such file[0m"}

## Script information
SCRIPT_INFO=( $($EXEC_SCRIPTINFO "$BASH_SOURCE") )
SCRIPT_DIR="${SCRIPT_INFO[0]}"
SCRIPT_EXEC="${SCRIPT_INFO[1]}"

# Display error if not running as root
if [ "$USER" != 'root' ]; then
	printError "$SCRIPT_EXEC" 'Permission denied (you must be root)'
	exit 1
fi

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Ubuntu Version Check ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Check which version of Ubuntu is installed
DISTRO_INFO="$(/usr/bin/lsb_release -sirc)"
DISTRO_INFO=${DISTRO_INFO//${newline}/ }

# Display error if not running on Ubuntu 16.04 xenial
if [ "$DISTRO_INFO" != 'Ubuntu 16.04 xenial' ]; then
	printError "$SCRIPT_EXEC" "Invalid Linux distribution '$DISTRO_INFO'"
	exit 1
fi

################################## Functions ##################################

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function:     installPackage
# Description:  Installs the specified package, if not already installed
#
# Parameter $1: The file to check for existence; install if not present
# Parameter $2: The name of the package to install
# -----------------------------------------------------------------------------
function installPackage() {
	PKG_INSTALLED=false

	if [ ! -f "$1" ]; then
		printBanner "Installing $2"
		$EXEC_APT -y install $2
		PKG_INSTALLED=true
		echo
	fi
}

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function:     installSnap
# Description:  Installs the specified snap, if not already installed
#
# Parameter $1: The directory to check for existence; install if not present
# Parameter $2: The name of the snap to install
# -----------------------------------------------------------------------------
function installSnap() {
	if [ ! -d "$1" ]; then
		printBanner "Installing $2"
		$EXEC_SNAP install $2
		echo
	fi
}

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function:     uninstallPackage
# Description:  Uninstalls the specified package, if already installed
#
# Parameter $1: The file to check for existence; uninstall if present
# Parameter $2: The name of the package to uninstall
# -----------------------------------------------------------------------------
function uninstallPackage() {
	if [ -f "$1" ]; then
		printBanner "Uninstalling $2"
		$EXEC_APT -y purge $2
		echo
	fi
}

################################## Variables ##################################

## Bash exec variables
EXEC_ADD_APT_REPO=/usr/bin/add-apt-repository

## Variables
DEFAULT_NIC=$($EXEC_IP -4 route show default | $EXEC_AWK '{ print $5 }')
PKG_INSTALLED=false
updateAptSources=false

################################### Actions ###################################

# Clear screen only if called from command line
if [ $SHLVL -eq 1 ]; then
	clear
fi

printBox "DevOpsBroker $UBUNTU_RELEASE Configurator" 'true'

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Firewall ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Install iptables
installPackage '/sbin/iptables' 'iptables'

# Configure IPv4 firewall with iptables-desktop.sh script
if [ ! -f /etc/network/iptables.rules ] || \
	[ "$SCRIPT_DIR"/etc/network/iptables-desktop.sh -nt /etc/network/iptables.rules ]; then

		"$SCRIPT_DIR"/etc/network/iptables-desktop.sh
		echo
fi

# Configure IPv6 firewall with ip6tables-desktop.sh script
if [ ! -f /etc/network/ip6tables.rules ] || \
	[ "$SCRIPT_DIR"/etc/network/ip6tables-desktop.sh -nt /etc/network/ip6tables.rules ]; then

		"$SCRIPT_DIR"/etc/network/ip6tables-desktop.sh
		echo
fi

#~~~~~~~~~~~~~~~~~~~~~~~~~~~ DevOpsBroker Utilities ~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Install and/or update DevOpsBroker system administration and user utilities
if [ -f "$SCRIPT_DIR"/update-utils.sh ]; then
	"$SCRIPT_DIR"/update-utils.sh
fi

# ~~~~~~~~~~~~~~~~~~~~~~~~~ APT Sources Configuration ~~~~~~~~~~~~~~~~~~~~~~~~~

if [ ! -f /etc/apt/sources.list.d/git-core-ubuntu-ppa-xenial.list ]; then
	printInfo 'Adding Git stable release PPA'
	$EXEC_ADD_APT_REPO -y ppa:git-core/ppa
	updateAptSources=true
fi

if [ ! -f /etc/apt/sources.list.d/inkscape_dev-ubuntu-stable-xenial.list ]; then
	printInfo 'Adding Inkscape stable release PPA'
	$EXEC_ADD_APT_REPO -y ppa:inkscape.dev/stable
	updateAptSources=true
fi

if [ ! -f /etc/apt/sources.list.d/maxmind-ubuntu-ppa-xenial.list ]; then
	printInfo 'Add MaxMind PPA for GeoLite2 Support'
	$EXEC_ADD_APT_REPO -y ppa:maxmind/ppa
	updateAptSources=true
fi

if [ ! -f /etc/apt/sources.list.d/nilarimogard-ubuntu-webupd8-xenial.list ]; then
	printInfo 'Adding webupd8.org PPA'
	$EXEC_ADD_APT_REPO -y ppa:nilarimogard/webupd8
	updateAptSources=true
fi

# Install curl
installPackage '/usr/bin/curl' 'curl'

# Install gawk
installPackage '/usr/bin/gawk' 'gawk'

# Install parallel
installPackage '/usr/bin/parallel' 'parallel'

# Configure /etc/apt/sources.list with configure-apt-mirror.sh script
if [ "$updateAptSources" == 'true' ]; then
	"$SCRIPT_DIR"/etc/apt/configure-apt-mirror.sh 'false'

	printInfo 'Updating APT package information from all configured sources'
	$EXEC_APT update
else
	"$SCRIPT_DIR"/etc/apt/configure-apt-mirror.sh
fi

#~~~~~~~~~~~~~~~~~~~~ Applications / Libraries / Utilities ~~~~~~~~~~~~~~~~~~~~

# Install apparmor-utils
installPackage '/usr/sbin/aa-genprof' 'apparmor-utils'

# Install arp-scan
installPackage '/usr/bin/arp-scan' 'arp-scan'

# Install aspell
installPackage '/usr/bin/aspell' 'aspell aspell-en'

# Install avahi-daemon
installPackage '/usr/sbin/avahi-daemon' 'avahi-daemon'

# Install clang
installPackage '/usr/bin/clang-5.0' 'clang-5.0 clang-5.0-doc'

if [ ! -L /usr/bin/clang ]; then
	printInfo "Creating symbolic link /usr/lib/llvm-5.0/bin/clang"
	$EXEC_LN -s /usr/lib/llvm-5.0/bin/clang /usr/bin/clang
fi

# Install compizconfig-settings-manager
installPackage '/usr/bin/ccsm' 'compizconfig-settings-manager'

# Install dconf-editor
installPackage '/usr/bin/dconf-editor' 'dconf-editor'

# Install debhelper
installPackage '/usr/bin/dh' 'debhelper'

# Install dkms
installPackage '/usr/sbin/dkms' 'dkms'

# Install dnsutils
installPackage '/usr/bin/dig' 'dnsutils'

# Install dos2unix
installPackage '/usr/bin/dos2unix' 'dos2unix'

# Install exfat
installPackage '/sbin/mkfs.exfat' 'exfat-fuse exfat-utils'

# Install fio
installPackage '/usr/bin/fio' 'fio'

# Install flashplugin-installer
installPackage '/usr/lib/flashplugin-installer/install_plugin' 'flashplugin-installer'

# Install gcc
installPackage '/usr/bin/gcc' 'gcc'

# Install gdb
installPackage '/usr/bin/gdb' 'gdb'

# Uninstall geoip-bin
uninstallPackage '/usr/bin/geoiplookup' 'geoip-bin'

# Uninstall geoip-database
uninstallPackage '/usr/share/GeoIP/GeoIP.dat' 'geoip-database'

# Delete /usr/share/GeoIP directory
if [ -d /usr/share/GeoIP ]; then
	printInfo 'Deleting /usr/share/GeoIP directory'
	$EXEC_RM -rf /usr/share/GeoIP
	echo
fi

# Install ioping
installPackage '/usr/bin/ioping' 'ioping'

# Install libc-bin
installPackage '/usr/bin/getent' 'libc-bin'

# Install mmdblookup
installPackage '/usr/bin/mmdblookup' 'libmaxminddb0 libmaxminddb-dev mmdb-bin'

if [ "$PKG_INSTALLED" == 'true' ]; then
	# Install GeoLite2 City geolocation database
	/usr/local/bin/geoip update
	echo
fi

# Install gimp
installPackage '/usr/bin/gimp' 'gimp'

# Install git
installPackage '/usr/bin/git' 'git'

# Install gksu
installPackage '/usr/bin/gksu' 'gksu'

# Install gnome-tweak-tool
installPackage '/usr/bin/gnome-tweak-tool' 'gnome-tweak-tool'

# Install gparted
installPackage '/usr/sbin/gparted' 'gparted'

# Install gstreamer1.0-libav
installPackage '/usr/share/doc/gstreamer1.0-libav/README' 'gstreamer1.0-libav'

# Install htop
installPackage '/usr/bin/htop' 'htop'

# Install hwinfo
installPackage '/usr/sbin/hwinfo' 'hwinfo'

# Install inkscape
installPackage '/usr/bin/inkscape' 'inkscape'

# Uninstall irqbalance
uninstallPackage '/usr/sbin/irqbalance' 'irqbalance'

# Install libaio-dev
installPackage '/usr/include/libaio.h' 'libaio-dev'

# Uninstall libc6-dbg
uninstallPackage '/usr/share/doc/libc6-dbg/copyright' 'libc6-dbg'

# Install libmagic-dev
installPackage '/usr/include/magic.h' 'libmagic-dev'

# Install libpam-modules
installPackage '/usr/share/doc/libpam-modules/copyright' 'libpam-modules'

# Install libpixman-1-0
installPackage '/usr/share/doc/libpixman-1-0/copyright' 'libpixman-1-0'

# Install linux-generic-hwe-16.04
installPackage '/usr/share/doc/linux-generic-hwe-16.04/copyright' 'linux-generic-hwe-16.04'

# Install mesa-utils
installPackage '/usr/bin/glxinfo' 'mesa-utils'

# Install net-tools
installPackage '/bin/netstat' 'net-tools'

# Install nmap
installPackage '/usr/bin/nmap' 'nmap'

# Install ntp
installPackage '/usr/sbin/ntpd' 'ntp'

# Install openssh-client
installPackage '/usr/bin/ssh-keygen' 'openssh-client'

# Install ovmf
installPackage '/usr/share/ovmf/OVMF.fd' 'ovmf'

# Install pulseaudio-equalizer
if [ ! -f /usr/bin/pulseaudio-equalizer-gtk ]; then
	# BEGIN Install pulseaudio-equalizer

	installPackage '/usr/bin/pulseaudio-equalizer-gtk' 'pulseaudio-equalizer'

	# Install PulseAudio icon
	printInfo 'Installing pulseaudio icon'
	$EXEC_INSTALL -o root -g root -m 644 "$SCRIPT_DIR/usr/share/pixmaps/pulseaudio.png" /usr/share/pixmaps

	# .desktop directory
	desktopDir='usr/share/applications'
	# Fix icon in /usr/share/applications/pulseaudio-equalizer.desktop
	$EXEC_INSTALL -o root -g root -m 644 "$SCRIPT_DIR/$desktopDir/pulseaudio-equalizer.desktop" "/$desktopDir"

	# Presets directory
	presetsDir='usr/share/pulseaudio-equalizer/presets'

	# Install Default preset
	printInfo 'Installing Default equalizer preset'
	$EXEC_INSTALL -o root -g root -m 644 "$SCRIPT_DIR/$presetsDir/Default.preset" "/$presetsDir"
	echo

	# END Install pulseaudio-equalizer
fi

# Install pv
installPackage '/usr/bin/pv' 'pv'

# Install qemu-kvm
installPackage '/usr/share/doc/qemu-kvm/copyright' 'qemu-kvm'

# Install rng-tools
installPackage '/usr/sbin/rngd' 'rng-tools'

if [ "$PKG_INSTALLED" == 'true' ]; then
	/usr/sbin/rngd -r /dev/urandom
fi

# Install samba
installPackage '/usr/sbin/smbd' 'samba'

# Install smbclient
installPackage '/usr/bin/smbtree' 'smbclient'

# Install shutter
#if [ ! -f /usr/bin/shutter ]; then
#  printBanner 'Installing shutter'
#
#  printInfo 'Add Shutter stable release PPA'
#  $EXEC_ADD_APT_REPO ppa:shutter/ppa
#  $EXEC_APT update
#  echo
#
#  $EXEC_APT -y install shutter
#
#  echo
#fi

# Install speedtest-cli
installPackage '/usr/bin/speedtest-cli' 'speedtest-cli'

# Install sudo
installPackage '/usr/bin/sudo' 'sudo'

# Install sysfsutils
installPackage '/usr/bin/systool' 'sysfsutils'

# Install sysstat
installPackage '/usr/bin/iostat' 'sysstat'

# Install latest version of tidy from .deb file
if [ ! -f /usr/lib/libtidy.so.5.6.0 ]; then
	# Uninstall tidy and libtidy-0.99-0
	uninstallPackage '/usr/bin/tidy' 'tidy libtidy-0.99-0'

	# Install new tidy
	/usr/bin/dpkg -i "$SCRIPT_DIR"/archives/tidy-5.6.0-64bit.deb
	/usr/bin/apt-get -f install
	echo
fi

# Install traceroute
installPackage '/usr/sbin/traceroute' 'traceroute'

# Install ttf-mscorefonts-installer
installPackage '/usr/share/fonts/truetype/msttcorefonts/Arial.ttf' 'ttf-mscorefonts-installer'

if [ "$PKG_INSTALLED" == 'true' ]; then
	printInfo 'Updating the font cache'
	/usr/bin/fc-cache -f -v
	echo
fi

# Install unbound
installPackage '/usr/sbin/unbound' 'unbound'

# Uninstall vim-tiny
uninstallPackage '/usr/bin/vim.tiny' 'vim-tiny'

# Install vim
installPackage '/usr/bin/vim.basic' 'vim'

# Install vlc
installSnap '/snap/vlc' 'vlc'

# Install whois
installPackage '/usr/bin/whois' 'whois'

# Install whoopsie
installPackage '/usr/bin/whoopsie' 'whoopsie'

# Install xclip
installPackage '/usr/bin/xclip' 'xclip'

# Install xserver-xorg-hwe-16.04
installPackage '/usr/share/doc/xserver-xorg-hwe-16.04/copyright' 'xserver-xorg-hwe-16.04'

# Install yad
installPackage '/usr/bin/yad' 'yad'

# ~~~~~~~~~~~~~~~~~~~~~~~~~ System/User Configuration ~~~~~~~~~~~~~~~~~~~~~~~~~

#
# Device Driver Installation
#

"$SCRIPT_DIR"/device-drivers.sh

#
# Filesystem Configuration
#

# Configure /etc/fstab with configure-fstab.sh script
"$SCRIPT_DIR"/etc/configure-fstab.sh

#
# Linux Kernel Tuning
#

# Configure /etc/sysctl.conf with configure-kernel.sh script
"$SCRIPT_DIR"/etc/configure-kernel.sh

#
# General System Configuration
#

# Configure system with configure-system.sh script
"$SCRIPT_DIR"/etc/configure-system.sh

#
# GRUB Configuration
#

# Configure /etc/default/grub with configure-grub.sh script
"$SCRIPT_DIR"/etc/default/configure-grub.sh

#
# Unbound DNS Cache Server Configuration
#

# Configure /etc/unbound/unbound.conf.d/ with configure-unbound.sh script
"$SCRIPT_DIR"/etc/unbound/configure-unbound.sh

#
# NetworkManager Configuration
#

# Configure /etc/NetworkManager with configure-nm.sh script
"$SCRIPT_DIR"/etc/NetworkManager/configure-nm.sh $DEFAULT_NIC

#
# Samba Configuration
#

# Configure /etc/samba/smb.conf with configure-samba.sh script
"$SCRIPT_DIR"/etc/samba/configure-samba.sh $DEFAULT_NIC

#
# Systemwide Security Configuration
#

# Configure /etc/security/limits.d/ with configure-security.sh script
"$SCRIPT_DIR"/etc/security/configure-security.sh

#
# Udev Configuration
#

# Configure /etc/udev/rules.d/ with configure-udev.sh script
"$SCRIPT_DIR"/etc/udev/configure-udev.sh

#
# User Configuration
#

# Configure the user with configure-user.sh script
"$SCRIPT_DIR"/home/configure-user.sh $SUDO_USER

# Uninstall dnsmasq
uninstallPackage '/etc/dnsmasq.conf' 'dnsmasq'

#
# Upgrade Ubuntu
#

today=$($EXEC_DATE -I)
if [ ! -f /etc/devops/last-update ] || [ $($EXEC_CAT /etc/devops/last-update) != $today ]; then
	/usr/local/sbin/pms upgrade
fi

echo 'Done!'
echo

exit 0
