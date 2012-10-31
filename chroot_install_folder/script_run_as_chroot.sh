#! /bin/sh

cd $(dirname $(readlink -f $0))


# Run this as root

PACKET_INSTALL="build-essential python2.7 git sshfs vim gnuplot gstreamer0.10-ffmpeg gstreamer0.10-plugins-bad gperf tk ant openjdk-6-jdk subversion"

set -x
apt-get update
apt-get upgrade


# install

apt-get install $PACKET_INSTALL


# rename User
sed -i '/USERNAME/ s/".*"/"fit-senslab"/' /etc/casper.conf





cd /etc/skel

FIRST="#_BEGIN_FIT_SENSLAB_LINES"
PROFILE_ADD='# set PATH to includes mspgcc bin if it exists
if [ -d "/opt/mspgcc/bin" ] ; then
	PATH="$PATH:/opt/mspgcc/bin"
fi'
LAST="#_END_FIT_SENSLAB_LINES"

sed -i "/$FIRST/,/$LAST/d" .profile
echo "$FIRST" >> .profile
echo "$PROFILE_ADD" >> .profile
echo "$LAST" >> .profile

cd -





# Install VBOX addition
sh VBoxLinuxAdditions.run


# clean before closing
apt-get clean

update-initramfs -k all -u
cd -
