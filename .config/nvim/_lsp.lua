local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

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
