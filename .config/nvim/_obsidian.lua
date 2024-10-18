-- Function to check if a directory exists
local function directory_exists(path)
    local stat = vim.loop.fs_stat(path)
    return stat and stat.type == "directory"
end

-- Function to create a directory if it doesn't exist
local function ensure_directory_exists(path)
    if not directory_exists(path) then
        local success, err = vim.loop.fs_mkdir(path, 511) -- 511 decimal is 0777 octal
        if not success then
            error("Could not create directory: " .. err)
        end
    end
end

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

-- Function to assign the id as the file on the path
local function note_path_id_fn(note)
    local current_path = tostring(note.path)
    local id = tostring(note.id)

	if not current_path then
        error("current_path is nil")
    end

    -- Strip the filename from the current path
    local path_without_file = current_path:match("(.*/)")
    -- Append the id with the markdown extension as the new filename to the path
    local new_path = path_without_file .. id .. ".md"

	return require("obsidian").Path.new(new_path)
end

require("obsidian").setup({
  dir = "~/second-brain",
  open_app_foreground = false,
  completion = {
    nvim_cmp = true,
	min_chars = 2,
  },
  new_notes_location = "inbox",
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
  -- Titles passed as foo_bar-my-title-name become foo/bar/my-title-name.md (only one subdir permitted)
  note_path_func = function(spec)
	local dir = tostring(spec.dir)
	local id = tostring(spec.id)

	local path
	local segments = {}

	for segment in string.gmatch(id, "[^_]+") do
	  print("segment: " .. segment)
	  table.insert(segments, segment)
	end

	if segments[1] and segments[2] then
	  local type = segments[1]
	  local subtype = segments[2]

	  local type_dir = dir .. "/" .. type .. "/"
	  ensure_directory_exists(type_dir)
	  print("type_dir: " .. type_dir)

	  local subtype_dir = subtype .. "/"
	  ensure_directory_exists(type_dir .. subtype_dir)
	  print("subtype_dir: " .. subtype_dir)

	  local file = segments[3]
	  print("file: " .. file)

	  path = type_dir .. subtype_dir .. file
	else
	  path = dir .. "/" .. spec.id
	end

	print("path: " .. path)
    return path .. ".md"
  end,
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

-- -- fixup incorrect notes
-- local client = require("obsidian").get_client()
-- client:apply_async(function(note)
--   local did_update = false

--   -- TODO: Copy contents to new note, delete old note to .trash
--   if note.id ~= nil and string.find(note.id, " ") ~= nil then
-- 	did_update = true

-- 	print("note.id: " .. note.id)

-- 	local new_id = note_id_fn(note.id)
-- 	print("new_id: " .. new_id)

-- 	print(string.format("ID: %s to %s", note.id, new_id))
-- 	note.id = new_id

-- 	local new_path = note_path_id_fn(note)
-- 	print(string.format("PATH: %s to %s", note.path, new_path))
-- 	note.path = new_path
--   end

--   if did_update then
-- 	print(string.format("UPDATE: %s", note.id))
-- 	note:save()
--   end
-- end)

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
