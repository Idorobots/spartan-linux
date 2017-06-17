# Generic x86_64 Spartan Linux

You'll need:

- [SYSLINUX](http://www.syslinux.org)

## Rootfs image

Create a suitable-sized file in `/path/to/image/rootfs.img`, mount it as a loopback device to `/path/to/image/mnt` and copy the rootfs contents there:

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

## Bootloader & bootable file system image

This repository includes a simple EXTLINUX config file that will boot a Linux kernel supplied in `/boot` directory of the root filesystem. To use it: re-mount the image, install the kernel image and EXTLINUX bootloader. Afterwards, mark the only partition as **bootable** and install the boot code:

```
$ cd /path/to/image
# cp /path/to/dist/kernel mnt/boot
# extlinux --install mnt/boot/syslinux/
# dd bs=440 count=1 if=/usr/lib/syslinux/bios/mbr.bin of=$LOOPBACK
$ echo -e 'a\nw\n' | fdisk rootfs.img
```

## Testing

The kernel image & root filesystem image can be run directly using QEMU:

```
$ qemu-system-x86_64 /path/to/image/rootfs.img
```
