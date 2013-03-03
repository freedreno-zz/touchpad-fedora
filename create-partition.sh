#!/bin/bash -e

partition_size=$1

if [ "x" = "x$partition_size" ] || ! [[ "$partition_size" =~ ^[0-9]+$ ]]; then
	echo "usage: $0 <partition_size>"
	echo "creates a <partition_size>MB partition"
	exit 1
fi


# we can't very easily do interactive cmds w/ novacom, so instead we
# build up a shell script to run to do what we want on the device:
novacom put file:///tmp/do-resize-partition.sh <<EOF
#!/bin/sh -e

PARTITION=$partition_size
echo "Creating \${PARTITION}MB partition"
CURRENTSIZE=\$(lvm.static lvdisplay -c store/media | awk -F: '{print \$7/2048}')
NEWSIZE=\$((\$CURRENTSIZE - \$PARTITION))

echo "Your new partition layout will include a \${PARTITION}MB ext3 partition and a \${NEWSIZE}MB media partition."
echo "Does this seem correct? If so, type 1, if not, type 0."
read OK
if [ \$OK == "y" ];
	then echo "Ok, continuing."
else
	echo "Goodbye."
	exit
fi

echo "Repartition to create ext3 volume for Fedora."
pkill -SIGUSR1 cryptofs
umount /media/internal

echo "Now resizing your media partition and creating the ext3 partition for Fedora"
resizefat /dev/store/media \${NEWSIZE}M
lvresize -f -L -\${PARTITION}M /dev/store/media
lvcreate -L \${PARTITION}M -n fedora-root store
mkfs.ext3 /dev/store/fedora-root 
sync

# Possibly we don't actually have to reboot here..
echo "Rebooting..."
reboot
EOF

novacom run file:///bin/chmod 755 /tmp/do-resize-partition.sh
novacom run file:///tmp/do-resize-partition.sh

