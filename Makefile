KERNEL_VERSION=4.11.2
KERNEL_URL=https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-$(KERNEL_VERSION).tar.xz
PATCH_HEADERS=false

MUSL_VERSION=1.1.15
MUSL_URL=https://www.musl-libc.org/releases/musl-$(MUSL_VERSION).tar.gz

BUSYBOX_VERSION=1.26.2
BUSYBOX_URL=https://www.busybox.net/downloads/busybox-$(BUSYBOX_VERSION).tar.bz2

DROPBEAR_VERSION=2017.75
DROPBEAR_URL=https://matt.ucc.asn.au/dropbear/dropbear-$(DROPBEAR_VERSION).tar.bz2
DROPBEAR_PROGRAMS=dropbear dbclient dropbearkey dropbearconvert scp

BUILD_DIR=build
ABS_BUILD_DIR=$(shell pwd)/$(BUILD_DIR)
DIST_DIR=dist

VPATH=$(BUILD_DIR)

all: $(DIST_DIR)/bzImage $(DIST_DIR)/fs

$(BUILD_DIR):
	mkdir $(BUILD_DIR); true

$(DIST_DIR):
	mkdir $(DIST_DIR); true

$(BUILD_DIR)/linux-$(KERNEL_VERSION).tar.xz: $(BUILD_DIR)
	wget $(KERNEL_URL) -N -P $(BUILD_DIR)

$(BUILD_DIR)/linux-$(KERNEL_VERSION): $(BUILD_DIR)/linux-$(KERNEL_VERSION).tar.xz
	tar -xf $^ -C $(BUILD_DIR)

$(DIST_DIR)/bzImage: $(BUILD_DIR)/linux-$(KERNEL_VERSION) kernel.config $(DIST_DIR)
	cp kernel.config $(BUILD_DIR)/linux-$(KERNEL_VERSION)/.config
	$(MAKE) -C $(BUILD_DIR)/linux-$(KERNEL_VERSION)
	cp $(BUILD_DIR)/linux-$(KERNEL_VERSION)/arch/x86/boot/bzImage $(DIST_DIR)

$(BUILD_DIR)/include: $(DIST_DIR)/bzImage kernel_headers.patch
	$(MAKE) -C $(BUILD_DIR)/linux-$(KERNEL_VERSION) headers_install INSTALL_HDR_PATH=$(ABS_BUILD_DIR)

ifeq ($(PATCH_HEADERS), true)
	patch -p0 -d $(BUILD_DIR) -N < kernel_headers.patch; true
endif

$(BUILD_DIR)/musl-$(MUSL_VERSION).tar.gz: $(BUILD_DIR)
	wget $(MUSL_URL) -N -P $(BUILD_DIR)

$(BUILD_DIR)/musl-$(MUSL_VERSION): $(BUILD_DIR)/musl-$(MUSL_VERSION).tar.gz
	tar -xf $^ -C $(BUILD_DIR)

$(BUILD_DIR)/musl: $(BUILD_DIR)/musl-$(MUSL_VERSION) $(BUILD_DIR)/include
	(cd $(BUILD_DIR)/musl-$(MUSL_VERSION) ; ./configure --prefix="$(ABS_BUILD_DIR)/musl" --syslibdir="$(ABS_BUILD_DIR)/musl" --enable-wrapper=gcc CFLAGS="-I $(ABS_BUILD_DIR)/include")
	$(MAKE) -C $(BUILD_DIR)/musl-$(MUSL_VERSION)
	$(MAKE) -C $(BUILD_DIR)/musl-$(MUSL_VERSION) install

$(BUILD_DIR)/busybox-$(BUSYBOX_VERSION).tar.bz2: $(BUILD_DIR)
	wget $(BUSYBOX_URL) -N -P $(BUILD_DIR)

$(BUILD_DIR)/busybox-$(BUSYBOX_VERSION): $(BUILD_DIR)/busybox-$(BUSYBOX_VERSION).tar.bz2
	tar -xf $^ -C $(BUILD_DIR)

$(BUILD_DIR)/busybox: $(BUILD_DIR)/busybox-$(BUSYBOX_VERSION) busybox.config $(BUILD_DIR)/include $(BUILD_DIR)/musl
	cp busybox.config $(BUILD_DIR)/busybox-$(BUSYBOX_VERSION)/.config
	$(MAKE) -C $(BUILD_DIR)/busybox-$(BUSYBOX_VERSION) CC="$(ABS_BUILD_DIR)/musl/bin/musl-gcc" CONFIG_EXTRA_CFLAGS="-I $(ABS_BUILD_DIR)/include"
	cp $(BUILD_DIR)/busybox-$(BUSYBOX_VERSION)/busybox $(BUILD_DIR)

$(BUILD_DIR)/dropbear-$(DROPBEAR_VERSION).tar.bz2: $(BUILD_DIR)
	wget $(DROPBEAR_URL) -N -P $(BUILD_DIR)

$(BUILD_DIR)/dropbear-$(DROPBEAR_VERSION): $(BUILD_DIR)/dropbear-$(DROPBEAR_VERSION).tar.bz2
	tar -xf $^ -C $(BUILD_DIR)

$(BUILD_DIR)/dropbearmulti: $(BUILD_DIR)/dropbear-$(DROPBEAR_VERSION) $(BUILD_DIR)/include $(BUILD_DIR)/musl
	(cd $(BUILD_DIR)/dropbear-$(DROPBEAR_VERSION) ; ./configure --disable-zlib CC="$(ABS_BUILD_DIR)/musl/bin/musl-gcc" CFLAGS="-I $(ABS_BUILD_DIR)/include")
	$(MAKE) -C $(BUILD_DIR)/dropbear-$(DROPBEAR_VERSION) MULTI=1 STATIC=1 PROGRAMS="$(DROPBEAR_PROGRAMS)"
	$(MAKE) -C $(BUILD_DIR)/dropbear-$(DROPBEAR_VERSION) strip MULTI=1
	cp $(BUILD_DIR)/dropbear-$(DROPBEAR_VERSION)/dropbearmulti $(BUILD_DIR)

$(DIST_DIR)/fs: $(DIST_DIR) rootfs $(BUILD_DIR)/busybox $(BUILD_DIR)/dropbearmulti
	mkdir $(DIST_DIR)/fs; true
	mkdir -p $(DIST_DIR)/fs/{bin,boot,dev,etc,home,lib,mnt,opt,proc,run,sbin,srv,sys}
	mkdir -p $(DIST_DIR)/fs/usr/{bin,sbin,include,lib,share,src}
	mkdir -p $(DIST_DIR)/fs/var/{lib,lock,log,run,spool}
	install -d -m 0750 $(DIST_DIR)/fs/root
	install -d -m 1777 $(DIST_DIR)/fs/tmp
	cp -r rootfs/* $(DIST_DIR)/fs/
	cp $(BUILD_DIR)/busybox $(DIST_DIR)/fs/bin/
	for util in $$($(DIST_DIR)/fs/bin/busybox --list-full); do ln -s /bin/busybox $(DIST_DIR)/fs/$$util; done
	cp $(BUILD_DIR)/dropbearmulti $(DIST_DIR)/fs/bin/
	for util in $(DROPBEAR_PROGRAMS); do ln -s /bin/dropbearmulti $(DIST_DIR)/fs/bin/$$util; done

clean:
	rm -rf build; true
	rm -rf dist; true

.PHONY: clean
