local M = {
  "junegunn/goyo.vim",
  keys = require("config.keymaps").goyo_hotkeys,
  init = function()
    vim.g['goyo_width'] = 120
  end,
  config = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "GoyoEnter",
      callback = function()
        require("lualine").hide()
      end,
    })
    vim.api.nvim_create_autocmd("User", {
      pattern = "GoyoLeave",
      callback = function()
        require("lualine").hide({ unhide = true })
      end,
    })
  end,
}

return M

