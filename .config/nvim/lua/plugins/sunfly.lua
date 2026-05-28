local function apply_sunfly_gutter_overrides()
  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  local line_nr = vim.api.nvim_get_hl(0, { name = "LineNr", link = false })
  local cursor_line = vim.api.nvim_get_hl(0, { name = "CursorLine", link = false })

  if normal.bg == nil then
    return
  end

  vim.api.nvim_set_hl(0, "SignColumn", { bg = normal.bg, fg = line_nr.fg })
  vim.api.nvim_set_hl(0, "FoldColumn", { bg = normal.bg, fg = line_nr.fg })

  if cursor_line.bg ~= nil then
    vim.api.nvim_set_hl(0, "CursorLineSign", { bg = cursor_line.bg })
  end
end

local sunfly_plugin_dir = vim.env.SUNFLY_PLUGIN_DIR
if sunfly_plugin_dir == "" then
  sunfly_plugin_dir = nil
end

local M = {
  "bry-guy/sunfly",
  name = "sunfly",
  dir = sunfly_plugin_dir,
  branch = sunfly_plugin_dir and nil or "main",
  lazy = false,
  priority = 1001,
  -- Sunfly currently reuses Moonfly's implementation and palette plumbing under the hood.
  -- Keep Moonfly installed as an explicit dependency until Sunfly becomes fully standalone.
  dependencies = {
    { "bluz71/vim-moonfly-colors", name = "moonfly" },
  },
  init = function()
    local group = vim.api.nvim_create_augroup("SunflyThemeOverrides", { clear = true })
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = group,
      pattern = "sunfly*",
      callback = apply_sunfly_gutter_overrides,
    })
  end,
}

return M
