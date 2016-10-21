#!/bin/sh

rm -rf opencv-cuda-git

git clone https://aur.archlinux.org/opencv-cuda-git.git \
    && cd opencv-cuda-git \
    && ln -sf /sources/opencv-git opencv \
    && ln -sf /sources/opencv_contrib-git opencv_contrib \
    && ln -sf /sources/ippicv_linux_20151201.tgz \
    && makepkg -Asf

sudo pacman --noconfirm -U opencv-cuda-git/opencv-cuda-git-*.pkg.tar.xz

