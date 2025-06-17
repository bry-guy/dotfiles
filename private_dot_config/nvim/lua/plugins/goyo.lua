local M = {
  "junegunn/goyo.vim",
  dependencies = { "junegunn/limelight.vim" },
  ft = { 'markdown', 'mkd', 'text' },
  keys = require("config.keymaps").goyo_hotkeys,
  init = function()
    vim.g['goyo_width'] = 120
    vim.g['limelight_paragraph_span'] = 1
  end,
  config = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "GoyoEnter",
      callback = function()
        vim.cmd("Limelight")
        require("lualine").hide()
      end,
    })
    vim.api.nvim_create_autocmd("User", {
      pattern = "GoyoLeave",
      callback = function()
        vim.cmd("Limelight!")
        require("lualine").hide({ unhide = true })
      end,
    })
  end
}

return M

