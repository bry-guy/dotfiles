return {
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    dependencies = { "3rd/image.nvim" },
    build = ":UpdateRemotePlugins",
    keys = {
      { "<leader>ja", "<cmd>MoltenInit<cr>", desc = "Attach notebook kernel" },
      { "<leader>jA", "<cmd>MoltenDeinit<cr>", desc = "Deinitialize notebook kernel" },
      { "<leader>jo", "<cmd>noautocmd MoltenEnterOutput<cr>", desc = "Enter notebook output" },
      { "<leader>jO", "<cmd>MoltenHideOutput<cr>", desc = "Hide notebook output" },
      { "<leader>ji", "<cmd>MoltenImportOutput<cr>", desc = "Import notebook output" },
    },
    init = function()
      vim.g.molten_auto_open_output = true
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_virt_lines_off_by_1 = true
      vim.g.molten_virt_text_output = false
      vim.g.molten_wrap_output = true
    end,
  },
  {
    "3rd/image.nvim",
    opts = {
      backend = "kitty",
      max_height_window_percentage = 100,
      integrations = {
        markdown = {
          enabled = false,
        },
      },
    },
  },
}
