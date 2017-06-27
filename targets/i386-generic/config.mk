ARCH=i386
HOST=i486-unknown-linux-musl

# $(1) - destination directory
# $(2) - kernel directory
define install_kernel =
	mkdir -p $(1)/boot
	$(MAKE) -C $(2) install INSTALL_PATH=$(1)/boot
endef
