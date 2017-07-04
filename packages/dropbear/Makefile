NAME=dropbear
VERSION=2017.75

DROPBEAR_URL=https://matt.ucc.asn.au/dropbear/dropbear-$(VERSION).tar.bz2
DROPBEAR_PROGRAMS=dropbear dbclient dropbearkey dropbearconvert scp

TARBALLS_DIR=./cache
INSTALL_PREFIX=./dist
PACKAGE_PATH=.

PACKAGE=$(PACKAGE_PATH)/$(NAME)-$(VERSION)-$(ARCH).tar.gz

$(TARBALLS_DIR)/dropbear-$(VERSION).tar.bz2:
	mkdir -p $(TARBALLS_DIR)
	wget $(DROPBEAR_URL) -N -T 5 -P $(TARBALLS_DIR)

dropbear-$(VERSION): $(TARBALLS_DIR)/dropbear-$(VERSION).tar.bz2
	tar -xf $^

dropbear-$(VERSION)/dropbearmulti: dropbear-$(VERSION)
	(cd dropbear-$(VERSION) ; ./configure --disable-zlib --host="$(HOST)")
	$(MAKE) -C dropbear-$(VERSION) MULTI=1 STATIC=1 PROGRAMS="$(DROPBEAR_PROGRAMS)"
	$(MAKE) -C dropbear-$(VERSION) strip MULTI=1

install: dropbear-$(VERSION)/dropbearmulti runit.run
	mkdir -p $(INSTALL_PREFIX)/bin
	cp dropbear-$(VERSION)/dropbearmulti $(INSTALL_PREFIX)/bin
	for util in $(DROPBEAR_PROGRAMS); do ln -fs dropbearmulti $(INSTALL_PREFIX)/bin/$$util; done
	mkdir -p $(INSTALL_PREFIX)/etc/init.d/dropbear
	cp runit.run $(INSTALL_PREFIX)/etc/init.d/dropbear/run

.PHONY: install

package: install
	tar -czf $(PACKAGE) $(INSTALL_PREFIX)

.PHONY: package
