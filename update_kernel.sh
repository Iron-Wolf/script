#!/bin/bash
#
# Retrieve latest pre-compiled kernel from :
# https://kernel.ubuntu.com/~kernel-ppa/mainline
#
# Purge old kernel with : 
# sudo dpkg --purge linux-image-unsigned-5.6.0-050600-generic
#

wget -c https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.6.7/linux-headers-5.6.7-050607_5.6.7-050607.202004230933_all.deb

wget -c https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.6.7/linux-headers-5.6.7-050607-generic_5.6.7-050607.202004230933_amd64.deb

wget -c https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.6.7/linux-image-unsigned-5.6.7-050607-generic_5.6.7-050607.202004230933_amd64.deb

wget -c https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.6.7/linux-modules-5.6.7-050607-generic_5.6.7-050607.202004230933_amd64.deb

# Install downloaded files with :
# sudo dpkg -i *.deb
# sudo update-grub
