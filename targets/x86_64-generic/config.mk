ARCH=x86_64
HOST=x86_64-unknown-linux-musl

# $(1) - destination directory
# $(2) - kernel directory
define install_kernel =
	$(MAKE) -C $(2) install INSTALL_PATH=$(1)
	$(MAKE) -C $(2) headers_install INSTALL_HDR_PATH=$(1)/headers
	$(MAKE) -C $(2) modules_install INSTALL_MOD_PATH=$(1)/modules; true
	$(MAKE) -C $(2) firmware_install INSTALL_FW_PATH=$(1)/firmware; true
	$(MAKE) -C $(2) dtbs_install INSTALL_PATH=$(1); true
endef
