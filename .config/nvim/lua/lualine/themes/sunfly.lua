-- Pulls accent colors from the active sunfly palette so it tracks the variant.
local ok, sunfly = pcall(require, "sunfly")
local c = ok and sunfly.palette or {}

local colors = {
  color_bg1 = "#d2c5b5",
  color_bg2 = c.bg and (c.bg == "#f0e8da" and "#e6ddd0" or "#efe7dc") or "#efe7dc",

  color1 = c.blue or "#1b4fae",
  color2 = c.emerald or "#0d5f20",
  color3 = c.violet or "#5530bb",
  color4 = c.khaki or "#594800",
  color5 = c.red or "#9b1b23",

  color6 = "#fffefb",
  color7 = "#65594e",
  color8 = "#271e17",
  color9 = "#463c33",
}

return {
  normal = {
    a = { bg = colors.color1, fg = colors.color6 },
    b = { bg = colors.color_bg1, fg = colors.color1 },
    c = { bg = colors.color_bg2, fg = colors.color9 },
  },
  insert = {
    a = { bg = colors.color2, fg = colors.color6 },
    b = { bg = colors.color_bg1, fg = colors.color2 },
  },
  visual = {
    a = { bg = colors.color3, fg = colors.color6 },
    b = { bg = colors.color_bg1, fg = colors.color3 },
  },
  command = {
    a = { bg = colors.color4, fg = colors.color6 },
    b = { bg = colors.color_bg1, fg = colors.color4 },
  },
  replace = {
    a = { bg = colors.color5, fg = colors.color6 },
    b = { bg = colors.color_bg1, fg = colors.color5 },
  },
  terminal = {
    a = { bg = colors.color2, fg = colors.color6 },
    b = { bg = colors.color_bg1, fg = colors.color2 },
  },
  inactive = {
    a = { bg = colors.color_bg1, fg = colors.color7 },
    b = { bg = colors.color_bg1, fg = colors.color7 },
    c = { bg = colors.color_bg2, fg = colors.color7 },
  },
}
