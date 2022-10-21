export EXECUTABLE_NAME = serial

PREFIX = /usr/local
INSTALL_PATH = $(PREFIX)/bin/$(EXECUTABLE_NAME)
SHARE_PATH = $(PREFIX)/share/$(EXECUTABLE_NAME)
CURRENT_PATH = $(PWD)
SWIFT_BUILD_FLAGS = --disable-sandbox -c release --arch arm64 --arch x86_64
EXECUTABLE_PATH = $(shell swift build $(SWIFT_BUILD_FLAGS) --show-bin-path)/$(EXECUTABLE_NAME)

.PHONY: install build uninstall format_code brew release

install: build
	mkdir -p $(PREFIX)/bin
	cp -f $(EXECUTABLE_PATH) $(INSTALL_PATH)

build:
	swift build $(SWIFT_BUILD_FLAGS)
