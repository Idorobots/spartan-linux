# Spartan Linux

Based on [this](https://github.com/MichielDerhaeg/build-linux) instruction. You'll need:

- Linux 4.11 kernel [sources](https://kernel.org)
- [musl](https://www.musl-libc.org/)
- Busybox 1.26.2 [sources](https://busybox.net)
- Dropbear 2016.74 [sources](https://matt.ucc.asn.au/dropbear/dropbear.html)

## Building

### Linux 4.11 Kernel

Unpack kernel sources to `/path/to/kernel/` and use the supplied `kernel-config` to build the kernel **bzImage**:

```
$ cp kernel.config /path/to/kernel/.config
$ cd /path/to/kernel/
$ make -j8
```

Generate kernel header files:

```
$ cd /path/to/kernel/
$ make headers_install INSTALL_HDR_PATH=/path/to/headers/
```

Patch the header files for compatibility with musl libC:

```
$ cp kernel_headers.patch /path/to/headers
$ patch -p0 < kernel_headers.patch
```

### Busybox with musl

Unpack the Busybox sources to `/path/to/busybox/` and use the supplied `busybox-config` to build Busybox using musl libC:

```
$ cp busybox.config /path/to/busybox/.config
$ cd /path/to/busybox/
$ make -j8 CC=musl-gcc CONFIG_EXTRA_CFLAGS='-I /path/to/headers/include/'
```

### Dropbear with musl

Unpack Dropbear sources to `/path/to/dropbear` and compile it with musl libC compatibility:

```
$ cd /path/to/dropbear
$ ./configure --disable-zlib CC=musl-gcc CFLAGS='-I /path/to/headers/include'
$ make -j8 STATIC=1
```

### Upserspace

Create a directory for your root file system, for instance `/path/to/fs`. Next, create the basic filesystem structure:

```
$ mkdir -p /path/to/fs/{bin,boot,dev,etc,home,lib,mnt,opt,proc,run,sbin,srv,sys}
$ mkdir -p /path/to/fs/usr/{bin,sbin,include,lib,share,src}
$ mkdir -p /path/to/fs/var/{lib,lock,log,run,spool}
$ install -d -m 0750 /path/to/fs/root
$ install -d -m 1777 /path/to/fs/tmp
```

In addition to that, you will need the Busybox userspace:

```
$ cp /path/to/busybox/busybox /path/to/fs/bin/
$ for util in $(/path/to/fs/bin/busybox --list-full); do ln -s /bin/busybox /path/to/fs/$util; done
```

And Dropbear:

```
$ cp /path/to/dropbear/{dropbear,dbclient,dropbearkey,dropbearconvert} /path/to/fs/bin/
```

The rest of the root file system contents resides in the `rootfs` directory, you can simply copy them over:

```
$ cp -r rootfs/* /path/to/fs/
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
# cp -r /path/to/fs/* /path/to/mnt/rootfs.img
# sync
# umount /path/to/mnt/rootfs.img
# losetup -d "${LOOPBACK}"
```

## Testing

The kernel image & root filesystem can be run directly using QEMU:

```
$ qemu-system-x86_64 -kernel bzImage -append "root=/dev/sda1" /path/to/rootfs.img
```
