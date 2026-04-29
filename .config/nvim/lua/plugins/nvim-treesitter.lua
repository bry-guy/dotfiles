local M = {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  priority = 999,
  build = ":TSUpdate",
  config = function()
    require('nvim-treesitter').install({
      "ruby",
      "python",
      "java",
      "vim",
      "go",
      "bash",
      "javascript",
      "typescript",
      "tsx",
      "dockerfile",
      "lua",
      "html",
      "hcl",
      "json",
      "markdown",
      "markdown_inline",
      "yaml",
      "c",
      "vimdoc",
      "scala"
    })
  end,
  init = function()
    local active_ft = {
      "ruby",
      "python",
      "java",
      "vim",
      "go",
      "bash",
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
      "dockerfile",
      "lua",
      "html",
      "hcl",
      "json",
      "markdown",
      "yaml",
      "c",
      "vimdoc",
      "scala"
    }

    vim.api.nvim_create_autocmd('FileType', {
      pattern = active_ft,
      callback = function(args)
        local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype) or vim.bo[args.buf].filetype

        vim.treesitter.start(args.buf, lang)

        -- vim.wo.foldmethod = 'expr'
        -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

        -- vim.cmd("normal! zR")
      end,
    })
  end,
}

return M
