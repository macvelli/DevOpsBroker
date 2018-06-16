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
#   o Ensures all configuration scripts DevOpsBroker utilizes are executable
#   o Configures firewall using both iptables and ip6tables for IPv4 and IPv6
#   o Tunes the default network card (hardware offload / tx queue length / initcwnd and initrwnd)
#   o Installs any available proprietary drivers
#   o Configures and optimizes the filesystem
#   o Performs Linux kernel tuning optimizations
#   o Performs general system configuration
#   o Configures the fastest APT sources mirror
#   o Configures and optimizes GRUB
#   o Performs Samba configuration and optimization
#   o Configures systemwide security configuration
#   o Configures the Disk I/O schedulers
#   o Replaces dnsmasq with unbound for the local DNS cache server
#   o Performs user configuration
#
# Installs the following user utilities:
#   o addUserToGroup
#   o firewall
#   o archive
#   o between
#   o bgedit
#   o convert-number (binary / decimal / hex / octal)
#   o decrypt
#   o encrypt
#   o extract
#   o firelog
#   o geoip
#   o git-config
#   o hexToRgb
#   o hypotenuse
#   o pms
#   o printAnsi256
#   o public-ip
#   o random-password
#   o reverse-dns
#   o rgbToHex
#   o showFileFormat
#   o ssh-key
#   o symlink
#   o venture
#   o verifyip
#
# Installs the following packages and Snaps:
#   o arp-scan
#   o avahi-daemon
#   o curl
#   o dconf-editor
#   o dnsutils
#   o dos2unix
#   o exfat
#   o flashplugin-installer
#   o gcc
#   o gdb
#   o mmdblookup
#   o getent
#   o gimp
#   o git
#   o gksu
#   o gnome-tweak-tool
#   o gparted
#   o gstreamer1.0-libav
#   o htop
#   o irqbalance
#   o libpam-modules
#   o mesa-utils
#   o net-tools
#   o nmap
#   o ntp
#   o openssh-client
#   o parallel
#   o pulseaudio-equalizer
#   o samba
#   o speedtest-cli
#   o sysstat
#   o ttf-mscorefonts-installer
#   o unbound
#   o vlc
#   o xclip
#   o whois
#   o yad
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
# o Measure read speed of any drive (Hard Drive/SSD/USB):
# hdparm -t /dev/sd(a|b|c|d...)
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


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Initialization ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Display error if not running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "\033[1mconfigure-desktop.sh: \033[38;5;203mPermission denied (you must be root)\033[0m"

  exit 1
fi

# Find the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Create /etc/dob directory
if [ ! -d /etc/dob ]; then

  # Make the /etc/dob directory
  mkdir -p --mode=0755 /etc/dob

fi

# Install /etc/dob/ansi.conf
if [ ! -f /etc/dob/ansi.conf ]; then

  # Install as root:root with rw-r--r-- privileges
  install -o root -g root -m 644 "$SCRIPT_DIR/etc/dob/ansi.conf" /etc/dob

fi

# Install /etc/dob/functions.conf
if [ ! -f /etc/dob/ansi.conf ]; then

  # Install as root:root with rw-r--r-- privileges
  install -o root -g root -m 644 "$SCRIPT_DIR/etc/dob/functions.conf" /etc/dob

fi


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Preprocessing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Load /etc/dob/ansi.conf if bittersweet function does not exist
if [[ ! "$(declare -F 'bittersweet')" ]]; then
  . /etc/dob/ansi.conf
fi

# Load /etc/dob/functions.conf if printBanner function does not exist
if [[ ! "$(declare -F 'printBanner')" ]]; then
  . /etc/dob/functions.conf
fi

# Check which version of Ubuntu is installed
IFS=$'\n'
DISTRO_INFO=($(lsb_release -sirc))
IFS=' '

