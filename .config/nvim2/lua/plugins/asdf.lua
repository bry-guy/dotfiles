local M = {
  -- "bry-guy/asdf.nvim",
  dir = "~/dev/personal/asdf.nvim",
  lazy = false,
  config = function()
    require("asdf").setup()
  end
}

return M
