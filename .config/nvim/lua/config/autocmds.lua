vim.filetype.add({
  filename = {
    [".justfile"] = "just",
    ["justfile"] = "just",
  },
  pattern = {
    ["justfile.*"] = "just",
  },
})


-- vim-pencil
-- vim.api.nvim_create_augroup("pencil", { clear = true })
-- vim.api.nvim_create_autocmd("FileType", {
--   group = "pencil",
--   pattern = { "markdown", "mkd" },
--   callback = function()
--     vim.fn["pencil#init"]()
--   end,
-- })
-- vim.api.nvim_create_autocmd("FileType", {
--   group = "pencil",
--   pattern = "text",
--   callback = function()
--     vim.fn["pencil#init"]()
--   end,
-- })

