local builtin = require('telescope.builtin')
local actions = require('telescope.actions')

local M = {
  "nvim-telescope/telescope.nvim",
  tag = '0.1.8',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope-dap.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    'sudormrfbin/cheatsheet.nvim',
  },
  init = function()
    require("config.keymaps").telescope_hotkeys(builtin)
  end,
  config = function(_, opts)
    require('telescope').setup(opts)
    require('telescope').load_extension('fzf')
    require('telescope').load_extension('dap')
    require('telescope').load_extension('cheatsheet')
  end,
  opts = {
      defaults = {
        file_ignore_patterns = { "^.git/", "node_modules", "^.yarn/cache" },
        hidden = true,
        mappings = {
          n = {
            ["J"] = actions.preview_scrolling_down,
            ["K"] = actions.preview_scrolling_up,
            ['"'] = actions.select_vertical,
            ["%"] = actions.select_horizontal,
            ["Q"] = actions.send_selected_to_qflist + actions.open_qflist,
          },
        },
        layout_strategy = 'flex',
        layout_config = {
          width = 0.95,
          mirror = true,
          flex = {
            flip_columns = 240,
          }
        },
      },
      pickers = {
        find_files = {
          no_ignore = true,
          hidden = true,
        },
        buffers = {
          sort_mru = true
        },
        live_grep = {
          additional_args = function(_)
            return {"--hidden"}
          end
        },
      },
      extensions = {
        fzf = {
          fuzzy = true,                    -- false will only do exact matching
          override_generic_sorter = true,  -- override the generic sorter
          override_file_sorter = true,     -- override the file sorter
          case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
        }
      }
  },
}

return M
