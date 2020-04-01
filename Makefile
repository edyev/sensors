UNAME_S := $(shell uname -s)
BUILDDIR = build
DEPENDENCYDIR = extern
PREFIX = /usr/local
VERBOSE = 0
BUILD_TYPE = Debug

PROTO_PATH := proto_files
PROTO_FILES := $(PROTO_PATH)/data_service.proto $(PROTO_PATH)/envelope.proto
PROTO_CC_FILES := $(PROTO_FILES:.proto=.pb.cc)

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
	$(MAKE) $(BUILDDIR)/basecamp_service

.PHONY: bootstrap
bootstrap:
	$(MAKE) _bootstrap

ifeq ($(UNAME_S),Linux)
_bootstrap:
	# add kitware repo to get newer cmake
	$(SUDO_CMD) apt-get update
	$(SUDO_CMD) apt-get -y -q install --no-install-recommends \
	    wget \
        gnupg
	wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | $(SUDO_CMD) apt-key add -
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
	    ca-certificates \
	    unzip \
	    wget;
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
clone_dependencies:
	./clone_dependencies.sh

.PHONY: install_dependencies
install_dependencies:
	$(MAKE) protobuf
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
	cd $(DEPENDENCYDIR)/schema_registry && $(MAKE) install-protobuf-cpp PREFIX=$(PREFIX)

$(BUILDDIR):
	mkdir -p build

$(BUILDDIR)/basecamp_service: $(BUILDDIR)
	cd $(BUILDDIR) && cmake -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) ..
	make -C $(BUILDDIR) VERBOSE=$(VERBOSE)

.PHONY: update_protobufs
update_protobufs:
	rm -rf $(DEPENDENCYDIR)/schema_registry
	$(MAKE) clone_dependencies
	mkdir -p $(PROTO_PATH)
	cp $(DEPENDENCYDIR)/schema_registry/proto_files/envelope.proto ./$(PROTO_PATH)/.
	cp $(DEPENDENCYDIR)/schema_registry/proto_files/data_service.proto ./$(PROTO_PATH)/.

.PHONY: help
help: ##			Show this help.
	@echo "Welcome to basecamp_service! Please use \`make <target>\` where <target> is one of the following:"
	@fgrep -h "##" Makefile | fgrep -v fgrep | sed -e 's/:[[:space:]]*##//'

.PHONY: docker
docker: ##		Build and upload CI docker image
	echo "$(GITLAB_API_TOKEN)" | docker login registry.gitlab.com/ontera/sw-team/flintstones/basecamp_service --username gitlab-ci-token --password-stdin
	docker build -t registry.gitlab.com/ontera/sw-team/flintstones/basecamp_service . --build-arg GITLAB_TOKEN=$(GITLAB_TOKEN)
	docker push registry.gitlab.com/ontera/sw-team/flintstones/basecamp_service

.PHONY: docker_interactive 
docker_interactive: ##		Download and run CI docker image interactively
	echo "$(GITLAB_API_TOKEN)" | docker login registry.gitlab.com/ontera/sw-team/flintstones/basecamp_service:latest --username gitlab-ci-token --password-stdin
	docker pull registry.gitlab.com/ontera/sw-team/flintstones/basecamp_service
	docker run -it -v `pwd`:/builds/ontera/sw-team/flintstones/basecamp_service registry.gitlab.com/ontera/sw-team/flintstones/basecamp_service:latest bash

.PHONY: test
test:
	$(MAKE)
	$(BUILDDIR)/run_tests

.PHONY: clean
clean:
	rm -rf $(PROTO_FILES) $(BUILDDIR)

.PHONY: clean_deps
clean_deps:
	rm -rf $(DEPENDENCYDIR)