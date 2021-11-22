#!/bin/bash
#
# +-------------+
# | Description |
# +-------------+
# Clone and build Bonzomatic.
#
# If launched from a folder, Bonzomatic will search for files :
#  - config.json : settings
#  - shader.glsl : last working shader
# If files not found, Bonzomatic will use default param and
# a sample shader

# Global Variable
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
build_threads=$(( $(nproc) + 1 ))

# Descritpion of parameters :
#   pkgversion : year.month.day
#   pkgrelease : git commit ID
ck_install_cmd="checkinstall --install=no --showinstall=no --default \
  --pkgname=bonzomatic \
  --pkgversion=21.04.16 \
  --pkgrelease=f6570cc \
  --pkgarch=amd64 \
  --maintainer=iw \
  --backup=no"

# Methods
getBonzo() {
  echo 'Downloading...'
  git clone https://github.com/Gargaj/Bonzomatic.git
}

updateBonzo() {
  cd $DIR/dolphin
  echo 'Updating the local repository...'
  git pull origin
}


build() {
  cmake $DIR/Bonzomatic
  make -j $build_threads
}


# Start script
updateBonzo || getBonzo
mkdir $DIR/build
cd $DIR/build
build && echo 'Compiled successfully' || exit


echo 'Proceeding to the installation; press Enter to continue or Ctrl+C to cancel.'
read
if [ $(whoami) == "root" ];
  then
    $ck_install_cmd
  else
    sudo $ck_install_cmd
fi
