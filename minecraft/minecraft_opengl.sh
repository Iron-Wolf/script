#!/bin/bash
#
# Enforce open source driver (Mesa3D) and launch minecraft.
#
# Note that these environment variables will work for any 
# OpenGL game/application that does not request the core profile from Mesa.
# Source : https://www.youtube.com/watch?v=7oKsJ5WXdOo

# For Mesa versions older than 18.3.3
#export MESA_GL_VERSION_OVERRIDE=4.5COMPAT
#export MESA_GLSL_VERSION_OVERRIDE=450
#export allow_higher_compat_version=true

export force_glsl_extensions_warn=true
export vblank_mode=0
export mesa_glthread=true

./minecraft-launcher
