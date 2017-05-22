KERNEL_VERSION=4.11.2
KERNEL_URL=https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-$(KERNEL_VERSION).tar.xz

BUILD_DIR=build

all: bzImage

$(BUILD_DIR):
	mkdir $(BUILD_DIR)

linux-$(KERNEL_VERSION).tar.xz:
	wget $(KERNEL_URL)

linux-$(KERNEL_VERSION): linux-$(KERNEL_VERSION).tar.xz
	tar -xf linux-$(KERNEL_VERSION).tar.xz

bzImage: linux-$(KERNEL_VERSION) kernel.config $(BUILD_DIR)
	cp kernel.config linux-$(KERNEL_VERSION)/.config
	$(MAKE) -C linux-$(KERNEL_VERSION)
	cp linux-$(KERNEL_VERSION)/arch/x86/boot/bzImage $(BUILD_DIR)

kernel-headers: linux-$(KERNEL_VERSION) kernel_headers.patch $(BUILD_DIR)
	$(MAKE) -C linux-$(KERNEL_VERSION) headers_install INSTALL_HDR_PATH="$(shell pwd)/$(BUILD_DIR)"
	patch -p0 -d $(BUILD_DIR) < kernel_headers.patch

clean:
	- rm linux-$(KERNEL_VERSION).tar.xz
	- rm -rf linux-$(KERNEL_VERSION)
	- rm -rf build
