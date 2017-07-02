TARBALLS_DIR=$(shell pwd)
INSTALL_PREFIX=$(shell pwd)

all: ;

install: rootfs
	mkdir -p $(INSTALL_PREFIX)
	mkdir -p $(INSTALL_PREFIX)/{bin,boot,dev,etc,home,lib,mnt,opt,proc,run,sbin,srv,sys}
	mkdir -p $(INSTALL_PREFIX)/usr/{bin,sbin,include,lib,share,src}
	mkdir -p $(INSTALL_PREFIX)/var/{lib,lock,log,run,spool}
	install -d -m 0750 $(INSTALL_PREFIX)/root
	install -d -m 1777 $(INSTALL_PREFIX)/tmp
	cp -r rootfs/* $(INSTALL_PREFIX)

.PHONY: install
