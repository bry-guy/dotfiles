local M = {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  config = function()
    local home = os.getenv("HOME")
    local workspace_folder = vim.fs.joinpath(home, "dev", "workspaces")
    local keymaps = require("config.keymaps").copilot_hotkeys
    require("copilot").setup({
      copilot_model = "gpt-41-copilot",
      panel = {
        enabled = false,
        auto_refresh = false,
        keymap = keymaps.panel,
        layout = {
          position = "bottom", -- | top | left | right | bottom |
          ratio = 0.4
        },
      },
      suggestion = {
        enabled = true,
        auto_trigger = false,
        hide_during_completion = true,
        debounce = 75,
        trigger_on_accept = true,
        keymap = keymaps.suggestion,
      },
      filetypes = {
        yaml = false,
        markdown = false,
        help = false,
        gitcommit = false,
        gitrebase = false,
        hgcommit = false,
        svn = false,
        cvs = false,
        ["."] = false,
      },
      workspace_folders = {
        workspace_folder
      },
    })
  end,
--   "github/copilot.vim",
--   cmd = "Copilot",
--   event = "InsertEnter",
  -- init = function()
  --   vim.g.copilot_settings = { selectedCompletionModel = 'gpt-4o-copilot' }
  --   vim.g.copilot_integration_id = "vscode-chat"
  --   vim.g.copilot_filetypes = {
  --       go = true,
  --       python = true,
  --       java = true,
  --       javascript = true,
  --       typescript = true,
  --       ["*"] = false, -- disable for all other filetypes and ignore default `filetypes`
  --   }
  --   vim.g.copilot_no_tab_map = 1
  --   vim.keymap.set('i', '<M-CR>', 'copilot#Accept("<CR>")', {
  --     expr = true,
  --     silent = true,
  --     replace_keycodes = false,
  --     desc = 'Accept Copilot suggestion',
  --   })
  -- end
}


return M
