KERNEL_VERSION=4.11.3
KERNEL_URL=https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-$(KERNEL_VERSION).tar.xz

TARBALLS_DIR=$(shell pwd)
INSTALL_PREFIX=$(shell pwd)

all: linux-$(KERNEL_VERSION)/vmlinuz

$(TARBALLS_DIR)/linux-$(KERNEL_VERSION).tar.xz:
	mkdir -p $(TARBALLS_DIR)
	wget $(KERNEL_URL) -N -T 5 -P $(TARBALLS_DIR)

linux-$(KERNEL_VERSION): $(TARBALLS_DIR)/linux-$(KERNEL_VERSION).tar.xz
	tar -xf $^

linux-$(KERNEL_VERSION)/.config: linux-$(KERNEL_VERSION)
	$(MAKE) -C linux-$(KERNEL_VERSION) defconfig

linux-$(KERNEL_VERSION)/vmlinuz: linux-$(KERNEL_VERSION) linux-$(KERNEL_VERSION)/.config
	$(MAKE) -C linux-$(KERNEL_VERSION) oldconfig
	$(MAKE) -C linux-$(KERNEL_VERSION)

install: linux-$(KERNEL_VERSION)/vmlinuz
	mkdir -p $(INSTALL_PREFIX)/boot
	$(MAKE) -C linux-$(KERNEL_VERSION) install INSTALL_PATH=$(INSTALL_PREFIX)/boot

.PHONY: install
