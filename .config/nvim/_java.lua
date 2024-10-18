local M = {}

local on_attach = function(_, bufnr)
  require('jdtls').setup_dap({ hotcodereplace = 'auto' })
  require('jdtls.setup').add_commands()
  local opts = { noremap=true, silent=true }

  -- typical lsp mappings (see _lsp.lua)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)

  -- jdtls mappings
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>o', "<cmd>lua require'jdtls'.organize_imports()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>ev', "<cmd>lua require'jdtls'.extract_variable()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'v', '<space>ev', "<Esc><cmd>lua require'jdtls'.extract_variable(true)<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>ec', "<cmd>lua require'jdtls'.extract_constant()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'v', '<space>ec', "<Esc><cmd>lua require'jdtls'.extract_constant(true)<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'v', '<space>em', "<Esc><cmd>lua require'jdtls'.extract_method(true)<CR>", opts)

  vim.api.nvim_set_keymap('n', '<leader>dn', "<cmd>lua require('jdtls').test_nearest_method()<CR>", { noremap = true })
  vim.api.nvim_set_keymap('n', '<leader>dc', "<cmd>lua require('jdtls').test_class()<CR>", { noremap = true })
end

local capabilities = require('cmp_nvim_lsp').default_capabilities()

function M.handler()
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
    local workspace_dir = vim.env.HOME .. '/dev/workspaces/' .. project_name
    local mason_pkgs = vim.env.HOME .. '/.local/share/nvim/mason/packages'
    local java_installs = vim.env.HOME .. '/.asdf/installs/java'

	local bundles = {
	  vim.fn.glob(mason_pkgs .. "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar", 1),
	};

	vim.list_extend(bundles, vim.split(vim.fn.glob(mason_pkgs .. "/java-test/extension/server/*.jar", 1), "\n"))


    local config = {
        cmd = {
            'java',
			'-Declipse.application=org.eclipse.jdt.ls.core.id1',
			'-Dosgi.bundles.defaultStartLevel=4',
			'-Declipse.product=org.eclipse.jdt.ls.core.product',
			'-Dlog.protocol=true',
			'-Dlog.level=ALL',
			'-Xms1g',
			'-javaagent:' .. mason_pkgs .. '/jdtls/lombok.jar',
			'-jar', vim.fn.glob(mason_pkgs .. '/jdtls/plugins/org.eclipse.equinox.launcher_1.6.500.*.jar'),
			'-configuration', mason_pkgs .. '/jdtls/config_mac',
			'-data', workspace_dir,
			'--add-modules=ALL-SYSTEM',
			'--add-opens', 'java.base/java.util=ALL-UNNAMED',
			'--add-opens', 'java.base/java.lang=ALL-UNNAMED',
        },
        root_dir = require('jdtls.setup').find_root({'.git', 'mvnw', 'gradlew'}),
        capabilities = capabilities,
        on_attach = on_attach,
		init_options = {
		  bundles = bundles
		},
		settings = {
		  java = {
			configuration = {
			  runtimes = {
				{
				  name = "JavaSE-11",
				  path = vim.fn.glob(java_installs .. '/adoptopenjdk-11*'),
				},
				{
				  name = "JavaSE-17",
				  path = vim.fn.glob(java_installs .. '/adoptopenjdk-17*'),
				},
			  }
			}
		  }
		},
    }

    -- Finally, start or attach the jdtls server
    require('jdtls').start_or_attach(config)
end
