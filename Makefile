KERNEL_VERSION=4.11.2
KERNEL_URL=https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-$(KERNEL_VERSION).tar.xz

BUSYBOX_VERSION=1.26.2
BUSYBOX_URL=https://www.busybox.net/downloads/busybox-$(BUSYBOX_VERSION).tar.bz2

DROPBEAR_VERSION=2016.74
DROPBEAR_URL=https://matt.ucc.asn.au/dropbear/dropbear-$(DROPBEAR_VERSION).tar.bz2

BUILD_DIR="build"
ABS_BUILD_DIR="$(shell pwd)/$(BUILD_DIR)"
DIST_DIR="dist"

VPATH=$(BUILD_DIR)

all: $(DIST_DIR)/bzImage $(DIST_DIR)/fs

$(BUILD_DIR):
	- mkdir $(BUILD_DIR)

$(DIST_DIR):
	- mkdir $(DIST_DIR)

$(BUILD_DIR)/linux-$(KERNEL_VERSION).tar.xz: $(BUILD_DIR)
	wget $(KERNEL_URL) -P $(BUILD_DIR)

$(BUILD_DIR)/linux-$(KERNEL_VERSION): $(BUILD_DIR)/linux-$(KERNEL_VERSION).tar.xz
	tar -xf $^ -C $(BUILD_DIR)

$(DIST_DIR)/bzImage: $(BUILD_DIR)/linux-$(KERNEL_VERSION) kernel.config $(DIST_DIR)
	cp kernel.config $(BUILD_DIR)/linux-$(KERNEL_VERSION)/.config
	$(MAKE) -C $(BUILD_DIR)/linux-$(KERNEL_VERSION)
	cp $(BUILD_DIR)/linux-$(KERNEL_VERSION)/arch/x86/boot/bzImage $(DIST_DIR)

$(BUILD_DIR)/include: $(DIST_DIR)/bzImage kernel_headers.patch
	$(MAKE) -C $(BUILD_DIR)/linux-$(KERNEL_VERSION) headers_install INSTALL_HDR_PATH=$(ABS_BUILD_DIR)
	- patch -p0 -d $(BUILD_DIR) -N < kernel_headers.patch

$(BUILD_DIR)/busybox-$(BUSYBOX_VERSION).tar.bz2: $(BUILD_DIR)
	wget $(BUSYBOX_URL) -P $(BUILD_DIR)

$(BUILD_DIR)/busybox-$(BUSYBOX_VERSION): $(BUILD_DIR)/busybox-$(BUSYBOX_VERSION).tar.bz2
	tar -xf $^ -C $(BUILD_DIR)

$(BUILD_DIR)/busybox: $(BUILD_DIR)/busybox-$(BUSYBOX_VERSION) busybox.config $(BUILD_DIR)/include
	cp busybox.config $(BUILD_DIR)/busybox-$(BUSYBOX_VERSION)/.config
	$(MAKE) -C $(BUILD_DIR)/busybox-$(BUSYBOX_VERSION) CC=musl-gcc CONFIG_EXTRA_CFLAGS="-I $(ABS_BUILD_DIR)/include"
	cp $(BUILD_DIR)/busybox-$(BUSYBOX_VERSION)/busybox $(BUILD_DIR)

$(BUILD_DIR)/dropbear-$(DROPBEAR_VERSION).tar.bz2: $(BUILD_DIR)
	wget $(DROPBEAR_URL) -P $(BUILD_DIR)

$(BUILD_DIR)/dropbear-$(DROPBEAR_VERSION): $(BUILD_DIR)/dropbear-$(DROPBEAR_VERSION).tar.bz2
	tar -xf $^ -C $(BUILD_DIR)

$(BUILD_DIR)/dropbear: $(BUILD_DIR)/dropbear-$(DROPBEAR_VERSION) $(BUILD_DIR)/include
	(cd $(BUILD_DIR)/dropbear-$(DROPBEAR_VERSION) ; ./configure --disable-zlib CC=musl-gcc CFLAGS="-I $(ABS_BUILD_DIR)/include")
	$(MAKE) -C $(BUILD_DIR)/dropbear-$(DROPBEAR_VERSION) STATIC=1
	cp $(BUILD_DIR)/dropbear-$(DROPBEAR_VERSION)/{dropbear,dbclient,dropbearkey,dropbearconvert} $(BUILD_DIR)

$(DIST_DIR)/fs: $(DIST_DIR) rootfs $(BUILD_DIR)/busybox $(BUILD_DIR)/dropbear
	mkdir $(DIST_DIR)/fs; true
	mkdir -p $(DIST_DIR)/fs/{bin,boot,dev,etc,home,lib,mnt,opt,proc,run,sbin,srv,sys}
	mkdir -p $(DIST_DIR)/fs/usr/{bin,sbin,include,lib,share,src}
	mkdir -p $(DIST_DIR)/fs/var/{lib,lock,log,run,spool}
	install -d -m 0750 $(DIST_DIR)/fs/root
	install -d -m 1777 $(DIST_DIR)/fs/tmp
	cp -r rootfs/* $(DIST_DIR)/fs/
	cp $(BUILD_DIR)/busybox $(DIST_DIR)/fs/bin/
	for util in $$($(DIST_DIR)/fs/bin/busybox --list-full); do ln -s /bin/busybox $(DIST_DIR)/fs/$$util; done
	cp $(BUILD_DIR)/{dropbear,dbclient,dropbearkey,dropbearconvert} $(DIST_DIR)/fs/bin/

clean:
	- rm -rf build
	- rm -rf dist

.PHONY: clean