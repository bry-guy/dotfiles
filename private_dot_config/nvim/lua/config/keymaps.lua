local bufopts = { noremap = true, silent = true }
local M = {}

-- TODO: Export and invoke
-- diagnostics
vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', bufopts) -- "next diagnostic"
vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', bufopts)

-- dap
M.dap_hotkeys = {
  { "<leader>dh", "<cmd>lua require'dap.ui.widgets'.hover()<CR>" },
  { "<leader>dx", "<cmd>lua require'dap'.continue()<CR>" },
  { "<leader>ds", "<cmd>lua require'dap'.step_over()<CR>" },
  { "<leader>di", "<cmd>lua require'dap'.step_into()<CR>" },
  { "<leader>do", "<cmd>lua require'dap'.step_out()<CR>" },
  { "<leader>db", "<cmd>lua require'dap'.toggle_breakpoint()<CR>" },
  { "<leader>dB", "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>" },
  { "<leader>dp", "<cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>" },
  { "<leader>dr", "<cmd>lua require'dap'.repl.open({},'tabnew')<CR>" },
  { "<leader>dR", "<cmd>lua require'dap'.repl.close()<CR>" },
  { "<leader>dl", "<cmd>lua require'dap'.run_last()<CR>" },
  --- telescope dap
  { "<leader>dc", "<cmd>lua require'telescope'.extensions.dap.commands{}<CR>" },
  { "<leader>dg", "<cmd>lua require'telescope'.extensions.dap.configurations{}<CR>" },
  { "<leader>dk", "<cmd>lua require'telescope'.extensions.dap.list_breakpoints{}<CR>" },
  { "<leader>dv", "<cmd>lua require'telescope'.extensions.dap.variables{}<CR>" },
  { "<leader>df", "<cmd>lua require'telescope'.extensions.dap.frames{}<CR>" },
}



-- lsp
M.lsp_hotkeys = {
  { "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", bufopts },
  { "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", bufopts },
  { "gt", "<cmd>lua vim.lsp.buf.type_definition()<CR>", bufopts },
  { "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", bufopts },
  { "gr", "<cmd>lua vim.lsp.buf.references()<CR>", bufopts },
  { "gh", "<cmd>lua vim.lsp.buf.hover()<CR>", bufopts },
  { "gH", "<cmd>lua vim.lsp.buf.signature_help()<CR>", bufopts },
  { "gR", "<cmd>lua vim.lsp.buf.rename()<CR>", bufopts },
  { "gA", "<cmd>lua vim.lsp.buf.code_action()<CR>", bufopts },
}

-- test
M.test_hotkeys = {
  { "<leader>tn", "<cmd>lua require('neotest').run.run()<CR>" },
  { "<leader>tl", "<cmd>lua require('neotest').run.run_last()<CR>" },
  { "<leader>tf", "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<CR>" },
  { "<leader>td", "<cmd>lua require('neotest').run.run({strategy = 'dap'})<CR>" },
  { "<leader>tp", "<cmd>lua require('neotest').output_panel.open()<CR>:tabnext<CR>" },
  { "<leader>tP", "<cmd>lua require('neotest').output_panel.close()<CR>" },
  { "<leader>tc", "<cmd>lua require('neotest').output_panel.clear()<CR>" },
  { "<leader>to", "<cmd>lua require('neotest').output.open({ short = true, enter = true, auto_close = true })<CR>" },
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
  { "<Leader>c", "<Cmd>MultipleCursorsAddMatches<CR>", mode = { "n", "x" }, desc = "Add cursors to cword" }, -- "leader cursors"
  { "<C-k>",     "<Cmd>MultipleCursorsAddUp<CR>",      mode = { "n", "x" }, desc = "Add cursor and move up" },
  { "<C-j>",     "<Cmd>MultipleCursorsAddDown<CR>",    mode = { "n", "x" }, desc = "Add cursor and move down" },
  custom = {
    { "n", "<Leader>ca", function() require("multiple-cursors").align() end },
  }
}

-- telescope
M.telescope_hotkeys = {
  { "<leader>fF", "<cmd>lua require('telescope.builtin').find_files()<CR>", {} },
  { "<leader>ff", "<cmd>lua require('telescope.builtin').git_files()<CR>", {} },
  { "<leader>fg", "<cmd>lua require('telescope.builtin').live_grep()<CR>", {} },
  { "<leader>fw", "<cmd>lua require('telescope.builtin').grep_string()<CR>", {} },
  { "<leader>fb", "<cmd>lua require('telescope.builtin').buffers()<CR>", {} },
  { "<leader>fh", "<cmd>lua require('telescope.builtin').help_tags()<CR>", {} },
  { "<leader>fo", "<cmd>lua require('telescope.builtin').oldfiles()<CR>", {} },
  { "<leader>fm", "<cmd>lua require('telescope.builtin').commands()<CR>", {} },
  { "<leader>fn", "<cmd>lua require('telescope.builtin').man_pages()<CR>", {} },
  { "<leader>fr", "<cmd>lua require('telescope.builtin').lsp_references()<CR>", {} },
  { "<leader>ft", "<cmd>lua require('telescope.builtin').treesitter()<CR>", {} },
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
  { "<leader>wn", "<Cmd>ObsidianNew<CR>" },
  { "<leader>wf", "<Cmd>ObsidianQuickSwitch<CR>" },
  { "<leader>ws", "<Cmd>ObsidianSearch<CR>" },
  { "<leader>wt", "<Cmd>ObsidianToday<CR>" },
  { "<leader>wb", "<Cmd>ObsidianBacklinks<CR>" },
  { "<leader>wl", "<Cmd>ObsidianLink<CR>" },
  { "<leader>wL", "<Cmd>ObsidianLinkNew<CR>" },
  { "<leader>wg", "<Cmd>ObsidianFollowLink<CR>" },
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
    { "<leader>g", "<CMD>Goyo<CR>", { desc = "Toggle Goyo" } },
  }

-- codecompanion (ai)
M.ai_hotkeys = {
  { "<leader>aa", "<cmd>CodeCompanionActions<cr>"},
  { "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>"},
  { "<leader>ap", "<cmd>CodeCompanionChat Add<cr>"},
}

-- codecompanion diff (ai)
M.ai_diff_hotkeys = {
  { "<leader>ady",
    function() require("codecompanion").diff.accept() end,
    bufopts, desc = "Accept CodeCompanion diff" },
  { "<leader>adn",
    function() require("codecompanion").diff.reject() end,
    bufopts, desc = "Reject CodeCompanion diff" },
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
  { "<leader>rs", "<cmd>RemoteStart<cr>" },
  { "<leader>rS", "<cmd>RemoteStop<cr>" },
  { "<leader>ri", "<cmd>RemoteStop<cr>" },
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
