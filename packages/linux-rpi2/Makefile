NAME=linux-rpi2
VERSION=13a75e97dca4e3f3ca286a44162629bd32bfe4c8

KERNEL_URL=https://github.com/raspberrypi/linux/archive/$(VERSION).tar.gz
FIRMWARE_BLOBS_VERSION=a878899b378a4421f009c49ddb33fc7206d540d1
FIRMWARE_BLOBS_URL=https://github.com/raspberrypi/firmware/blob/$(FIRMWARE_BLOBS_VERSION)/boot
FIRMWARE_BLOBS=bootcode.bin fixup.dat fixup_cd.dat fixup_db.dat fixup_x.dat start.elf start_cd.elf start_db.elf start_x.elf

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

install: linux-$(VERSION)/vmlinuz cmdline.txt config.txt
	mkdir -p $(INSTALL_PREFIX)/boot
	$(MAKE) -C linux-$(VERSION) zinstall INSTALL_PATH=$(INSTALL_PREFIX)/boot
	mv linux-$(VERSION)/boot/vmlinuz* $(INSTALL_PREFIX)/boot/kernel7.img
#	$(MAKE) -C linux-$(VERSION) dtbs_install INSTALL_DTBS_PATH=$(INSTALL_PREFIX)/boot
	cp linux-$(VERSION)/arch/$(ARCH)/boot/dts/bcm2709-rpi-2-b.dtb $(INSTALL_PREFIX)/boot
	for blob in $(FIRMWARE_BLOBS); do wget $(FIRMWARE_BLOBS_URL)/$$blob -N -P $(INSTALL_PREFIX)/boot; done
	cp cmdline.txt $(INSTALL_PREFIX)/boot
	cp config.txt $(INSTALL_PREFIX)/boot

.PHONY: install

package: install
	tar -czf $(PACKAGE) $(INSTALL_PREFIX)

.PHONY: package
