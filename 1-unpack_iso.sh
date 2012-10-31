#! /bin/sh

set -x


LIVECD="lubuntu-12.04-desktop-i386.iso"
ISO_F="iso"
SQUASHFS="squashfs"
CDROM="/media/cdrom"


init()
{
	mkdir $ISO_F $SQUASHFS
}
clean()
{
	sudo umount $CDROM
	sudo rm -rf $ISO_F $SQUASHFS
}
unpack_iso()
{
	sudo mount -o loop $LIVECD $CDROM

	sudo cp -a $CDROM/. $ISO_F  # keep file permissions
	sudo umount $CDROM

	# remove Windows 'install' files
	{
		cd $ISO_F; 
		sudo rm -r wubi.exe autorun.inf; 
		cd - >/dev/null;
	}
}

unpack_squashfs()
{
	sudo mount -t squashfs -o loop $ISO_F/casper/filesystem.squashfs $CDROM
	sudo cp -av $CDROM/. $SQUASHFS
	sudo umount $CDROM
}

clean
init
unpack_iso
unpack_squashfs

exit 0
