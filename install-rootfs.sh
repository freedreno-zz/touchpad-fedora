#!/bin/bash

echo "Mount rootfs."
novacom run "file:///bin/mkdir -p /tmp/linux"
novacom run "file:///bin/mount /dev/store/fedora-root /tmp/linux"

for f in rootfs/*.tar.gz; do
	echo "Extracting: $f"
	novacom run "file:///bin/tar -C /tmp/linux -xvzf -" < $f
done

echo "Unmounting rootfs."
novacom run "file:///bin/sync"
novacom run "file:///bin/umount /tmp/linux"

echo "Rebooting."
novacom run "file:///bin/reboot"

