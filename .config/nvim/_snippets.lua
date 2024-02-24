require('snippy').setup({
    mappings = {
        is = {
            ['<leader>s'] = 'expand_or_advance',
            ['<leader>S'] = 'previous',
        },
        nx = {
            ['<leader>x'] = 'cut_text',
        },
    },
})
