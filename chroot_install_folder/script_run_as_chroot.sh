#! /bin/sh

cd $(dirname $(readlink -f $0))


# Run this as root

PACKET_INSTALL="build-essential \
	python2.7 git sshfs vim gnuplot\
	gstreamer0.10-ffmpeg gstreamer0.10-plugins-bad gperf tk ant openjdk-6-jdk "

set -xe

# install
apt-get update
# apt-get dist-upgrade
apt-get install $PACKET_INSTALL

# Install VBOX addition
# sh VBoxLinuxAdditions.run

# rename User
sed -i 's/USERNAME=.*/USERNAME="tuto"/' /etc/casper.conf
sed -i 's/HOST=.*/HOST="live-fit-senslab"/' /etc/casper.conf
sed -i '/^export FLAVOUR/d' /etc/casper.conf
echo 'export FLAVOUR="fit-senslab"' > /etc/casper.conf



# User Home modifications
cd /etc/skel

FIRST="#_BEGIN_FIT_SENSLAB_LINES"
PROFILE_ADD='# set PATH to includes mspgcc bin if it exists
if [ -d "/opt/msp430-z1/bin" ] ; then
	PATH="$PATH:/opt/msp430-z1/bin"
fi'
LAST="#_END_FIT_SENSLAB_LINES"

sed -i "/$FIRST/,/$LAST/d" .profile
echo "$FIRST" >> .profile
echo "$PROFILE_ADD" >> .profile
echo "$LAST" >> .profile

cd -



# clean before closing
apt-get clean

update-initramfs -k all -u

cd -
