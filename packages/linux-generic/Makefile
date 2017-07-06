include ../package.mk

NAME=linux-generic

KERNEL_VERSION=4.11.3
KERNEL_URL=https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-$(KERNEL_VERSION).tar.xz

$(TARBALLS_DIR)/linux-$(KERNEL_VERSION).tar.xz:
	mkdir -p $(TARBALLS_DIR)
	wget $(KERNEL_URL) -N -T 5 -P $(TARBALLS_DIR)

$(BUILD_DIR)/linux-$(KERNEL_VERSION): $(TARBALLS_DIR)/linux-$(KERNEL_VERSION).tar.xz
	tar -xf $^ -C $(BUILD_DIR)

$(BUILD_DIR)/linux-$(KERNEL_VERSION)/.config: $(BUILD_DIR)/linux-$(KERNEL_VERSION)
	$(MAKE) -C linux-$(KERNEL_VERSION) defconfig

$(BUILD_DIR)/linux-$(KERNEL_VERSION)/vmlinuz: $(BUILD_DIR)/linux-$(KERNEL_VERSION)/.config
	$(MAKE) -C $(BUILD_DIR)/linux-$(KERNEL_VERSION) oldconfig
	$(MAKE) -C $(BUILD_DIR)/linux-$(KERNEL_VERSION)

$(DIST_DIR): $(BUILD_DIR)/linux-$(KERNEL_VERSION)/vmlinuz
	mkdir -p $(DIST_DIR)/boot
	$(MAKE) -C $(BUILD_DIR)/linux-$(KERNEL_VERSION) install INSTALL_PATH=$(DIST_DIR)/boot
