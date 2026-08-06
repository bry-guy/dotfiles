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
end

return M
