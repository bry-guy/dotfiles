local actions = require('telescope.actions')

require('telescope').setup {
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
require('telescope').load_extension('software-licenses')
