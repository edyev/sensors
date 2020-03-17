BUCK_DIR = $(HOME)/.buck
UNAME_S := $(shell uname -s)

# get default shell for user
DEFAULT_SHELL=$(shell finger $(USER) | grep 'Shell:*' | cut -f3 -d ":")
BUCK_PATH_VAR="export PATH=$(HOME)/.buck/bin:$(PATH)"
BUCK_PATH_UPDATED=$(shell grep "export PATH=$(HOME)/.buck/bin:$(PATH)" 2> /dev/null; echo $$?)

# use sudo if non-root user
THISUSER := $(shell whoami)
ifeq (x$(THISUSER), xroot)
	SUDO_CMD =
else
	SUDO_CMD = sudo
endif

.PHONY: bootstrap
bootstrap:
	$(MAKE) _bootstrap
	$(MAKE) buck
	$(MAKE) buckaroo

ifeq ($(UNAME_S),Linux)
_bootstrap:
	$(SUDO_CMD) apt-get update
	$(SUDO_CMD) apt-get -y -q install --no-install-recommends \
		watchman apache-ant;
else ifeq ($(UNAME_S),Darwin)
_bootstrap:
	@if [ -x /opt/local/bin/port ]; then \
		echo "Using macports with sudo - might need your password"; \
		$(SUDO_CMD) port install openjdk8 watchman apache-ant; \
		/usr/libexec/java_home -v 1.8; \
	else \
		echo "You don't have macports installed."; \
	fi
else
_bootstrap:
	@$(error Unsupported platform: $(UNAME_S))
endif

.PHONY: _bootstrap
_bootstrap:

.PHONY: buck 
buck:
	# clone and install buck build system
	if [ ! -d $(BUCK_DIR) ]; then \
		git clone https://github.com/facebook/buck.git --depth 1 $(BUCK_DIR); \
	fi
	cd $(BUCK_DIR) && ant
	cd $(BUCK_DIR) && ./bin/buck build --show-output buck

	# add ~/.buck/bin to PATH (if not already present)
	@if [[ ( "$(DEFAULT_SHELL)" == *"zsh"* ) && ( "$(PATH)" != *"$(HOME)/.buck/bin"* ) ]]; then \
		echo "\nexport PATH=\"$(HOME)/.buck/bin:\$$PATH\"" >> ~/.zshrc; \
		echo "~/.zshrc updated. Please restart shell to add buck to PATH."; \
	elif [[ ( "$(DEFAULT_SHELL)" == *"bash"* ) && ( "$(PATH)" != *"$(HOME)/.buck/bin"* ) ]]; then \
		echo "\nexport PATH=\"$(HOME)/.buck/bin:\$$PATH\"" >> ~/.bashrc; \
		echo "~/.bashrc updated. Please restart shell to add buck to PATH."; \
	else \
		echo "Not using bash or zsh (Using $(DEFAULT_SHELL)), or PATH already set up. Setup buck path manually."; \
	fi

.PHONY: buckaroo
buckaroo:
	wget https://github.com/LoopPerfect/buckaroo/releases/download/v2.2.0/buckaroo-macos -O $(BUCK_DIR)/bin/buckaroo
	chmod +x $(BUCK_DIR)/bin/buckaroo

.PHONY: clean
clean:
	rm -rf build