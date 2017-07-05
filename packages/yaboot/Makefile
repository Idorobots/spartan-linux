INSTALL_PREFIX=$(shell pwd)

all:

install: yaboot yaboot.conf boot.msg
	mkdir -p $(INSTALL_PREFIX)/boot
	cp yaboot yaboot.conf boot.msg $(INSTALL_PREFIX)/boot

.PHONY: install
