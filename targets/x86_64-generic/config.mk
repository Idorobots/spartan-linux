ARCH=x86_64
HOST=x86_64-unknown-linux-musl

# $(1) - destination directory
# $(2) - kernel directory
define install_kernel =
	$(MAKE) -C $(2) install INSTALL_PATH=$(1)/boot
endef
