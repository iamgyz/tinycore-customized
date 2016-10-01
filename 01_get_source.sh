#!/bin/bash

# default config
URL="http://distro.ibiblio.org/tinycorelinux/4.x/x86_64"
ISO_URL="http://distro.ibiblio.org/tinycorelinux/7.x/x86_64"

INPUTISO="CorePure64-7.2.iso"
EXTENSIONS=("ntfs-3g.tcz")
BOOTARGS=""
ROOTFS=`pwd`"/rootfs"
# create our working folders
TMPDIR=`pwd`"/temp"

mkdir ${TMPDIR}
chmod 755 "${TMPDIR}"
mkdir -p dist/{iso,tcz,dep} "${TMPDIR}/cde/optional"


function getISO() {
    echo  "${ISO_URL}/${3}/${1}"
    [ -f "dist/${2}/${1}" ] || wget "${ISO_URL}/${3}/${1}" -O "dist/${2}/${1}" \
                            || [[ ${2} == dep ]] && touch "dist/${2}/${1}"

}

# downloads a file, only if it's not already cached
function cachefile() {
    [ -f "dist/${2}/${1}" ] || wget "${URL}/${3}/${1}" -O "dist/${2}/${1}" \
                            || [[ ${2} == dep ]] && touch "dist/${2}/${1}"
}

# download the ISO
getISO "${INPUTISO}" iso release

# get the contents of the iso
xorriso -osirrox on -indev "dist/iso/${INPUTISO}" -extract / "${TMPDIR}"


# install extensions and dependencies
while [ -n "${EXTENSIONS}" ] ; do
    DEPS=""
    for EXTENSION in ${EXTENSIONS} ; do
        cachefile "${EXTENSION}" tcz tcz
        cachefile "${EXTENSION}.dep" dep tcz
        cp "dist/tcz/${EXTENSION}" "${TMPDIR}/cde/optional"
        DEPS=$(echo ${DEPS} | cat - "dist/dep/${EXTENSION}.dep" | sort -u)
    done
    EXTENSIONS=$DEPS
done


# set extensions to start on boot
pushd ${TMPDIR}/cde/optional
    ls | tee ../onboot.lst > ../copy2fs.lst
popd


# alter isolinux config to use our changes
ISOLINUX_CFG="${TMPDIR}/boot/isolinux/isolinux.cfg"
sed -i 's/prompt 1/prompt 0/' "${ISOLINUX_CFG}"
sed -i "s/append/append cde ${BOOTARGS}/" "${ISOLINUX_CFG}"


#extract rootfs
mkdir ${ROOTFS}
mv ${TMPDIR}/boot/corepure64.gz ${ROOTFS}
cd ${ROOTFS}
gunzip corepure64.gz
cpio -i < corepure64
rm -rf corepure64

echo "Step1 DONE! Please customize your own rootfs in rootfs and run the second script"
