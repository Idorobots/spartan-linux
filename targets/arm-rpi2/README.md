# Raspberry Pi 2 Spartan Linux

You'll need:

- [mkfs.vfat](https://github.com/dosfstools/dosfstools)

## Rootfs image

Create a suitable-sized file in `/path/to/image/rootfs.img`, mount it as a loopback device to `/path/to/image/mnt` and copy the rootfs contents there:

```
$ cd /path/to/image
$ fallocate -l64M rootfs.img
$ echo -e 'o\nn\np\n\n\n+20M\nt\nc\nn\np\n\n\n\nw\n' | fdisk rootfs.img
# export LOOPBACK=`losetup -P -f --show rootfs.img`
# mkfs.vfat "${LOOPBACK}p1"
# mkfs.ext4 -O^64bit "${LOOPBACK}p2"
$ mkdir mnt
# mount "${LOOPBACK}p2" mnt
# mkdir mnt/boot
# mount "${LOOPBACK}p1" mnt/boot
# cp -r /path/to/dist/fs/* mnt
# sync
# umount mnt/boot
# umount mnt
# losetup -d "$LOOPBACK"
```


## Testing

QEMU currently partially supports Raspberry Pi 2 emulation. You can try Spartan Linux (without support for USB devices) by running the following command:

```
cd /path/to/rootfs
qemu-system-arm -M raspi2 -kernel boot/kernel7.img -append "$(cat boot/cmdline.txt)" -dtb boot/bcm2836-rpi-2-b.dtb -sd rootfs.img
```
