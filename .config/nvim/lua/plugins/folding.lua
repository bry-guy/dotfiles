local handler = function(virtText, lnum, endLnum, width, truncate)
    local newVirtText = {}
    local suffix = (' 󰁂 %d '):format(endLnum - lnum)
    local sufWidth = vim.fn.strdisplaywidth(suffix)
    local targetWidth = width - sufWidth
    local curWidth = 0
    for _, chunk in ipairs(virtText) do
        local chunkText = chunk[1]
        local chunkWidth = vim.fn.strdisplaywidth(chunkText)
        if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
        else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, {chunkText, hlGroup})
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            if curWidth + chunkWidth < targetWidth then
                suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
            end
            break
        end
        curWidth = curWidth + chunkWidth
    end
    table.insert(newVirtText, {suffix, 'MoreMsg'})
    return newVirtText
end

local MAX_FOLD_LEVEL = 99

local M = {
  'kevinhwang91/nvim-ufo',
  dependencies = {
    'kevinhwang91/promise-async',
    'nvim-treesitter/nvim-treesitter',
    {
      "luukvbaal/statuscol.nvim",
        config = function()
          local builtin = require("statuscol.builtin")
          require("statuscol").setup({
            relculright = true,
            segments = {
              { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
              { text = { "%s" }, click = "v:lua.ScSa" },
              { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
            },
          })
        end,
      },
    },
  event = "BufReadPost",
  opts = {
    provider_selector = function()
      return { "treesitter", "indent" }
    end,
    fold_virt_text_handler = handler
  },
  init = function()
    vim.o.foldcolumn = '1'
    vim.o.foldlevel = MAX_FOLD_LEVEL
    vim.o.foldlevelstart = MAX_FOLD_LEVEL
    vim.o.foldenable = true
    vim.o.fillchars = 'eob: ,fold: ,foldopen:▾,foldsep: ,foldclose:▸'

    local ufo = require('ufo')
    local current_level = MAX_FOLD_LEVEL

    vim.keymap.set('n', 'zR', function()
      current_level = MAX_FOLD_LEVEL
      ufo.openAllFolds()
    end, { desc = "Open all folds" })

    vim.keymap.set('n', 'zM', function()
      current_level = 0
      ufo.closeAllFolds()
    end, { desc = "Close all folds" })

    vim.keymap.set('n', 'zr', function()
      if current_level < MAX_FOLD_LEVEL then
        current_level = current_level + 1
      end
      ufo.closeFoldsWith(current_level)
    end, { desc = "Open one fold level" })

    vim.keymap.set('n', 'zm', function()
      if current_level > 0 then
        current_level = current_level - 1
      end
      ufo.closeFoldsWith(current_level)
    end, { desc = "Close one fold level" })

    vim.keymap.set('n', 'zp', function()
      local winid = ufo.peekFoldedLinesUnderCursor()
      if not winid then
        vim.lsp.buf.hover()
      end
    end, { desc = "Peek fold or hover" })
  end,
}
return M
