require('lint').linters_by_ft = {
  ['yaml.actions'] = {'actionlint'},
  yaml = {'yamllint'},
  markdown = {'vale'},
  java = {'checkstyle'},
  ansible = {'ansible_lint'},
  golang = {'golangcilint'},
  ruby = {'rubocop'},
  python = {'ruff'},
  typescript = {'eslint'},
  javascript = {'eslint'},
  bash = {'shellcheck'},
  zsh = {'shellcheck'},
  fish = {'shellcheck'},
  sh = {'shellcheck'},
  sql = {'sqlfluff'},
  lua = {'luacheck'},
  json = {'jsonlint'},
}

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function()
    require("lint").try_lint()
  end,
})
