
.PHONY:
check_extensions_enabled:
	@if [ -z "$$PASSWORD_STORE_ENABLE_EXTENSIONS" ]; then \
		echo "WARNING!  Extensions not enabled for pass(1), installing anyway."; \
		echo "          Set PASSWORD_STORE_ENABLE_EXTENSIONS to true to enable them."; \
	fi

.PHONY:
check_extensions_dir_set:
	@if [ -z "$$PASSWORD_STORE_EXTENSIONS_DIR" ]; then \
		echo "ERROR!  I don't know where to install pdf.bash to because the"; \
		echo "        pass(1) extensions directory is not set!"; \
		exit 1; \
	fi

.PHONY:
install: check_extensions_enabled check_extensions_dir_set
	cp pdf.bash "$$PASSWORD_STORE_EXTENSIONS_DIR"
	chmod +x "$$PASSWORD_STORE_EXTENSIONS_DIR/pdf.bash"

uninstall:
	rm -f "$$PASSWORD_STORE_EXTENSIONS_DIR/pdf.bash"
