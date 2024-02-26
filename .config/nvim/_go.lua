vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = {"*.go"},
  callback = function()
    -- Save the current buffer number
    local bufnr = vim.api.nvim_get_current_buf()

    -- Run `go fmt` on the current file
    vim.api.nvim_command('silent !go fmt %')

    -- Reload the buffer in case `go fmt` made changes
    vim.api.nvim_command('e!')

    -- Set the buffer as unmodified (since `go fmt` has saved it)
    vim.api.nvim_buf_set_option(bufnr, 'modified', false)
  end,
})

