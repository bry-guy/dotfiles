-- The built-in Markdown ftplugin enables automatic text wrapping via `t`.
-- Keep hard newlines manual; visual wrapping is handled by the window instead.
vim.opt_local.formatoptions:remove({ "t" })
