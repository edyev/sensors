UNAME_S := $(shell uname -s)
BUILDDIR = build

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
		cmake;
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

$(BUILDDIR):
	mkdir -p build

$(BUILDDIR)/basecamp_service: $(BUILDDIR)
	cd $(BUILDDIR) && cmake ..
	make -C $(BUILDDIR)

.PHONY: test
test:
	cd build && ctest ..

.PHONY: clean
clean:
	rm -rf build

.PHONY: clean_deps
clean_deps:
	rm -rf dependencies