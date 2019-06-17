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
# Execute the script from anywhere, by running sh /path/to/the/script.sh
#
# https://wiki.dolphin-emu.org/index.php?title=Building_Dolphin_on_Linux#Addendum_A
#
#
# +-------------------+
# | Qt5 specification |
# +-------------------+
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
# Once Dolphin is build, cancel installation and use checkinstall :
# - go in the build directory
# - use 'sudo checkinstall --install=no' to customize the package
# - generate the package with : Name = dolphin-emu / Version = major number / Release = minor number
# - install the package with dpkg
#
# Don't forget to hold the package in apt, otherwise, it will be replaced the next time the system is updated :
# - apt-mark hold dolphin-emu
# - apt-mark showhold
#


# Global Variable
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
build_threads=$(( $(nproc) + 1 ))
install_cmd="checkinstall --install=no --showinstall=no --default \
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

echo 'Proceeding to the installation; press Enter to continue or Ctrl+C to cancel.'
read
if [ $(whoami) == "root" ];
  then
    $install_cmd
  else
    sudo $install_cmd
fi
