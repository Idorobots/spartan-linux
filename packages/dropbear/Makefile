DROPBEAR_VERSION=2017.75
DROPBEAR_URL=https://matt.ucc.asn.au/dropbear/dropbear-$(DROPBEAR_VERSION).tar.bz2
DROPBEAR_PROGRAMS=dropbear dbclient dropbearkey dropbearconvert scp

TARBALLS_DIR=$(shell pwd)
INSTALL_PREFIX=$(shell pwd)

all: dropbear-$(DROPBEAR_VERSION)/dropbearmulti

$(TARBALLS_DIR)/dropbear-$(DROPBEAR_VERSION).tar.bz2: $(TARBALLS_DIR)
	wget $(DROPBEAR_URL) -N -P $(TARBALLS_DIR)

dropbear-$(DROPBEAR_VERSION): $(TARBALLS_DIR)/dropbear-$(DROPBEAR_VERSION).tar.bz2
	tar -xf $^

dropbear-$(DROPBEAR_VERSION)/dropbearmulti: dropbear-$(DROPBEAR_VERSION)
	(cd dropbear-$(DROPBEAR_VERSION) ; ./configure --disable-zlib --host="$(HOST)")
	$(MAKE) -C dropbear-$(DROPBEAR_VERSION) MULTI=1 STATIC=1 PROGRAMS="$(DROPBEAR_PROGRAMS)"
	$(MAKE) -C dropbear-$(DROPBEAR_VERSION) strip MULTI=1

install: dropbear-$(DROPBEAR_VERSION)/dropbearmulti runit.run
	mkdir -p $(INSTALL_PREFIX)/bin
	cp dropbear-$(DROPBEAR_VERSION)/dropbearmulti $(INSTALL_PREFIX)/bin
	for util in $(DROPBEAR_PROGRAMS); do ln -fs dropbearmulti $(INSTALL_PREFIX)/bin/$$util; done
	mkdir -p $(INSTALL_PREFIX)/etc/init.d/dropbear
	cp runit.run $(INSTALL_PREFIX)/etc/init.d/dropbear/run

.PHONY: install
