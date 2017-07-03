BUSYBOX_VERSION=1.26.2
BUSYBOX_URL=https://www.busybox.net/downloads/busybox-$(BUSYBOX_VERSION).tar.bz2

TARBALLS_DIR=$(shell pwd)
INSTALL_PREFIX=$(shell pwd)

all: busybox-$(BUSYBOX_VERSION)/busybox

$(TARBALLS_DIR)/busybox-$(BUSYBOX_VERSION).tar.bz2:
	mkdir -p $(TARBALLS_DIR)
	wget $(BUSYBOX_URL) -N -T 5 -P $(TARBALLS_DIR)

busybox-$(BUSYBOX_VERSION): $(TARBALLS_DIR)/busybox-$(BUSYBOX_VERSION).tar.bz2
	tar -xf $^

busybox-$(BUSYBOX_VERSION)/busybox: busybox-$(BUSYBOX_VERSION) busybox.config
	cp busybox.config busybox-$(BUSYBOX_VERSION)/.config
	$(MAKE) -C busybox-$(BUSYBOX_VERSION) oldconfig
	$(MAKE) -C busybox-$(BUSYBOX_VERSION)

install: busybox-$(BUSYBOX_VERSION)/busybox rootfs
	mkdir -p $(INSTALL_PREFIX)/{bin,boot,dev,etc,home,lib,mnt,opt,proc,run,sbin,srv,sys}
	mkdir -p $(INSTALL_PREFIX)/usr/{bin,sbin,include,lib,share,src}
	mkdir -p $(INSTALL_PREFIX)/var/{lib,lock,log,run,spool}
	mkdir -p $(INSTALL_PREFIX)/etc/init.d/{klogd,syslogd,ntpd,udhcpc}
	install -d -m 0750 $(INSTALL_PREFIX)/root
	install -d -m 1777 $(INSTALL_PREFIX)/tmp
	cp -r rootfs/* $(INSTALL_PREFIX)
	$(MAKE) -C busybox-$(BUSYBOX_VERSION) install CONFIG_PREFIX="$(INSTALL_PREFIX)"

.PHONY: install
