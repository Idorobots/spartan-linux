NAME=base
VERSION=1.26.2

BUSYBOX_URL=https://www.busybox.net/downloads/busybox-$(VERSION).tar.bz2

TARBALLS_DIR=./cache
INSTALL_PREFIX=./dist
PACKAGE_PATH=.

PACKAGE=$(PACKAGE_PATH)/$(NAME)-$(VERSION)-$(ARCH).tar.gz

$(TARBALLS_DIR)/busybox-$(VERSION).tar.bz2:
	mkdir -p $(TARBALLS_DIR)
	wget $(BUSYBOX_URL) -N -T 5 -P $(TARBALLS_DIR)

busybox-$(VERSION): $(TARBALLS_DIR)/busybox-$(VERSION).tar.bz2
	tar -xf $^

busybox-$(VERSION)/busybox: busybox-$(VERSION) busybox.config
	cp busybox.config busybox-$(VERSION)/.config
	$(MAKE) -C busybox-$(VERSION) oldconfig
	$(MAKE) -C busybox-$(VERSION)

install: busybox-$(VERSION)/busybox rootfs
	mkdir -p $(INSTALL_PREFIX)/{bin,boot,dev,etc,home,lib,mnt,opt,proc,run,sbin,srv,sys}
	mkdir -p $(INSTALL_PREFIX)/usr/{bin,sbin,include,lib,share,src}
	mkdir -p $(INSTALL_PREFIX)/var/{lib,lock,log,run,spool}
	mkdir -p $(INSTALL_PREFIX)/etc/init.d/{klogd,syslogd,ntpd,udhcpc}
	install -d -m 0750 $(INSTALL_PREFIX)/root
	install -d -m 1777 $(INSTALL_PREFIX)/tmp
	cp -r rootfs/* $(INSTALL_PREFIX)
	$(MAKE) -C busybox-$(VERSION) install CONFIG_PREFIX="$(INSTALL_PREFIX)"

.PHONY: install

package: install
	tar -czf $(PACKAGE) $(INSTALL_PREFIX)

.PHONY: package
