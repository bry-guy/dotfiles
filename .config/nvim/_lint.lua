require('lint').linters_by_ft = {
  ['yaml.actions'] = {'actionlint'},
  yaml = {'yamllint'},
  -- markdown = {'vale'},
  -- java = {'checkstyle'},
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


-- markdown
-- local function get_cur_file_extension(bufnr)
--   bufnr = bufnr or 0
--   return "." .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':e')
-- end

-- require('lint.linters.vale').args = {
--     '--no-exit',
--     '--output', 'JSON',
--     '--ext', get_cur_file_extension,
--     -- '--config', '/home/leesoh/.config/vale/vale.ini'
-- }
