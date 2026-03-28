local M = {
  "brenton-leighton/multiple-cursors.nvim",
  version = "*",  -- Use the latest tagged version
  opts = { -- This causes the plugin setup function to be called
    custom_key_maps = require("config.keymaps").multicursors_hotkeys.custom
  },
  keys = require("config.keymaps").multicursors_hotkeys,
}

return M
