local M = {
  "junegunn/goyo.vim",
  keys = require("config.keymaps").goyo_hotkeys,
  init = function()
    vim.g['goyo_width'] = 120
  end,
  config = function()
    local function set_markdown_zen_wrap(enabled)
      if vim.bo.filetype ~= "markdown" then
        return
      end

      if enabled then
        vim.w.goyo_markdown_wrap_previous = {
          wrap = vim.wo.wrap,
          linebreak = vim.wo.linebreak,
          breakindent = vim.wo.breakindent,
        }
        vim.wo.wrap = true
        vim.wo.linebreak = true
        vim.wo.breakindent = true
      else
        local previous = vim.w.goyo_markdown_wrap_previous
        if previous then
          vim.wo.wrap = previous.wrap
          vim.wo.linebreak = previous.linebreak
          vim.wo.breakindent = previous.breakindent
          vim.w.goyo_markdown_wrap_previous = nil
        end
      end
    end

    vim.api.nvim_create_autocmd("User", {
      pattern = "GoyoEnter",
      callback = function()
        require("lualine").hide()
        set_markdown_zen_wrap(true)
      end,
    })
    vim.api.nvim_create_autocmd("User", {
      pattern = "GoyoLeave",
      callback = function()
        require("lualine").hide({ unhide = true })
        set_markdown_zen_wrap(false)
      end,
    })
  end,
}

return M

