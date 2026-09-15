return {
  "quarto-dev/quarto-nvim",
  ft = { "quarto", "markdown" },
  dependencies = {
    "jmbuhr/otter.nvim",
    "nvim-treesitter/nvim-treesitter",
    "benlubas/molten-nvim",
  },
  config = function()
    require("quarto").setup({
      lspFeatures = {
        enabled = true,
        languages = { "python" },
        chunks = "all",
        diagnostics = {
          enabled = true,
          triggers = { "BufWritePost" },
        },
        completion = {
          enabled = true,
        },
      },
      codeRunner = {
        enabled = true,
        default_method = "molten",
      },
    })

    local runner = require("quarto.runner")
    vim.keymap.set("n", "<leader>jr", runner.run_cell, { desc = "Run notebook cell" })
    vim.keymap.set("n", "<leader>jra", runner.run_above, { desc = "Run notebook cells above" })
    vim.keymap.set("n", "<leader>jrA", runner.run_all, { desc = "Run all notebook cells" })
    vim.keymap.set("n", "<leader>jrl", runner.run_line, { desc = "Run notebook line" })
    vim.keymap.set("v", "<leader>jr", runner.run_range, { desc = "Run notebook selection" })
  end,
}
