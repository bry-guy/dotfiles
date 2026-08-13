local M = {}
local state_root = vim.env.XDG_STATE_HOME
if state_root == nil or state_root == "" then
  state_root = vim.fn.expand("~/.local/state")
end
local state_file = state_root .. "/dotfiles/theme-sync"

local function is_sunfly_theme(theme)
  return theme == "sunfly"
end

local function normalize_theme(theme)
  if theme == nil or theme == "" then
    return nil
  end

  return tostring(theme):lower()
end

local function explicit_theme()
  return normalize_theme(vim.g.dotfiles_theme or vim.env.DOTFILES_NVIM_THEME)
end

local function synced_theme()
  local file = io.open(state_file, "r")
  if not file then
    return nil
  end

  for line in file:lines() do
    local appearance = line:match("^appearance=(%a+)$")
    if appearance then
      file:close()
      return appearance == "light" and "sunfly" or "moonfly"
    end
  end

  file:close()
  return nil
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

  local theme = synced_theme()
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
  if M._focus_sync_initialized or explicit_theme() then
    return
  end

  M._focus_sync_initialized = true
  local group = vim.api.nvim_create_augroup("DotfilesThemeSync", { clear = true })
  vim.api.nvim_create_autocmd("FocusGained", {
    group = group,
    callback = function()
      if M.current() ~= M._active_theme then
        M.apply()
      end
    end,
  })
  if vim.uv and vim.uv.new_timer then
    local timer = vim.uv.new_timer()
    if timer then
      timer:start(1000, 2000, vim.schedule_wrap(function()
        if M.current() ~= M._active_theme then
          M.apply()
          vim.cmd("redraw!")
        end
      end))
      M._state_timer = timer
      vim.api.nvim_create_autocmd("VimLeavePre", {
        group = group,
        once = true,
        callback = function()
          timer:stop()
          timer:close()
        end,
      })
    end
  end
end

function M.apply()
  local theme = M.current()

  reset_theme_modules()

  if is_sunfly_theme(theme) then
    vim.cmd("colorscheme sunfly")
    M._active_theme = "sunfly"
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
    return "sunfly"
  end

  return "moonfly"
end

return M
