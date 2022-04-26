local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local workspace_dir = vim.env.HOME .. '/dev/' .. project_name

local config = {
  cmd = {
    'java',
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xms1g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
    '-jar', vim.env.HOME .. '/.local/lib/jdt-language-server/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar',
    '-configuration', vim.env.HOME .. '/.local/lib/jdt-language-server/config_linux',
    '-data', workspace_dir
  },

  root_dir = require('jdtls.setup').find_root({'.git', 'mvnw', 'gradlew'}),
  capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities()),
  on_attach = {
		    require('jdtls').setup_dap({ hotcodereplace = 'auto' }),
			require('jdtls.setup').add_commands()
  },
}

local bundles = {
  vim.fn.glob("$HOME/.local/lib/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar"),
};

vim.list_extend(bundles, vim.split(vim.fn.glob("$HOME/.local/lib/vscode-java-test/server/*.jar"), "\n"))
config['init_options'] = {
  bundles = bundles;
}

require('jdtls').start_or_attach(config)
