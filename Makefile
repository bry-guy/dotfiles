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
