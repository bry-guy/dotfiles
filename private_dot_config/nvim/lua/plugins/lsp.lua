local M = {
  "neovim/nvim-lspconfig",
  dependencies = {
    "hrsh7th/nvim-cmp",
    'hrsh7th/cmp-nvim-lsp',
  },
  event = "BufReadPre",
  config = function()
    local lsp = require("lspconfig")

    local default_cap = vim.lsp.protocol.make_client_capabilities()
    local cmp_cap = require('cmp_nvim_lsp').default_capabilities()

    local capabilities = vim.tbl_deep_extend(
      'force',
      default_cap,
      cmp_cap
    )

    -- jdtls / java is setup via nvim-jdtls

    lsp.ts_ls.setup{
      on_attach = require("config.keymaps").lsp_hotkeys,
      capabilities = capabilities,
    }

    lsp.gopls.setup{
      on_attach = require("config.keymaps").lsp_hotkeys,
      capabilities = capabilities,
      settings = {
        gopls = {
          gofumpt = true
        }
      }
    }

    lsp.lua_ls.setup{
      on_attach = require("config.keymaps").lsp_hotkeys,
      capabilities = capabilities,
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
        }
      }

    }
  end
}

return M
