local M = {
  "neovim/nvim-lspconfig",
  event = "BufReadPre",
  config = function()
    local lsp = require("lspconfig")

    lsp.gopls.setup{
      on_attach = require("config.keymaps").lsp_hotkeys
    }

    lsp.lua_ls.setup{
      on_attach = require("config.keymaps").lsp_hotkeys,
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
