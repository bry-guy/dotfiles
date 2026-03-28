require("config.lazy")
require("config.autocmds")
require("config.options")

-- non-plugin hotkeys
require("config.keymaps").apply(require("config.keymaps").tab_hotkeys)
