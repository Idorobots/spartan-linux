ARCH=arm
HOST=arm-unknown-linux-musleabi

# $(1) - destination directory
# $(2) - kernel directory
define install_kernel =
	mkdir -p $(1)/boot
	$(MAKE) -C $(2) zinstall INSTALL_PATH=$(1)/boot
	mv $(1)/boot/vmlinuz* $(1)/boot/kernel7.img
	$(MAKE) -C $(2) dtbs_install INSTALL_DTBS_PATH=$(1)/boot
	rm -f $(1)/boot/dtbs/*/bcm{2835,2708}*.dtb
endef