# Display error if not running on Ubuntu 16.04 xenial
if [ ${#DISTRO_INFO[@]} -ne 3 ] || \
      [ "${DISTRO_INFO[0]}" != "Ubuntu" ] || \
      [ "${DISTRO_INFO[1]}" != "16.04" ] || \
      [ "${DISTRO_INFO[2]}" != "xenial" ]; then
  printError "configure-desktop.sh" "Invalid Linux distribution ${DISTRO_INFO[@]}"

  exit 1
fi

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Shell Scripts ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## Define shell script locations

# Make gsettings.sh executable
isExecutable "$SCRIPT_DIR/gsettings.sh" 1>/dev/null

# Make install-drivers.sh executable
isExecutable "$SCRIPT_DIR/install-drivers.sh" 1>/dev/null

# Make install-services.sh executable
isExecutable "$SCRIPT_DIR/install-services.sh" 1>/dev/null

# Make ttf-msclearfonts.sh executable
isExecutable "$SCRIPT_DIR/ttf-msclearfonts.sh" 1>/dev/null

# Set configure-fstab.sh location and make it executable
configFstab=$(isExecutable "$SCRIPT_DIR/etc/configure-fstab.sh")

# Set configure-kernel.sh location and make it executable
configKernel=$(isExecutable "$SCRIPT_DIR/etc/configure-kernel.sh")

# Set configure-system.sh location and make it executable
configSystem=$(isExecutable "$SCRIPT_DIR/etc/configure-system.sh")

# Set configure-apt-mirror.sh location and make it executable
configAptMirror=$(isExecutable "$SCRIPT_DIR/etc/apt/configure-apt-mirror.sh")

# Set configure-grub.sh location and make it executable
configGrub=$(isExecutable "$SCRIPT_DIR/etc/default/configure-grub.sh")

# Set ip6tables-desktop.sh location and make it executable
ip6tablesDesktop=$(isExecutable "$SCRIPT_DIR/etc/network/ip6tables-desktop.sh")

# Set iptables-desktop.sh location and make it executable
iptablesDesktop=$(isExecutable "$SCRIPT_DIR/etc/network/iptables-desktop.sh")

# Set configure-nic.sh location and make it executable
configNic=$(isExecutable "$SCRIPT_DIR/etc/network/if-up.d/configure-nic.sh")

# Set configure-samba.sh location and make it executable
configSamba=$(isExecutable "$SCRIPT_DIR/etc/samba/configure-samba.sh")

# Set configure-security.sh location and make it executable
configSecurity=$(isExecutable "$SCRIPT_DIR/etc/security/configure-security.sh")

# Set configure-unbound.sh location and make it executable
configUnbound=$(isExecutable "$SCRIPT_DIR/etc/unbound/configure-unbound.sh")

# Set configure-user.sh location and make it executable
configUser=$(isExecutable "$SCRIPT_DIR/home/configure-user.sh")


################################## Functions ##################################

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function:	installPackage
# Description:	Installs the specified package, if not already installed
#
# Parameter $1:	The file to check for existence; install if not present
# Parameter $2: The name of the package to install
# -----------------------------------------------------------------------------
function installPackage() {
  if [ ! -f "$1" ]; then
    printBanner "Installing $2"

    apt -y install $2

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

    snap install $2

    echo
  fi
}

# ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
# Function:	installUtility
# Description:	Installs the utility into the specified directory
#
# Parameter $1:	The name of the utility to install
# Parameter $2:	The source directory (where to find the utility to install)
# Parameter $3: The installation directory
# -----------------------------------------------------------------------------
function installUtility() {
  # BEGIN install utility function

  local utility="$1"
  local sourceDir="$2"
  local installDir="$3"

  if [ ! -f "$installDir/$utility" ]; then

    if [ "$installDir" == "/usr/local/sbin" ]; then
      # Install administration utility
      printInfo "Installing $utility administration utility"

      # Install utility as root:sudo with rwxr-x--- privileges
      install -o root -g sudo -m 750 "$sourceDir/$utility" /usr/local/sbin

    elif [ "$installDir" == "/usr/local/bin" ]; then
      # Install user utility
      printInfo "Installing $utility user utility"

      # Install utility as root:users with rwxr-xr-x privileges
      install -o root -g users -m 755 "$sourceDir/$utility" /usr/local/bin

    fi

    echo

  elif [ "$sourceDir/$utility" -nt "$installDir/$utility" ]; then

    if [ "$installDir" == "/usr/local/sbin" ]; then
      # Update administration utility
      printInfo "Updating $utility administration utility"

      # Install utility as root:sudo with rwxr-x--- privileges
      install -o root -g sudo -m 750 "$sourceDir/$utility" /usr/local/sbin

    elif [ "$installDir" == "/usr/local/bin" ]; then
      # Update user utility
      printInfo "Updating $utility user utility"

      # Install utility as root:users with rwxr-xr-x privileges
      install -o root -g users -m 755 "$sourceDir/$utility" /usr/local/bin

    fi

    echo

  fi

  # END install utility function
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

    apt -y purge $2

    echo
  fi
}


################################## Variables ##################################

# Default network interface
DEFAULT_NIC=$(ip -4 route show default | awk '{ print $5 }')

# Number of CPUs
NUM_CPUS=$(grep -c ^processor /proc/cpuinfo)

################################### Actions ###################################

# Clear screen and print banner only if called from command line
if [ $SHLVL -eq 1 ]; then
  clear

  bannerMsg="DevOpsBroker Ubuntu 16.04 Desktop Configurator"

  echo -e $(bold kobi)
  echo    "╔════════════════════════════════════════════════╗"
  echo -e "║ "$(white)$bannerMsg$(kobi)                    "║"
  echo    "╚════════════════════════════════════════════════╝"
  echo -e $(reset)

fi


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Firewall/Network ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Install iptables
installPackage "/sbin/iptables" "iptables"

## Configure iptables

# Call iptables-desktop.sh script
if [ ! -f /etc/network/iptables.rules ] || \
	[ "$iptablesDesktop" -nt /etc/network/iptables.rules ]; then

  $SHELL -c "$iptablesDesktop"

  echo
fi

## Configure ip6tables

# Call ip6tables-desktop.sh script
if [ ! -f /etc/network/ip6tables.rules ] || \
	[ "$ip6tablesDesktop" -nt /etc/network/ip6tables.rules ]; then

  $SHELL -c "$ip6tablesDesktop"

  echo
fi

## Install iface-preup-config.sh script

ifacePreUpDir="etc/network/if-pre-up.d"
if [ ! -f /etc/network/if-pre-up.d/iface-preup-config.sh ]; then

  printInfo "Installing /etc/network/if-pre-up.d/iface-preup-config.sh"

  # Install as root:root with rwxr-xr-x privileges
  install -o root -g root -m 755 "$SCRIPT_DIR/$ifacePreUpDir/iface-preup-config.sh" /$ifacePreUpDir

elif [ "$SCRIPT_DIR/$ifacePreUpDir/iface-preup-config.sh" -nt "/$ifacePreUpDir/iface-preup-config.sh" ]; then

  printInfo "Updating /etc/network/if-pre-up.d/iface-preup-config.sh"

  # Install as root:root with rwxr-xr-x privileges
  install -b --suffix .bak -o root -g root -m 755 "$SCRIPT_DIR/$ifacePreUpDir/iface-preup-config.sh" /$ifacePreUpDir

fi

if [ ! -z "$DEFAULT_NIC" ]; then

  ## Tune Default NIC Interface

  $SHELL -c "$configNic" "$DEFAULT_NIC"

  ## Configure /etc/network/interfaces
  if ! grep -Fq "$DEFAULT_NIC" /etc/network/interfaces; then
    echo "o Configuring /etc/network/interfaces..."

  echo "
# $DEFAULT_NIC
auto $DEFAULT_NIC
iface $DEFAULT_NIC inet dhcp
  pre-up /etc/network/if-pre-up.d/iface-preup-config.sh
  post-up /etc/network/if-up.d/tune-$DEFAULT_NIC.sh" >> /etc/network/interfaces

    echo
  fi
fi


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ User Utilities ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Build all C language utilties
/usr/bin/make -s --directory="$SCRIPT_DIR/C"
chown -R $SUDO_USER:$SUDO_USER "$SCRIPT_DIR/C"

# Install addUserToGroup administration script
installUtility addUserToGroup "$SCRIPT_DIR/usr/local/sbin" /usr/local/sbin

# Install firewall administration script
installUtility firewall "$SCRIPT_DIR/usr/local/sbin" /usr/local/sbin

# Install archive script
installUtility archive "$SCRIPT_DIR/usr/local/bin" /usr/local/bin

# Install between utility
installUtility between "$SCRIPT_DIR/C" /usr/local/bin

# Install bgedit script
installUtility bgedit "$SCRIPT_DIR/usr/local/bin" /usr/local/bin

# Install convert-number script
installUtility convert-number "$SCRIPT_DIR/usr/local/bin" /usr/local/bin

# Create symbolic links to the convert-number script
if [ ! -L /usr/local/bin/binary ]; then
  printInfo "Creating symbolic link /usr/local/bin/binary"
  ln -s /usr/local/bin/convert-number /usr/local/bin/binary
  chown --no-dereference root:users /usr/local/bin/binary

  printInfo "Creating symbolic link /usr/local/bin/decimal"
  ln -s /usr/local/bin/convert-number /usr/local/bin/decimal
  chown --no-dereference root:users /usr/local/bin/decimal

  printInfo "Creating symbolic link /usr/local/bin/hex"
  ln -s /usr/local/bin/convert-number /usr/local/bin/hex
  chown --no-dereference root:users /usr/local/bin/hex

  printInfo "Creating symbolic link /usr/local/bin/octal"
  ln -s /usr/local/bin/convert-number /usr/local/bin/octal
  chown --no-dereference root:users /usr/local/bin/octal
fi

# Install decrypt script
installUtility decrypt "$SCRIPT_DIR/usr/local/bin" /usr/local/bin

# Install encrypt script
installUtility encrypt "$SCRIPT_DIR/usr/local/bin" /usr/local/bin

# Install extract script
installUtility extract "$SCRIPT_DIR/usr/local/bin" /usr/local/bin

# Install firelog utility
installUtility firelog "$SCRIPT_DIR/C" /usr/local/bin

# Install geoip script
installUtility geoip "$SCRIPT_DIR/usr/local/bin" /usr/local/bin

# Install git-config script
installUtility git-config "$SCRIPT_DIR/usr/local/bin" /usr/local/bin

# Install hexToRgb script
installUtility hexToRgb "$SCRIPT_DIR/usr/local/bin" /usr/local/bin

# Install hypotenuse script
installUtility hypotenuse "$SCRIPT_DIR/usr/local/bin" /usr/local/bin

# Install pms script
installUtility pms "$SCRIPT_DIR/usr/local/bin" /usr/local/bin

# Install printAnsi256 script
installUtility printAnsi256 "$SCRIPT_DIR/usr/local/bin" /usr/local/bin

# Install public-ip script
installUtility public-ip "$SCRIPT_DIR/usr/local/bin" /usr/local/bin

# Install random-password script
installUtility random-password "$SCRIPT_DIR/usr/local/bin" /usr/local/bin

# Install reverse-dns script
installUtility reverse-dns "$SCRIPT_DIR/usr/local/bin" /usr/local/bin

# Install rgbToHex script
installUtility rgbToHex "$SCRIPT_DIR/usr/local/bin" /usr/local/bin

# Install showFileFormat script
installUtility showFileFormat "$SCRIPT_DIR/usr/local/bin" /usr/local/bin

# Install ssh-key script
installUtility ssh-key "$SCRIPT_DIR/usr/local/bin" /usr/local/bin

# Install symlink script
installUtility symlink "$SCRIPT_DIR/usr/local/bin" /usr/local/bin

# Install venture script
installUtility venture "$SCRIPT_DIR/usr/local/bin" /usr/local/bin

# Install verifyip utility
installUtility verifyip "$SCRIPT_DIR/C" /usr/local/bin


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~ Applications/Utilities ~~~~~~~~~~~~~~~~~~~~~~~~~~

# Install arp-scan
installPackage "/usr/bin/arp-scan" "arp-scan"

# Install avahi-daemon
installPackage "/usr/sbin/avahi-daemon" "avahi-daemon"

# Install curl
installPackage "/usr/bin/curl" "curl"

# Install dconf-editor
installPackage "/usr/bin/dconf-editor" "dconf-editor"

# Uninstall dnsmasq
uninstallPackage "/etc/dnsmasq.conf" "dnsmasq"

# Install dnsutils
installPackage "/usr/bin/dig" "dnsutils"

# Install dos2unix
installPackage "/usr/bin/dos2unix" "dos2unix"

# Install exfat
installPackage "/sbin/mkfs.exfat" "exfat-fuse exfat-utils"

# Install flashplugin-installer
installPackage "/usr/lib/flashplugin-installer/install_plugin" "flashplugin-installer"

# Install gcc
installPackage "/usr/bin/gcc" "gcc"

# Install gdb
installPackage "/usr/bin/gdb" "gdb"

# Uninstall geoip-bin
uninstallPackage "/usr/bin/geoiplookup" "geoip-bin"

# Uninstall geoip-database
uninstallPackage "/usr/share/GeoIP/GeoIP.dat" "geoip-database"

# Delete /usr/share/GeoIP directory
if [ -d /usr/share/GeoIP ]; then
  printInfo "Deleting /usr/share/GeoIP directory"

  rm -rf /usr/share/GeoIP

  echo
fi

# Install mmdblookup
if [ ! -f /usr/bin/mmdblookup ]; then
  # BEGIN GeoLite2 City Lookup

  printBanner "Installing MaxMind GeoLite2 Geolocation"

  printInfo "Add MaxMind PPA for GeoLite2 Support"
  add-apt-repository -y ppa:maxmind/ppa
  apt update
  echo

  printInfo "Install mmdblookup"
  apt -y install libmaxminddb0 libmaxminddb-dev mmdb-bin
  echo

  # Install GeoLite2 City geolocation database
  geoip update

  echo

  # END GeoLite2 City Lookup
fi

# Install getent
installPackage "/usr/bin/getent" "libc-bin"

# Install gimp
installSnap "/snap/gimp" "gimp"

# Install git
if [ ! -f /usr/bin/git ]; then
  printBanner "Installing git"

  printInfo "Add Git stable release PPA"
  add-apt-repository ppa:git-core/ppa
  apt-get update
  echo

  apt -y install git

  echo

  printInfo "Configure git color UI"
  /usr/bin/git config --global color.ui auto
fi

# Install gksu
installPackage "/usr/bin/gksu" "gksu"

# Install gnome-tweak-tool
installPackage "/usr/bin/gnome-tweak-tool" "gnome-tweak-tool"

# Install gparted
installPackage "/usr/sbin/gparted" "gparted"

# Install gstreamer1.0-libav
installPackage "/usr/share/doc/gstreamer1.0-libav/README" "gstreamer1.0-libav"

# Install htop
installPackage "/usr/bin/htop" "htop"

#
# irqbalance
#   o Install and activate for multi-core/multi-cpu systems
#
if [ $NUM_CPUS -gt 1 ]; then
  # Install irqbalance
  installPackage "/usr/sbin/irqbalance" "irqbalance"

  # Start irqbalance service
  if ! systemctl status irqbalance | grep -Fq "active (running)"; then
    printInfo "Start irqbalance service"

    systemctl start irqbalance

    echo
  fi

fi

# Install libpam-modules
installPackage "/usr/share/doc/libpam-modules/copyright" "libpam-modules"

# Install mesa-utils
installPackage "/usr/bin/glxinfo" "mesa-utils"

# Install net-tools
installPackage "/bin/netstat" "net-tools"

# Install nmap
installPackage "/usr/bin/nmap" "nmap"

# Install ntp
installPackage "/usr/sbin/ntpd" "ntp"

# Install openssh-client
installPackage "/usr/bin/ssh-keygen" "openssh-client"

# Install parallel
installPackage "/usr/bin/parallel" "parallel"

# Install pulseaudio-equalizer
if [ ! -f /usr/bin/pulseaudio-equalizer-gtk ]; then
  # BEGIN Install pulseaudio-equalizer

  printBanner "Installing pulseaudio-equalizer"

  printInfo "Adding webupd8.org PPA"
  add-apt-repository ppa:nilarimogard/webupd8
  apt update
  echo

  # Install the equalizer
  apt -y install pulseaudio-equalizer
  echo

  # Install PulseAudio icon
  printInfo "Installing pulseaudio icon"
  install -o root -g root -m 644 "$SCRIPT_DIR/usr/share/pixmaps/pulseaudio.png" /usr/share/pixmaps

  # .desktop directory
  desktopDir="usr/share/applications"

  # Fix icon in /usr/share/applications/pulseaudio-equalizer.desktop
  install -o root -g root -m 644 "$SCRIPT_DIR/$desktopDir/pulseaudio-equalizer.desktop" "/$desktopDir"

  # Presets directory
  presetsDir="usr/share/pulseaudio-equalizer/presets"

  # Install Default preset
  printInfo "Installing Default equalizer preset"
  install -o root -g root -m 644 "$SCRIPT_DIR/$presetsDir/Default.preset" "/$presetsDir"

  echo

  # END Install pulseaudio-equalizer
fi

# Install samba
installPackage "/usr/sbin/smbd" "samba"

# Install speedtest-cli
installPackage "/usr/bin/speedtest-cli" "speedtest-cli"

# Install sysstat
installPackage "/usr/bin/iostat" "sysstat"

# Install ttf-mscorefonts-installer
if [ ! -d /usr/share/fonts/truetype/msttcorefonts ]; then
  printBanner "Installing ttf-mscorefonts-installer"

  apt -y install ttf-mscorefonts-installer
  echo

  printInfo "Updating the font cache"
  fc-cache -f -v

  echo
fi

# Install unbound
installPackage "/usr/sbin/unbound" "unbound"

# Install vlc
installSnap "/snap/vlc" "vlc"

# Install whois
installPackage "/usr/bin/whois" "whois"

# Install xclip
installPackage "/usr/bin/xclip" "xclip"

# Install yad
installPackage "/usr/bin/yad" "yad"

# ~~~~~~~~~~~~~~~~~~~~~~~~~ System/User Configuration ~~~~~~~~~~~~~~~~~~~~~~~~~

#
# Filesystem Configuration
#

# Configure /etc/fstab with configure-fstab.sh script
$SHELL -c "$configFstab"

#
# Linux Kernel Tuning
#

# Configure /etc/sysctl.conf with configure-kernel.sh script
$SHELL -c "$configKernel"

#
# General System Configuration
#

# Configure system with configure-system.sh script
$SHELL -c "$configSystem"

#
# APT Sources Mirror Configuration
#

# Configure /etc/apt/sources.list with configure-apt-mirror.sh script
$SHELL -c "$configAptMirror"

#
# GRUB Configuration
#

# Configure /etc/default/grub with configure-grub.sh script
$SHELL -c "$configGrub"

#
# DevOpsBroker Configration Files
#

# Install /etc/dob/ansi.conf
installConfig "ansi.conf" "$SCRIPT_DIR/etc/dob" /etc/dob

# Install /etc/dob/functions.conf
installConfig "functions.conf" "$SCRIPT_DIR/etc/dob" /etc/dob

#
# Samba Configuration
#

# Configure /etc/samba/smb.conf with configure-samba.sh script
$SHELL -c "$configSamba"

#
# Systemwide Security Configuration
#

# Configure /etc/security with configure-security.sh script
$SHELL -c  "$configSecurity"

#
# Disk I/O Schedulers Configuration
#   o Non-rotational disks: kyber
#   o Rotational disks: bfq
#

# Install /etc/udev/rules.d/60-io-schedulers.rules
installConfig "60-io-schedulers.rules" "$SCRIPT_DIR/etc/udev/rules.d" /etc/udev/rules.d

#
# Unbound DNS Cache Server Configuration
#

# Configure /etc/unbound/unbound.conf.d/dns-cache-server.conf with configure-unbound.sh script
$SHELL -c "$configUnbound"

#
# User Configuration
#

# Configure the user with configure-user.sh script
$SHELL -c "$configUser $SUDO_USER"

#
# Upgrade Ubuntu
#

today=$(date -I)
if [ $(cat /etc/dob/last-update) != $today ]; then
  pms upgrade

  echo $today > /etc/dob/last-update
fi

echo "Done!"
echo

exit 0

