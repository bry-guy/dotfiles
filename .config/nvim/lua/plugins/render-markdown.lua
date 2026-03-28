local M = {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
  ft = { 'markdown', 'md', 'mkd' },
  enabled = false,
  keys = require("config.keymaps").rendermarkdown_hotkeys,
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    pipe_table = {
      style = 'normal',
    }
  },
}

return M
