local M = {
  "OXY2DEV/markview.nvim",
  lazy = false,
  keys = require("config.keymaps").markview_hotkeys,
  opts = {
    preview = {
      enable = false,
    },
  },
}

return M
