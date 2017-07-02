# CTNG_VERSION=crosstool-ng-1.24.0
CTNG_VERSION=a9f8a8e67509547a53b9b4781734e2b482b75b4e
CTNG_URL=https://github.com/crosstool-ng/crosstool-ng/archive/$(CTNG_VERSION).tar.gz

KERNEL_VERSION=4.11.3
KERNEL_EXTENSION=tar.xz
KERNEL_URL=https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-$(KERNEL_VERSION).$(KERNEL_EXTENSION)

BUSYBOX_VERSION=1.26.2
BUSYBOX_URL=https://www.busybox.net/downloads/busybox-$(BUSYBOX_VERSION).tar.bz2

TARGET=x86_64-generic

COMMON_DIR=$(shell pwd)/common
PACKAGES_DIR=$(shell pwd)/packages
TARBALLS_DIR=$(shell pwd)/cache
TARGET_DIR=$(shell pwd)/targets/$(TARGET)
BUILD_DIR=$(shell pwd)/build/$(TARGET)
DIST_DIR=$(shell pwd)/dist/$(TARGET)

include $(TARGET_DIR)/config.mk

CTNG_DIR=$(BUILD_DIR)/ct-ng
CTNG=$(CTNG_DIR)/bin/ct-ng

TOOLCHAIN_DIR=$(BUILD_DIR)/toolchain
TOOLCHAIN_CC_DIR=$(TOOLCHAIN_DIR)/bin
TOOLCHAIN_CC_PREFIX=$(TOOLCHAIN_CC_DIR)/$(HOST)-

export ARCH
export HOST
export CROSS_COMPILE=$(TOOLCHAIN_CC_PREFIX)
export PATH:=$(TOOLCHAIN_CC_DIR):$(PATH)

VPATH=$(BUILD_DIR)

all: $(DIST_DIR)

$(TARBALLS_DIR):
	mkdir -p $@

$(TARBALLS_DIR)/$(CTNG_VERSION).tar.gz: $(TARBALLS_DIR)
	wget $(CTNG_URL) -N -P $(TARBALLS_DIR)

$(BUILD_DIR)/crosstool-ng-$(CTNG_VERSION): $(TARBALLS_DIR)/$(CTNG_VERSION).tar.gz
	mkdir -p $(BUILD_DIR)
	tar -xf $^ -C $(BUILD_DIR)

$(CTNG): $(BUILD_DIR)/crosstool-ng-$(CTNG_VERSION) $(COMMON_DIR)/crosstool-ng.patch
	mkdir -p $(CTNG_DIR)
	if ! [ -z $${LIBRARY_PATH+dummy} ]; then echo "LIBRARY_PATH is set; crosstool-ng build won't work."; false; fi
	if ! [ -z $${LD_LIBRARY_PATH+dummy} ]; then echo "LD_LIBRARY_PATH is set; crosstool-ng build won't work."; false; fi
	(cd $(BUILD_DIR)/crosstool-ng-$(CTNG_VERSION) ; ./bootstrap)
	(cd $(BUILD_DIR)/crosstool-ng-$(CTNG_VERSION) ; ./configure --prefix="$(CTNG_DIR)")
	patch -p0 -d $(BUILD_DIR)/crosstool-ng-$(CTNG_VERSION) -N < $(COMMON_DIR)/crosstool-ng.patch; true
	$(MAKE) -C $(BUILD_DIR)/crosstool-ng-$(CTNG_VERSION)
	$(MAKE) -C $(BUILD_DIR)/crosstool-ng-$(CTNG_VERSION) install

$(TOOLCHAIN_CC_DIR): $(TARBALLS_DIR) $(CTNG) $(TARGET_DIR)/crosstool-ng.config
	mkdir -p $(TOOLCHAIN_DIR)
	cp $(TARGET_DIR)/crosstool-ng.config $(BUILD_DIR)/.config
	sed -i -r "s:(CT_LOCAL_TARBALLS_DIR).+:\1=$(TARBALLS_DIR):" $(BUILD_DIR)/.config
	sed -i -r "s:(CT_PREFIX_DIR).+:\1=$(TOOLCHAIN_DIR):" $(BUILD_DIR)/.config
	(cd $(BUILD_DIR) ; $(CTNG) build)

