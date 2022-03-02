#! /bin/sh

apt-get update

# Install library dependencies.
pkghdf5="$(apt-cache search libhdf5-serial | grep dev | cut -d' ' -f1)"
pkgnetcdf4="$(apt-cache search libnetcdf-dev | grep dev | cut -d' ' -f1)"
apt-get install -y ${pkghdf5} ${pkgnetcdf4}

# Install build dependencies.
apt-get install -y gcc libc6-dev unzip
