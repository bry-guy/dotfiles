require("obsidian").setup({
  dir = "~/second-brain",
  log_level = vim.log.levels.DEBUG,
  open_app_foreground = false,
  completion = {
    nvim_cmp = true,
	min_chars = 2,
	new_notes_location = "notes_subdir",
	prepend_note_id = true
  },
  notes_subdir = "Inbox",
  daily_notes = {
    folder = "Diaries",
  },
  mappings = {
    -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
    ["gf"] = require("obsidian.mapping").gf_passthrough(),
  },
  note_id_func = function(title)
    local suffix = ""
    if title ~= nil then
	  -- Replace spaces with dashes
      suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
    end
    return suffix
  end,
  note_frontmatter_func = function(note)
    local out = { id = note.id, tags = note.tags }
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

vim.keymap.set('n', '<leader>of', '<Cmd>ObsidianQuickSwitch<CR>')
vim.keymap.set('n', '<leader>os', '<Cmd>ObsidianSearch<CR>')
vim.keymap.set('n', '<leader>od', '<Cmd>ObsidianToday<CR>')
vim.keymap.set('n', '<leader>ob', '<Cmd>ObsidianBacklinks<CR>')

vim.keymap.set('n', 'gf',
  function()
    if require('obsidian').util.cursor_on_markdown_link() then
      return "<cmd>ObsidianFollowLink<CR>"
    else
      return "gf"
    end
  end,
  { noremap = false, expr = true })
