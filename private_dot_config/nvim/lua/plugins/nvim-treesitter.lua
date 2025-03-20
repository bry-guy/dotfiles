local M = {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  priority = 999,
  init = function()
    -- https://www.jmaguire.tech/posts/treesitter_folding/
    -- Configure folding via treesitter
    local opt = vim.opt
    opt.foldmethod = "expr"
    opt.foldexpr = "nvim_treesitter#foldexpr()"

    local augroup = vim.api.nvim_create_augroup
    local autocmd = vim.api.nvim_create_autocmd

    augroup('open_folds', { clear = true })

    autocmd('BufReadPost', {
      group = 'open_folds',
      pattern = '*',
      command = "normal zR"
    })

    autocmd('FileReadPost', {
      group = 'open_folds',
      pattern = '*',
      command = "normal zR"
    })
  end,
  config = function()
    require 'nvim-treesitter.configs'.setup {
      ensure_installed = {
        "ruby",
        "python",
        "java",
        "vim",
        "go",
        "bash",
        "javascript",
        "typescript",
        "dockerfile",
        "lua",
        "html",
        "hcl",
        "json",
        "markdown",
        "yaml",
        "c",
        "vimdoc"
      },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { "markdown" },
      }
    }
    vim.cmd("TSUpdate")
  end
}

return M
