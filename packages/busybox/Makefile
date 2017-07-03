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

install: busybox-$(BUSYBOX_VERSION)/busybox run_klogd.sh run_syslogd.sh run_udhcpc.sh run_ntpd.sh syslog.conf
	mkdir -p $(INSTALL_PREFIX)/etc/init.d/{klogd,syslogd,ntpd,udhcpc}
	$(MAKE) -C busybox-$(BUSYBOX_VERSION) install CONFIG_PREFIX="$(INSTALL_PREFIX)"
	cp run_klogd.sh $(INSTALL_PREFIX)/etc/init.d/klogd/run
	cp run_syslogd.sh $(INSTALL_PREFIX)/etc/init.d/syslogd/run
	cp run_udhcpc.sh $(INSTALL_PREFIX)/etc/init.d/udhcpc/run
	cp run_ntpd.sh $(INSTALL_PREFIX)/etc/init.d/ntpd/run
	cp syslog.conf $(INSTALL_PREFIX)/etc/syslog.conf

.PHONY: install
