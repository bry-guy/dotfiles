vim.api.nvim_command('set completeopt=menu,menuone,noselect')

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local cmp = require('cmp')
local snippy = require('snippy')

cmp.setup({
  completion = {
		autocomplete = { require('cmp.types').cmp.TriggerEvent.TextChanged },
  },
  snippet = {
	expand = function(args)
	  require('snippy').expand_snippet(args.body)
	end
  },
  mapping = {
    -- ['<C-Tab>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    -- ['<C-S-Tab>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
	["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
	  elseif snippy.can_expand_or_advance() then
		snippy.expand_or_advance()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
      end
    end, { "i", "s" }),

    ["<S-Tab>"] = cmp.mapping(function()
      if cmp.visible() then
        cmp.select_prev_item()
	  elseif snippy.can_jump(-1) then
        snippy.previous()
      end
    end, { "i", "s" }),
    ['<C-s>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<C-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
  }, {
    { name = 'buffer' },
  })
})

cmp.setup.cmdline('/', {
  sources = {
    { name = 'buffer' }
  }
})

cmp.setup.cmdline(':', {
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})
