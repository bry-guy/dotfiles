local M = {
  "bluz71/vim-moonfly-colors",
  name = "moonfly",
  lazy = false,
  priority = 1000,
  init = function()
    vim.g.moonflyCursorColor = true
    vim.g.moonflyItalics = false
    vim.g.moonflyVirtualTextColor = true
    vim.g.moonflyNormalFloat = true

    local c = vim.api.nvim_create_augroup("CustomHighlight", {})
    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "moonfly",
      callback = function()
        vim.api.nvim_set_hl(0, "FoldColumn", {
          bg=require("moonfly").palette.bg,
          fg=require("moonfly").palette.lime,
        })
      end,
      group = c,
    })
  end
}

return M
