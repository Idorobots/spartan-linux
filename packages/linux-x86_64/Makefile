include ../linux-generic/Makefile

NAME=linux-x86_64

$(BUILD_DIR)/linux-$(KERNEL_VERSION)/.config: $(BUILD_DIR)/linux-$(KERNEL_VERSION) kernel.config
	cp kernel.config $@
