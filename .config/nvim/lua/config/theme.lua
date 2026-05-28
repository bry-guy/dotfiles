local M = {}

local sunfly_variants = {
  paper = true,
  bright = true,
}

local function normalize_sunfly_variant(variant)
  if variant == nil or variant == "" then
    return "paper"
  end

  variant = tostring(variant):lower()
  variant = variant:gsub("^sunfly%-", "")

  if not sunfly_variants[variant] then
    return "paper"
  end

  return variant
end

function M.sunfly_variant()
  return normalize_sunfly_variant(vim.g.dotfiles_sunfly_variant or vim.env.DOTFILES_SUNFLY_VARIANT)
end

local function sunfly_theme()
  return "sunfly-" .. M.sunfly_variant()
end

local function is_sunfly_theme(theme)
  return theme == "sunfly" or theme:match("^sunfly%-") ~= nil
end

local function normalize_theme(theme)
  if theme == nil or theme == "" then
    return nil
  end

  theme = tostring(theme):lower()
  if theme == "paper" or theme == "bright" then
    return "sunfly-" .. normalize_sunfly_variant(theme)
  end

  if theme == "sunfly" then
    return sunfly_theme()
  end

  return theme
end

local function explicit_theme()
  return normalize_theme(vim.g.dotfiles_theme or vim.env.DOTFILES_NVIM_THEME)
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
    return sunfly_theme()
  end

  return "moonfly"
end

function M.is(name)
  return M.current() == normalize_theme(name)
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

  if is_sunfly_theme(theme) then
    local ok = pcall(vim.cmd, "colorscheme " .. theme)
    if ok then
      M._active_theme = theme
    else
      vim.cmd("colorscheme sunfly")
      M._active_theme = "sunfly"
    end
  else
    vim.cmd("colorscheme moonfly")
    M._active_theme = "moonfly"
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
  local theme = M._active_theme or M.current()
  if is_sunfly_theme(theme) then
    if theme ~= "sunfly" then
      local lualine_theme_path = "lua/lualine/themes/" .. theme .. ".lua"
      if vim.fn.globpath(vim.o.runtimepath, lualine_theme_path) == "" then
        return "sunfly"
      end
    end

    return theme
  end

  return "moonfly"
end

return M
