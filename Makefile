.PHONY: code lsp goenv

EXT_INSTALLED=code --list-extensions
EXT_RECOMMENDED=jq -r '.recommendations[]' ~/.config/code/extensions.json

code:
	@echo "Checking for missing extensions..."
	@echo "\nRecommended:"
	@$(EXT_RECOMMENDED)
	@echo "\nInstalled:"
	@$(EXT_INSTALLED)
	@echo "\n"
	@$(EXT_RECOMMENDED) | while read extension; do \
		echo "Checking $$extension..."; \
		if $(EXT_INSTALLED) | grep -iq $$extension; then \
			echo "$$extension is already available"; \
		else \
			echo "Installing $$extension..."; \
			code --install-extension $$extension; \
		fi; \
	done

goenv:

LSP_VERSIONS_FILE=$(HOME)/.lsp-versions

lsp:
	@echo "$(LANG): installing lsp"
	@if [ "$(LANG)" = "golang" ]; then \
		$(MAKE) lsp_golang; \
	fi

lsp_golang:
	$(MAKE) install_lsp LSP_NAME=gopls INSTALL_CMD="go install golang.org/x/tools/gopls@v%s" CHECK_CMD="gopls version"
	$(MAKE) install_lsp LSP_NAME=golangci-lint INSTALL_CMD="go install github.com/golangci/golangci-lint/cmd/golangci-lint@v%s" CHECK_CMD="golangci-lint version";

install_lsp:
	@echo "install_lsp"
	$(eval VERSION=$(shell grep $(LSP_NAME) $(LSP_VERSIONS_FILE) | cut -d ' ' -f2))
	@if [ -z "$(VERSION)" ]; then \
		echo "$(LSP_NAME): no version, skipping installation."; \
	else \
		echo "$(LSP_NAME): version $(VERSION)..."; \
		CURRENT_VERSION=$$($(CHECK_CMD) | rg -o "$(VERSION)" | uniq); \
		if [ "$$CURRENT_VERSION" = "$(VERSION)" ]; then \
			echo "$(LSP_NAME) is already at the desired version $(VERSION)."; \
		else \
			echo "Installing $(LSP_NAME)@v$(VERSION)..."; \
			$(shell printf "$(INSTALL_CMD)" $(VERSION)); \
		fi \
	fi

