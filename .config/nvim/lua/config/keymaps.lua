local M = {}


-- TODO: Export and invoke the vim.keymaps below
-- overwrites
vim.keymap.set('v', 'Y', '"+y', { desc = "Yank selection (Clipboard)" })

-- diagnostics
vim.keymap.set('n', ']d', function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Diagnostic Next" })
vim.keymap.set('n', '[d', function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Diagnostic Prev" })

-- dap
M.dap_hotkeys = {
  { "<leader>dh", "<cmd>lua require'dap.ui.widgets'.hover()<CR>", desc = "DAP Hover" },
  { "<leader>dx", "<cmd>lua require'dap'.continue()<CR>", desc = "DAP Continue" },
  { "<leader>ds", "<cmd>lua require'dap'.step_over()<CR>", desc = "DAP Step Over" },
  { "<leader>di", "<cmd>lua require'dap'.step_into()<CR>", desc = "DAP Step Into" },
  { "<leader>do", "<cmd>lua require'dap'.step_out()<CR>", desc = "DAP Step Out" },
  { "<leader>db", "<cmd>lua require'dap'.toggle_breakpoint()<CR>", desc = "DAP Toggle Breakpoint" },
  { "<leader>dB", "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>", desc = "DAP Conditional Breakpoint" },
  { "<leader>dp", "<cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>", desc = "DAP Log Point" },
  { "<leader>dr", "<cmd>lua require'dap'.repl.open({},'tabnew')<CR>", desc = "DAP Open REPL" },
  { "<leader>dR", "<cmd>lua require'dap'.repl.close()<CR>", desc = "DAP Close REPL" },
  { "<leader>dl", "<cmd>lua require'dap'.run_last()<CR>", desc = "DAP Run Last" },
  --- telescope dap
  { "<leader>dc", "<cmd>lua require'telescope'.extensions.dap.commands{}<CR>", desc = "Tele DAP Commands" },
  { "<leader>dg", "<cmd>lua require'telescope'.extensions.dap.configurations{}<CR>", desc = "Tele DAP Configs" },
  { "<leader>dk", "<cmd>lua require'telescope'.extensions.dap.list_breakpoints{}<CR>", desc = "Tele DAP Breakpoints" },
  { "<leader>dv", "<cmd>lua require'telescope'.extensions.dap.variables{}<CR>", desc = "Tele DAP Variables" },
  { "<leader>df", "<cmd>lua require'telescope'.extensions.dap.frames{}<CR>", desc = "Tele DAP Frames" },
}



-- lsp
M.lsp_hotkeys = {
  { "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", { desc = "LSP Definition" } },
  { "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", { desc = "LSP Declaration" } },
  { "gt", "<cmd>lua vim.lsp.buf.type_definition()<CR>", { desc = "LSP Type Definition" } },
  { "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", { desc = "LSP Implementation" } },
  { "gr", "<cmd>lua vim.lsp.buf.references()<CR>", { desc = "LSP References" } },
  { "gh", function() vim.lsp.buf.hover({ border = "single" }) end, { desc = "LSP Hover" } },
  { "gH", function() vim.lsp.buf.signature_help({ border = "single" }) end, { desc = "LSP Signature Help" } },
  { "gR", "<cmd>lua vim.lsp.buf.rename()<CR>", { desc = "LSP Rename" } },
  { "gA", "<cmd>lua vim.lsp.buf.code_action()<CR>", { desc = "LSP Code Action" } },
}

-- test
M.test_hotkeys = {
  { "<leader>tn", "<cmd>lua require('neotest').run.run()<CR>", desc = "Test Run Nearest" },
  { "<leader>tl", "<cmd>lua require('neotest').run.run_last()<CR>", desc = "Test Run Last" },
  { "<leader>tf", "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<CR>", desc = "Test Run File" },
  { "<leader>td", "<cmd>lua require('neotest').run.run({strategy = 'dap'})<CR>", desc = "Test Debug Nearest" },
  { "<leader>tp", "<cmd>lua require('neotest').output_panel.open()<CR>:tabnext<CR>", desc = "Test Output Panel" },
  { "<leader>tP", "<cmd>lua require('neotest').output_panel.close()<CR>", desc = "Test Close Panel" },
  { "<leader>tc", "<cmd>lua require('neotest').output_panel.clear()<CR>", desc = "Test Clear Panel" },
  { "<leader>to", "<cmd>lua require('neotest').output.open({ short = true, enter = true, auto_close = true })<CR>", desc = "Test Show Output" },
}

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
  { "<Leader>c", "<Cmd>MultipleCursorsAddMatches<CR>", mode = { "n", "x" }, desc = "Multicursors add cursors to cword" }, -- "leader cursors"
  { "<C-k>",     "<Cmd>MultipleCursorsAddUp<CR>",      mode = { "n", "x" }, desc = "Multicursors add cursor and move up" },
  { "<C-j>",     "<Cmd>MultipleCursorsAddDown<CR>",    mode = { "n", "x" }, desc = "Multicursors add cursor and move down" },
  custom = {
    { "n", "<Leader>ca", function() require("multiple-cursors").align() end, { desc = "Multicursors align" } },
  }
}

-- telescope
M.telescope_hotkeys = {
  { "<leader>fF", "<cmd>lua require('telescope.builtin').find_files()<CR>", { desc = "Tele Find All Files" } },
  { "<leader>ff", "<cmd>lua require('telescope.builtin').git_files()<CR>", { desc = "Tele Git Files" } },
  { "<leader>fg", "<cmd>lua require('telescope.builtin').live_grep()<CR>", { desc = "Tele Live Grep" } },
  { "<leader>fw", "<cmd>lua require('telescope.builtin').grep_string()<CR>", { desc = "Tele Grep Word" } },
  { "<leader>fb", "<cmd>lua require('telescope.builtin').buffers()<CR>", { desc = "Tele Buffers" } },
  { "<leader>fh", "<cmd>lua require('telescope.builtin').help_tags()<CR>", { desc = "Tele Help Tags" } },
  { "<leader>fo", "<cmd>lua require('telescope.builtin').oldfiles()<CR>", { desc = "Tele Old Files" } },
  { "<leader>fc", "<cmd>lua require('telescope.builtin').commands()<CR>", { desc = "Tele Commands" } },
  { "<leader>fm", "<cmd>lua require('telescope.builtin').man_pages()<CR>", { desc = "Tele Man Pages" } },
  { "<leader>fl", "<cmd>lua require('telescope.builtin').lsp_references()<CR>", { desc = "Tele LSP References" } },
  { "<leader>ft", "<cmd>lua require('telescope.builtin').treesitter()<CR>", { desc = "Tele Treesitter Symbols" } },
  { "<leader>fl", "<cmd>lua require('telescope.builtin').registers()<CR>", { desc = "Tele Registers" } },
}

-- tabs
M.tab_hotkeys = {
  { "<C-t>l", "<CMD>tabnext<CR>", { desc = "Next tab" } },
  { "<C-t>h", "<CMD>tabprev<CR>", { desc = "Previous tab" } },
  { "<C-t>n", "<CMD>tabnew<CR>", { desc = "New tab" } },
  { "<C-t>x", "<CMD>tabclose<CR>", { desc = "Close tab" } },
  { "<C-t>S-l", "<CMD>+tabmove<CR>", { desc = "Move tab to next" } },
  { "<C-t>S-h", "<CMD>-tabmove<CR>", { desc = "Move tab to previous" } },
}

-- completion (nvim-cmp) TODO: Uhhh what do
M.cmp_hotkeys = {
}


M.obsidian_hotkeys = {
  { "<leader>wn", "<Cmd>ObsidianNew<CR>", { desc = "Wiki New Note" } },
  { "<leader>wf", "<Cmd>ObsidianQuickSwitch<CR>", { desc = "Wiki Quick Switch" } },
  { "<leader>ws", "<Cmd>ObsidianSearch<CR>", { desc = "Wiki Search" } },
  { "<leader>wt", "<Cmd>ObsidianToday<CR>", { desc = "Wiki Today" } },
  { "<leader>wb", "<Cmd>ObsidianBacklinks<CR>", { desc = "Wiki Backlinks" } },
  { "<leader>wl", "<Cmd>ObsidianLink<CR>", { desc = "Wiki Link" } },
  { "<leader>wL", "<Cmd>ObsidianLinkNew<CR>", { desc = "Wiki Link New" } },
  { "<leader>wg", "<Cmd>ObsidianFollowLink<CR>", { desc = "Wiki Follow Link" } },
}

-- render-markdown
M.rendermarkdown_hotkeys = {
  { "<leader>me", "<CMD>RenderMarkdown enable<CR>", { desc = "Enable this plugin" } },
  { "<leader>md", "<CMD>RenderMarkdown disable<CR>", { desc = "Disable this plugin" } },
  { "<leader>mt", "<CMD>RenderMarkdown toggle<CR>", { desc = "Switch between enabling & disabling this plugin" } },
  { "<leader>ml", "<CMD>RenderMarkdown log<CR>", { desc = "Opens the log file for this plugin" } },
  { "<leader>me", "<CMD>RenderMarkdown expand<CR>", { desc = "Increase anti-conceal margin above and below by 1" } },
  { "<leader>mc", "<CMD>RenderMarkdown contract<CR>", { desc = "Decrease anti-conceal margin above and below by 1" } },
}

-- goyo
  M.goyo_hotkeys = {
    { "<leader>G", "<CMD>Goyo<CR>", { desc = "Goyo Toggle" } },
  }

-- codecompanion (ai)
M.ai_hotkeys = {
  { "<leader>aa", "<cmd>CodeCompanionActions<cr>", desc = "AI Actions" },
  { "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", desc = "AI Chat Toggle" },
  { "<leader>ap", "<cmd>CodeCompanionChat Add<cr>", desc = "AI Chat Add" },
}

-- codecompanion diff (ai)
M.ai_diff_hotkeys = {
  { "<leader>ady", function() require("codecompanion").diff.accept() end, { desc = "AI Accept Diff" } },
  { "<leader>adn", function() require("codecompanion").diff.reject() end, { desc = "AI Reject Diff" } },
}

-- copilot hotkeys (ai)
M.copilot_hotkeys = {
  suggestion = {
    accept = "<leader>ay",
    accept_word = false,
    accept_line = false,
    next = "<leader>as",
    prev = false,
    dismiss = "<leader>aS",
  },
  panel = {
    jump_prev = "[[",
    jump_next = "]]",
    accept = "<CR>",
    refresh = "gr",
    open = false,
  }
}

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
  { "<leader>rs", "<cmd>RemoteStart<cr>", desc = "Remote Start" },
  { "<leader>rS", "<cmd>RemoteStop<cr>", desc = "Remote Stop" },
  { "<leader>ri", "<cmd>RemoteInfo<cr>", desc = "Remote Info" },
}

M.whichkey_hotkeys = {
  {
    "<leader>?",
    function()
      require("which-key").show({ global = false })
    end,
    desc = "Buffer Local Keymaps (which-key)",
  },
}

-- apply a table directly
function M.apply(mappings)
  for _, map in ipairs(mappings) do
    local lhs, rhs, opts = map[1], map[2], map[3] or {}
    local mode = opts.mode or "n"
    -- remove .mode from opts so vim.keymap.set won’t choke
    opts.mode = nil
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

return M
