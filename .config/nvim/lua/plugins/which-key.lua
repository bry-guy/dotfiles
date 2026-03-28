local M = {
  "folke/which-key.nvim",
  event = "VeryLazy",
  keys = require("config.keymaps").whichkey_hotkeys,
  opts = {
    preset = "modern",
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
      { "<leader>m", group = "Markdown" },
      { "<leader>r", group = "Remote" },
      { "<leader>t", group = "Test (Neotest)" },
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
