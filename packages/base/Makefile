include ../package.mk

NAME=base

BUSYBOX_VERSION=1.29.3
BUSYBOX_URL=https://www.busybox.net/downloads/busybox-$(BUSYBOX_VERSION).tar.bz2

$(TARBALLS_DIR)/busybox-$(BUSYBOX_VERSION).tar.bz2:
	mkdir -p $(TARBALLS_DIR)
	wget $(BUSYBOX_URL) -N -T 5 -P $(TARBALLS_DIR)

$(BUILD_DIR)/busybox-$(BUSYBOX_VERSION): $(TARBALLS_DIR)/busybox-$(BUSYBOX_VERSION).tar.bz2
	tar -xf $^ -C $(BUILD_DIR)

$(BUILD_DIR)/busybox-$(BUSYBOX_VERSION)/busybox: $(BUILD_DIR)/busybox-$(BUSYBOX_VERSION) busybox.config
	cp busybox.config $(BUILD_DIR)/busybox-$(BUSYBOX_VERSION)/.config
	$(MAKE) -C $(BUILD_DIR)/busybox-$(BUSYBOX_VERSION) oldconfig
	$(MAKE) -C $(BUILD_DIR)/busybox-$(BUSYBOX_VERSION)

$(DIST_DIR): $(BUILD_DIR)/busybox-$(BUSYBOX_VERSION)/busybox rootfs
	mkdir -p $(DIST_DIR)/{bin,boot,dev,etc,home,lib,mnt,opt,proc,run,sbin,srv,sys}
	mkdir -p $(DIST_DIR)/usr/{bin,sbin,include,lib,share,src}
	mkdir -p $(DIST_DIR)/var/{lib,lock,log,run,spool}
	mkdir -p $(DIST_DIR)/etc/init.d/{klogd,syslogd,ntpd,udhcpc}
	install -d -m 0750 $(DIST_DIR)/root
	install -d -m 1777 $(DIST_DIR)/tmp
	cp -r rootfs/* $(DIST_DIR)
	$(MAKE) -C $(BUILD_DIR)/busybox-$(BUSYBOX_VERSION) install CONFIG_PREFIX="$(DIST_DIR)"
