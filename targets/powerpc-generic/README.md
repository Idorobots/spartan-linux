# Generic 32-bit PowerPC Spartan Linux

## Rootfs image

Create a suitable-sized file in `/path/to/image/rootfs.img`, mount it as a loopback device to `/path/to/image/mnt` and copy the rootfs contents there.

```
$ cd /path/to/image
$ fallocate -l64M rootfs.img
$ echo -e 'o\nn\np\n\n\n\nw\n' | fdisk rootfs.img
# export LOOPBACK=`losetup -P -f --show rootfs.img`
# mkfs.ext4 -O^64bit "${LOOPBACK}p1"
$ mkdir mnt
# mount "${LOOPBACK}p1" mnt
# cp -r /path/to/dist/fs/* mnt
# sync
# umount mnt
# losetup -d "$LOOPBACK"
```

## Testing

The kernel image & root filesystem image can be run directly using QEMU:

```
qemu-system-ppc -M mac99 -m 512 -kernel path/to/rootfs/boot/vmlinux -append "root=/dev/sda1" path/to/image/rootfs.img
```
