local M = {
  "github/copilot.vim",
  cmd = "Copilot",
  event = "InsertEnter",
  init = function()
    vim.g.copilot_settings = { selectedCompletionModel = 'claude-3.7-sonnet' }
    vim.g.copilot_filetypes = {
        go = true,
        python = true,
        ["*"] = false, -- disable for all other filetypes and ignore default `filetypes`
    }
    vim.g.copilot_suggestion = {
        auto_trigger = true,
        keymap = {
          accept = "<M-CR>",
          prev = "<M-[>",
          next = "<M-]>",
          dismiss = "<M-x>",
        },
    }
  end
}


return M
