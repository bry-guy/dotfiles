local M = {
  "junegunn/goyo.vim",
  keys = require("config.keymaps").goyo_hotkeys,
  init = function()
    vim.g['goyo_width'] = 120
  end,
  config = function()
    local function cursor_in_pipe_table(row)
      local ok, node = pcall(vim.treesitter.get_node, {
        buf = vim.api.nvim_get_current_buf(),
        pos = { row - 1, 0 },
      })

      while ok and node do
        if node:type():match("^pipe_table") then
          return true
        end
        node = node:parent()
      end

      return false
    end

    local function pipe_table_visible()
      if vim.bo.filetype ~= "markdown" then
        return false
      end

      local first = vim.fn.line("w0")
      local last = vim.fn.line("w$")
      for row = first, last do
        if cursor_in_pipe_table(row) then
          return true
        end
      end

      return false
    end

    local function update_markdown_table_wrap()
      if not vim.w.goyo_markdown_wrap_previous then
        return
      end

      if pipe_table_visible() then
        if not vim.w.goyo_markdown_table_wrap_disabled then
          vim.w.goyo_markdown_wrap_before_table = vim.wo.wrap
          vim.wo.wrap = false
          vim.w.goyo_markdown_table_wrap_disabled = true
        end
      elseif vim.w.goyo_markdown_table_wrap_disabled then
        vim.wo.wrap = vim.w.goyo_markdown_wrap_before_table
        vim.w.goyo_markdown_wrap_before_table = nil
        vim.w.goyo_markdown_table_wrap_disabled = false
      end
    end

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
        update_markdown_table_wrap()
      else
        local previous = vim.w.goyo_markdown_wrap_previous
        if previous then
          vim.wo.wrap = previous.wrap
          vim.wo.linebreak = previous.linebreak
          vim.wo.breakindent = previous.breakindent
          vim.w.goyo_markdown_wrap_previous = nil
        end
        vim.w.goyo_markdown_wrap_before_table = nil
        vim.w.goyo_markdown_table_wrap_disabled = false
      end
    end

    local wrap_group = vim.api.nvim_create_augroup("GoyoMarkdownWrap", { clear = true })
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "WinScrolled" }, {
      group = wrap_group,
      callback = update_markdown_table_wrap,
    })

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

