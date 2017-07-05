INSTALL_PREFIX=$(shell pwd)

all:

install: syslinux.cfg
	mkdir -p $(INSTALL_PREFIX)/boot/syslinux/
	cp syslinux.cfg $(INSTALL_PREFIX)/boot/syslinux/

.PHONY: install
