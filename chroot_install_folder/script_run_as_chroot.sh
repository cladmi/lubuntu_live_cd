#! /bin/sh


# Run this as root


PACKET_INSTALL="build-essential python2.7 git sshfs"

set -x
apt-get update
apt-get upgrade


# install

apt-get install $PACKET_INSTALL




# clean before closing
# apt-get clean

