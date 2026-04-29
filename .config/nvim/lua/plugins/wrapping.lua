local M = {
  "andrewferrier/wrapping.nvim",
  -- Markdown uses an explicit reading mode (<leader>vm) so editing remains
  -- plain/unwrapped by default. Keep wrapping.nvim only for generic text files.
  ft = { "text" },
}

return M
