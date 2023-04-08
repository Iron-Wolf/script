#!/bin/bash
#
# +-------------+
# | Description |
# +-------------+
# This script clone and build the Bonzomatic software.
#
# +--------------+
# | Dependencies |
# +--------------+
# You will need these packages :
# - git : clone the repo
# - cmake : generate the buildsystem of the project
# - checkinstall : build the ".deb" package
#
# +----------------+
# | Troubleshoting |
# +----------------+
# If error 
# -- Could NOT find OpenGL (missing: OPENGL_opengl_LIBRARY OPENGL_INCLUDE_DIR OpenGL)
# -> install : libgl1-mesa-dev
#
# If error :
# -- RandR headers not found; install libxrandr development package
# -> install : xorg-dev
#
# +--------------------+
# | Bonzomatic details |
# +--------------------+
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
  --pkgversion=2022.08.20 \
  --pkgrelease=5afe3cbce0de58b80ad0b43487788a93e5d39594 \
  --pkgarch=amd64 \
  --maintainer=iw \
  --backup=no"

# Methods
getBonzo() {
  echo 'Downloading...'
  git clone https://github.com/Gargaj/Bonzomatic.git
}

updateBonzo() {
  cd $DIR/Bonzomatic
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
