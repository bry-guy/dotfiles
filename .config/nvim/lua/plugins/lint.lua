local M = {
  "mfussenegger/nvim-lint",
  event = "BufWritePost",
  config = function()
    local lint = require("lint")
    lint.linters_by_ft = {}

    -- lua = { 'luacheck', },

    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
      callback = function(args)
        if vim.bo[args.buf].filetype == "go" then
          if vim.fn.executable("golangci-lint") == 1 then
            lint.linters_by_ft.go = { "golangcilint" }
          else
            lint.linters_by_ft.go = nil
          end
        end

        lint.try_lint()
      end,
    })
  end
}

return M
