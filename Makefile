# CTNG_VERSION=crosstool-ng-1.24.0
CTNG_VERSION=a9f8a8e67509547a53b9b4781734e2b482b75b4e
CTNG_URL=https://github.com/crosstool-ng/crosstool-ng/archive/$(CTNG_VERSION).tar.gz

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

$(BUILD_DIR)/packages: $(PACKAGES_DIR)
	mkdir -p $@
	cp -r $(PACKAGES_DIR)/* $@

.PHONY: $(BUILD_DIR)/packages

define build_package =
$(BUILD_DIR)/packages/$(1): $(TOOLCHAIN_CC_DIR) $(BUILD_DIR)/packages
	@echo "Building package $(1)"
	$(MAKE) -C $(BUILD_DIR)/packages/$(1) install INSTALL_PREFIX=$(DIST_DIR)/fs TARBALLS_DIR=$(TARBALLS_DIR)

.PHONY: $(BUILD_DIR)/packages/$(1)
endef

$(foreach PACKAGE,$(PACKAGES),$(eval $(call build_package,$(PACKAGE))))

$(DIST_DIR): $(foreach PACKAGE,$(PACKAGES),$(BUILD_DIR)/packages/$(PACKAGE))

clean:
	rm -rf $(BUILD_DIR); true
	rm -rf $(DIST_DIR); true

.PHONY: clean
