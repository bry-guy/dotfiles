local actions = require('telescope.actions')

require('telescope').setup {
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    }
  },
  defaults = {
    file_ignore_patterns = { ".git/", "node_modules", ".yarn/cache" },
	hidden = true,
	mappings = {
	  n = {
		["<C-j>"] = actions.preview_scrolling_down,
		["<C-k>"] = actions.preview_scrolling_up,
		["<C-v>"] = actions.select_vertical,
		["<C-s>"] = actions.select_horizontal,
	  },
	},
	layout_strategy = 'flex',
	layout_config = {
	  width = 0.90,
	  flex = {
		flip_columns = 320,
	  }
	},
  },
  pickers = {
	find_files = {
	  no_ignore = true,
	  hidden = true,
	}
  }
}

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>fF', builtin.find_files, {})
vim.keymap.set('n', '<leader>ff', builtin.git_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fw', builtin.grep_string, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<leader>fo', builtin.oldfiles, {})
vim.keymap.set('n', '<leader>fm', builtin.commands, {})
vim.keymap.set('n', '<leader>fn', builtin.man_pages, {})

vim.keymap.set('n', '<leader>fr', builtin.lsp_references, {})
-- TODO: Figure out how to use telescope to grep through auto-completion lists 
-- vim.keymap.set('i', '<leader>fd', builtin.lsp_incoming_calls, {})

vim.keymap.set('n', '<leader>ft', builtin.treesitter, {})

require('telescope').load_extension('fzf')
