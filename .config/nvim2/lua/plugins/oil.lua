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
      keymaps = {
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.select",
        ["<C-v>"] = "actions.select_vsplit",
        ["<C-s>"] = "actions.select_split",
        ["<C-t>"] = "actions.select_tab",
        ["<C-p>"] = "actions.preview",
        ["<C-c>"] = "actions.close",
        ["<C-l>"] = "actions.refresh",
        ["-"] = "actions.parent",
        ["`"] = "actions.cd",
        ["~"] = "actions.tcd",
        ["go"] = "actions.open_cmdline",
        ["gy"] = "actions.copy_entry_path",
        ["gs"] = "actions.change_sort",
        ["gx"] = "actions.open_external",
        ["g."] = "actions.toggle_hidden",
        ["g\\"] = "actions.toggle_trash",
      },
    })


  end
}

return M
