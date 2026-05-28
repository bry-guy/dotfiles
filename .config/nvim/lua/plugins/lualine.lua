local M = {
  'nvim-lualine/lualine.nvim',
  lazy = false,
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = function()
    local agentic_filetypes = {
      'AgenticChat',
      'AgenticInput',
      'AgenticCode',
      'AgenticFiles',
      'AgenticDiagnostics',
      'AgenticTodos',
    }

    return {
      options = {
        theme = require('config.theme').lualine_theme(),
        disabled_filetypes = {
          statusline = agentic_filetypes,
          winbar = agentic_filetypes,
        },
      },
    }
  end,
}

return M
