#! /bin/sh

apt-get update

# Make temporary backup of SSL certificates.
cp -R /etc/ssl /tmp/tmp-etc-ssl

# Install library dependencies.
pkghdf5="$(apt-cache search libhdf5-serial | grep dev | cut -d' ' -f1)"
pkgnetcdf4="$(apt-cache search libnetcdf-dev | grep dev | cut -d' ' -f1)"
apt-get install -y ${pkghdf5} ${pkgnetcdf4}

# Install build dependencies.
apt-get install -y gcc libc6-dev unzip

# Restore SSL certificates.
rm -rf /etc/ssl
mv /tmp/tmp-etc-ssl /etc/ssl
