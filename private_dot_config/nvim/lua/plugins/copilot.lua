local M = {
  "github/copilot.vim",
  cmd = "Copilot",
  event = "InsertEnter",
  init = function()
    vim.g.copilot_settings = { selectedCompletionModel = 'gpt-4o-copilot' }
    vim.g.copilot_integration_id = "vscode-chat"
    vim.g.copilot_filetypes = {
        go = true,
        python = true,
        java = true,
        javascript = true,
        typescript = true,
        ["*"] = false, -- disable for all other filetypes and ignore default `filetypes`
    }
    vim.g.copilot.no_tab_map = 1
    vim.keymap.set('i', '<M-CR>', 'copilot#Accept("<CR>")', {
      expr = true,
      silent = true,
      replace_keycodes = false,
      desc = 'Accept Copilot suggestion',
    })
  end
}


return M
