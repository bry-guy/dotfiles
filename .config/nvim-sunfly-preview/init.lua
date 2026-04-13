vim.g.dotfiles_theme = "sunfly"
vim.g.dotfiles_theme_preview = true

local home = vim.env.HOME or "~"
local main_config = home .. "/.config/nvim"

vim.opt.runtimepath:prepend(main_config)
package.path = table.concat({
  main_config .. "/lua/?.lua",
  main_config .. "/lua/?/init.lua",
  package.path,
}, ";")

dofile(main_config .. "/init.lua")
