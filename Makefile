CTNG_VERSION=1.23.0
CTNG_URL=https://github.com/crosstool-ng/crosstool-ng/archive/crosstool-ng-$(CTNG_VERSION).tar.gz
PATCH_CTNG=true

KERNEL_VERSION=4.11.3
KERNEL_URL=https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-$(KERNEL_VERSION).tar.xz
PATCH_HEADERS=false

MUSL_VERSION=1.1.16
MUSL_URL=https://www.musl-libc.org/releases/musl-$(MUSL_VERSION).tar.gz

BUSYBOX_VERSION=1.26.2
BUSYBOX_URL=https://www.busybox.net/downloads/busybox-$(BUSYBOX_VERSION).tar.bz2

DROPBEAR_VERSION=2017.75
DROPBEAR_URL=https://matt.ucc.asn.au/dropbear/dropbear-$(DROPBEAR_VERSION).tar.bz2
DROPBEAR_PROGRAMS=dropbear dbclient dropbearkey dropbearconvert scp

BUILD_DIR=build
DIST_DIR=dist
ABS_BUILD_DIR=$(shell pwd)/$(BUILD_DIR)
TARBALLS_DIR=$(ABS_BUILD_DIR)

CTNG_DIR=$(ABS_BUILD_DIR)/ct-ng
CTNG=$(CTNG_DIR)/bin/ct-ng

ARCH=x86_64
HOST=x86_64-unknown-linux-musl

TOOLCHAIN_DIR=$(ABS_BUILD_DIR)/toolchain
TOOLCHAIN_CC_DIR=$(TOOLCHAIN_DIR)/bin
TOOLCHAIN_CC_PREFIX=$(TOOLCHAIN_CC_DIR)/$(HOST)-

VPATH=$(BUILD_DIR)

all: $(DIST_DIR)/bzImage $(DIST_DIR)/fs

$(BUILD_DIR):
	mkdir $@; true

$(TOOLCHAIN_DIR): $(BUILD_DIR)
	mkdir $@; true

$(DIST_DIR):
	mkdir $@; true

$(BUILD_DIR)/crosstool-ng-$(CTNG_VERSION).tar.gz: $(BUILD_DIR)
	wget $(CTNG_URL) -N -P $(BUILD_DIR)

$(BUILD_DIR)/crosstool-ng-$(CTNG_VERSION): $(BUILD_DIR)/crosstool-ng-$(CTNG_VERSION).tar.gz
	tar -xf $^ -C $(BUILD_DIR)

ifeq ($(PATCH_CTNG), true)
	- rm -rf $@
	mv $(BUILD_DIR)/crosstool-ng-crosstool-ng-$(CTNG_VERSION) $@
endif

$(CTNG): $(BUILD_DIR)/crosstool-ng-$(CTNG_VERSION)

ifeq ($(PATCH_CTNG), true)
	if ! [ -z $${LIBRARY_PATH+dummy} ]; then echo "LIBRARY_PATH is set; crosstool-ng build won't work."; false; fi
	if ! [ -z $${LD_LIBRARY_PATH+dummy} ]; then echo "LD_LIBRARY_PATH is set; crosstool-ng build won't work."; false; fi
endif
	(cd $(BUILD_DIR)/crosstool-ng-$(CTNG_VERSION) ; ./bootstrap)
	(cd $(BUILD_DIR)/crosstool-ng-$(CTNG_VERSION) ; ./configure --prefix="$(CTNG_DIR)")

ifeq ($(PATCH_CTNG), true)
	patch -p0 -d $(BUILD_DIR)/crosstool-ng-$(CTNG_VERSION) -N < crosstool-ng.patch; true
endif

	$(MAKE) -C $(BUILD_DIR)/crosstool-ng-$(CTNG_VERSION)
	$(MAKE) -C $(BUILD_DIR)/crosstool-ng-$(CTNG_VERSION) install

