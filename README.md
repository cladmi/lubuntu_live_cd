Create SensLAB liveCD
=====================

Execute the scripts in the following order

* 1-unpack_iso.sh
* 2-chroot.sh
    * From the chrooted environment:
    * run your personnal update commands
    * /chroot_install_folder/script_run_as_chroot.sh
* 3-copy_static_files.sh
* 4-repack_iso.sh


Blocking steps
--------------