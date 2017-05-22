KERNEL_VERSION=4.11.2
KERNEL_URL=https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-$(KERNEL_VERSION).tar.xz

BUSYBOX_VERSION=1.26.2
BUSYBOX_URL=https://www.busybox.net/downloads/busybox-$(BUSYBOX_VERSION).tar.bz2

DROPBEAR_VERSION=2016.74
DROPBEAR_URL=https://matt.ucc.asn.au/dropbear/dropbear-$(DROPBEAR_VERSION).tar.bz2

BUILD_DIR="$(shell pwd)/build"

all: bzImage busybox dropbear

$(BUILD_DIR):
	- mkdir $(BUILD_DIR)

linux-$(KERNEL_VERSION).tar.xz:
	wget $(KERNEL_URL)

linux-$(KERNEL_VERSION): linux-$(KERNEL_VERSION).tar.xz
	tar -xf linux-$(KERNEL_VERSION).tar.xz

bzImage: linux-$(KERNEL_VERSION) kernel.config $(BUILD_DIR)
	cp kernel.config linux-$(KERNEL_VERSION)/.config
	$(MAKE) -C linux-$(KERNEL_VERSION)
	cp linux-$(KERNEL_VERSION)/arch/x86/boot/bzImage $(BUILD_DIR)

kernel-headers: linux-$(KERNEL_VERSION) kernel_headers.patch $(BUILD_DIR)
	$(MAKE) -C linux-$(KERNEL_VERSION) headers_install INSTALL_HDR_PATH=$(BUILD_DIR)
	patch -p0 -d $(BUILD_DIR) < kernel_headers.patch

busybox-$(BUSYBOX_VERSION).tar.bz2:
	wget $(BUSYBOX_URL)

busybox-$(BUSYBOX_VERSION): busybox-$(BUSYBOX_VERSION).tar.bz2
	tar -xf busybox-$(BUSYBOX_VERSION).tar.bz2

busybox: busybox-$(BUSYBOX_VERSION) busybox.config $(BUILD_DIR)
	cp busybox.config busybox-$(BUSYBOX_VERSION)/.config
	$(MAKE) -C busybox-$(BUSYBOX_VERSION) CC=musl-gcc CONFIG_EXTRA_CFLAGS="-I $(BUILD_DIR)/include"
	cp busybox-$(BUSYBOX_VERSION)/busybox $(BUILD_DIR)

dropbear-$(DROPBEAR_VERSION).tar.bz2:
	wget $(DROPBEAR_URL)

dropbear-$(DROPBEAR_VERSION): dropbear-$(DROPBEAR_VERSION).tar.bz2
	tar -xf dropbear-$(DROPBEAR_VERSION).tar.bz2

dropbear: dropbear-$(DROPBEAR_VERSION) $(BUILD_DIR)
	(cd dropbear-$(DROPBEAR_VERSION) ; ./configure --disable-zlib CC=musl-gcc CFLAGS="-I $(BUILD_DIR)/include")
	$(MAKE) -C dropbear-$(DROPBEAR_VERSION) STATIC=1
	cp dropbear-$(DROPBEAR_VERSION)/{dropbear,dbclient,dropbearkey,dropbearconvert} $(BUILD_DIR)

clean:
	- rm linux-$(KERNEL_VERSION).tar.xz
	- rm -rf linux-$(KERNEL_VERSION)
	- rm -rf build

.PHONY: clean
