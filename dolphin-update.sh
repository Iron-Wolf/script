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

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

getdolphin() {
  echo 'Downloading Dolphin...'
  git clone https://github.com/dolphin-emu/dolphin.git
}

updatedolphin() {
  cd $DIR/dolphin
  echo 'Updating the local repository...'
  git pull origin
}

build() {
  cmake $DIR/dolphin -DENABLE_QT2=true
  make
}

updatedolphin || getdolphin
mkdir $DIR/build
cd $DIR/build
build && echo 'Compiled successfully.' || exit

echo 'Proceeding to the installation; press Enter to continue or Ctrl+C to cancel.'
read
if [ $(whoami) == "root" ];
  then
    make install
  else
    sudo make install
fi

