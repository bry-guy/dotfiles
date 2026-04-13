local M = {
  'nvim-lualine/lualine.nvim',
  lazy = false,
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = function()
    return {
      options = { theme = require('config.theme').lualine_theme() },
    }
  end,
}

return M
