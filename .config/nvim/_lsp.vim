lua << EOF
		local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

		-- Use a loop to conveniently call 'setup' on multiple servers and
		-- map buffer local keybindings when the language server attaches
		local servers = {}
		for _, lsp in pairs(servers) do
				require('lspconfig')[lsp].setup {
						capabilities = capabilities,
						on_attach = on_attach,
						flags = {
						  debounce_text_changes = 150,
						}
				}
		end
EOF
