ARCH=arm
HOST=arm-unknown-linux-musleabi

FIRMWARE_BLOBS_VERSION=a878899b378a4421f009c49ddb33fc7206d540d1
FIRMWARE_BLOBS_URL=https://github.com/raspberrypi/firmware/blob/$(FIRMWARE_BLOBS_VERSION)/boot
FIRMWARE_BLOBS=bootcode.bin fixup.dat fixup_cd.dat fixup_db.dat fixup_x.dat start.elf start_cd.elf start_db.elf start_x.elf

# FIXME This needs to be pretty close to the default KERNEL_VERSION.
KERNEL_VERSION=13a75e97dca4e3f3ca286a44162629bd32bfe4c8
KERNEL_EXTENSION=tar.gz
KERNEL_URL=https://github.com/raspberrypi/linux/archive/$(KERNEL_VERSION).$(KERNEL_EXTENSION)

# $(1) - destination directory
# $(2) - kernel directory
define install_kernel =
	mkdir -p $(1)/boot
	$(MAKE) -C $(2) zinstall INSTALL_PATH=$(1)/boot
	mv $(1)/boot/vmlinuz* $(1)/boot/kernel7.img
#	$(MAKE) -C $(2) dtbs_install INSTALL_DTBS_PATH=$(1)/boot
	cp $(2)/arch/$(ARCH)/boot/dts/bcm2709-rpi-2-b.dtb $(1)/boot
	for blob in $(FIRMWARE_BLOBS); do wget $(FIRMWARE_BLOBS_URL)/$$blob -N -P $(1)/boot; done
endef
