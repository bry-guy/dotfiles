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

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.ipynb",
  callback = function()
    local ok, status = pcall(function()
      return require("molten.status").initialized()
    end)
    if ok and status == "Molten" then
      vim.cmd("MoltenExportOutput!")
    end
  end,
})

