-- Enable filetype detection
vim.cmd('filetype on')
-- Enable filetype-specific indenting and plugins
vim.cmd('filetype indent plugin on')
-- Enable syntax highlighting
vim.cmd('syntax on')

-- Automatically save before commands like :next and :make
vim.o.autowrite = true

-- Show line numbers
vim.o.number = true

-- Minimum number of screen lines to keep above and below the cursor
vim.o.scrolloff = 5

-- Set the number of spaces that a <Tab> in the file counts for
vim.o.tabstop = 4
-- Set the number of spaces that a <Tab> counts for while performing editing operations
vim.o.softtabstop = 4
-- Always show the sign column to avoid text shifting
vim.o.signcolumn = 'yes'

-- Allow hidden buffers
vim.o.hidden = true
-- Disable swap file creation
vim.o.swapfile = false

-- Ignore case in search patterns
vim.o.ignorecase = true
-- Override ignorecase if the search pattern contains uppercase characters
vim.o.smartcase = true

-- New split windows go below the current one
vim.o.splitbelow = true
-- New split windows go to the right of the current one
vim.o.splitright = true

-- Time in milliseconds to wait for a mapped sequence to complete
vim.o.timeoutlen = 500
-- Time in milliseconds to wait for a key code sequence to complete
vim.o.ttimeoutlen = 5

-- Set the character encoding of the file
vim.o.encoding = 'utf-8'

-- Relative line numbering
vim.o.number = true
vim.o.relativenumber = true

-- Enable colorscheme
vim.opt.termguicolors = true
vim.cmd [[colorscheme moonfly]]

-- LSP specific settings (TODO: why?)
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
  vim.lsp.handlers.hover, {
    border = "single"
  }
)
vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
  vim.lsp.handlers.signatureHelp, {
    border = "single"
  }
)
vim.diagnostic.config({ float = { border = "single" } })
