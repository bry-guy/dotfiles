local M = {}

-- Shared neutrals across all variants
local neutrals = {
  black = "#19120d",
  white = "#271e17",
  grey0 = "#e0d5c5",
  grey1 = "#d4c5b1",
  grey89 = "#372d25",
  grey70 = "#463c33",
  grey62 = "#564b41",
  grey58 = "#65594e",
  grey50 = "#75685b",
  grey39 = "#8b7d6f",
  grey35 = "#988979",
  grey30 = "#a59686",
  grey27 = "#b7a896",
  grey23 = "#c8b9a7",
  grey18 = "#dad0c1",
  grey16 = "#e7ddd1",
  grey15 = "#ece3d8",
  grey13 = "#f2ebe2",
  grey11 = "#f8f2ea",
  grey7 = "#fffefb",
  mineral = "#dceee7",
  bay = "#b3cdf7",
  slate = "#7489a7",
  haze = "#60758f",
}

-- "sunfly" (default) — Parchment + Vivid Ink
-- Warm parchment paper (#f0e8da), saturated accents. Easiest on eyes
-- in daylight. All accents >= 5.6:1 AA+.
local accents_sunfly = {
  bg = "#f0e8da",
  red = "#b01018",
  crimson = "#901848",
  cranberry = "#a81838",
  coral = "#884018",
  cinnamon = "#784830",
  orchid = "#5830b0",
  orange = "#884200",
  yellow = "#605200",
  khaki = "#6e5000",
  lime = "#306010",
  green = "#306800",
  emerald = "#006840",
  turquoise = "#005868",
  sky = "#004ca0",
  blue = "#105c98",
  lavender = "#4440b0",
  violet = "#801898",
  purple = "#4c28b0",
}

-- "crisp" — High Chroma Ink on near-white paper
-- Same hue strategy as sunfly but on cooler #fdfcf8 paper with all
-- accents darkened for AAA contrast (>= 7.3:1). Sharper in low light.
local accents_crisp = {
  bg = "#fdfcf8",
  red = "#a81018",
  crimson = "#881848",
  cranberry = "#a01030",
  coral = "#803818",
  cinnamon = "#703828",
  orchid = "#4e30a8",
  orange = "#7e3c00",
  yellow = "#5e4a00",
  khaki = "#6a4a08",
  lime = "#285410",
  green = "#285c00",
  emerald = "#005c45",
  turquoise = "#005060",
  sky = "#004898",
  blue = "#185888",
  lavender = "#4038a8",
  violet = "#7d1090",
  purple = "#5520a0",
}

local variants = {
  sunfly = accents_sunfly,
  crisp = accents_crisp,
}

function M.set_variant(v)
  v = (v or "sunfly"):lower()
  local accents = variants[v]
  if not accents then
    vim.notify("sunfly: unknown variant '" .. v .. "', using 'sunfly'", vim.log.levels.WARN)
    accents = accents_sunfly
  end
  M.palette = vim.tbl_extend("force", neutrals, accents)
  M._variant = v
end

-- Default to parchment variant
M.set_variant("sunfly")

function M.apply_overrides()
  local c = M.palette
  local set_hl = vim.api.nvim_set_hl

  set_hl(0, "Normal", { bg = c.bg, fg = c.white })
  set_hl(0, "NormalFloat", { bg = c.grey7, fg = c.white })
  set_hl(0, "FloatBorder", { bg = c.grey7, fg = c.grey27 })
  set_hl(0, "FloatTitle", { bg = c.grey18, fg = c.grey89 })
  set_hl(0, "Pmenu", { bg = c.grey7, fg = c.white })
  set_hl(0, "PmenuBorder", { bg = c.grey7, fg = c.grey27 })
  set_hl(0, "PmenuSel", { bg = c.bay, fg = c.black })
  set_hl(0, "Comment", { fg = c.grey50 })
  set_hl(0, "LineNr", { bg = c.bg, fg = c.grey39 })
  set_hl(0, "CursorLine", { bg = c.grey11 })
  set_hl(0, "CursorColumn", { bg = c.grey11 })
  set_hl(0, "CursorLineNr", { bg = c.grey11, fg = c.blue, bold = true })
  set_hl(0, "Visual", { bg = c.grey18 })
  set_hl(0, "VisualNOS", { bg = c.grey18, fg = c.grey89 })
  set_hl(0, "Search", { bg = c.grey1, fg = c.black })
  set_hl(0, "CurSearch", { bg = c.yellow, fg = c.black })
  set_hl(0, "IncSearch", { bg = c.coral, fg = c.black })
  set_hl(0, "ColorColumn", { bg = c.grey11 })
  set_hl(0, "Folded", { bg = c.grey13, fg = c.haze })
  set_hl(0, "StatusLine", { bg = c.grey16, fg = c.grey89 })
  set_hl(0, "StatusLineNC", { bg = c.grey16, fg = c.grey62 })
  set_hl(0, "TabLine", { bg = c.grey16, fg = c.grey62 })
  set_hl(0, "TabLineSel", { bg = c.grey7, fg = c.blue })
  set_hl(0, "TabLineFill", { bg = c.grey11, fg = c.grey18 })

  set_hl(0, "Function", { fg = c.sky })
  set_hl(0, "String", { fg = c.khaki })
  set_hl(0, "Type", { fg = c.emerald })
  set_hl(0, "Statement", { fg = c.violet })
  set_hl(0, "Identifier", { fg = c.turquoise })
  set_hl(0, "Constant", { fg = c.orange })
  set_hl(0, "Operator", { fg = c.cranberry })
  set_hl(0, "StorageClass", { fg = c.violet })
  set_hl(0, "Exception", { fg = c.red })
  set_hl(0, "Error", { fg = c.red })
  set_hl(0, "ErrorMsg", { fg = c.red })

  -- Tree-sitter: core groups (matches moonfly's full coverage)
  set_hl(0, "@attribute", { fg = c.sky })
  set_hl(0, "@annotation", { fg = c.sky })
  set_hl(0, "@comment.error", { fg = c.red })
  set_hl(0, "@comment.note", { fg = c.grey58 })
  set_hl(0, "@comment.ok", { fg = c.green })
  set_hl(0, "@comment.todo", { fg = c.yellow, bold = true })
  set_hl(0, "@comment.warning", { fg = c.yellow })
  set_hl(0, "@constant", { fg = c.turquoise })
  set_hl(0, "@constant.builtin", { fg = c.green })
  set_hl(0, "@constant.macro", { fg = c.violet })
  set_hl(0, "@constructor", { fg = c.emerald })
  set_hl(0, "@diff.delta", { link = "diffChanged" })
  set_hl(0, "@diff.minus", { link = "diffRemoved" })
  set_hl(0, "@diff.plus", { link = "diffAdded" })
  set_hl(0, "@function", { fg = c.sky })
  set_hl(0, "@function.builtin", { fg = c.sky })
  set_hl(0, "@function.call", { fg = c.sky })
  set_hl(0, "@function.macro", { fg = c.turquoise })
  set_hl(0, "@function.method", { fg = c.sky })
  set_hl(0, "@function.method.call", { fg = c.sky })
  set_hl(0, "@keyword", { fg = c.violet })
  set_hl(0, "@keyword.conditional", { fg = c.violet })
  set_hl(0, "@keyword.directive", { fg = c.cranberry })
  set_hl(0, "@keyword.directive.define", { fg = c.cranberry })
  set_hl(0, "@keyword.exception", { fg = c.violet })
  set_hl(0, "@keyword.function", { fg = c.violet })
  set_hl(0, "@keyword.import", { fg = c.cranberry })
  set_hl(0, "@keyword.modifier", { fg = c.violet })
  set_hl(0, "@keyword.operator", { fg = c.violet })
  set_hl(0, "@keyword.repeat", { fg = c.violet })
  set_hl(0, "@keyword.storage", { fg = c.violet })
  set_hl(0, "@module", { fg = c.turquoise })
  set_hl(0, "@module.builtin", { fg = c.green })
  set_hl(0, "@none", {})
  set_hl(0, "@number", { fg = c.purple })
  set_hl(0, "@parameter", { fg = c.orchid })
  set_hl(0, "@parameter.builtin", { fg = c.orchid })
  set_hl(0, "@property", { fg = c.lavender })
  set_hl(0, "@string", { fg = c.khaki })
  set_hl(0, "@string.documentation", { fg = c.haze })
  set_hl(0, "@string.regexp", { fg = c.turquoise })
  set_hl(0, "@string.special", { fg = c.orange })
  set_hl(0, "@string.special.path", { fg = c.orchid })
  set_hl(0, "@string.special.symbol", { fg = c.purple })
  set_hl(0, "@string.special.url", { fg = c.purple, underline = true, sp = c.grey50 })
  set_hl(0, "@tag", { fg = c.blue })
  set_hl(0, "@tag.attribute", { fg = c.turquoise })
  set_hl(0, "@tag.builtin", { fg = c.blue })
  set_hl(0, "@tag.delimiter", { fg = c.green })
  set_hl(0, "@type", { fg = c.emerald })
  set_hl(0, "@type.builtin", { fg = c.emerald })
  set_hl(0, "@type.definition", { fg = c.blue })
  set_hl(0, "@type.qualifier", { fg = c.violet })
  set_hl(0, "@variable", { fg = c.white })
  set_hl(0, "@variable.builtin", { fg = c.green })
  set_hl(0, "@variable.member", { fg = c.lavender })
  set_hl(0, "@variable.parameter", { fg = c.orchid })

  -- Tree-sitter: markup (markdown, help, vimdoc)
  set_hl(0, "@markup.environment", { fg = c.violet })
  set_hl(0, "@markup.environment.name", { fg = c.emerald })
  set_hl(0, "@markup.heading", { fg = c.violet })
  set_hl(0, "@markup.heading.1.markdown", { fg = c.lavender })
  set_hl(0, "@markup.heading.1.vimdoc", { fg = c.blue })
  set_hl(0, "@markup.heading.2.markdown", { fg = c.lavender })
  set_hl(0, "@markup.heading.2.vimdoc", { fg = c.blue })
  set_hl(0, "@markup.heading.3.markdown", { fg = c.turquoise })
  set_hl(0, "@markup.heading.3.vimdoc", { fg = c.blue })
  set_hl(0, "@markup.heading.4.markdown", { fg = c.orange })
  set_hl(0, "@markup.heading.5.markdown", { fg = c.sky })
  set_hl(0, "@markup.heading.6.markdown", { fg = c.violet })
  set_hl(0, "@markup.heading.help", { fg = c.sky })
  set_hl(0, "@markup.heading.markdown", { fg = c.sky })
  set_hl(0, "@markup.italic", { fg = c.orchid, italic = true })
  set_hl(0, "@markup.link", { fg = c.green })
  set_hl(0, "@markup.link.label", { fg = c.green })
  set_hl(0, "@markup.link.gitcommit", { fg = c.emerald })
  set_hl(0, "@markup.link.markdown_inline", {})
  set_hl(0, "@markup.link.url", { fg = c.purple, underline = true, sp = c.grey50 })
  set_hl(0, "@markup.link.url.astro", { fg = c.violet })
  set_hl(0, "@markup.link.url.gitcommit", { fg = c.emerald })
  set_hl(0, "@markup.link.url.html", { fg = c.violet })
  set_hl(0, "@markup.link.url.svelte", { fg = c.violet })
  set_hl(0, "@markup.link.url.vue", { fg = c.violet })
  set_hl(0, "@markup.list", { fg = c.cranberry })
  set_hl(0, "@markup.list.checked", { fg = c.turquoise })
  set_hl(0, "@markup.list.latex", { fg = c.purple })
  set_hl(0, "@markup.list.unchecked", { fg = c.blue })
  set_hl(0, "@markup.math", { fg = c.sky })
  set_hl(0, "@markup.quote", { fg = c.grey58 })
  set_hl(0, "@markup.raw", { fg = c.khaki })
  set_hl(0, "@markup.raw.vimdoc", { fg = c.orchid })
  set_hl(0, "@markup.strikethrough", { strikethrough = true })
  set_hl(0, "@markup.strong", { fg = c.orchid })
  set_hl(0, "@markup.underline", { underline = true })

  -- Tree-sitter: language-specific overrides
  set_hl(0, "@attribute.bind.html", { fg = c.emerald })
  set_hl(0, "@attribute.on.html", { fg = c.orchid })
  set_hl(0, "@attribute.zig", { fg = c.violet })
  set_hl(0, "@character.special.vim", { fg = c.sky })
  set_hl(0, "@function.macro.vim", { fg = c.sky })
  set_hl(0, "@keyword.gitcommit", { fg = c.sky })
  set_hl(0, "@keyword.import.bash", { link = "@keyword" })
  set_hl(0, "@keyword.import.rust", { link = "@keyword" })
  set_hl(0, "@keyword.storage.rust", { fg = c.violet })
  set_hl(0, "@namespace.latex", { fg = c.lavender })
  set_hl(0, "@punctuation.delimiter.astro", { fg = c.cranberry })
  set_hl(0, "@punctuation.delimiter.css", { fg = c.cranberry })
  set_hl(0, "@punctuation.delimiter.rust", { fg = c.cranberry })
  set_hl(0, "@punctuation.delimiter.scss", { fg = c.cranberry })
  set_hl(0, "@punctuation.delimiter.yaml", { fg = c.cranberry })
  set_hl(0, "@string.json", { fg = c.lime })
  set_hl(0, "@tag.javascript", { link = "@type" })
  set_hl(0, "@tag.jsx", { link = "@type" })
  set_hl(0, "@tag.tsx", { link = "@type" })
  set_hl(0, "@tag.typescript", { link = "@type" })
  set_hl(0, "@variable.builtin.tmux", { fg = c.turquoise })
  set_hl(0, "@variable.builtin.vim", { fg = c.emerald })
  set_hl(0, "@variable.member.ruby", { fg = c.turquoise })
  set_hl(0, "@variable.member.yaml", { fg = c.blue })
  set_hl(0, "@variable.parameter.bash", { fg = c.turquoise })
  set_hl(0, "@variable.scss", { fg = c.turquoise })
  set_hl(0, "@variable.vim", { fg = c.turquoise })

  -- LSP semantic highlights
  set_hl(0, "@lsp.type.boolean", { link = "@boolean" })
  set_hl(0, "@lsp.type.builtinConstant", { link = "@constant.builtin" })
  set_hl(0, "@lsp.type.builtinType", { link = "@type.builtin" })
  set_hl(0, "@lsp.type.class", { fg = c.emerald })
  set_hl(0, "@lsp.type.decorator", { fg = c.sky })
  set_hl(0, "@lsp.type.decorator.rust", { link = "@function.macro" })
  set_hl(0, "@lsp.type.enum", { fg = c.emerald })
  set_hl(0, "@lsp.type.escapeSequence", { link = "@string.escape" })
  set_hl(0, "@lsp.type.formatSpecifier", { link = "@punctuation.special" })
  set_hl(0, "@lsp.type.generic", { link = "@variable" })
  set_hl(0, "@lsp.type.interface", { fg = c.emerald })
  set_hl(0, "@lsp.type.lifetime", { link = "StorageClass" })
  set_hl(0, "@lsp.type.macro", {})
  set_hl(0, "@lsp.type.magicFunction", { link = "@function" })
  set_hl(0, "@lsp.type.method", { fg = c.sky })
  set_hl(0, "@lsp.type.namespace", { link = "@module" })
  set_hl(0, "@lsp.type.namespace.ruby", {})
  set_hl(0, "@lsp.type.operator", {})
  set_hl(0, "@lsp.type.parameter", { fg = c.orchid })
  set_hl(0, "@lsp.type.parameter.dockerfile", { link = "@property" })
  set_hl(0, "@lsp.type.property", { fg = c.lavender })
  set_hl(0, "@lsp.type.selfKeyword", { link = "@variable.builtin" })
  set_hl(0, "@lsp.type.selfParameter", { link = "@variable.builtin" })
  set_hl(0, "@lsp.type.typeAlias", { link = "@type.definition" })
  set_hl(0, "@lsp.type.typeParameter", { fg = c.emerald })
  set_hl(0, "@lsp.type.unresolvedReference", { underline = true, sp = c.red })
  set_hl(0, "@lsp.type.variable", {})
  set_hl(0, "@lsp.type.variable.dockerfile", { link = "@function" })

  -- LSP semantic type modifiers
  set_hl(0, "@lsp.typemod.class.defaultLibrary", { link = "@type" })
  set_hl(0, "@lsp.typemod.enum.defaultLibrary", { link = "@type" })
  set_hl(0, "@lsp.typemod.enumMember.defaultLibrary", { link = "@constant.builtin" })
  set_hl(0, "@lsp.typemod.function.defaultLibrary", { link = "@function" })
  set_hl(0, "@lsp.typemod.keyword.async", { link = "@keyword" })
  set_hl(0, "@lsp.typemod.keyword.injected", { link = "@keyword" })
  set_hl(0, "@lsp.typemod.method.defaultLibrary", { link = "@function" })
  set_hl(0, "@lsp.typemod.operator.injected", { link = "@operator" })
  set_hl(0, "@lsp.typemod.string.injected", { link = "@string" })
  set_hl(0, "@lsp.typemod.struct.defaultLibrary", { link = "@type" })
  set_hl(0, "@lsp.typemod.variable.callable", { link = "@function" })
  set_hl(0, "@lsp.typemod.variable.defaultLibrary", { link = "@variable.builtin" })
  set_hl(0, "@lsp.typemod.variable.injected", { link = "@variable" })
  set_hl(0, "@lsp.typemod.variable.static", { link = "@constant" })

  -- Diagnostics
  set_hl(0, "DiagnosticError", { fg = c.red })
  set_hl(0, "DiagnosticWarn", { fg = c.yellow })
  set_hl(0, "DiagnosticInfo", { fg = c.sky })
  set_hl(0, "DiagnosticHint", { fg = c.turquoise })
  set_hl(0, "DiagnosticOk", { fg = c.emerald })
  set_hl(0, "DiagnosticUnderlineError", { undercurl = true, sp = c.red })
  set_hl(0, "DiagnosticUnderlineWarn", { undercurl = true, sp = c.yellow })
  set_hl(0, "DiagnosticUnderlineInfo", { undercurl = true, sp = c.sky })
  set_hl(0, "DiagnosticUnderlineHint", { undercurl = true, sp = c.turquoise })
  set_hl(0, "DiagnosticUnderlineOk", { undercurl = true, sp = c.emerald })
  set_hl(0, "DiagnosticVirtualTextError", { bg = c.grey11, fg = c.red })
  set_hl(0, "DiagnosticVirtualTextWarn", { bg = c.grey11, fg = c.yellow })
  set_hl(0, "DiagnosticVirtualTextInfo", { bg = c.grey11, fg = c.sky })
  set_hl(0, "DiagnosticVirtualTextHint", { bg = c.grey11, fg = c.turquoise })
  set_hl(0, "DiagnosticVirtualTextOk", { bg = c.grey11, fg = c.emerald })
  set_hl(0, "DiagnosticSignError", { fg = c.red })
  set_hl(0, "DiagnosticSignWarn", { fg = c.yellow })
  set_hl(0, "DiagnosticSignInfo", { fg = c.sky })
  set_hl(0, "DiagnosticSignHint", { fg = c.turquoise })
  set_hl(0, "DiagnosticSignOk", { fg = c.emerald })
  set_hl(0, "DiagnosticFloatingError", { fg = c.red })
  set_hl(0, "DiagnosticFloatingWarn", { fg = c.yellow })
  set_hl(0, "DiagnosticFloatingInfo", { fg = c.sky })
  set_hl(0, "DiagnosticFloatingHint", { fg = c.turquoise })
  set_hl(0, "DiagnosticFloatingOk", { fg = c.emerald })

  -- LSP UI
  set_hl(0, "LspCodeLens", { fg = c.grey39 })
  set_hl(0, "LspCodeLensSeparator", { fg = c.grey39 })
  set_hl(0, "LspInfoBorder", { link = "FloatBorder" })
  set_hl(0, "LspInlayHint", { bg = c.grey13, fg = c.grey58 })
  set_hl(0, "LspReferenceText", { bg = c.grey18 })
  set_hl(0, "LspReferenceRead", { bg = c.grey18 })
  set_hl(0, "LspReferenceWrite", { bg = c.grey18 })
  set_hl(0, "LspSignatureActiveParameter", { bg = c.grey18 })
end

function M.load(variant)
  if variant then
    M.set_variant(variant)
  end
  vim.o.background = "light"
  require("moonfly").custom_colors(M.palette)
  vim.cmd("colorscheme moonfly")
  M.apply_overrides()
  vim.g.colors_name = "sunfly"
end

return M
