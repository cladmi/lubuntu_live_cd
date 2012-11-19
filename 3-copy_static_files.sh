#! /bin/bash

set -xe
source common.source

install_mspgcc() {
	MSP=msp430-z1.tar.gz
	wget http://downloads.sourceforge.net/project/zolertia/Toolchain/$MSP -O $MSP
	mkdir -p root/opt
	tar   -C root/opt -xzvf $MSP
}

clone_git_repo() {
	PREV=$(pwd)
	cd  $SQUASHFS/etc/skel
	[ -d fit-eco ] || sudo git clone git://scm.gforge.inria.fr/fit-eco/fit-eco.git
	cd fit-eco
	sudo git checkout fit_versions
	cd $PREV
}

copy_static_files() {
	sudo cp -r root/* $SQUASHFS
}

install_mspgcc
clone_git_repo
copy_static_files

