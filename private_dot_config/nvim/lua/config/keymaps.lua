local bufopts = { noremap=true, silent=true }

-- TODO: Export and invoke
-- diagnostics
vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', bufopts) -- "next diagnostic"
vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', bufopts)

-- TODO: Export and invoke
-- dap
vim.keymap.set('n', '<leader>dx', "<cmd>lua require'dap'.continue()<CR>", bufopts) -- "debug continue"
vim.keymap.set('n', '<leader>ds', "<cmd>lua require'dap'.step_over()<CR>", bufopts)
vim.keymap.set('n', '<leader>di', "<cmd>lua require'dap'.step_into()<CR>", bufopts)
vim.keymap.set('n', '<leader>do', "<cmd>lua require'dap'.step_out()<CR>", bufopts)
vim.keymap.set('n', '<leader>db', "<cmd>lua require'dap'.toggle_breakpoint()<CR>", bufopts)
vim.keymap.set('n', '<leader>dB', "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>", bufopts)
vim.keymap.set('n', '<leader>dp', "<cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>", bufopts)
vim.keymap.set('n', '<leader>dr', "<cmd>lua require'dap'.repl.open()<CR>", bufopts)
vim.keymap.set('n', '<leader>dl', "<cmd>lua require'dap'.run_last()<CR>", bufopts)
--- telescope dap
vim.keymap.set('n', '<leader>dc', "<cmd>lua require'telescope'.extensions.dap.commands{}<CR>", bufopts)
vim.keymap.set('n', '<leader>dg', "<cmd>lua require'telescope'.extensions.dap.configurations{}<CR>", bufopts)
vim.keymap.set('n', '<leader>dk', "<cmd>lua require'telescope'.extensions.dap.list_breakpoints{}<CR>", bufopts)
vim.keymap.set('n', '<leader>dv', "<cmd>lua require'telescope'.extensions.dap.variables{}<CR>", bufopts)
vim.keymap.set('n', '<leader>df', "<cmd>lua require'telescope'.extensions.dap.frames{}<CR>", bufopts)


local M = {}

-- lsp
M.lsp_hotkeys = function()
  vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", bufopts) -- "go to definition"
  vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", bufopts)
  vim.keymap.set("n", "gt", "<cmd>lua vim.lsp.buf.type_definition()<CR>", bufopts)
  vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", bufopts)
  vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", bufopts)
  vim.keymap.set("n", "gh", "<cmd>lua vim.lsp.buf.hover()<CR>", bufopts)
  vim.keymap.set("n", "gH", "<cmd>lua vim.lsp.buf.signature_help()<CR>", bufopts)
  vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.rename()<CR>", bufopts)
  vim.keymap.set("n", "ga", "<cmd>lua vim.lsp.buf.code_action()<CR>", bufopts)
end

-- oil (navigation)
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
M.oil_hotkeys = {
  ["g?"]    = "actions.show_help",
  ["<CR>"]  = "actions.select",
  ["<C-v>"] = "actions.select_vsplit",
  ["<C-s>"] = "actions.select_split",
  ["<C-t>"] = "actions.select_tab",
  ["<C-p>"] = "actions.preview",
  ["<C-c>"] = "actions.close",
  ["<C-l>"] = "actions.refresh",
  ["-"]     = "actions.parent",
  ["`"]     = "actions.cd",
  ["~"]     = "actions.tcd",
  ["go"]    = "actions.open_cmdline",
  ["gy"]    = "actions.copy_entry_path",
  ["gs"]    = "actions.change_sort",
  ["gx"]    = "actions.open_external",
  ["g."]    = "actions.toggle_hidden",
  ["g\\"]   = "actions.toggle_trash",
}

