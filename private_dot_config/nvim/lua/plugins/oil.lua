local M = {
  "stevearc/oil.nvim",
  lazy = false,
  event = "BufReadPre",
  dependencies = { { "echasnovski/mini.icons", opts = {} } },
  init = function()
    local optsfn = function (opts)
      vim.fn.system { 'open', opts.fargs[1] }
    end
    vim.api.nvim_create_user_command('Browse', optsfn, { nargs = 1 })
  end,
  config = function()
    require("oil").setup({
      keymaps = require("config.keymaps").oil_hotkeys,
    })
  end
}

return M
