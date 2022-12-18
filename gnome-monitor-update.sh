#!/bin/bash
#
# Manual installation of the system monitor extension
# from the github repo.
# 
# For now, the extensions.gnome.org repo contains an
# outdated version : 
# https://github.com/paradoxxxzero/gnome-shell-system-monitor-applet/issues/422
#
# Important : 
# After running this script, reload gnome-shell with ALT+F2, then "r"
#

rm -rf ~/.local/share/gnome-shell/extensions/system-monitor@paradoxxx.zero.gmail.com
git clone --depth=1 https://github.com/paradoxxxzero/gnome-shell-system-monitor-applet.git /tmp/system-monitor-complete
mv /tmp/system-monitor-complete/system-monitor@paradoxxx.zero.gmail.com ~/.local/share/gnome-shell/extensions/
rm -rf /tmp/system-monitor-complete
gnome-shell-extension-tool --enable-extension=system-monitor@paradoxxx.zero.gmail.com
