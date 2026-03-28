local M = {
  "neovim/nvim-lspconfig",
  dependencies = {
    "hrsh7th/nvim-cmp",
    'hrsh7th/cmp-nvim-lsp',
  },
  event = "BufReadPre",
  keys = require("config.keymaps").lsp_hotkeys,
  config = function()
    local default_cap = vim.lsp.protocol.make_client_capabilities()
    local cmp_cap = require('cmp_nvim_lsp').default_capabilities()

    local capabilities = vim.tbl_deep_extend(
      'force',
      default_cap,
      cmp_cap
    )

    -- jdtls / java is setup via nvim-jdtls

    local jsonls_cap = vim.deepcopy(capabilities)
    jsonls_cap.textDocument.completion.completionItem.snippetSupport = true

    vim.lsp.config('jsonls', {
      capabilities = jsonls_cap,
      cmd = { "vscode-json-languageserver", "--stdio" }
    })

    vim.lsp.config('eslint', {
      capabilities = capabilities,
    })

    vim.lsp.config('ts_ls', {
      capabilities = capabilities,
    })

    vim.lsp.config('gopls', {
      capabilities = capabilities,
      settings = {
        gopls = {
          gofumpt = true
        }
      }
    })

    vim.lsp.config('lua_ls', {
      capabilities = capabilities,
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
        }
      }
    })

    vim.lsp.config('metals', {
      capabilities = capabilities,
      cmd = { 'metals' },
      filetypes = { 'scala', 'sbt' },
      root_dir = function(bufnr, on_dir)
        local root = vim.fs.root(bufnr, { 'build.sbt', 'build.sc', 'settings.gradle', 'settings.gradle.kts', '.git' })
        if root then
          on_dir(root)
        end
      end,
    })

    vim.lsp.enable('jsonls')
    vim.lsp.enable('eslint')
    vim.lsp.enable('ts_ls')
    vim.lsp.enable('gopls')
    vim.lsp.enable('lua_ls')
    vim.lsp.enable('metals')
  end
}

return M
