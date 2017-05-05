# Spartan Linux

Based on [this](https://github.com/MichielDerhaeg/build-linux) instruction. You'll need:

- Linux 4.11 kernel [sources](https://kernel.org)
- [musl](https://www.musl-libc.org/)
- Busybox 1.26.2 [sources](https://busybox.net)

## Building

### Linux 4.11 Kernel

Unpack kernel sources to `/path/to/kernel/` and use the supplied `kernel-config` to build the kernel **bzImage**:

```
$ cp kernel-config /path/to/kernel/.config
$ cd /path/to/kernel/
$ make -j8
```

### Busybox with musl

Generate kernel header files:

```
$ cd /path/to/kernel/
$ make headers_install INSTALL_HDR_PATH=/path/to/headers/
```

Patch the header files for compatibility with musl libC:

```
$ cp busybox.diff /path/to/headers
$ patch -p0 < busybox.patch
```

Unpack the Busybox sources to `/path/to/busybox/` and use the supplied `busybox-config` to build Busybox using musl libC:

```
$ cp busybox-config /path/to/busybox/.config
$ cd /path/to/busybox/
$ make CC=musl-gcc CONFIG_EXTRA_CFLAGS='-I /path/to/headers/include/'
```

### Upserspace

Create a directory for your root file system, for instance `/path/to/fs`. Next, create the basic filesystem structure:

```
$ mkdir -p bin boot dev etc home lib mnt opt proc run sbin srv sys
$ mkdir -p usr/{bin,sbin,include,lib,share,src}
$ mkdir -p var/{lib,lock,log,run,spool}
$ install -d -m 0750 root
$ install -d -m 1777 tmp
```

In addition to that, you will need the Busybox userspace:

```
$ cp /path/to/busybox/busybox /path/to/fs/bin/
$ for util in $(/path/to/fs/bin/busybox --list-full); do ln -s /bin/busybox $util; done
```

The rest of the root file system contents resides in the `rootfs` directory, you can simply copy them over:

```
$ cp -r rootfs/* /path/to/fs/
```

### Rootfs image

Create a suitable-sized file in `/path/to/rootfs.img`, mount it as a loopback device to `/path/to/mnt/rootfs.img` and copy the rootfs contents there:

```
$ fallocate -l64M /path/to/rootfs.img
$ echo -n 'n\np\n\n\n\nw\n' | fdisk /path/to/rootfs.img
# export LOOPBACK=`losetup -P -f --show /path/to/rootfs.img`
# mkfs.ext4 "$(LOOPBACK)p1"
# mount "$(LOOPBACK)p1" /path/to/mnt/rootfs.img
# cp -r /path/to/fs/* /path/to/mnt/rootfs.img
# umount /path/to/mnt/rootfs.img
```

## Testing

The kernel image & root filesystem can be run directly using QEMU:

```
$ qemu-system-x86_64 -kernel bzImage -append "root=/dev/sda1" /path/to/rootfs.img
```
