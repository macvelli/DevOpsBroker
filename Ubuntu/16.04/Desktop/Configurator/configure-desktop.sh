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
#
# Useful Linux Command-Line Utilities
# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# o Dynamic real-time view of running processes:
# htop
#
# o Snapshot view of active processes:
# ps
#
# o Check Available RAM:
# free -h
#
# o Report virtual memory statistics (PGPGIN/PGPGOUT):
# vmstat -s
#
# o View USB Device Tree:
# lsusb -tv
#
# o View PCI Device Tree:
# lspci -tv
#
# o View Filesystem Types and Mountpoints:
# lsblk -o NAME,FSTYPE,LABEL,SIZE,UUID,MOUNTPOINT
#
# o View status of Linux Kernel modules:
# lsmod
#
# o View all available connection profiles for all network interfaces
# nmcli device show
#
# o View which devices and handlers are currently active:
# cat /proc/bus/input/devices
#
# o View every program which is listening on sockets for TCP/UDP traffic:
# sudo netstat -tulpn
#
# o Scan the 192.168.0.0/24 subnet for every device with an open port 631:
# nmap -p T:631 192.168.0.0/24 | grep -B4 open
#
# TODO: Test everything...again!!!
# -----------------------------------------------------------------------------
#

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Preprocessing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Load /etc/devops/ansi.conf if ANSI_CONFIG is unset
if [ -z "$ANSI_CONFIG" ] && [ -f /etc/devops/ansi.conf ]; then
  source /etc/devops/ansi.conf
fi

${ANSI_CONFIG?"[1;38;2;255;100;100mCannot load '/etc/devops/ansi.conf': No such file[0m"}

# Load /etc/devops/exec.conf if EXEC_CONFIG is unset
if [ -z "$EXEC_CONFIG" ] && [ -f /etc/devops/exec.conf ]; then
  source /etc/devops/exec.conf
fi

${EXEC_CONFIG?"${bold}${bittersweet}Cannot load '/etc/devops/exec.conf': No such file${reset}"}

# Load /etc/devops/functions.conf if FUNC_CONFIG is unset
if [ -z "$FUNC_CONFIG" ] && [ -f /etc/devops/functions.conf ]; then
  source /etc/devops/functions.conf
fi

${FUNC_CONFIG?"${bold}${bittersweet}Cannot load '/etc/devops/functions.conf': No such file${reset}"}

## Script information
SCRIPT_INFO=( $($EXEC_SCRIPTINFO "$BASH_SOURCE") )
SCRIPT_DIR="${SCRIPT_INFO[0]}"
SCRIPT_EXEC="${SCRIPT_INFO[1]}"

# Display error if not running as root
if [ "$EUID" -ne 0 ]; then
  echo "${bold}$SCRIPT_EXEC: ${bittersweet}Permission denied (you must be root)${reset}"

  exit 1
fi

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Ubuntu Version Check ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Check which version of Ubuntu is installed
EXEC_LSB_RELEASE=/usr/bin/lsb_release

IFS=$'\n'
DISTRO_INFO=($($EXEC_LSB_RELEASE -sirc))
IFS=' '

