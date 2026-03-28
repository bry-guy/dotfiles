local M = {
   "amitds1997/remote-nvim.nvim",
   -- version = "*", -- Pin to GitHub releases
   branch = "main",
   dependencies = {
       "nvim-lua/plenary.nvim", -- For standard functions
       "MunifTanjim/nui.nvim", -- To build the plugin UI
       "nvim-telescope/telescope.nvim", -- For picking b/w different remote methods
   },
   opts = {
     devpod = {
       docker_binary = "podman"
     }
   },
   keys = require("config.keymaps").remote_hotkeys
}

return M
