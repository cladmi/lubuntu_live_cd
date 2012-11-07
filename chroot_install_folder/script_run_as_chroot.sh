#! /bin/sh

cd $(dirname $(readlink -f $0))


# Run this as root

PACKET_INSTALL="build-essential \
	python2.7 git sshfs vim gnuplot\
	gstreamer0.10-ffmpeg gstreamer0.10-plugins-bad gperf\
	python-pip python-argparse"

set -xe

apt-get remove --purge $(dpkg-query -W --showformat='${Package}\n' | grep language-pack | egrep -v '\-en' | egrep -v '\-fr')

# install
apt-get update
apt-get upgrade
apt-get install $PACKET_INSTALL
apt-get autoremove




echo "Europe/Paris" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

# Install VBOX addition
# Cause autologin to fail

cp /bin/uname /bin/uname.real
cp uname /bin/uname

sh VBoxLinuxAdditions.run
usermod -u 501 vboxadd

mv /bin/uname.real /bin/uname


# rename User
sed -i 's/USERNAME=.*/USERNAME="tuto"/'     /etc/casper.conf
sed -i 's/HOST=.*/HOST="live-fit-senslab"/' /etc/casper.conf
sed -i '/^export FLAVOUR/d'                 /etc/casper.conf
echo 'export FLAVOUR="fit-senslab"'      >> /etc/casper.conf



# senslabcli
pip install requests
cd /tmp
wget http://www.senslab.info/alpha/senslabcli-1.0.tar.gz
tar xzvf  senslabcli-1.0.tar.gz
cd senslabcli-1.0
python setup.py install



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

BASHRC_ADD='# Senslab variables
export FIT_ECO="${HOME}/fit-eco"
export WSN430_DRIVERS_PATH="${FIT_ECO}/software/drivers/wsn430"
export WSN430_LIB_PATH="${FIT_ECO}/software/lib"
export FREERTOS_PATH="${FIT_ECO}/software/OS/FreeRTOS"
export CONTIKI_PATH="${FIT_ECO}/software/OS/Contiki"
'

sed -i 's/#\(force_color_prompt=yes\)/\1/' .bashrc
sed -i "/$FIRST/,/$LAST/d" .bashrc
echo "$FIRST" >> .bashrc
echo "$BASHRC_ADD" >> .bashrc
echo "$LAST" >> .bashrc

cd -



# clean before closing
apt-get clean

update-initramfs -k all -u

cd -
