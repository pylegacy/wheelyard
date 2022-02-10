#! /bin/sh

apt-get update

# Install library dependencies.
pkghdf4="$(apt-cache search libhdf4 | grep dev | cut -d' ' -f1)"
apt-get install -y ${pkghdf4}

# Install build dependencies.
apt-get install -y gcc g++ libc6-dev unzip
