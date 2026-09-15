-- The built-in Markdown ftplugin enables automatic text wrapping via `t`.
-- Keep hard newlines manual; visual wrapping is handled by the window instead.
vim.opt_local.formatoptions:remove({ "t" })

if vim.api.nvim_buf_get_name(0):match("%.ipynb$") then
  require("quarto").activate()
end
