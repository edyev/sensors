UNAME_S := $(shell uname -s)
BUILDDIR = build
PREFIX = /usr/local

PROTO_PATH := ./proto_files
PROTO_FILES := data_service.proto envelope.proto
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
	$(SUDO_CMD) apt-get update
	$(SUDO_CMD) apt-get -y -q install --no-install-recommends \
	    git \
	    make \
	    cmake \
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

.PHONY: nanomsg
nanomsg: ##			Install nanomsg C library
	mkdir -p dependencies/nanomsg/build
	cd dependencies/nanomsg/build && cmake .. -DCMAKE_INSTALL_PREFIX=$(PREFIX) -DCMAKE_MACOSX_RPATH=ON -DCMAKE_INSTALL_RPATH="$(PREFIX)/lib"
	cd dependencies/nanomsg/build && cmake --build .
	cd dependencies/nanomsg/build && ctest .
	cd dependencies/nanomsg/build && cmake --build . --target install
ifeq ($(UNAME_S),Linux)
	$(SUDO_CMD) ldconfig
endif

.PHONY: protobuf
protobuf: ##			Install protobuf C++
	cd dependencies/schema_registry && $(MAKE) install-protobuf-cpp PREFIX=$(PREFIX)

$(BUILDDIR):
	mkdir -p build

$(BUILDDIR)/basecamp_service: $(BUILDDIR)
	cd $(BUILDDIR) && cmake ../libbasecamp_service
	make -C $(BUILDDIR)

.PHONY: update_protobufs
update_protobufs:
	rm -rf dependencies/schema_registry
	$(MAKE) clone_dependencies
	mkdir -p ./proto_files
	cp dependencies/schema_registry/proto_files/envelope.proto ./proto_files/.
	cp dependencies/schema_registry/proto_files/data_service.proto ./proto_files/.
	$(MAKE) libbasecamp_service/src/momd_connection/envelope.pb.cc
	$(MAKE) libbasecamp_service/src/data_service.pb.cc

libbasecamp_service/src/%.pb.cc: $(PROTO_PATH)/%.proto
	protoc --cpp_out=libbasecamp_service/src --proto_path=$(PROTO_PATH) $<

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
	make -C $(BUILDDIR) test

.PHONY: clean
clean:
	rm -rf $(PROTO_PY_FILES) $(BUILDDIR)

.PHONY: clean_deps
clean_deps:
	rm -rf dependencies