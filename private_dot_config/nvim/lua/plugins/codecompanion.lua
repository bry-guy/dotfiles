M = {
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
    adapters = {
      copilot = function()
        return require("codecompanion.adapters").extend("copilot", {
          schema = {
            model = {
              default = "claude-3.7-sonnet",
            },
          },
        })
      end,
    },
    strategies = {
      chat = {
        adapter = "copilot",
      },
      inline = {
        adapter = "copilot",
      },
      cmd = {
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
