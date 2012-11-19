#! /bin/bash

source common.source

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
		sudo cp -r $i ${SQUASHFS}/${i}
	done
}

teardown()
{

	for i in $REV_MOUNTED; do
		sudo umount -lf ${SQUASHFS}/${i}
	done

	for i in  $COPIED_FILES; do
		sudo rm -r ${SQUASHFS}/$i
	done

}

# cleanup
teardown

set -e
setup
echo "Do all your modifications and then quit with 'exit'"
set +e; sudo chroot $SQUASHFS; set -e
teardown

exit 0

