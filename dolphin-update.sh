#!/bin/bash
#
# +-------------+
# | Description |
# +-------------+
#
# This script checks for Dolphin's source code, downloads it or updates it,
# then compiles it and finally installs it. 
# It is somewhat interactive and distro-independent.
#
# Execute the script from anywhere, by running : sh /path/to/the/script.sh
#
#
# +--------------+
# | Dependencies |
# +--------------+
# All packages listed on the Wiki : https://wiki.dolphin-emu.org/index.php?title=Building_Dolphin_on_Linux#Addendum_A
# 
# You will also need :
# - checkinstall : to build the ".deb" package
#
#
# +-------------------+
# | Qt5 specification | /!\ No longer needed /!\
# +-------------------+
#
# As the implementation of Qt has matured, it is now used by default
# and is included in the project. This means that we no longer need
# to download Qt to build dolphin.
# I leave theses instructions here if needed.
#
# When building :
#   Add Qt binaries path to the PATH env variable : 
#     Qt/Tools/QtCreator/bin
#     Qt/5.10.1/gcc_64/bin
#
# Start building with :
#   $ env Qt5Gui_DIR=Qt/5.10.1/gcc_64/lib ./dolphin-update.sh
#
# Launch Dolphin with :
#   $ env LD_LIBRARY_PATH=Qt/5.10.1/gcc_64/lib dolphin-emu-qt2
#
#
# +---------------+
# | File location |
# +---------------+
#
# User's File : .local/share/dolphin-emu
# Config File : .config/dolphin-emu
# Instal File : /usr/local/share/dolphin-emu
#
#
# +-------------------------+
# | Build with checkinstall |
# +-------------------------+
#
# Once Dolphin is build, this script use checkinstall :
# - checkinstall need to be executed in the "build" directory
# - option '--install=no' is used to NOT install the package by default
# - the package is generated with : Name = dolphin-emu / Version = major number / Release = minor number
# - install it with 'dpkg -i'
#
# Don't forget to hold the package in apt. Otherwise, 
# it will be replaced the next time the system is updated :
#   $ apt-mark hold dolphin-emu
#   $ apt-mark showhold
#


# Global Variable
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
build_threads=$(( $(nproc) + 1 ))
package_cmd="checkinstall --install=no --showinstall=no --default \
  --pkgname=dolphin-emu \
  --pkgversion=5.0 \
  --pkgrelease=10506 \
  --pkgarch=amd64 \
  --maintainer=iw \
  --backup=no"

# Methods
getdolphin() {
  echo 'Downloading Dolphin...'
  git clone https://github.com/dolphin-emu/dolphin.git
}

updatedolphin() {
  cd $DIR/dolphin
  echo 'Updating the local repository...'
  git pull origin
  # you can also 'git checkout <id>' to get a specific version
  #git fetch origin
  #git checkout 8d4e8
}

build() {
  # If needed, export env variables
  # export CC=/usr/bin/gcc
  # export CXX=/usr/bin/g++
  cmake $DIR/dolphin -DENABLE_QT2=true
  make -j $build_threads
}


# Start script
updatedolphin || getdolphin
mkdir $DIR/build
cd $DIR/build
build && echo 'Compiled successfully.' || exit

echo 'Proceeding to the .deb packaging; press Enter to continue or Ctrl+C to cancel.'
read
if [ $(whoami) == "root" ];
  then
    $package_cmd
  else
    sudo $package_cmd
fi
