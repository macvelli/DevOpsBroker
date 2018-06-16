#!/bin/bash

#
# gsettings.sh - Description goes here
#
# Copyright (C) 2018 AUTHOR_NAME <email@address.com>
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
# NOTE: This script *cannot* be executed as root. The dconf settings will not
#	apply to the user otherwise
# -----------------------------------------------------------------------------
#


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Preprocessing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Display error if running as root
if [ "$EUID" -eq 0 ]; then
  echo -e "\033[1mgsettings.sh: \033[38;5;203mPermission denied (you cannot be root)\033[0m"

  exit 1
fi

# Load /etc/dob/ansi.conf if bittersweet function does not exist
if [[ ! "$(declare -F 'bittersweet')" ]]; then
  . /etc/dob/ansi.conf
fi

# Load /etc/dob/functions.conf if printBanner function does not exist
if [[ ! "$(declare -F 'printBanner')" ]]; then
  . /etc/dob/functions.conf
fi


################################## Questions ##################################

# Clear screen and print banner only if called from command line
if [ $SHLVL -eq 2 ]; then
  clear

  bannerMsg="DevOpsBroker Ubuntu 16.04 Desktop GSettings Configurator"

  echo -e $(bold kobi)
  echo    "╔══════════════════════════════════════════════════════════╗"
  echo -e "║ "$(white)$bannerMsg$(kobi)                              "║"
  echo    "╚══════════════════════════════════════════════════════════╝"
  echo -e $(reset)

fi

#
# Show application menus in window title bar
#   o System Settings -> Appearance -> Behavior
#
echo "Want the menus in the title bar for a window?"
select titleBarMenus in "Yes" "No"; do
  break;
done

echo

#
# Enable workspaces
#   o System Settings -> Appearance -> Behavior
#
echo "Want to enable workspaces?"
select workspaces in "Yes" "No"; do
  break;
done

echo

################################### Actions ###################################

# Title bar menus
if [ "$titleBarMenus" == "Yes" ]; then
  printInfo "Enabling title bar menus"

  # Enable integrated menus
  dconf write /com/canonical/unity/integrated-menus true

else
  printInfo "Disabling title bar menus"

  # Disable integrated menus
  dconf write /com/canonical/unity/integrated-menus false

fi

# Workspaces
if [ "$workspaces" == "Yes" ]; then
  printInfo "Enabling workspaces"

  # Enable workspaces
  dconf write /org/compiz/profiles/unity/plugins/core/hsize 2
  dconf write /org/compiz/profiles/unity/plugins/core/vsize 2

else
  printInfo "Disabling workspaces"

  # Disable workspaces
  dconf write /org/compiz/profiles/unity/plugins/core/hsize 1
  dconf write /org/compiz/profiles/unity/plugins/core/vsize 1

fi

echo

exit 0

