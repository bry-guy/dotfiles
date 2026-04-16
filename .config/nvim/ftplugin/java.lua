-- ftplugin/java.lua
vim.opt_local.shiftwidth = 4
vim.opt_local.tabstop = 4
vim.opt_local.softtabstop = 4
vim.opt_local.expandtab = true
vim.opt_local.autoindent = true
vim.opt_local.smartindent = true
vim.opt_local.commentstring = "//%s"

local uv = vim.uv or vim.loop

local function trim(s)
  return (s or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function system(cmd)
  return trim(vim.fn.system(cmd))
end

local root_markers = {
  ".git",
  "gradlew",
  "mvnw",
  "build.sbt",
  "project.scala",
  "settings.gradle",
  "mise.local.toml",
  ".mise.toml",
  "mise.toml",
}

local root_dir = vim.fs.root(0, root_markers)
if not root_dir then
  vim.notify('Could not determine Java project root', vim.log.levels.ERROR)
  return
end

local function executable_path(cmd, dir)
  local path = nil

  if dir and vim.fn.executable('mise') == 1 then
    path = system(("mise x -C %s -- which %s"):format(vim.fn.shellescape(dir), vim.fn.shellescape(cmd)))
  else
    path = vim.fn.exepath(cmd)
  end

  if path == nil or path == "" then
    return nil
  end

  return uv.fs_realpath(path) or path
end

local function parent_dir(path)
  return vim.fn.fnamemodify(path, ':h')
end

local function jdtls_home(dir)
  local jdtls_bin = executable_path('jdtls', dir)
  if not jdtls_bin then
    return nil
  end
  return parent_dir(parent_dir(jdtls_bin))
end

local function java_debug_jar(dir)
  local jar = nil

  if dir and vim.fn.executable('mise') == 1 then
    jar = system(("mise x -C %s -- java-debug --path"):format(vim.fn.shellescape(dir)))
  elseif vim.fn.executable('java-debug') == 1 then
    jar = system('java-debug --path')
  end

  if not jar or jar == '' or vim.fn.filereadable(jar) ~= 1 then
    return nil
  end

  return jar
end

-- Project workspace directory
local project_name = vim.fn.fnamemodify(root_dir, ':t')
local workspace_dir = vim.fn.expand('~/dev/workspaces/') .. project_name

local jdtls_path = jdtls_home(root_dir)
if not jdtls_path or vim.fn.isdirectory(jdtls_path) ~= 1 then
  vim.notify('jdtls not found via mise for ' .. root_dir, vim.log.levels.ERROR)
  return
end

-- Find the Equinox launcher jar
local launcher_jar = ''
local find_launcher = "find " .. vim.fn.shellescape(jdtls_path .. "/plugins") .. " -name 'org.eclipse.equinox.launcher_*.jar' | sort | tail -n 1"
launcher_jar = system(find_launcher)

if launcher_jar == '' or vim.fn.filereadable(launcher_jar) ~= 1 then
  vim.notify('Could not find JDTLS Equinox launcher jar under ' .. jdtls_path, vim.log.levels.ERROR)
  return
end

-- Determine OS for configuration directory
local config_dir = ''
local os_name = system('uname -s')
if os_name == "Darwin" then
  local is_arm = system('uname -m') == "arm64"
  if is_arm then
    config_dir = jdtls_path .. "/config_mac_arm"
  else
    config_dir = jdtls_path .. "/config_mac"
  end
elseif os_name == "Linux" then
  local is_arm = system('uname -m'):match("arm")
  if is_arm then
    config_dir = jdtls_path .. "/config_linux_arm"
  else
    config_dir = jdtls_path .. "/config_linux"
  end
else
  config_dir = jdtls_path .. "/config_win"
end

if vim.fn.isdirectory(config_dir) ~= 1 then
  vim.notify('Could not find JDTLS config dir: ' .. config_dir, vim.log.levels.ERROR)
  return
end

-- Find java-debug.jar
local bundles = {}
local debug_jar = java_debug_jar(root_dir)
if debug_jar then
  table.insert(bundles, debug_jar)
end

local keymaps = require("config.keymaps")
local lsp_hotkeys = keymaps.lsp_hotkeys

local config = {
  cmd = {
    'mise', 'x', '-C', root_dir, '--',
    'java',
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xmx2g',
    '-Xms1g',
    '-XX:+UseG1GC',
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
    '-jar', launcher_jar,
    '-configuration', config_dir,
    '-data', workspace_dir
  },
  -- One dedicated LSP server & client will be started per unique root_dir
  root_dir = root_dir,

  -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
  settings = {
    java = {
      configuration = {
        updateBuildConfiguration = "automatic",
      },
    }
  },
  init_options = {
    bundles = bundles
  },
  on_attach = function(_,_)
    keymaps.apply(lsp_hotkeys)
  end,
}
require('jdtls').start_or_attach(config)
