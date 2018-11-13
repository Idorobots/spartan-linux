include ../package.mk

NAME=dropbear

DROPBEAR_VERSION=2017.75
DROPBEAR_URL=https://matt.ucc.asn.au/dropbear/dropbear-$(DROPBEAR_VERSION).tar.bz2
DROPBEAR_PROGRAMS=dropbear dbclient dropbearkey dropbearconvert scp

$(TARBALLS_DIR)/dropbear-$(DROPBEAR_VERSION).tar.bz2:
	mkdir -p $(TARBALLS_DIR)
	wget $(DROPBEAR_URL) -N -T 5 -P $(TARBALLS_DIR)

$(BUILD_DIR)/dropbear-$(DROPBEAR_VERSION): $(TARBALLS_DIR)/dropbear-$(DROPBEAR_VERSION).tar.bz2
	tar -xf $^ -C $(BUILD_DIR)

$(BUILD_DIR)/dropbear-$(DROPBEAR_VERSION)/dropbearmulti: $(BUILD_DIR)/dropbear-$(DROPBEAR_VERSION)
	(cd $(BUILD_DIR)/dropbear-$(DROPBEAR_VERSION) ; ./configure --disable-zlib --host="$(HOST)")
	$(MAKE) -C $(BUILD_DIR)/dropbear-$(DROPBEAR_VERSION) MULTI=1 STATIC=1 PROGRAMS="$(DROPBEAR_PROGRAMS)"
	$(MAKE) -C $(BUILD_DIR)/dropbear-$(DROPBEAR_VERSION) strip MULTI=1

$(DIST_DIR): $(BUILD_DIR)/dropbear-$(DROPBEAR_VERSION)/dropbearmulti runit.run
	mkdir -p $(DIST_DIR)/bin
	cp $(BUILD_DIR)/dropbear-$(DROPBEAR_VERSION)/dropbearmulti $(DIST_DIR)/bin
	for util in $(DROPBEAR_PROGRAMS); do ln -fs dropbearmulti $(DIST_DIR)/bin/$$util; done
	mkdir -p $(DIST_DIR)/etc/init.d/dropbear
	cp runit.run $(DIST_DIR)/etc/init.d/dropbear/run
