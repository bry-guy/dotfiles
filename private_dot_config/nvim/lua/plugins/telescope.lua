local actions = require('telescope.actions')

local select_one_or_multi = function(prompt_bufnr)
  local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
  local multi = picker:get_multi_selection()

  local picker_type = picker.prompt_title or ""
  local is_codecompanion = string.find(picker_type, "Select file%(s%)")
    or string.find(picker_type, "Select buffer%(s%)")
    or string.find(picker_type, "Select symbol%(s%)")

  if is_codecompanion then
    require("telescope.actions").select_default(prompt_bufnr)
    return
  end

  if not vim.tbl_isempty(multi) then
    require("telescope.actions").close(prompt_bufnr)
    for _, j in pairs(multi) do
      if j.path ~= nil then
        if j.lnum ~= nil then
          vim.cmd(string.format("%s %s:%s", "edit", j.path, j.lnum))
        else
          vim.cmd(string.format("%s %s", "edit", j.path))
        end
      end
    end
  else
    require("telescope.actions").select_default(prompt_bufnr)
  end
end

local M = {
  "nvim-telescope/telescope.nvim",
  tag = '0.1.8',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope-dap.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    'sudormrfbin/cheatsheet.nvim',
    'nvim-telescope/telescope-ui-select.nvim',
  },
  -- init = function()
  --   require("config.keymaps").telescope_hotkeys(builtin)
  -- end,
  keys = require("config.keymaps").telescope_hotkeys,
  config = function(_, opts)
    require('telescope').setup(opts)
    require('telescope').load_extension('fzf')
    require('telescope').load_extension('dap')
    require('telescope').load_extension('cheatsheet')
    require('telescope').load_extension('ui-select')
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
            ["<CR>"] = select_one_or_multi,
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
