#! /bin/sh



CHROOT_INSTALL_FILES="chroot_install_folder"

LIVECD="lubuntu-12.04-desktop-i386.iso"
ISO_F="iso"
SQUASHFS="squashfs"
CDROM="/media/cdrom"

MOUNTED="/proc /sys /dev /dev/pts /var/run/dbus/"
REV_MOUNTED=$(echo $MOUNTED | tac -s' ')

COPIED_FILES="/etc/resolv.conf /etc/hosts $CHROOT_INSTALL_FILES"

set -x
setup() 
{
	for i in $MOUNTED; do
		sudo mount --bind $i ${SQUASHFS}/${i}
	done

	for i in  $COPIED_FILES; do
		sudo cp $i ${SQUASHFS}/${i}
	done
}

teardown()
{

	for i in $REV_MOUNTED; do
		sudo umount -lf ${SQUASHFS}/${i}
	done

	for i in  $COPIED_FILES; do
		sudo rm ${SQUASHFS}/$i
	done

}

setup
echo "Do all your modifications and then quit with 'exit'"
sudo chroot $SQUASHFS

teardown
exit 0

