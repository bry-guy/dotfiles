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

local M = {
  "epwalsh/obsidian.nvim",
  lazy = true,
  init = function()
    vim.opt.conceallevel = 1
  end,
  keys = require("config.keymaps").obsidian_hotkeys
  opts = function()
    local obsidian = require("obsidian")
    return {
      dir = "~/second-brain",
      open_app_foreground = false,
      ui = { enable = false },
      completion = {
        nvim_cmp = true,
        min_chars = 2,
      },
      notes_subdir = "inbox",
      new_notes_location = "notes_subdir",
      daily_notes = {
        folder = "dailies",
      },
      mappings = {},
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
    }
  end,
}

return M


