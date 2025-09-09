#!/bin/sh
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

pacman -Q           > ${SCRIPT_DIR}/manjaro-cinnamon-$(uname -r).pacman-pkgs.txt 
vainfo              > ${SCRIPT_DIR}/manjaro-cinnamon-$(uname -r).vainfo.txt 
inxi -MCaGxA        > ${SCRIPT_DIR}/manjaro-cinnamon-$(uname -r).inxi-MCaGxA.txt
lspci | grep -i amd > ${SCRIPT_DIR}/manjaro-cinnamon-$(uname -r).lspci-amd.txt
cat /proc/cmdline   > ${SCRIPT_DIR}/manjaro-cinnamon-$(uname -r).proc-cmdline_defaultLiveCD.txt
