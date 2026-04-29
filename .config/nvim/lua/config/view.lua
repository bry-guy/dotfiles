local M = {}

local function notify(message)
  vim.notify(message, vim.log.levels.INFO, { title = "View" })
end

function M.toggle_wrap()
  vim.wo.wrap = not vim.wo.wrap
  vim.wo.linebreak = vim.wo.wrap
  notify(string.format("wrap %s", vim.wo.wrap and "enabled" or "disabled"))
end

function M.toggle_diagnostics_virtual_text()
  local config = vim.diagnostic.config()
  local enabled = config.virtual_text ~= false
  vim.diagnostic.config({ virtual_text = not enabled })
  notify(string.format("diagnostic virtual text %s", (not enabled) and "enabled" or "disabled"))
end

local function inlay_hints_enabled(bufnr)
  if vim.lsp.inlay_hint == nil then
    return false
  end

  if type(vim.lsp.inlay_hint.is_enabled) == "function" then
    local ok, enabled = pcall(vim.lsp.inlay_hint.is_enabled, { bufnr = bufnr })
    if ok then
      return enabled
    end

    ok, enabled = pcall(vim.lsp.inlay_hint.is_enabled, bufnr)
    if ok then
      return enabled
    end
  end

  return false
end

function M.toggle_inlay_hints(bufnr)
  bufnr = bufnr or 0

  if vim.lsp.inlay_hint == nil or type(vim.lsp.inlay_hint.enable) ~= "function" then
    notify("inlay hints are not supported in this Neovim build")
    return
  end

  local enabled = inlay_hints_enabled(bufnr)
  local ok = pcall(vim.lsp.inlay_hint.enable, not enabled, { bufnr = bufnr })
  if not ok then
    pcall(vim.lsp.inlay_hint.enable, bufnr, not enabled)
  end

  notify(string.format("inlay hints %s", (not enabled) and "enabled" or "disabled"))
end

local function markview_buffer_enabled(bufnr)
  local ok, state = pcall(require, "markview.state")
  if not ok then
    return false
  end

  local buf_state = state.get_buffer_state(bufnr, false)
  return buf_state ~= nil and buf_state.enable == true
end

local function markview_set_enabled(bufnr, enabled)
  local ok, commands = pcall(require, "markview.commands")
  if not ok then
    return
  end

  pcall(commands.attach, bufnr)
  pcall(enabled and commands.enable or commands.disable, bufnr)
end

function M.toggle_markdown_read_mode()
  local bufnr = vim.api.nvim_get_current_buf()

  if vim.bo[bufnr].filetype ~= "markdown" then
    notify("markdown read mode is only available in Markdown buffers")
    return
  end

  if vim.w.markdown_read_mode then
    local previous = vim.w.markdown_read_mode_previous or {}

    if previous.markview_enabled ~= nil then
      markview_set_enabled(bufnr, previous.markview_enabled)
    end

    vim.wo.wrap = previous.wrap or false
    vim.wo.linebreak = previous.linebreak or false
    vim.wo.breakindent = previous.breakindent or false
    vim.wo.conceallevel = previous.conceallevel or 0
    vim.wo.concealcursor = previous.concealcursor or ""

    vim.w.markdown_read_mode = false
    vim.w.markdown_read_mode_previous = nil
    notify("markdown read mode disabled")
    return
  end

  vim.w.markdown_read_mode_previous = {
    wrap = vim.wo.wrap,
    linebreak = vim.wo.linebreak,
    breakindent = vim.wo.breakindent,
    conceallevel = vim.wo.conceallevel,
    concealcursor = vim.wo.concealcursor,
    markview_enabled = markview_buffer_enabled(bufnr),
  }

  vim.wo.wrap = true
  vim.wo.linebreak = true
  vim.wo.breakindent = true
  vim.wo.conceallevel = 2
  vim.wo.concealcursor = "nc"
  markview_set_enabled(bufnr, true)

  vim.w.markdown_read_mode = true
  notify("markdown read mode enabled")
end

function M.setup()
  if M._setup_done then
    return
  end

  M._setup_done = true

  vim.api.nvim_create_user_command("ViewWrapToggle", function()
    M.toggle_wrap()
  end, { desc = "Toggle line wrapping in the current window" })

  vim.api.nvim_create_user_command("ViewDiagnosticsToggle", function()
    M.toggle_diagnostics_virtual_text()
  end, { desc = "Toggle diagnostic virtual text" })

  vim.api.nvim_create_user_command("ViewInlayHintsToggle", function()
    M.toggle_inlay_hints(0)
  end, { desc = "Toggle LSP inlay hints" })

  vim.api.nvim_create_user_command("MarkdownReadModeToggle", function()
    M.toggle_markdown_read_mode()
  end, { desc = "Toggle Markdown reading mode in the current window" })
end

return M
