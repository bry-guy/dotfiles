-- local registry = require("mason-registry")
-- registry.refresh(function ()
--      registry.get_package("bash-debug-adapter")
--      registry.get_package("motoko-lsp")
-- end)

local capabilities = require('cmp_nvim_lsp').default_capabilities()

local opts = { noremap=true, silent=true }
vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
vim.api.nvim_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

local on_attach = function(_, bufnr)
  -- print("setting up server "  .. server)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gh', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ch', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>cr', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  --
  -- "organize imports"
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ci', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
  -- vim.lsp.buf.execute_command({command = "_typescript.organizeImports", arguments = {vim.fn.expand("%:p")}})
  --
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
end

require("neodev").setup({
  -- override = function(_, library)
	-- library.enabled = true
	-- library.plugins = true
  -- end,
})


local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status_ok then
  vim.notify("Couldn't load LSP-Config" .. lspconfig, vim.log.levels.ERROR)
  return
end

-- pylsp pipenv setup

-- Function to get the command to run pylsp using Pipenv
local function get_pylsp_command()
  -- Check if a Pipfile exists to confirm it's a pipenv project
  if vim.fn.filereadable("Pipfile") ~= 0 then
    -- print("Pipfile found. Using pipenv to run pylsp.")  -- Debug: Confirm using Pipenv
    return {"pipenv", "run", "pylsp"}
  else
    -- print("No Pipfile found. Falling back to global pylsp.")  -- Debug: Fallback to global pylsp
    return {"pylsp"}
  end
end

-- Check if Pipfile exists in the current directory to decide environment
local function setup_pylsp()
  lspconfig.pylsp.setup{
    cmd = get_pylsp_command(),
    on_attach = on_attach,
	capabilities = capabilities,
    settings = {
      pylsp = {
        configurationSources = {"pycodestyle"},
        plugins = {
          pycodestyle = {enabled = true},
          pyflakes = {enabled = false},
          flake8 = {enabled = true},
          pylint = {enabled = true},
          jedi_completion = {enabled = true},
          jedi_definition = {enabled = true, follow_imports = true},
        }
      }
    } }
end

local handlers = {
  function (server_name)
	lspconfig[server_name].setup {
	  on_attach = on_attach,
	  capabilities = capabilities
	}
  end,
  ["lua_ls"] = function ()
	lspconfig.lua_ls.setup {
	  on_attach = on_attach,
	  settings = {
		Lua = {
		  completion = {
			callSnippet = "Replace"
		  },
		  diagnostics = {
			globals = { "vim" },
		  },
		  workspace = {
			checkThirdParty = false,
		  },
		  telemetry = {
			enable = false
		  }
		}
	  }
	}
  end,
  ["jdtls"] = function () end, -- jdtls is invoked on each buffer via filetype hook
  -- ["pylsp"] = setup_pylsp(),
  -- ["pylsp"] = function ()
	-- lspconfig.pylsp.setup {
	  -- on_attach = on_attach,
	  -- settings = {
		-- pylsp = {
		  -- plugins = {
			-- pyflakes = {enabled = false},
			-- pylint = {enabled = false},
		  -- },
		-- },
	  -- },
	-- }
  -- end,
}

require("mason").setup()

require("mason-lspconfig").setup({
  -- ensure_installed = {
	-- 'apex_ls',
	-- 'bashls',
	-- 'lua_ls',
	-- 'terraformls',
	-- 'tsserver',
	-- 'pylsp',
	-- 'jdtls',
  -- },

  -- automatic_installation = { exclude = { "lua_ls" }},
  -- automatic_installation = true,
  handlers = handlers,
})

require('lspconfig').golangci_lint_ls.setup{
  on_attach = on_attach,
  capabilities = capabilities
}
require('lspconfig').gopls.setup{
  on_attach = on_attach,
  capabilities = capabilities
}
setup_pylsp()
