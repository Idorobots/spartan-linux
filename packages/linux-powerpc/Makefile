include ../linux-generic/Makefile

NAME=linux-powerpc

$(BUILD_DIR)/linux-$(KERNEL_VERSION)/.config: $(BUILD_DIR)/linux-$(KERNEL_VERSION) kernel.config
	cp kernel.config $@
