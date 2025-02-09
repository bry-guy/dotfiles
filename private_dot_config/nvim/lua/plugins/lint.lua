local M = {
  "mfussenegger/nvim-lint",
  event = "BufReadPre", -- TODO: Should this be on save?
  config = function()
    local lint = require("lint")
    lint.linters_by_ft = {
      go = { 'golangcilint', },
      -- lua = { 'luacheck', },
    }
  end
}

return M
