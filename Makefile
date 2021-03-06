PREFIX = /usr/local/bin

SOURCE_FILE = $(wildcard $(notdir $(CURDIR)).*)
SOURCE_PATH = $(CURDIR)/$(SOURCE_FILE)
TARGET_FILE = $(basename $(SOURCE_FILE))
TARGET_PATH = $(PREFIX)/$(TARGET_FILE)

.PHONY: test
test:
	$(CURDIR)/test.sh

.PHONY: install
install:
	install $(SOURCE_PATH) $(TARGET_PATH)
	sed -i -e 's#\(\./\)\?$(SOURCE_FILE)#$(TARGET_FILE)#g' $(TARGET_PATH)
	if [ -d /etc/bash_completion.d ]; then \
		install --mode 644 etc/bash_completion.d/$(TARGET_FILE) /etc/bash_completion.d/; \
	fi

include tools.mk
