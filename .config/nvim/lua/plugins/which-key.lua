local M = {
  "folke/which-key.nvim",
  event = "VeryLazy",
  keys = require("config.keymaps").whichkey_hotkeys,
  opts = {
    preset = "modern",
    delay = function(ctx)
      return ctx.plugin and 0 or 150
    end,
    plugins = {
      registers = false,
    },
    keys = {
      scroll_down = "<Down>",
      scroll_up = "<Up>",
    },
    spec = {
      { "<leader>a", group = "AI (CodeCompanion/Copilot)" },
      { "<leader>ad", group = "AI Diff" },
      { "<leader>c", group = "Multiple Cursors" },
      { "<leader>d", group = "Debug (DAP)" },
      { "<leader>f", group = "Find (Telescope)" },
      { "<leader>r", group = "Remote" },
      { "<leader>s", group = "Session" },
      { "<leader>v", group = "View" },
      { "<leader>w", group = "Wiki (Obsidian)" },
      { "g", group = "LSP/Goto" },
      { "z", group = "Fold" },
      { "[", group = "Diagnostic" },
      { "]", group = "Diagnostic" },
      { "<C-t>", group = "Tabs" },
    },
  },
}

return M
