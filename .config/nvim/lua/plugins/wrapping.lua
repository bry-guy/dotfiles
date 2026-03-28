local M = {
  "andrewferrier/wrapping.nvim",
  ft = { 'markdown', 'mkd', 'text' },
  opts = {
    softener = { markdown = function()
      return true
    end
  },
  },
}

return M
