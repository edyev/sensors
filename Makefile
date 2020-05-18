UNAME_S := $(shell uname -s)
BUILDDIR = build
DEPENDENCYDIR = extern
PREFIX = /usr/local
VERBOSE = 0
BUILD_TYPE = Debug

PROTO_BUF_VER = 3.11.0

override SHELL = /bin/bash

# use sudo if non-root user
THISUSER := $(shell whoami)
ifeq (x$(THISUSER), xroot)
	SUDO_CMD =
else
	SUDO_CMD = sudo
endif

.PHONY: all
all:
	$(MAKE) clone_dependencies
	$(MAKE) $(BUILDDIR)/sensor_service

.PHONY: bootstrap
bootstrap: ##		Install development 
	$(MAKE) _bootstrap

ifeq ($(UNAME_S),Linux)
_bootstrap:
	# add kitware repo to get newer cmake
	$(SUDO_CMD) apt-get update
	$(SUDO_CMD) apt-get -y -q install --no-install-recommends \
	    ca-certificates \
	    wget \
        gnupg \
	    software-properties-common
	wget -qO kitware-archive-latest.asc https://apt.kitware.com/keys/kitware-archive-latest.asc
	$(SUDO_CMD) apt-key add kitware-archive-latest.asc
	$(SUDO_CMD) apt-add-repository 'deb https://apt.kitware.com/ubuntu/ bionic main'
	$(SUDO_CMD) apt-get update
	$(SUDO_CMD) apt-get -y -q install --no-install-recommends \
	    git \
	    make \
	    cmake \
	    pkg-config \
	    autoconf \
	    automake \
	    libtool \
	    curl \
	    g++ \
		lcov \
	    unzip;
	$(SUDO_CMD) rm -f kitware-archive-latest.asc
else ifeq ($(UNAME_S),Darwin)
_bootstrap:
	@if [ -x /opt/local/bin/port ]; then \
		echo "Using macports with sudo - might need your password"; \
		$(SUDO_CMD) port install cmake; \
	else \
		echo "You don't have macports installed."; \
	fi
else
_bootstrap:
	@$(error Unsupported platform: $(UNAME_S))
endif

.PHONY: clone_dependencies
clone_dependencies: ##	Clone dependent library source
	./clone_dependencies.sh

.PHONY: install_dependencies
install_dependencies: ##		Install dependent libraries (protobuf, nanomsg, nanomsgxx)
	$(MAKE) clone_dependencies
	#$(MAKE) protobuf
	$(MAKE) nanomsg
	$(MAKE) nanomsgxx

.PHONY: nanomsg
nanomsg: ##			Install nanomsg C library
	mkdir -p $(DEPENDENCYDIR)/nanomsg/build
	cd $(DEPENDENCYDIR)/nanomsg/build && cmake .. -DCMAKE_INSTALL_PREFIX=$(PREFIX) -DCMAKE_MACOSX_RPATH=ON -DCMAKE_INSTALL_RPATH="$(PREFIX)/lib"
	cd $(DEPENDENCYDIR)/nanomsg/build && cmake --build .
	cd $(DEPENDENCYDIR)/nanomsg/build && ctest .
	cd $(DEPENDENCYDIR)/nanomsg/build && $(SUDO_CMD) cmake --build . --target install
ifeq ($(UNAME_S),Linux)
	$(SUDO_CMD) ldconfig
endif

.PHONY: nanomsgxx
nanomsgxx: ##			Install nanomsgxx C++ library
	mkdir -p $(DEPENDENCYDIR)/nanomsgxx/build
	cd $(DEPENDENCYDIR)/nanomsgxx/build && cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$(PREFIX) -DCMAKE_MACOSX_RPATH=ON -DCMAKE_INSTALL_RPATH="$(PREFIX)/lib"
	$(MAKE) -C $(DEPENDENCYDIR)/nanomsgxx/build
	$(MAKE) -C $(DEPENDENCYDIR)/nanomsgxx/build test
	$(SUDO_CMD) $(MAKE) -C $(DEPENDENCYDIR)/nanomsgxx/build install
ifeq ($(UNAME_S),Linux)
	$(SUDO_CMD) ldconfig
endif

.PHONY: protobuf
protobuf: ##			Install protobuf C++
	mkdir -p build
	cd ./build && wget -O protobuf-all-$(PROTO_BUF_VER).tar.gz https://github.com/protocolbuffers/protobuf/releases/download/v$(PROTO_BUF_VER)/protobuf-all-$(PROTO_BUF_VER).tar.gz
	cd ./build && tar -xvzf protobuf-all-$(PROTO_BUF_VER).tar.gz
	cd ./build/protobuf-$(PROTO_BUF_VER) && ./configure --prefix=$(PREFIX)
	cd ./build/protobuf-$(PROTO_BUF_VER) && $(MAKE)
	cd ./build/protobuf-$(PROTO_BUF_VER) && $(MAKE) check
	cd ./build/protobuf-$(PROTO_BUF_VER) && $(SUDO_CMD) $(MAKE) install
ifeq ($(UNAME_S),Linux)
	cd ./build/protobuf-$(PROTO_BUF_VER) && $(SUDO_CMD) ldconfig
endif

$(BUILDDIR):
	mkdir -p build

$(BUILDDIR)/sensor_service: $(BUILDDIR)
	cd $(BUILDDIR) && cmake -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) ..
	make -C $(BUILDDIR) VERBOSE=$(VERBOSE)

.PHONY: help
help: ##			Show this help.
	@echo "Welcome to sensor_service! Please use \`make <target>\` where <target> is one of the following:"
	@fgrep -h "##" Makefile | fgrep -v fgrep | sed -e 's/:[[:space:]]*##//'

.PHONY: test
test: ##			Run GoogleTest harness
	$(BUILDDIR)/run_tests

.PHONY: coverage
coverage: ##			Run tests and calculate code coverage
	cd $(BUILDDIR) && make coverage_run_tests

.PHONY: clean
clean: ##			Clean build products
	cd $(BUILDDIR) && make clean

.PHONY: clean_deps
clean_deps: ##		Clean dependency build products
	rm -rf $(DEPENDENCYDIR)