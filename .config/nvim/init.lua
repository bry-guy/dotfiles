require("config.lazy")
require("config.autocmds")
require("config.options")

-- non-plugin hotkeys
local keymaps = require("config.keymaps")
keymaps.apply(keymaps.tab_hotkeys)
keymaps.apply(keymaps.view_hotkeys)
