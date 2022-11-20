require'nvim-treesitter.configs'.setup {
  ensure_installed = { "ruby", "python", "java", "vim", "go", "bash", "javascript", "typescript", "dockerfile", "lua", "html", "hcl", "json", "markdown", "yaml", },
  highlight = {
    enable = true,
	additional_vim_regex_highlighting = { "markdown" },
  }
}
