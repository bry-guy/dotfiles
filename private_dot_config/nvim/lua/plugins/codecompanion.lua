M = {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    { "MeanderingProgrammer/render-markdown.nvim", ft = { "markdown", "codecompanion" } },
    {
      "Davidyz/VectorCode",
      cmd = "VectorCode",
    }
  },
  keys = require("config.keymaps").ai_hotkeys,
  init = function()
    vim.cmd([[cab cc CodeCompanion]])
  end,
  opts = {
    stream = false,
    adapters = {
      http = {
        copilot = function()
          return require("codecompanion.adapters").extend("copilot", {
            schema = {
              model = {
                -- "gpt-4.1", "gpt-4o", "o1", "claude-3.5-sonnet", "claude-3.7.-sonnet", "claude-3.7-sonnet-thought", 
                default = "claude-sonnet-4",
              },
            },
          })
        end,
      },
    },
    strategies = {
      chat = {
        adapter = "copilot",
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
      },
      inline = {
        adapter = "copilot",
        keymaps = {
          accept_change = {
            modes = { n = "ga" },
            description = "Accept the suggested change",
          },
          reject_change = {
            modes = { n = "gr" },
            description = "Reject the suggested change",
          },
        },
      },
      cmd = {
        adapter = "copilot",
      },
    },
    opts = {
      log_level = "DEBUG",
    },
    extensions = {
      vectorcode = {
        opts = { add_tool = true, add_slash_command = true, tool_opts = {} },
      },
    },
    display = {
      chat = {
        render_headers = false,
      }
    },
  }
}

return M
