Create Custom liveCD
====================

This are the scripts used to create a live cd for the SensLab platform.

Githubers interest is the content of the scripts and the problems I got and how they got solved.

Creating a customized livecd
----------------------------

Execute the scripts in the following order

* 1-unpack_iso.sh
* 2-chroot.sh
    * From the chrooted environment:
    * run your personal update commands
    * /chroot_install_folder/script_run_as_chroot.sh
* 3-copy_static_files.sh
* 4-repack_iso.sh


Personalization, what to do before using
----------------------------------------

1. Update the common.source to set the correct livecd url and the directories
2. Personalize the content of `chroot_install_folder/script_run_as_chroot.sh`
3. Personalize the content of `3-copy_static_files.sh`
4. Add files to copy on the livecd in `root` folder. Files in `root/etc/skel` will be copied in the user home directory.
5. Update the version of `chroot_install_folder/VBoxLinuxAdditions.run`

Blocking steps
--------------

I updated the documentation on the Ubuntu English and French wikis to correct errors I got. So errors mentioned here are already solved in the documentation.

### casper.conf ###

The documentation on liveCDcustomization used an out of date /etc/casper.conf and did not mention the `FLAVOUR` command that must be set in order to take the other variables into account.

It should be set to something

	# This file should go in /etc/casper.conf
	# Supported variables are:
	# USERNAME, USERFULLNAME, HOST, BUILD_SYSTEM, FLAVOUR

	export USERNAME="custom-username"
	export USERFULLNAME="Live session user"
	export HOST="ubuntu"
	export BUILD_SYSTEM="Ubuntu"

	# USERNAME and HOSTNAME as specified above won't be honoured and will be set to
	# flavour string acquired at boot time, unless you set FLAVOUR to any
	# non-empty string.

	export FLAVOUR="MyLiveCD"


### Installing virtual box guest additions breaks startup ###

On boot, the casper scripts that configure the livecd environment creates an user with UID=999 (see /usr/share/initramfs-tools/scripts/casper-bottom/25adduser).
If this UID is already used, the creation fails.

VirtualBoxGuestAdditions creates an user which may get the 999 UID

	# This is the LSB version of useradd and should work on recent
	# distributions
	useradd -d /var/run/vboxadd -g 1 -r -s /bin/false vboxadd >/dev/null 2>&1
	# And for the others, we choose a UID ourselves
	useradd -d /var/run/vboxadd -g 1 -u 501 -o -s /bin/false vboxadd >/dev/null 2>&1

On my lubuntu it's the first command that creates the user `vboxadd` with an uid == 999.

So, I changed the uid for 501 with the command:

	usermod -u 501 vboxadd

The English Ubuntu Wiki mentioned to pay attention to users with UID > 999, but did not include 999. And I removed the mention to UID > 999 as it has no reason to exist anymore.

### Compiling VBoxGuestAdditions on a different architecture and kernel version ###

When compiling the vbox module, the system rely on the result of `uname` command.
But, on a `chrooted` environment, the value return are the one of the host computer.

As the PATH is somehow manipulated during the execution, the easiest solution was to overwrite the regular `/bin/uname` with a script that basically does

	/bin/uname.real $@ | sed "s/$KERNEL/$DEST_KERNEL/g; s/$PROCESSOR/$DEST_PROCESSOR/g"

The complete `uname` script can be found in the `chroot_install_folder` directory.


## Links ##

Ubuntu customization scripts:
* https://help.ubuntu.com/community/LiveCDCustomization
* http://doc.ubuntu-fr.org/personnaliser_livecd

uname idea found here:
* https://github.com/aix27249/chroot_scripts/blob/master/fake-uname/uname


