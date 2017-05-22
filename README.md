# Spartan Linux

Based on [this](https://github.com/MichielDerhaeg/build-linux) instruction. You'll need:

- [musl](https://www.musl-libc.org/)
- *nix environment (make, wget, tar, patch, etc)

## Building

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
# mkfs.ext4 "${LOOPBACK}p1"
$ mkdir /path/to/mnt/rootfs.img
# mount "${LOOPBACK}p1" /path/to/mnt/rootfs.img
# cp -r /path/to/dist/fs/* /path/to/mnt/rootfs.img
# sync
# umount /path/to/mnt/rootfs.img
# losetup -d "${LOOPBACK}"
```

## Testing

The kernel image & root filesystem image can be run directly using QEMU:

```
$ qemu-system-x86_64 -kernel /path/to/dist/bzImage -append "root=/dev/sda1" /path/to/rootfs.img
```
