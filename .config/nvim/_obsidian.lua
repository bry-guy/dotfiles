-- Function to assign title as id (dash delimited)
local function note_id_fn(title)
    local suffix = ""
    if title ~= nil then
        -- Replace spaces with underscores, then remove all characters except
        -- letters, numbers, underscores, and hyphens
        suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9_-]", ""):lower()
    end
    return suffix
end

require("obsidian").setup({
  dir = "~/second-brain",
  open_app_foreground = false,
  completion = {
    nvim_cmp = true,
	min_chars = 2,
  },
  notes_subdir = "inbox",
  new_notes_location = "notes_subdir",
  daily_notes = {
    folder = "dailies",
  },
  mappings = {
    -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
	["gf"] = {
	  action = function()
		return require("obsidian").util.gf_passthrough()
	  end,
	  opts = { noremap = false, expr = true, buffer = true },
	},
	-- Toggle check-boxes.
	["<leader>wc"] = {
      action = function()
        return require("obsidian").util.toggle_checkbox()
      end,
      opts = { buffer = true },
    },
  },
  note_id_func = note_id_fn,
  note_frontmatter_func = function(note)
	local out = {
	  id = note.id or '',
	  tags = note.tags or {},
	  aliases = note.aliases or {},
	}

	-- If 'note.aliases' contains 'note.id', remove it
	if note.id and note.aliases then
	  local filtered_aliases = {}
	  for _, alias in ipairs(note.aliases) do
		if alias ~= note.id then
		  table.insert(filtered_aliases, alias)
		end
	  end
	  out.aliases = filtered_aliases
	end

	-- Merge additional metadata into 'out', ensuring manually added fields are kept
	if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
	  for k, v in pairs(note.metadata) do
		out[k] = v
	  end
	end

	return out
  end,
  finder = "telescope.nvim",
  open_notes_in = "hsplit"
})

vim.keymap.set('n', '<leader>wn', "<Cmd>ObsidianNew<CR>")
vim.keymap.set('n', '<leader>wf', "<Cmd>ObsidianQuickSwitch<CR>")
vim.keymap.set('n', '<leader>ws', "<Cmd>ObsidianSearch<CR>")
vim.keymap.set('n', '<leader>wt', "<Cmd>ObsidianToday<CR>")
vim.keymap.set('n', '<leader>wb', "<Cmd>ObsidianBacklinks<CR>")
vim.keymap.set('v', '<leader>wl', "<Cmd>ObsidianLink<CR>")
vim.keymap.set('n', '<leader>wl', "<Cmd>ObsidianLinkNew<CR>")
vim.keymap.set('n', '<leader>wg', "<Cmd>ObsidianFollowLink<CR>")

vim.keymap.set('n', '<CR>',
  function()
    if require('obsidian').util.cursor_on_markdown_link() then
      return "<cmd>ObsidianFollowLink<CR>"
    else
      return "<CR>"
    end
  end,
  { noremap = false, expr = true })
