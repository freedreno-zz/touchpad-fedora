#!/bin/bash -e

moboot=uImage.moboot_0.3.8
kernel=uImage.Fedora

cat <<EOF
This script installs moboot and kernel.  The moboot src can be had at:

   git://github.com/jcsullins/moboot.git

And the kernel:

   git://github.com/freedreno/kernel-msm.git
   branch: hp-tenderloin-3.0
   use tenderloin_rob_defconfig

Note that kernel uImage is not a normal uImage, but has has ramdisk
embedded.  It can be created with mkimage:

  mkimage -A arm -O linux -T multi -a 0x40208000 -e 0x40208000 -C none -n "multi image" -d arch/arm/boot/uImage:uRamdisk uImage.Fedora

EOF

# Put the files we'll need in /tmp
novacom put file:///tmp/$moboot < boot/$moboot
novacom put file:///tmp/$kernel < boot/$kernel
novacom put file:///tmp/moboot.background.tga < boot/moboot.background.tga

# we can't very easily do interactive cmds w/ novacom, so instead we
# build up a shell script to run to do what we want on the device:
novacom put file:///tmp/do-setup-boot.sh <<EOF
#!/bin/sh -e

echo "Mount boot writable."
mount -o rw,remount /boot

echo "Install moboot."
mv /tmp/$moboot /boot/uImage.moboot
cd /boot
rm uImage
ln -s uImage.moboot uImage

# setup symlink so moboot gives user a boot-to-webos option:
rm -f uImage.webOS
ln -s uImage-2.6.35-palm-tenderloin uImage.webOS

# install moboot theme/background:
mv /tmp/moboot.background.tga /boot/moboot.background.tga

mv /tmp/$kernel /boot/$kernel
echo "yes" > moboot.verbose.${kernel##uImage\.} sync

cd /tmp
sync

echo "Mount boot read-only."
mount -o ro,remount /boot

echo "Done!"

EOF

novacom run file:///bin/chmod 755 /tmp/do-setup-boot.sh
novacom run file:///tmp/do-setup-boot.sh

