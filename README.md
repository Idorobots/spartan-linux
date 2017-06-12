# Spartan Linux

A Linux kernel with statically-compiled Busybox & Dropbear userspace. Based on [this](https://github.com/MichielDerhaeg/build-linux) instruction.

## Building

You'll need:

- *nix environment (make, wget, tar, patch, etc)
- gperf, help2man & other [crosstool-ng](http://crosstool-ng.github.io/) dependencies
- [SYSLINUX](http://www.syslinux.org)

### Kernel & Userspace

Simply run:

```
$ make -j8
```

### Rootfs image

Create a suitable-sized file in `/path/to/rootfs.img`, mount it as a loopback device to `/path/to/mnt/rootfs.img` and copy the rootfs contents there:

```
$ fallocate -l64M /path/to/rootfs.img
$ echo -e 'o\nn\np\n\n\n\nw\n' | fdisk /path/to/rootfs.img
# export LOOPBACK=`losetup -P -f --show /path/to/rootfs.img`
# mkfs.ext4 -O^64bit "${LOOPBACK}p1"
$ mkdir /path/to/mnt/rootfs.img
# mount "${LOOPBACK}p1" /path/to/mnt/rootfs.img
# cp -r /path/to/dist/fs/* /path/to/mnt/rootfs.img
# sync
# umount /path/to/mnt/rootfs.img
# losetup -d "$LOOPBACK"
```

### Bootloader & bootable file system image

This repository includes a simple EXTLINUX config file that will boot a Linux kernel supplied in `/boot` directory of the root filesystem. To use it: re-mount the image, install the kernel `bzImage` and install EXTLINUX bootloader:

```
# cp /path/to/bzImage /path/to/mnt/rootfs.img/boot/
# extlinux --install /path/to/mnt/rootfs.img/boot/syslinux/
```

Afterwards, mark the only partition as **bootable** and install the boot code:

```
# dd bs=440 count=1 if=/usr/lib/syslinux/bios/mbr.bin of=$LOOPBACK
$ echo -e 'a\nw\n' | fdisk /path/to/rootfs.img
```

## Testing

The kernel image & root filesystem image can be run directly using QEMU:

```
$ qemu-system-x86_64 -kernel /path/to/dist/bzImage -append "root=/dev/sda1" /path/to/rootfs.img
```

Alternatively, you can boot the bootable file system image:

```
$ qemu-system-x86_64 /path/to/rootfs.img
```