# Display error if not running on Ubuntu 16.04 xenial
if [ ${#DISTRO_INFO[@]} -ne 3 ] || \
      [ "${DISTRO_INFO[0]}" != 'Ubuntu' ] || \
      [ "${DISTRO_INFO[1]}" != '16.04' ] || \
      [ "${DISTRO_INFO[2]}" != 'xenial' ]; then
  printError 'configure-desktop.sh' "Invalid Linux distribution ${DISTRO_INFO[@]}"

  exit 1
fi

################################## Variables ##################################

## Bash exec variables
EXEC_ADD_APT_REPO=/usr/bin/add-apt-repository

# Default network interface
DEFAULT_NIC=$($EXEC_IP -4 route show default | $EXEC_AWK '{ print $5 }')

# Number of CPUs
NUM_CPUS=$($EXEC_GREP -c ^processor /proc/cpuinfo)

################################## Functions ##################################

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function:	installPackage
# Description:	Installs the specified package, if not already installed
#
# Parameter $1:	The file to check for existence; install if not present
# Parameter $2: The name of the package to install~/Development/GitHub/DevOpsBroker/Ubuntu/16.04/Desktop/Configurator
# -----------------------------------------------------------------------------
function installPackage() {
  if [ ! -f "$1" ]; then
    printBanner "Installing $2"

    $EXEC_APT -y install $2

    echo
  fi
}

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function:	installSnap
# Description:	Installs the specified snap, if not already installed
#
# Parameter $1:	The directory to check for existence; install if not present
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
# Function:	uninstallPackage
# Description:	Uninstalls the specified package, if already installed
#
# Parameter $1:	The file to check for existence; uninstall if present
# Parameter $2: The name of the package to uninstall
# -----------------------------------------------------------------------------
function uninstallPackage() {
  if [ -f "$1" ]; then
    printBanner "Uninstalling $2"

    $EXEC_APT -y purge $2

    echo
  fi
}

################################### Actions ###################################

# Clear screen only if called from command line
if [ $SHLVL -eq 1 ]; then
  clear
fi

bannerMsg='DevOpsBroker Ubuntu 16.04 Desktop Configurator'

echo ${bold} ${wisteria}
echo '╔════════════════════════════════════════════════╗'
echo "║ ${white}$bannerMsg${wisteria}"		      '║'
echo '╚════════════════════════════════════════════════╝'
echo ${reset}

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

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~ DevOpsBroker Utilities ~~~~~~~~~~~~~~~~~~~~~~~~~~

# Install and/or update DevOpsBroker system administration and user utilities
"$SCRIPT_DIR"/update-utils.sh

#~~~~~~~~~~~~~~~~~~~~ Applications / Libraries / Utilities ~~~~~~~~~~~~~~~~~~~~

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

# Install curl
installPackage '/usr/bin/curl' 'curl'

# Install dconf-editor
installPackage '/usr/bin/dconf-editor' 'dconf-editor'

# Uninstall dnsmasq
uninstallPackage '/etc/dnsmasq.conf' 'dnsmasq'

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

# Install gawk
installPackage '/usr/bin/gawk' 'gawk'

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
if [ ! -f /usr/bin/mmdblookup ]; then
  # BEGIN GeoLite2 City Lookup

  printBanner 'Installing MaxMind GeoLite2 Geolocation'

  printInfo 'Add MaxMind PPA for GeoLite2 Support'
  $EXEC_ADD_APT_REPO -y ppa:maxmind/ppa
  $EXEC_APT update
  echo

  printInfo 'Install mmdblookup'
  $EXEC_APT -y install libmaxminddb0 libmaxminddb-dev mmdb-bin
  echo

  # Install GeoLite2 City geolocation database
  /usr/local/bin/geoip update

  echo

  # END GeoLite2 City Lookup
fi

# Install gimp
installSnap '/snap/gimp' 'gimp'

# Install git
if [ ! -f /usr/bin/git ]; then
  printBanner 'Installing git'

  printInfo 'Add Git stable release PPA'
  $EXEC_ADD_APT_REPO ppa:git-core/ppa
  $EXEC_APT update
  echo

  $EXEC_APT -y install git

  echo
fi

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
installSnap '/snap/inkscape' 'inkscape'

#
# irqbalance
#   o Install and activate for multi-core/multi-cpu systems
#
if [ $NUM_CPUS -gt 1 ]; then
  # Install irqbalance
  installPackage '/usr/sbin/irqbalance' 'irqbalance'

  # Start irqbalance service
  if ! $EXEC_SYSTEMCTL status irqbalance | $EXEC_GREP -Fq 'active (running)'; then
    printInfo 'Start irqbalance service'

    $EXEC_SYSTEMCTL start irqbalance

    echo
  fi

fi

# Install libaio-dev
installPackage '/usr/include/libaio.h' 'libaio-dev'

# Uninstall libc6-dbg
uninstallPackage '/usr/share/doc/libc6-dbg/copyright' 'libc6-dbg'

# Install libmagic-dev
installPackage '/usr/include/magic.h' 'libmagic-dev'

# Install libpam-modules
installPackage '/usr/share/doc/libpam-modules/copyright' 'libpam-modules'

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

# Install parallel
installPackage '/usr/bin/parallel' 'parallel'

# Install pulseaudio-equalizer
if [ ! -f /usr/bin/pulseaudio-equalizer-gtk ]; then
  # BEGIN Install pulseaudio-equalizer

  printBanner 'Installing pulseaudio-equalizer'

  printInfo 'Adding webupd8.org PPA'
  $EXEC_ADD_APT_REPO ppa:nilarimogard/webupd8
  $EXEC_APT update
  echo

  # Install the equalizer
  $EXEC_APT -y install pulseaudio-equalizer
  echo

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

# Install qemu-kvm
installPackage '/usr/share/doc/qemu-kvm/copyright' 'qemu-kvm'

# Install samba
installPackage '/usr/sbin/smbd' 'samba'

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

# Install sysfsutils
installPackage '/usr/bin/systool' 'sysfsutils'

# Install sysstat
installPackage '/usr/bin/iostat' 'sysstat'

# Install tidy
installPackage '/usr/bin/tidy' 'tidy'

# Install ttf-mscorefonts-installer
if [ ! -d /usr/share/fonts/truetype/msttcorefonts ]; then
  printBanner 'Installing ttf-mscorefonts-installer'

  $EXEC_APT -y install ttf-mscorefonts-installer
  echo

  printInfo 'Updating the font cache'
  /usr/bin/fc-cache -f -v

  echo
fi

# Install unbound
installPackage '/usr/sbin/unbound' 'unbound'

# Install vlc
installSnap '/snap/vlc' 'vlc'

# Install whois
installPackage '/usr/bin/whois' 'whois'

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
# APT Sources Mirror Configuration
#

# Configure /etc/apt/sources.list with configure-apt-mirror.sh script
"$SCRIPT_DIR"/etc/apt/configure-apt-mirror.sh

#
# GRUB Configuration
#

# Configure /etc/default/grub with configure-grub.sh script
"$SCRIPT_DIR"/etc/default/configure-grub.sh

#
# DevOpsBroker Configration Files
#

# Install /etc/devops/ansi.conf
installConfig 'ansi.conf' "$SCRIPT_DIR"/etc/devops /etc/devops

# Install /etc/devops/exec.conf
installConfig 'exec.conf' "$SCRIPT_DIR"/etc/devops /etc/devops

# Install /etc/devops/functions.conf
installConfig 'functions.conf' "$SCRIPT_DIR"/etc/devops /etc/devops

#
# Network Interface Card Configuration
#

# TODO: Move this to configure-nic.sh

# Install /etc/network/if-pre-up.d/iface-preup-config.sh
installConfig 'iface-preup-config.sh' "$SCRIPT_DIR"/etc/network/if-pre-up.d /etc/network/if-pre-up.d
$EXEC_CHMOD 755 /etc/network/if-pre-up.d/iface-preup-config.sh

if [ ! -z "$DEFAULT_NIC" ]; then
  # Configure /etc/network/if-up.d/ with configure-nic.sh script
  "$SCRIPT_DIR"/etc/network/configure-nic.sh $DEFAULT_NIC

  # Configure /etc/network/interfaces
  if ! $EXEC_GREP -Fq $DEFAULT_NIC /etc/network/interfaces; then

    printInfo 'Configuring /etc/network/interfaces'

## Template
/bin/cat << EOF >> /etc/network/interfaces

# $DEFAULT_NIC
auto $DEFAULT_NIC
iface $DEFAULT_NIC inet dhcp
  pre-up /etc/network/if-pre-up.d/iface-preup-config.sh
EOF
    echo
  fi
fi

#
# Samba Configuration
#

# Configure /etc/samba/smb.conf with configure-samba.sh script
"$SCRIPT_DIR"/etc/samba/configure-samba.sh

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
# Unbound DNS Cache Server Configuration
#

# Configure /etc/unbound/unbound.conf.d/ with configure-unbound.sh script
"$SCRIPT_DIR"/etc/unbound/configure-unbound.sh

#
# User Configuration
#

# Configure the user with configure-user.sh script
"$SCRIPT_DIR"/home/configure-user.sh $SUDO_USER

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