-- multicursors
M.multicursors_hotkeys = {
  {"<Leader>c", "<Cmd>MultipleCursorsAddMatches<CR>", mode = {"n", "x"}, desc = "Add cursors to cword"}, -- "leader cursors"
  {"<C-k>", "<Cmd>MultipleCursorsAddUp<CR>", mode = {"n", "x"}, desc = "Add cursor and move up"},
  {"<C-j>", "<Cmd>MultipleCursorsAddDown<CR>", mode = {"n", "x"}, desc = "Add cursor and move down"},
  custom = {
        {"n", "<Leader>ca", function() require("multiple-cursors").align() end},
  }
}

-- telescope
M.telescope_hotkeys = function(builtin)
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
end

-- tabs
M.tab_hotkeys = function()
  vim.keymap.set("n", "<C-t>l", "<CMD>tabnext<CR>", { desc = "Next tab" })
  vim.keymap.set("n", "<C-t>h", "<CMD>tabprev<CR>", { desc = "Previous tab" })
  vim.keymap.set("n", "<C-t>n", "<CMD>tabnew<CR>", { desc = "New tab" })
  vim.keymap.set("n", "<C-t>x", "<CMD>tabclose<CR>", { desc = "Close tab" })
  vim.keymap.set("n", "<C-t>S-l", "<CMD>+tabmove<CR>", { desc = "Move tab to next" })
  vim.keymap.set("n", "<C-t>S-h", "<CMD>-tabmove<CR>", { desc = "Move tab to previous" })
end

-- completion (nvim-cmp) TODO: Uhhh what do
M.cmp_hotkeys = {
}

-- obsidian
M.obsidian_hotkeys = function()
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
end

-- render-markdown
M.rendermarkdown_hotkeys = function()
  vim.keymap.set('n', '<leader>me', '<CMD>RenderMarkdown enable<CR>', { desc = "Enable this plugin" })
  vim.keymap.set('n', '<leader>md', '<CMD>RenderMarkdown disable<CR>', { desc = "Disable this plugin" })
  vim.keymap.set('n', '<leader>mt', '<CMD>RenderMarkdown toggle<CR>', { desc = "Switch between enabling & disabling this plugin" })
  vim.keymap.set('n', '<leader>ml', '<CMD>RenderMarkdown log<CR>', { desc = "Opens the log file for this plugin" })
  vim.keymap.set('n', '<leader>me', '<CMD>RenderMarkdown expand<CR>', { desc = "Increase anti-conceal margin above and below by 1" })
  vim.keymap.set('n', '<leader>mc', '<CMD>RenderMarkdown contract<CR>', { desc = "Decrease anti-conceal margin above and below by 1" })
end

-- goyo
M.goyo_hotkeys = function()
  vim.keymap.set('n', '<leader>g', '<CMD>Goyo<CR>', { desc = "Toggle Goyo"})
end

-- codecompanion (ai)
M.codecompanion_hotkeys = function()
  vim.keymap.set("n", "<leader>aa", "<cmd>CodeCompanionActions<cr>", { desc = "AI actions" })
  vim.keymap.set("v", "<leader>aa", "<cmd>CodeCompanionActions<cr>", { desc = "AI actions" })
  vim.keymap.set("n", "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "AI chat" })
  vim.keymap.set("v", "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "AI chat" })
  vim.keymap.set("v", "<leader>ap", "<cmd>CodeCompanionChat Add<cr>", { desc = "AI push (add)" })

  -- Expand 'cc' into 'CodeCompanion' in the command line
  vim.cmd([[cab cc CodeCompanion]])
end

-- snippets
M.snippets_hotkeys = {
  is = {
    ['<leader>s'] = 'expand_or_advance',
    ['<leader>S'] = 'previous',
  },
  nx = {
    ['<leader>x'] = 'cut_text',
  },
}

-- remote (devcontainer)
M.remote_hotkeys = {
  { "<leader>rs", "<cmd>RemoteStart<cr>" },
  { "<leader>rS", "<cmd>RemoteStop<cr>" },
  { "<leader>ri", "<cmd>RemoteStop<cr>" },
}

return M
