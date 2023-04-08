#!/bin/bash
#
# +-------------+
# | Description |
# +-------------+
# This script clone and build the Bonzomatic software.
# It then generates a .deb package that can easily be installed/updated.
#
# Warning : this is only tested on Debian based systems.
# No support is provided for other systems.
#
# +--------------+
# | Dependencies |
# +--------------+
# You will need these packages :
# - git : clone the repo
# - cmake : generate the buildsystem of the project
# - checkinstall : build the ".deb" package
#
# +-----------------+
# | Troubleshooting |
# +-----------------+
# If error : Could NOT find OpenGL (missing: OPENGL_opengl_LIBRARY OPENGL_INCLUDE_DIR OpenGL)
# Solution : install package "libgl1-mesa-dev"
#
# If error : RandR headers not found; install libxrandr development package
# Solution : install package "xorg-dev"
#
# If error : GL/glu.h no such file or directory
# Solution : install package "libglu1-mesa-dev"
#
# If error : alsa/asoundlib.h no such file or directory
# Solution : install package "libasound2-dev"
#
# +--------------------+
# | Bonzomatic details |
# +--------------------+
# If launched from a folder, Bonzomatic will search for files :
#  - config.json : settings
#  - shader.glsl : last working shader
# If files not found, Bonzomatic will use default param and a sample shader.
# 
# To retrieve the screen width/height value to use in the "config.json" file,
# you can run this command : xrandr | grep ' connected'

# Global Variable
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
build_threads=$(( $(nproc) + 1 ))

# Descritpion of parameters :
#   pkgversion : year.month.day
#   pkgrelease : git commit ID
ck_install_cmd="checkinstall --install=no --showinstall=no --default \
  --pkgname=bonzomatic \
  --pkgversion=2022.08.20 \
  --pkgrelease=5afe3cbc \
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
