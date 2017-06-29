# Generic 32-bit PowerPC Spartan Linux

You'll need:

- [yaboot](https://github.com/pnasrat/yaboot)
- [parted](https://www.gnu.org/software/parted/)
- [hformat](https://github.com/Distrotech/hfsutils)

## Rootfs image

Create a suitable-sized file in `/path/to/image/rootfs.img`, mount it as a loopback device to `/path/to/image/mnt` and copy the rootfs contents there.

```
$ cd /path/to/image
$ fallocate -l64M rootfs.img
$ echo -e 'mktable mac\nmkpart primary hfs 1MB 3MB\nmkpart primary ext4 3MB 100%\nquit\n' | parted rootfs.img
# export LOOPBACK=`losetup -P -f --show rootfs.img`
# hformat "${LOOPBACK}p2"
# mkfs.ext4 -O^64bit "${LOOPBACK}p3"
$ mkdir bootcode
# mount "${LOOPBACK}p2" bootcode
# cp /path/to/dist/fs/boot/yaboot* bootcode
$ mkdir mnt
# mount "${LOOPBACK}p3" mnt
# cp -r /path/to/dist/fs/* mnt
# sync
# umount bootcode
# umount mnt
# losetup -d "$LOOPBACK"
```

## Testing

The kernel image & root filesystem image can be run directly using QEMU:

```
qemu-system-ppc -M mac99 path/to/image/rootfs.img
```

Once OpenBIOS boots, run yaboot manually:

```
0 > boot hd:2,\yaboot
```
