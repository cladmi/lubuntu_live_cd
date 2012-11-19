#! /bin/bash

set -xe

source common.source

# test that commands are installed
for prog in "mkisofs" "isohybrid" "mksquashfs" ; do
	sudo which $prog || echo "'$prog' is required, please install it"
done

update_squashfs() {
	sudo rm -f $ISO_F/casper/filesystem.squashfs

	sudo chmod a+w $ISO_F/casper/filesystem.manifest
	sudo chroot $SQUASHFS dpkg-query -W --showformat='${Package} ${Version}\n' > $ISO_F/casper/filesystem.manifest
	sudo chmod go-w $ISO_F/casper/filesystem.manifest
	sudo touch $ISO_F/casper/filesystem.manifest-desktop
	sudo chmod a+w $ISO_F/casper/filesystem.manifest-desktop
	sudo chroot $SQUASHFS dpkg-query -W --showformat='${Package} ${Version}\n' > $ISO_F/casper/filesystem.manifest-desktop
	sudo chmod go-w $ISO_F/casper/filesystem.manifest-desktop

	cd $SQUASHFS
	sudo mksquashfs . ../$ISO_F/casper/filesystem.squashfs
	cd -
}

copy_initrd_vmlinuz() {
	# initrd file format == /boot/initrd-img.XXXXX == on the host system
	# output is changed to the file on the live CD
	SQUASH_INITRD_FILE=$(readlink -f $SQUASHFS/initrd.img | sed "s#^#$SQUASHFS/#")

	set +e
	INITRD_FILE=$(readlink -e $SQUASH_INITRD_FILE)
	VMLINUZ_FILE=$(readlink -e $SQUASHFS/vmlinuz)
	set -e

	# copy files if they exist
	if [[ "x$INITRD_FILE" != "x" ]]; then
		echo "Update initrd.lz file"
		sudo cp $INITRD_FILE iso/casper/initrd.lz
	else
		# there must be an initrd.lz file !
		echo "ERROR no initrd.lz file found"
		exit -1
	fi
	if [[ "x$VMLINUZ_FILE" != "x" ]]; then
		echo "Update vmlinux file"
		sudo cp $SQUASHFS/boot/vmlinuz iso/casper/vmlinuz
	else
		# there may not be any vmlinuz file if no dist-upgrade was done
		echo "No vmlinuz file, OK, continuing"
	fi
}


update_md5sum() {
	cd $ISO_F
	sudo bash -c "find . -path ./isolinux -prune -o -type f -not -name md5sum.txt -print0 | xargs -0 md5sum | tee md5sum.txt"
	cd ..
}

recreate_iso() {
	sudo mkisofs -r -V "Custom Ubuntu Live CD" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o custom-live-cd-i386.iso $ISO_F
}

make_iso_bootable_via_usb() {
	sudo isohybrid custom-live-cd-i386.iso
}



update_squashfs
copy_initrd_vmlinuz
update_md5sum

recreate_iso
make_iso_bootable_via_usb

