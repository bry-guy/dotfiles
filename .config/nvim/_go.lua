vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = {"*.go"},
  callback = function()
    -- Save the current buffer number
    local bufnr = vim.api.nvim_get_current_buf()

	-- Save the current cursor position
    local cursor_pos = vim.api.nvim_win_get_cursor(0)

    -- Run `go fmt` on the current file
    vim.api.nvim_command('silent !go fmt %')

    -- Reload the buffer in case `go fmt` made changes
    vim.api.nvim_command('e!')

	-- Restore the cursor position
    vim.api.nvim_win_set_cursor(0, cursor_pos)

    -- Set the buffer as unmodified (since `go fmt` has saved it)
    vim.api.nvim_buf_set_option(bufnr, 'modified', false)
  end,
})


-- vim.api.nvim_create_autocmd("BufWritePost", {
--   pattern = {"*.go"},
--   callback = function()
--     -- Save the current buffer number
--     local bufnr = vim.api.nvim_get_current_buf()

--     -- Save the current cursor position
--     local cursor_pos = vim.api.nvim_win_get_cursor(0)

--     -- Define the command to run `go fmt` on the current file
--     local cmd = "go fmt " .. vim.api.nvim_buf_get_name(bufnr)

--     -- Run `go fmt` asynchronously
--     vim.fn.jobstart(cmd, {
--       on_exit = function(_, exit_code)
--         if exit_code == 0 then
--           -- Reload the buffer in case `go fmt` made changes, avoiding cursor jump
--           vim.api.nvim_buf_call(bufnr, function()
--             vim.cmd('silent! e!')
--             -- Restore the cursor position
--             vim.api.nvim_win_set_cursor(0, cursor_pos)
--             -- Set the buffer as unmodified (since `go fmt` has saved it)
--             vim.api.nvim_buf_set_option(bufnr, 'modified', false)
--           end)
--         end
--       end
--     })
--   end,
-- })

