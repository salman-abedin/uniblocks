.POSIX:
DIR_BIN = /usr/local/bin
CONFIG = uniblocksrc
SCRIPT = $(shell grep -l "^#\!" ./* | sed 's/.\///')
init:
	@[ -f ~/.config/$(CONFIG) ] || cp $(CONFIG) ~/.config
	@echo Initiation finished.
install:
	@mkdir -p $(DIR_BIN)
	@cp -f $(SCRIPT) $(DIR_BIN)
	@chmod 755 $(DIR_BIN)/${SCRIPT}
	@echo Installation finished.
uninstall:
	@rm -f $(DIR_BIN)/$(SCRIPT)
	@echo Uninstallation finished.
.PHONY: init install uninstall
