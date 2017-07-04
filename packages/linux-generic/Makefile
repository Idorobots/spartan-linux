NAME=linux-generic
VERSION=4.11.3

KERNEL_URL=https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-$(VERSION).tar.xz

TARBALLS_DIR=./cache
INSTALL_PREFIX=./dist
PACKAGE_PATH=.

PACKAGE=$(PACKAGE_PATH)/$(NAME)-$(VERSION)-$(ARCH).tar.gz

$(TARBALLS_DIR)/linux-$(VERSION).tar.xz:
	mkdir -p $(TARBALLS_DIR)
	wget $(KERNEL_URL) -N -T 5 -P $(TARBALLS_DIR)

linux-$(VERSION): $(TARBALLS_DIR)/linux-$(VERSION).tar.xz
	tar -xf $^

linux-$(VERSION)/.config: linux-$(VERSION)
	$(MAKE) -C linux-$(VERSION) defconfig

linux-$(VERSION)/vmlinuz: linux-$(VERSION) linux-$(VERSION)/.config
	$(MAKE) -C linux-$(VERSION) oldconfig
	$(MAKE) -C linux-$(VERSION)

install: linux-$(VERSION)/vmlinuz
	mkdir -p $(INSTALL_PREFIX)/boot
	$(MAKE) -C linux-$(VERSION) install INSTALL_PATH=$(INSTALL_PREFIX)/boot

.PHONY: install

package: install
	tar -czf $(PACKAGE) $(INSTALL_PREFIX)

.PHONY: package
