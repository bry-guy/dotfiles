local M = {
  "mfussenegger/nvim-dap",
  dependencies = {
    "leoluz/nvim-dap-go",
  },
  keys = require("config.keymaps").dap_hotkeys,
  config = function()
    require("dap-go").setup()
    local dap = require("dap")
    dap.switchbuf = "usevisible,usetab,uselast"

    -- dap.adapters.delve = {
    --   type = 'server',
    --   port = '${port}',
    --   executable = {
    --     command = 'dlv',
    --     args = {'dap', '-l', '127.0.0.1:${port}'},
    --   }
    -- }

    -- -- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
    -- dap.configurations.go = {
    --   {
    --     type = "delve",
    --     name = "Debug",
    --     request = "launch",
    --     program = "${file}"
    --   },
    --   {
    --     type = "delve",
    --     name = "Debug test", -- configuration for debugging test files
    --     request = "launch",
    --     mode = "test",
    --     program = "${file}"
    --   },
    --   -- works with go.mod packages and sub packages
    --   {
    --     type = "delve",
    --     name = "Debug test (go.mod)",
    --     request = "launch",
    --     mode = "test",
    --     program = "./${relativeFileDirname}"
    --   }
    -- }
  end
}

return M
