#! /bin/sh

apt-get update

# Install library dependencies.
pkgblas="$(apt-cache search libblas3 | grep libblas3 | cut -d' ' -f1)"
pkglapack="$(apt-cache search liblapack3 | grep liblapack3 | cut -d' ' -f1)"
apt-get install -y ${pkgblas} libblas-dev ${pkglapack} liblapack-dev

# Install build dependencies.
apt-get install -y gcc g++ gfortran libc6-dev unzip
