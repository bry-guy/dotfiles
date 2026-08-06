local function darker_color(color, amount)
  if color == nil then
    return nil
  end

  local red = math.floor(color / 65536) % 256
  local green = math.floor(color / 256) % 256
  local blue = color % 256
  local factor = 1 - amount

  return string.format(
    "#%02x%02x%02x",
    math.floor(red * factor),
    math.floor(green * factor),
    math.floor(blue * factor)
  )
end

local function apply_glow_heading_highlights()
  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  local h1 = vim.api.nvim_get_hl(0, { name = "RenderMarkdownH1", link = false })
  local h1_background = vim.api.nvim_get_hl(0, { name = "RenderMarkdownH1Bg", link = false })

  local code_background = darker_color(normal.bg, 0.07)
  if code_background then
    vim.api.nvim_set_hl(0, "RenderMarkdownGlowCode", { bg = code_background })
  end

  for level = 1, 6 do
    local name = string.format("@markup.heading.%d.markdown", level)
    local current = vim.api.nvim_get_hl(0, { name = name, link = false })
    if vim.tbl_count(current) > 0 then
      current.bold = level <= 3
      vim.api.nvim_set_hl(0, name, current)
    end

    local background = { bg = normal.bg }
    if level == 1 then
      background = {
        fg = h1.fg or normal.fg,
        bg = h1_background.bg or normal.bg,
        bold = true,
      }
    end
    vim.api.nvim_set_hl(0, string.format("RenderMarkdownGlowH%dBg", level), background)
  end
end

local M = {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown" },
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  init = function()
    local group = vim.api.nvim_create_augroup("RenderMarkdownGlowHeadings", { clear = true })
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = group,
      callback = function()
        vim.schedule(apply_glow_heading_highlights)
      end,
    })
  end,
  opts = {
    -- Keep the rendered view consistent even while the cursor is on a heading.
    anti_conceal = {
      enabled = false,
    },
    -- Match Glow's hierarchy: a decorated H1, then bold/colorized H2/H3
    -- while keeping their Markdown markers visible.
    heading = {
      enabled = true,
      sign = false,
      icons = function(context)
        return context.level == 1 and " " or nil
      end,
      position = "inline",
      width = "block",
      border = false,
      backgrounds = {
        "RenderMarkdownGlowH1Bg",
        "RenderMarkdownGlowH2Bg",
        "RenderMarkdownGlowH3Bg",
        "RenderMarkdownGlowH4Bg",
        "RenderMarkdownGlowH5Bg",
        "RenderMarkdownGlowH6Bg",
      },
    },
    code = {
      sign = false,
      style = "normal",
      border = "hide",
      left_pad = 2,
      -- Use a theme-derived background that is slightly darker than Normal.
      -- The group has no foreground, so Treesitter syntax colors remain intact.
      highlight = "RenderMarkdownGlowCode",
      highlight_border = "RenderMarkdownGlowCode",
      highlight_inline = "RenderMarkdownGlowCode",
    },
    bullet = {
      icons = { "•" },
      highlight = "Normal",
    },
    quote = {
      icon = "│",
      highlight = "Normal",
    },
    pipe_table = {
      preset = "none",
      border_enabled = false,
    },
    on = {
      initial = apply_glow_heading_highlights,
    },
  },
  config = function(_, opts)
    require("render-markdown").setup(opts)
    apply_glow_heading_highlights()
  end,
}

return M
