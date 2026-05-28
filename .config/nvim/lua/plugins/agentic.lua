local M = {
  "carlos-algms/agentic.nvim",
  keys = require("config.keymaps").ai_hotkeys,
  init = function()
    vim.api.nvim_create_user_command("AIChat", function()
      require("agentic").toggle({ auto_add_to_context = false })
    end, { desc = "Toggle AI chat" })
    vim.cmd([[cab cc AIChat]])
  end,
  config = function(_, opts)
    require("agentic").setup(opts)

    -- pi-acp can replay historic tool calls with rawInput=null. Neovim decodes
    -- JSON null as a userdata sentinel, while Agentic assumes rawInput is a
    -- table. Normalize that until either side hardens this path upstream.
    local ACPClient = require("agentic.acp.acp_client")
    if not ACPClient._dotfiles_pi_acp_raw_input_patch then
      ACPClient._dotfiles_pi_acp_raw_input_patch = true
      local original_build_tool_call_message = ACPClient.__build_tool_call_message
      function ACPClient:__build_tool_call_message(update)
        if update and update.rawInput ~= nil and type(update.rawInput) ~= "table" then
          local normalized = {}
          for key, value in pairs(update) do
            normalized[key] = value
          end
          normalized.rawInput = nil
          update = normalized
        end

        return original_build_tool_call_message(self, update)
      end
    end

    -- pi-acp emits session_info_update for /name. Agentic does not handle it
    -- yet, so treat it as an informational title update instead of warning.
    local SessionManager = require("agentic.session_manager")
    if not SessionManager._dotfiles_pi_acp_session_info_patch then
      SessionManager._dotfiles_pi_acp_session_info_patch = true
      local original_on_session_update = SessionManager._on_session_update
      function SessionManager:_on_session_update(update)
        if update.sessionUpdate == "session_info_update" then
          if update.title and self.chat_history then
            self.chat_history.title = update.title
          end
          return
        end

        return original_on_session_update(self, update)
      end
    end
  end,
  opts = {
    provider = "pi-acp",
    acp_providers = {
      ["pi-acp"] = {
        name = "Pi ACP",
        command = "pi-acp",
        env = {
          PI_ACP_PI_COMMAND = "/opt/homebrew/bin/pi",
        },
      },
    },
    keymaps = {
      widget = {
        -- Agentic's built-in provider switcher only lists built-in providers,
        -- not custom ones like pi-acp.
        switch_provider = {},
      },
    },
  },
}

return M
