#! /bin/sh

apt-get update

# Install library dependencies.
pkglibpng="$(apt-cache search libpng12-dev | grep libpng12-dev | cut -d' ' -f1)"
pkgfreetype="$(apt-cache search libfreetype6-dev | grep libfreetype6-dev | cut -d' ' -f1)"
apt-get install -y ${pkglibpng} ${pkgfreetype}

# Install build dependencies.
apt-get install -y gcc g++ libc6-dev make pkg-config unzip