$(TOOLCHAIN_CC_DIR): $(BUILD_DIR) $(CTNG) crosstool-ng.config
	cp crosstool-ng.config $(BUILD_DIR)/.config
	sed -i -r "s:(CT_LOCAL_TARBALLS_DIR).+:\1=$(TARBALLS_DIR):" $(BUILD_DIR)/.config
	sed -i -r "s:(CT_PREFIX_DIR).+:\1=$(TOOLCHAIN_DIR):" $(BUILD_DIR)/.config
	(cd $(BUILD_DIR) ; $(CTNG) build)

$(BUILD_DIR)/linux-$(KERNEL_VERSION).tar.xz: $(BUILD_DIR)
	wget $(KERNEL_URL) -N -P $(BUILD_DIR)

$(BUILD_DIR)/linux-$(KERNEL_VERSION): $(BUILD_DIR)/linux-$(KERNEL_VERSION).tar.xz
	tar -xf $^ -C $(BUILD_DIR)

$(DIST_DIR)/bzImage: $(DIST_DIR) $(TOOLCHAIN_CC_DIR) $(BUILD_DIR)/linux-$(KERNEL_VERSION) kernel.config
	cp kernel.config $(BUILD_DIR)/linux-$(KERNEL_VERSION)/.config
	$(MAKE) -C $(BUILD_DIR)/linux-$(KERNEL_VERSION) ARCH=$(ARCH) CROSS_COMPILE="$(TOOLCHAIN_CC_PREFIX)"
	cp $(BUILD_DIR)/linux-$(KERNEL_VERSION)/arch/x86/boot/bzImage $(DIST_DIR)

$(BUILD_DIR)/busybox-$(BUSYBOX_VERSION).tar.bz2: $(BUILD_DIR)
	wget $(BUSYBOX_URL) -N -P $(BUILD_DIR)

$(BUILD_DIR)/busybox-$(BUSYBOX_VERSION): $(BUILD_DIR)/busybox-$(BUSYBOX_VERSION).tar.bz2
	tar -xf $^ -C $(BUILD_DIR)

$(BUILD_DIR)/busybox: $(TOOLCHAIN_CC_DIR) $(BUILD_DIR)/busybox-$(BUSYBOX_VERSION) busybox.config
	cp busybox.config $(BUILD_DIR)/busybox-$(BUSYBOX_VERSION)/.config
	$(MAKE) -C $(BUILD_DIR)/busybox-$(BUSYBOX_VERSION) ARCH=$(ARCH) CROSS_COMPILE="$(TOOLCHAIN_CC_PREFIX)"
	cp $(BUILD_DIR)/busybox-$(BUSYBOX_VERSION)/busybox $(BUILD_DIR)

$(BUILD_DIR)/dropbear-$(DROPBEAR_VERSION).tar.bz2: $(BUILD_DIR)
	wget $(DROPBEAR_URL) -N -P $(BUILD_DIR)

$(BUILD_DIR)/dropbear-$(DROPBEAR_VERSION): $(BUILD_DIR)/dropbear-$(DROPBEAR_VERSION).tar.bz2
	tar -xf $^ -C $(BUILD_DIR)

$(BUILD_DIR)/dropbearmulti: $(TOOLCHAIN_CC_DIR) $(BUILD_DIR)/dropbear-$(DROPBEAR_VERSION)
	(cd $(BUILD_DIR)/dropbear-$(DROPBEAR_VERSION) ; ./configure --disable-zlib --host="$(HOST)" PATH="$(TOOLCHAIN_CC_DIR):$$PATH")
	$(MAKE) -C $(BUILD_DIR)/dropbear-$(DROPBEAR_VERSION) MULTI=1 STATIC=1 PROGRAMS="$(DROPBEAR_PROGRAMS)"
	$(MAKE) -C $(BUILD_DIR)/dropbear-$(DROPBEAR_VERSION) strip MULTI=1
	cp $(BUILD_DIR)/dropbear-$(DROPBEAR_VERSION)/dropbearmulti $(BUILD_DIR)

$(DIST_DIR)/fs: $(DIST_DIR) $(BUILD_DIR)/busybox $(BUILD_DIR)/dropbearmulti rootfs
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
