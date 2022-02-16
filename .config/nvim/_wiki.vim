" TODO: Get styles for Github-style markdown working in default.tpl
" https://github.com/vimwiki/vimwiki
" converts wiki to html with ruby gem https://github.com/patrickdavey/vimwiki_markdown
let g:vimwiki_list = [{'path': '~/vimwiki', 
						\ 'template_path': '~/vimwiki/templates/',
						\ 'template_default': 'default', 
						\ 'syntax': 'markdown', 'ext': '.md',
						\ 'path_html': '~/vimwiki/site_html/', 
						\ 'custom_wiki2html': 'vimwiki_markdown',
						\ 'html_filename_parameterization': 1,
						\ 'template_ext': '.tpl'}]


let b:exists = system('gem list --local | grep vimwiki_markdown | wc -l')
if !b:exists
		let b:installed = system('gem install vimwiki_markdown')
end

nnoremap <Leader>w- <Plug>VimwikiRemoveHeaderLevel
nnoremap <Leader>w= <Plug>VimwikiAddHeaderLevel

" vim-zettel
" TODO: Finish vim-zettel config
