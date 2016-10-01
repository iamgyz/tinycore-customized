#!/bin/bash

# default config
OUTPUTISO="tinycore-custom.iso"
TMPDIR=`pwd`"/temp"

ROOTFS=`pwd`"/rootfs"
VOLUMEID="tinycore-custom"

# build the rootfs and place it on the iso
if [ -d ${ROOTFS} ] ; then
	cd ${ROOTFS}
	find | cpio -o -H newc | gzip -2 > "${TMPDIR}/boot/corepure64.gz"
	cd -
fi


# build a new iso
xorriso -as mkisofs -iso-level 3 -full-iso9660-filenames -volid "${VOLUMEID}" \
        -eltorito-boot boot/isolinux/isolinux.bin -boot-load-size 4 \
        -eltorito-catalog boot/isolinux/boot.cat -boot-info-table \
        -no-emul-boot -output "${OUTPUTISO}" "${TMPDIR}"

echo "DONE!"
