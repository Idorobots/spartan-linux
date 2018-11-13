include ../package.mk

NAME=linux-rpi2

KERNEL_VERSION=13a75e97dca4e3f3ca286a44162629bd32bfe4c8
KERNEL_URL=https://github.com/raspberrypi/linux/archive/$(KERNEL_VERSION).tar.gz

FIRMWARE_BLOBS_VERSION=a878899b378a4421f009c49ddb33fc7206d540d1
FIRMWARE_BLOBS_URL=https://github.com/raspberrypi/firmware/blob/$(FIRMWARE_BLOBS_VERSION)/boot
FIRMWARE_BLOBS=bootcode.bin fixup.dat fixup_cd.dat fixup_db.dat fixup_x.dat start.elf start_cd.elf start_db.elf start_x.elf

$(TARBALLS_DIR)/linux-$(KERNEL_VERSION).tar.xz:
	mkdir -p $(TARBALLS_DIR)
	wget $(KERNEL_URL) -N -T 5 -P $(TARBALLS_DIR)

$(BUILD_DIR)/linux-$(KERNEL_VERSION): $(TARBALLS_DIR)/linux-$(KERNEL_VERSION).tar.xz
	tar -xf $^ -C $(BUILD_DIR)

$(BUILD_DIR)/linux-$(KERNEL_VERSION)/.config: $(BUILD_DIR)/linux-$(KERNEL_VERSION)
	$(MAKE) -C $(BUILD_DIR)/linux-$(KERNEL_VERSION) defconfig

$(BUILD_DIR)/linux-$(KERNEL_VERSION)/vmlinuz: $(BUILD_DIR)/linux-$(KERNEL_VERSION) $(BUILD_DIR)/linux-$(KERNEL_VERSION)/.config
	$(MAKE) -C $(BUILD_DIR)/linux-$(KERNEL_VERSION) oldconfig
	$(MAKE) -C $(BUILD_DIR)/linux-$(KERNEL_VERSION)

$(DIST_DIR): $(BUILD_DIR)/linux-$(KERNEL_VERSION)/vmlinuz
	mkdir -p $(DIST_DIR)/boot
	$(MAKE) -C $(BUILD_DIR)/linux-$(KERNEL_VERSION) zinstall INSTALL_PATH=$(DIST_DIR)/boot
	mv $(BUILD_DIR)/linux-$(KERNEL_VERSION)/boot/vmlinuz* $(DIST_DIR)/boot/kernel7.img
#	$(MAKE) -C $(BUILD_DIR)/linux-$(KERNEL_VERSION) dtbs_install INSTALL_DTBS_PATH=$(DIST_DIR)/boot
	cp $(BUILD_DIR)/linux-$(KERNEL_VERSION)/arch/$(ARCH)/boot/dts/bcm2709-rpi-2-b.dtb $(DIST_DIR)/boot
	for blob in $(FIRMWARE_BLOBS); do wget $(FIRMWARE_BLOBS_URL)/$$blob -N -P $(DIST_DIR)/boot; done
	cp cmdline.txt $(DIST_DIR)/boot
	cp config.txt $(DIST_DIR)/boot
