# Define a NAME for each package.
NAME=

BUILD_DIR=build
DIST_DIR=dist
TARBALLS_DIR=cache
INSTALL_PREFIX=.

all: $(INSTALL_PREFIX)/$(NAME).tar.gz

# Define a rule for pupulating the DIST_DIR while building in BUILD_DIR.

$(INSTALL_PREFIX)/$(NAME).tar.gz: $(DIST_DIR)
	tar -cvzf $(INSTALL_PREFIX)/$(NAME).tar.gz -C $(DIST_DIR) .