$(TARBALLS_DIR)/linux-$(KERNEL_VERSION).$(KERNEL_EXTENSION): $(TARBALLS_DIR)
	wget $(KERNEL_URL) -N -P $(TARBALLS_DIR)

$(BUILD_DIR)/linux-$(KERNEL_VERSION): $(TARBALLS_DIR)/linux-$(KERNEL_VERSION).$(KERNEL_EXTENSION)
	mkdir -p $(BUILD_DIR)
	tar -xf $^ -C $(BUILD_DIR)

$(BUILD_DIR)/kernel: $(TOOLCHAIN_CC_DIR) $(BUILD_DIR)/linux-$(KERNEL_VERSION) $(TARGET_DIR)/kernel.config
	cp $(TARGET_DIR)/kernel.config $(BUILD_DIR)/linux-$(KERNEL_VERSION)/.config
	$(MAKE) -C $(BUILD_DIR)/linux-$(KERNEL_VERSION) oldconfig
	$(MAKE) -C $(BUILD_DIR)/linux-$(KERNEL_VERSION)
	$(call install_kernel,$@,$(BUILD_DIR)/linux-$(KERNEL_VERSION))

$(TARBALLS_DIR)/busybox-$(BUSYBOX_VERSION).tar.bz2: $(TARBALLS_DIR)
	wget $(BUSYBOX_URL) -N -P $(TARBALLS_DIR)

$(BUILD_DIR)/busybox-$(BUSYBOX_VERSION): $(TARBALLS_DIR)/busybox-$(BUSYBOX_VERSION).tar.bz2
	mkdir -p $(BUILD_DIR)
	tar -xf $^ -C $(BUILD_DIR)

$(BUILD_DIR)/busybox: $(TOOLCHAIN_CC_DIR) $(BUILD_DIR)/busybox-$(BUSYBOX_VERSION) $(COMMON_DIR)/busybox.config
	cp $(COMMON_DIR)/busybox.config $(BUILD_DIR)/busybox-$(BUSYBOX_VERSION)/.config
	$(MAKE) -C $(BUILD_DIR)/busybox-$(BUSYBOX_VERSION) oldconfig
	$(MAKE) -C $(BUILD_DIR)/busybox-$(BUSYBOX_VERSION)
	$(MAKE) -C $(BUILD_DIR)/busybox-$(BUSYBOX_VERSION) install CONFIG_PREFIX="$@"

$(BUILD_DIR)/dropbear: $(TOOLCHAIN_CC_DIR) $(PACKAGES_DIR)/dropbear
	mkdir -p $@
	cp -r $(PACKAGES_DIR)/dropbear/* $@
	$(MAKE) -C $@ TARBALLS_DIR=$(TARBALLS_DIR)
	$(MAKE) -C $@ install INSTALL_PREFIX=$(DIST_DIR)/fs

$(DIST_DIR): $(BUILD_DIR)/kernel $(BUILD_DIR)/busybox $(BUILD_DIR)/dropbear $(COMMON_DIR)/rootfs
	mkdir -p $(DIST_DIR)/fs
	mkdir -p $(DIST_DIR)/fs/{bin,boot,dev,etc,home,lib,mnt,opt,proc,run,sbin,srv,sys}
	mkdir -p $(DIST_DIR)/fs/usr/{bin,sbin,include,lib,share,src}
	mkdir -p $(DIST_DIR)/fs/var/{lib,lock,log,run,spool}
	install -d -m 0750 $(DIST_DIR)/fs/root
	install -d -m 1777 $(DIST_DIR)/fs/tmp
	cp -r $(COMMON_DIR)/rootfs/* $(DIST_DIR)/fs/
	cp -r $(TARGET_DIR)/rootfs/* $(DIST_DIR)/fs/
	cp -r $(BUILD_DIR)/kernel/* $(DIST_DIR)/fs/
	cp -r $(BUILD_DIR)/busybox/* $(DIST_DIR)/fs/

clean:
	rm -rf $(BUILD_DIR); true
	rm -rf $(DIST_DIR); true

.PHONY: clean
