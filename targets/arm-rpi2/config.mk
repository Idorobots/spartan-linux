ARCH=arm
HOST=arm-unknown-linux-musleabi

# $(1) - destination directory
# $(2) - kernel directory
define install_kernel =
	$(MAKE) -C $(2) zinstall INSTALL_PATH=$(1)/boot
	mv $(1)/boot/zImage $(1)/boot/kernel7.img
	$(MAKE) -C $(2) dtbs_install INSTALL_PATH=$(1)/boot
	rm -f $(1)/boot/bcm{2835,2708}*.dtb
endef
