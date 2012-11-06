#! /bin/sh

LIVECD="lubuntu-12.04-desktop-i386.iso"
ISO_F="iso"
SQUASHFS="squashfs"
CDROM="/media/cdrom"

set -xe


# MSPGCC
MSP=msp430-z1.tar.gz
wget http://downloads.sourceforge.net/project/zolertia/Toolchain/msp430-z1.tar.gz -O $MSP
mkdir -p root/opt
tar   -C root/opt -xzvf $MSP

PREV=$(pwd)
cd  $SQUASHFS/etc/skel
[ -d fit-eco ] || sudo git clone git://scm.gforge.inria.fr/fit-eco/fit-eco.git
cd fit-eco
sudo git checkout fit_versions
cd $PREV



sudo cp -r root/* $SQUASHFS

sudo rm -f $ISO_F/casper/filesystem.squashfs

sudo chmod a+w $ISO_F/casper/filesystem.manifest
sudo chroot $SQUASHFS dpkg-query -W --showformat='${Package} ${Version}\n' > $ISO_F/casper/filesystem.manifest
sudo chmod go-w $ISO_F/casper/filesystem.manifest
sudo touch $ISO_F/casper/filesystem.manifest-desktop
sudo chmod a+w $ISO_F/casper/filesystem.manifest-desktop
sudo chroot $SQUASHFS dpkg-query -W --showformat='${Package} ${Version}\n' > $ISO_F/casper/filesystem.manifest-desktop
sudo chmod go-w $ISO_F/casper/filesystem.manifest-desktop



cd $SQUASHFS
sudo mksquashfs . ../$ISO_F/casper/filesystem.squashfs -info
cd -

sudo cp $SQUASHFS/boot/initrd.img-3.2.0-23-generic iso/casper/initrd.lz
# sudo cp $SQUASHFS/boot/vmlinuz iso/casper/vmlinuz

cd $ISO_F
sudo bash -c "find . -path ./isolinux -prune -o -type f -not -name md5sum.txt -print0 | xargs -0 md5sum | tee md5sum.txt"
cd ..


sudo mkisofs -r -V "Custom Ubuntu Live CD" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o custom-live-cd-i386.iso $ISO_F


sudo isohybrid custom-live-cd-i386.iso


