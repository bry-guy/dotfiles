local M = {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    { "MeanderingProgrammer/render-markdown.nvim", ft = { "markdown", "codecompanion" } },
  },
  keys = require("config.keymaps").ai_hotkeys,
  init = function()
    vim.cmd([[cab cc CodeCompanion]])
  end,
  opts = {
    stream = false,
    -- adapters = {
    --   gemini = function()
    --     return require("codecompanion.adapters").extend("gemini", {
    --       schema = {
    --         model = {
    --           default = "gemini-3-flash-preview",
    --         },
    --       },
    --     })
    --   end,
    -- },
    interactions = {
      chat = {
        adapter = {
          name = "gemini",
          model = "gemini-3-flash-preview",
        },
        slash_commands = {
          ["buffer"] = { opts = { provider = "telescope" } },
          ["file"] = { opts = { provider = "telescope", max_lines = 1000 } },
          ["help"] = { opts = { provider = "telescope" } },
          ["symbols"] = { opts = { provider = "telescope" } },
        },
      },
      inline = {
        adapter = "gemini",
        keymaps = {
          accept_change = { modes = { n = "ga" }, description = "Accept change" },
          reject_change = { modes = { n = "gr" }, description = "Reject change" },
        },
      },
      cmd = {
        adapter = "gemini",
      },
    },
    display = {
      chat = {
        render_headers = false,
      }
    },
    opts = {
      log_level = "DEBUG",
    },
  }
}

return M
