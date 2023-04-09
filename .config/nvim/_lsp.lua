local capabilities = require('cmp_nvim_lsp').default_capabilities()

local opts = { noremap=true, silent=true }
vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
vim.api.nvim_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

local on_attach = function(_, bufnr)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
end

require("mason-lspconfig").setup({
  ensure_installed = {
	'apex_ls',
	'bashls',
	'lua_ls',
	'terraformls',
	'tsserver',
	'pylsp',
	'jdtls',
	'gopls',
	'golangci_lint_ls'
  },
  automatic_installation = true,
})

local lsp = require("lspconfig")

require("mason-lspconfig").setup_handlers {
  function (server_name)
	require("lspconfig")[server_name].setup {
	  on_attach = on_attach,
	  capabilities = capabilities
	}
  end,
  ["jdtls"] = function() end,
  ["lua_ls"] = function ()
	lsp.lua_ls.setup {
	  -- root_dir = function(fname)
		-- if fname == vim.loop.os_homedir() then return nil end
		-- local root_pattern = lsp.util.root_pattern('.git', '*.rockspec')(fname)
		-- return root_pattern or fname
	  -- end,
	  settings = {
		Lua = {
		  runtime = {
			version = 'LuaJIT',
		  },
		  diagnostics = {
			globals = {'vim'},
		  },
		  workspace = {
			library = vim.api.nvim_get_runtime_file("", true),
		  },
		  telemetry = {
			enable = false,
		  },
		},
	  },
	}
  end,
}
