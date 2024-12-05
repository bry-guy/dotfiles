M = {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "github/copilot.vim",
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    { "MeanderingProgrammer/render-markdown.nvim", ft = { "markdown", "codecompanion" } },
  },
  config = true,
  lazy = false,
  -- TODO: Use "cmd" to load API keys from 1password
  opts = {
    strategies = {
      chat = {
        adapter = "anthropic",
      },
      inline = {
        adapter = "copilot",
      },
    },
    display = {
      chat = {
        render_headers = false,
      }
    },
    slash_commands = {
      ["buffer"] = {
        callback = "strategies.chat.slash_commands.buffer",
        description = "Insert open buffers",
        opts = {
          contains_code = true,
          provider = "telescope",
        },
      },
      ["file"] = {
        callback = "strategies.chat.slash_commands.file",
        description = "Insert a file",
        opts = {
          contains_code = true,
          max_lines = 1000,
          provider = "telescope",
        },
      },
      ["help"] = {
        callback = "strategies.chat.slash_commands.help",
        description = "Insert content from help tags",
        opts = {
          contains_code = false,
          provider = "telescope",
        },
      },
      ["symbols"] = {
        callback = "strategies.chat.slash_commands.symbols",
        description = "Insert symbols for a selected file",
        opts = {
          contains_code = true,
          provider = "telescope",
        },
      },
    },
  }
}

return M
