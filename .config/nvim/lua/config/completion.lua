local M = {}

local prose_filetypes = {
  asciidoc = true,
  gitcommit = true,
  mail = true,
  markdown = true,
  rst = true,
  text = true,
}

local function is_dap_buffer()
  local ok, cmp_dap = pcall(require, "cmp_dap")
  return ok and cmp_dap.is_dap_buffer()
end

local function current_filetype(bufnr)
  local filetype = vim.bo[bufnr].filetype
  if filetype:match("^markdown%.") then
    return "markdown"
  end
  return filetype
end

function M.enabled(bufnr)
  bufnr = bufnr or 0

  local override = vim.b[bufnr].dotfiles_completion_enabled
  if override ~= nil then
    return override
  end

  local buftype = vim.api.nvim_get_option_value("buftype", { buf = bufnr })
  if buftype == "prompt" then
    return is_dap_buffer()
  end

  return not prose_filetypes[current_filetype(bufnr)]
end

local function cmp_refresh()
  local ok, cmp = pcall(require, "cmp")
  if not ok then
    return
  end

  cmp.close()
end

local function notify_status(prefix, bufnr)
  bufnr = bufnr or 0

  local status = M.enabled(bufnr) and "enabled" or "disabled"
  local scope = vim.b[bufnr].dotfiles_completion_enabled == nil and "auto" or "buffer"
  local filetype = current_filetype(bufnr)
  if filetype == "" then
    filetype = "no filetype"
  end

  vim.notify(string.format("%s: completion %s (%s, %s)", prefix, status, scope, filetype), vim.log.levels.INFO, {
    title = "Completion",
  })
end

function M.enable(bufnr)
  bufnr = bufnr or 0
  vim.b[bufnr].dotfiles_completion_enabled = true
  cmp_refresh()
  notify_status("Set", bufnr)
end

function M.disable(bufnr)
  bufnr = bufnr or 0
  vim.b[bufnr].dotfiles_completion_enabled = false
  cmp_refresh()
  notify_status("Set", bufnr)
end

function M.toggle(bufnr)
  bufnr = bufnr or 0
  vim.b[bufnr].dotfiles_completion_enabled = not M.enabled(bufnr)
  cmp_refresh()
  notify_status("Toggled", bufnr)
end

function M.reset(bufnr)
  bufnr = bufnr or 0
  vim.b[bufnr].dotfiles_completion_enabled = nil
  cmp_refresh()
  notify_status("Reset", bufnr)
end

function M.setup()
  if M._setup_done then
    return
  end

  M._setup_done = true

  vim.api.nvim_create_user_command("CompletionEnable", function()
    M.enable(0)
  end, { desc = "Enable completion in the current buffer" })

  vim.api.nvim_create_user_command("CompletionDisable", function()
    M.disable(0)
  end, { desc = "Disable completion in the current buffer" })

  vim.api.nvim_create_user_command("CompletionToggle", function()
    M.toggle(0)
  end, { desc = "Toggle completion in the current buffer" })

  vim.api.nvim_create_user_command("CompletionAuto", function()
    M.reset(0)
  end, { desc = "Reset completion to automatic per-filetype behavior" })
end

return M
