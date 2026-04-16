local M = {}

local function explicit_theme()
  local theme = vim.g.dotfiles_theme or vim.env.DOTFILES_NVIM_THEME
  if theme == nil or theme == "" then
    return nil
  end
  return theme
end

local function system_appearance()
  if vim.fn.has("mac") == 0 then
    return nil
  end

  local result = vim.fn.system({ "defaults", "read", "-g", "AppleInterfaceStyle" })
  if vim.v.shell_error == 0 and result:match("Dark") then
    return "dark"
  end

  return "light"
end

function M.current()
  local theme = explicit_theme()
  if theme then
    return theme
  end

  local appearance = system_appearance()
  if appearance == "light" then
    return "sunfly"
  end

  return "moonfly"
end

function M.is(name)
  return M.current() == name
end

local function sync_lualine()
  local ok, lualine = pcall(require, "lualine")
  if not ok then
    return
  end

  local ok_config, config = pcall(lualine.get_config)
  if not ok_config or type(config) ~= "table" then
    return
  end

  config.options = config.options or {}
  local theme = M.lualine_theme()
  if config.options.theme == theme then
    lualine.refresh()
    return
  end

  config.options.theme = theme
  lualine.setup(config)
end

local function reset_theme_modules()
  package.loaded["moonfly"] = nil
  package.loaded["sunfly"] = nil
end

local function sync_devicons()
  local ok, devicons = pcall(require, "nvim-web-devicons")
  if not ok or type(devicons.refresh) ~= "function" then
    return
  end

  devicons.refresh()
end

local function ensure_focus_sync()
  if M._focus_sync_initialized or explicit_theme() or vim.fn.has("mac") == 0 then
    return
  end

  M._focus_sync_initialized = true
  local group = vim.api.nvim_create_augroup("DotfilesThemeSync", { clear = true })
  vim.api.nvim_create_autocmd("FocusGained", {
    group = group,
    callback = function()
      M.apply()
    end,
  })
end

function M.apply()
  local theme = M.current()

  reset_theme_modules()

  if theme == "sunfly" then
    vim.cmd("colorscheme sunfly")
  else
    vim.cmd("colorscheme moonfly")
  end

  sync_devicons()
  sync_lualine()
  ensure_focus_sync()
end

function M.refresh()
  M.apply()
  vim.cmd("redraw!")
end

function M.setup()
  if M._setup_done then
    return
  end

  M._setup_done = true
  vim.api.nvim_create_user_command("ThemeRefresh", function()
    M.refresh()
  end, { desc = "Refresh the current Neovim theme" })
end

function M.lualine_theme()
  if M.is("sunfly") then
    return "sunfly"
  end

  return "moonfly"
end

return M
