require("copilot").setup {
  filetypes = {
	go = true,
	["*"] = false, -- disable for all other filetypes and ignore default `filetypes`
  },
  panel = {
	auto_refresh = false,
	keymap = {
	  accept = "<CR>",
	  jump_prev = "[[",
	  jump_next = "]]",
	  refresh = "gr",
	  open = "<M-CR>",
	},
  },
  suggestion = {
	auto_trigger = true,
	keymap = {
	  accept = "<M-CR>",
	  prev = "<M-[>",
	  next = "<M-]>",
	  dismiss = "<M-x>",
	},
  },
}

-- hide copilot suggestions when cmp menu is open
-- to prevent odd behavior/garbled up suggestions
-- local cmp_status_ok, cmp = pcall(require, "cmp")
-- if cmp_status_ok then
--   cmp.event:on("menu_opened", function()
-- 	vim.b.copilot_suggestion_hidden = true
--   end)

--   cmp.event:on("menu_closed", function()
-- 	vim.b.copilot_suggestion_hidden = false
--   end)
-- end

