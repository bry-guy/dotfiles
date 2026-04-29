local M = {
  "folke/persistence.nvim",
  event = "BufReadPre",
  opts = {},
  keys = require("config.keymaps").session_hotkeys,
}

return M
