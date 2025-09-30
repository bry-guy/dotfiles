-- ftplugin/java.lua
vim.opt_local.shiftwidth = 4
vim.opt_local.tabstop = 4
vim.opt_local.softtabstop = 4
vim.opt_local.expandtab = true
vim.opt_local.autoindent = true
vim.opt_local.smartindent = true
vim.opt_local.foldmethod = "indent"
vim.opt_local.foldlevelstart = 99
vim.opt_local.commentstring = "//%s"

-- Project workspace directory
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local workspace_dir = vim.fn.expand('~/dev/workspaces/') .. project_name

-- Dynamically find JDTLS and java-debug paths using mise
local jdtls_path = vim.fn.trim(vim.fn.system('mise where jdtls'))
local java_debug_path = vim.fn.trim(vim.fn.system('mise where java-debug'))

-- Find the Equinox launcher jar
local launcher_jar = ''
if vim.fn.isdirectory(jdtls_path) == 1 then
  local find_launcher = "find " .. jdtls_path .. "/plugins -name 'org.eclipse.equinox.launcher_*.jar' | sort | tail -n 1"
  launcher_jar = vim.fn.trim(vim.fn.system(find_launcher))
end

-- Determine OS for configuration directory
local config_dir = ''
local os_name = vim.fn.system('uname -s'):gsub('\n', '')
if os_name == "Darwin" then
  local is_arm = vim.fn.system('uname -m'):gsub('\n', '') == "arm64"
  if is_arm then
    config_dir = jdtls_path .. "/config_mac_arm"
  else
    config_dir = jdtls_path .. "/config_mac"
  end
elseif os_name == "Linux" then
  local is_arm = vim.fn.system('uname -m'):match("arm")
  if is_arm then
    config_dir = jdtls_path .. "/config_linux_arm"
  else
    config_dir = jdtls_path .. "/config_linux"
  end
else
  config_dir = jdtls_path .. "/config_win"
end

-- Find java-debug.jar
local bundles = {}
if vim.fn.filereadable(java_debug_path .. "/java-debug.jar") == 1 then
  table.insert(bundles, java_debug_path .. "/java-debug.jar")
end

local keymaps = require("config.keymaps")
local lsp_hotkeys = keymaps.lsp_hotkeys

local config = {
  cmd = {
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
  root_dir = vim.fs.root(0, {".git", "mvnw", "gradlew"}),

  -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
  settings = {
    java = {
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
