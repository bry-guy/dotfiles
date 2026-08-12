local M = {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    worktrees = {
      {
        toplevel = vim.env.HOME,
        gitdir = vim.env.HOME .. "/.local/share/yadm/repo.git",
      },
    },
    on_attach = function(bufnr)
      local gitsigns = require("gitsigns")
      local keymaps = require("config.keymaps")
      keymaps.apply(keymaps.gitsigns_hotkeys(gitsigns), { buffer = bufnr })
    end,
  },
  config = function(_, opts)
    require("gitsigns").setup(opts)
  end,
}

return M
