" YVim
" Maintainer: dexteryy <dexter.yy at gmail.com>
" URL:        https://github.com/dexteryy/YVim

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Default
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible
set history=400
if has('mouse')
  set mouse=a
endif
set backspace=indent,eol,start
set ruler
set showcmd
set incsearch
set hlsearch
syntax on
filetype plugin indent on

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugins
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" for Vundle
"filetype off
"set rtp+=~/.vim/plugged/Vundle.vim
"call vundle#begin('~/.vim/plugged')

" for vim-plug
call plug#begin()

" ==============================================================
"Plug 'gmarik/Vundle.vim'
" ==============================================================
Plug 'L9'
Plug 'cecutil'
Plug 'tpope/vim-scriptease'
Plug 'xolox/vim-misc'
" ==============================================================
Plug 'flazz/vim-colorschemes'
" ==============================================================
Plug 'pangloss/vim-javascript'
"Plug 'othree/yajs.vim'
Plug 'othree/javascript-libraries-syntax.vim'
Plug 'elzr/vim-json'
Plug 'othree/html5.vim'
Plug 'JulesWang/css.vim'
Plug 'hail2u/vim-css3-syntax'
Plug 'cakebaker/scss-syntax.vim'
Plug 'mustache/vim-mustache-handlebars'
Plug 'digitaltoad/vim-jade'
Plug 'slim-template/vim-slim'
Plug 'rust-lang/rust.vim'
Plug 'cespare/vim-toml'
Plug 'fatih/vim-go'
Plug 'dart-lang/dart-vim-plugin'
Plug 'tpope/vim-bundler'
"Plug 'b4winckler/vim-objc'
Plug 'plasticboy/vim-markdown'
Plug 'chrisbra/csv.vim'
" ==============================================================
Plug 'scrooloose/syntastic'
Plug 'Shutnik/jshint2.vim'
Plug 'suan/vim-instant-markdown'
Plug 'mattn/emmet-vim'
Plug 'tpope/vim-rails'
"Plug 'eraserhd/vim-ios'
Plug 'paredit.vim'
Plug 'jmcantrell/vim-virtualenv'
" ==============================================================
Plug 'IndentAnything'
Plug 'matchit.zip'
Plug 'delimitMate.vim'
Plug 'ShowMarks7'
Plug 'tpope/vim-repeat'
" ==============================================================
Plug 'Lokaltog/vim-easymotion'
Plug 'terryma/vim-expand-region'
" ==============================================================
Plug 'godlygeek/tabular'
Plug 'scrooloose/nerdcommenter'
Plug 'tpope/vim-surround'
" ==============================================================
"Plug 'powerline/powerline'
Plug 'bling/vim-airline'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'myusuf3/numbers.vim'
Plug 'justincampbell/vim-eighties'
" ==============================================================
Plug 'scrooloose/nerdtree'
Plug 'FuzzyFinder'
Plug 'ctrlp.vim'
Plug 'mru.vim'
Plug 'Shougo/unite.vim'
Plug 'jlanzarotta/bufexplorer'
Plug 'rking/ag.vim'
Plug 'majutsushi/tagbar'
" ==============================================================
"Plug 'Shougo/neosnippet'
"Plug 'Shougo/neosnippet-snippets'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
"Plug 'Shougo/neocomplcache.vim'
"Plug 'Shougo/neocomplete'
Plug 'Valloric/YouCompleteMe'
Plug 'SyntaxComplete'
"Plug 'SQLComplete.vim'
Plug 'https://bitbucket.org/teramako/jscomplete-vim.git'
Plug 'myhere/vim-nodejs-complete'
Plug 'marijnh/tern_for_vim'
" ==============================================================
Plug 'xolox/vim-session'
Plug 'thinca/vim-quickrun'
Plug 'Gundo'
" ==============================================================
Plug 'airblade/vim-gitgutter'
Plug 'vcscommand.vim'
Plug 'fugitive.vim'
Plug 'kablamo/vim-git-log'
" ==============================================================
Plug 'TaskList.vim'
Plug 'scratch.vim'
Plug 'DrawIt'
Plug 'mattn/calendar-vim'
Plug 'uguu-org/vim-matrix-screensaver'
" ==============================================================

" for Vundle
"call vundle#end()
"filetype plugin indent on

" for vim-plug
call plug#end()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Platform
function! MySys()
	if has("win32") || has("win64")
    	return "windows"
	elseif has("mac")
		return "mac"
	else
    	return "linux"
  	endif
endfunction

"if MySys() == 'mac' || MySys() == 'linux'
	"set shell=/bin/bash\ -l
"endif

set encoding=utf-8
set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936

set backupdir=~/.vim/backups
set dir=~/.vim/backups
set nobackup
"set nowritebackup

set undodir=~/.vim/undos
set undofile

set laststatus=2   " Always show the statusline
set ambiwidth=single

set expandtab
set shiftwidth=4
set tabstop=4
set softtabstop=4
set nowrap
set colorcolumn=+1
set wildmenu
set wildmode=longest:full,full
set wildignore+=*.orig,*.pyc
set matchpairs=(:),{:},[:]
set whichwrap=b,s,<,>,[,]
set foldmethod=marker
set diffopt+=iwhite,vertical " 忽略缩进的差异
"set cursorbind
"set gdefault

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if has("gui_running") || has("gui_macvim")
    "colorscheme blackboard
    "colorscheme badwolf
    "colorscheme molokai
    "colorscheme yyblackboard
    colorscheme yymolokai
    let g:colors_name="yymolokai"
else
    colorscheme molokai
    let g:colors_name="molokai"
	"colorscheme slate
endif

if MySys() == "mac"
	"set guifont=Monaco:h13
    set guifont=Consolas:h14
    "set guifont=M+\ 1m:h13
	"set guifontwide=Hei_Regular:h13
elseif MySys() == "linux"
	set guifont=Monospace
endif

set anti
set linespace=2
set cursorline
set nu
set numberwidth=4
set equalalways
set guitablabel=%t

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" MacVim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if has("gui_macvim")

	"set columns=171
	"set lines=58
	"winpos 52 42

	let macvim_skip_cmd_opt_movement = 1
	let macvim_hig_shift_movement = 1

	set transparency=5
	set guioptions-=T "egmrt
	"set guioptions+=b

endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Autocmd
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Jumping to last cursor position
augroup vimrcEx
    au!
    au BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif
augroup END

au! BufWritePost vimrc source ~/.vimrc

"let g:jslint_neverAutoRun=1

if exists('+autochdir')
	set autochdir
else
	au BufEnter * silent! lcd %:p:h:gs/ /\\ /
endif

" filetype
au BufNewFile,BufRead *.js setf javascript
au BufNewFile,BufRead *.json setf json
au BufNewFile,BufRead *.scss setf scss.css
au BufNewFile,BufRead *.as	setf actionscript
au BufNewFile,BufRead *.xul setf xml
au BufNewFile,BufRead *.vm setf html
au BufNewFile,BufRead *.md setf markdown
au BufNewFile,BufRead *.csv,*.dat setf csv
au BufNewFile,BufRead *.ypac setf yaml
"au BufNewFile,BufRead *.json setf javascript
au BufNewFile,BufRead *.pac setf javascript


" language support
au FileType text setlocal wrap textwidth=80
au FileType javascript setlocal expandtab shiftwidth=4 tabstop=4 softtabstop=4 textwidth=80
au FileType css setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2
au FileType scss setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2
au FileType vim setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2
au FileType python setlocal expandtab shiftwidth=4 tabstop=4 softtabstop=4 textwidth=80
au FileType ruby setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2
au FileType rust setlocal expandtab shiftwidth=4 tabstop=4 softtabstop=4 textwidth=80
au FileType yaml setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2

" Enable omni completion.
au FileType css,scss,sass,less setlocal omnifunc=csscomplete#CompleteCSS
au FileType html setlocal omnifunc=htmlcomplete#CompleteTags
au FileType javascript setlocal omnifunc=nodejscomplete#CompleteJS
"au FileType javascript setlocal omnifunc=tern#CompleteJS
au FileType python setlocal omnifunc=pythoncomplete#Complete
au FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
au Filetype * if &omnifunc == "" |	setlocal omnifunc=syntaxcomplete#Complete |	endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Commands
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" sudo save
command! W :w ! sudo tee %

:command! -nargs=+ SuperRetab call SuperRetab(<f-args>)

function! SuperRetab(p, n)
    execute 'setl et! ts='.a:p.' sw='.a:p.' sts='.a:p
    retab!
    execute 'setl et ts='.a:n.' sw='.a:n.' sts='.a:n
    retab
endfunction

" for make & debug

function! QFSwitch() " toggle quickfix window
	redir => ls_output
		execute ':silent! ls'
	redir END

	let exists = match(ls_output, "[Quickfix List")
	if exists == -1
		execute ':copen'
	else
		execute ':cclose'
	endif
endfunction

function! LLSwitch() " toggle location list window
	redir => ls_output
		execute ':silent! ls'
	redir END

	let exists = match(ls_output, "[Location List")
	if exists == -1
		execute ':lopen'
	else
		execute ':lclose'
	endif
endfunction

function! MyMake()
    if &buftype == 'quickfix'
        :q
    else
        exe 'call ' . b:myMake . '()'
	endif
endfunction

function! MyLint()
    if &buftype == 'quickfix'
        :q
    else
        exe 'call ' . b:myLint . '()'
	endif
endfunction

function! MySetBreakPoint()
	exe 'call ' . b:mySetBreakPoint . '()'
endfunction

function! MySetLog()
	exe 'call ' . b:mySetLog. '()'
endfunction

function! MyRemoveBreakPoint()
	exe 'call ' . b:myRemoveBreakPoint . '()'
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Macro
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"let @u = ""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Key mapping
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let mapleader=","
let g:mapleader=","

map <silent> <leader>rc :tabe ~/.vim/vimrc<cr>
map <leader>q :q<cr>

nnoremap <leader><space> :noh<cr>:set nocrb<cr>

nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <C-V> <C-w>v
nnoremap <C-S> <C-w>s

" for make & debug
"noremap <silent> <F1> <ESC>:call LLSwitch()<CR>
noremap <silent> <F3> <ESC>:call MyLint()<CR>
noremap <silent> <F4> :call MyMake()<CR>
noremap <silent> <F5> <ESC>:call QFSwitch()<CR>
noremap <silent> <F6> <ESC>:call LLSwitch()<CR>
noremap <silent> <F7> :call MySetBreakPoint()<CR>
noremap <silent> <F8> :call MySetLog()<CR>
noremap <silent> <F9> :call MyRemoveBreakPoint()<CR>

nmap <tab> 		v>
nmap <c-tab>  v>
nmap <s-tab> 	v<
vmap <tab> 		>gv
vmap <c-tab> 	>gv
vmap <s-tab> 	<gv

nnoremap / /\v
vnoremap / /\v

" map cmd to ctrl
if has("gui_macvim")
    map <D-H> <C-h>
    map <D-J> <C-j>
    map <D-K> <C-k>
    map <D-L> <C-l>
    map <D-V> <C-V>
    map <D-S> <C-S>
	imap <D-c> <C-c>	"快速结束插入模式
	map <D-y> <C-y>
	map <D-e> <C-e>
	map <D-f> <C-f>
	map <D-b> <C-b>
	map <D-u> <C-u>
	map <D-d> <C-d>
	map <D-w> <C-w>
	map <D-r> <C-r>
	map <D-o> <C-o>
	map <D-i> <C-i>
	map <D-g> <C-g>
	map <D-]> <C-]>
    map <D-p> <C-p>
	cmap <D-d> <C-d>
	imap <D-e> <C-e>
	imap <D-y> <C-y>
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plug settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" -------------------------------------------------------------
" Plug 'flazz/vim-colorschemes'
" https://github.com/flazz/vim-colorschemes
" -------------------------------------------------------------

" ==============================================================

" -------------------------------------------------------------
" Plug 'pangloss/vim-javascript'
" https://github.com/pangloss/vim-javascript
" alternative:
" * https://github.com/jelera/vim-javascript-syntax
" * https://github.com/othree/yajs.vim
" -------------------------------------------------------------
let g:javascript_enable_domhtmlcss = 0
let b:javascript_fold = 0

" -------------------------------------------------------------
" Plug 'othree/javascript-libraries-syntax.vim'
" https://github.com/othree/javascript-libraries-syntax.vim
" -------------------------------------------------------------
let g:used_javascript_libs = 'jquery,underscore,react,flux,jasmine,chai'

" -------------------------------------------------------------
" Plug 'elzr/vim-json'
" https://github.com/elzr/vim-json
" -------------------------------------------------------------

" -------------------------------------------------------------
" Plug 'othree/html5.vim'
" https://github.com/othree/html5.vim
" omnicomplete function, indent and syntax
" all new elements and attribute + all SVG elements 
"   + microdata + RDFa + WAI-ARIA
" -------------------------------------------------------------
let g:html5_event_handler_attributes_complete = 1
let g:html5_rdfa_attributes_complete = 1
let g:html5_microdata_attributes_complete = 1
let g:html5_aria_attributes_complete = 0

" -------------------------------------------------------------
" Plug 'JulesWang/css.vim'
" https://github.com/JulesWang/css.vim
" -------------------------------------------------------------

" -------------------------------------------------------------
" Plug 'hail2u/vim-css3-syntax'
" https://github.com/hail2u/vim-css3-syntax
" -------------------------------------------------------------

" -------------------------------------------------------------
" Plug 'cakebaker/scss-syntax.vim'
" https://github.com/cakebaker/scss-syntax.vim
" -------------------------------------------------------------

" -------------------------------------------------------------
" Plug 'mustache/vim-mustache-handlebars'
" https://github.com/mustache/vim-mustache-handlebars
" -------------------------------------------------------------
"let g:mustache_abbreviations = 1

" -------------------------------------------------------------
" Plug 'digitaltoad/vim-jade'
" https://github.com/digitaltoad/vim-jade
" -------------------------------------------------------------

" -------------------------------------------------------------
" Plug 'slim-template/vim-slim'
" https://github.com/slim-template/vim-slim
" -------------------------------------------------------------

" -------------------------------------------------------------
" Plug 'rust-lang/rust.vim'
" https://github.com/rust-lang/rust.vim
" -------------------------------------------------------------

" -------------------------------------------------------------
" Plug 'cespare/vim-toml'
" https://github.com/cespare/vim-toml
" -------------------------------------------------------------

" -------------------------------------------------------------
" Plug 'fatih/vim-go'
" https://github.com/fatih/vim-go
" TODO
" -------------------------------------------------------------

" -------------------------------------------------------------
" Plug 'dart-lang/dart-vim-plugin'
" https://github.com/dart-lang/dart-vim-plugin
" -------------------------------------------------------------

" -------------------------------------------------------------
" Plug 'tpope/vim-bundler'
" https://github.com/tpope/vim-bundler
" * :Bundle
" -------------------------------------------------------------

" -------------------------------------------------------------
" Plug 'plasticboy/vim-markdown'
" https://github.com/plasticboy/vim-markdown
" * gx - open link
" * ]] - go to next header
" * [[ - go to previous header 
" * :Toc - create a quickfix window navigable table of contents
" -------------------------------------------------------------
let g:vim_markdown_folding_disabled = 1

" -------------------------------------------------------------
" Plug 'chrisbra/csv.vim'
" https://github.com/chrisbra/csv.vim
" * :CSVHiColumn
" * :CSVTabulariz
" -------------------------------------------------------------
let g:csv_highlight_column = 'y'

" ==============================================================

" -------------------------------------------------------------
" Plug 'scrooloose/syntastic'
" https://github.com/scrooloose/syntastic
" -------------------------------------------------------------
"let g:syntastic_html_tidy_blocklevel_tags=['x-card', 'x-part', 'ck-card', 'ck-part']
"let g:syntastic_css_checkers = ['csslint']
"let g:syntastic_csslint_options = '--warnings=none --errors=box-model'
let g:syntastic_javascript_checkers = ['jshint']
let g:syntastic_python_checkers = ['flake8']
let g:syntastic_python_flake8_args = '--ignore="E401,E501"'
let g:syntastic_lisp_checkers = ['clisp']
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1

" -------------------------------------------------------------
" Plug 'Shutnik/jshint2.vim'
" https://github.com/Shutnik/jshint2.vim
" * :JSHint
" * <F3>
" -------------------------------------------------------------

" -------------------------------------------------------------
" Plug 'suan/vim-instant-markdown'
" https://github.com/suan/vim-instant-markdown
" npm -g install instant-markdown-d
" -------------------------------------------------------------
let g:instant_markdown_slow = 1
let g:instant_markdown_autostart = 0

" -------------------------------------------------------------
" Plug 'mattn/emmet-vim'
" https://github.com/mattn/emmet-vim
" https://raw.githubusercontent.com/mattn/emmet-vim/master/TUTORIAL
" in insert mode
" * <C-e>, - expand
" * <C-e>n - next edit point
" * <C-e>p - previous edit point
" * <C-e>k - remove a tag
" * <C-e>/ - toggle comment
" -------------------------------------------------------------
let g:user_emmet_leader_key='<C-e>'

" -------------------------------------------------------------
" Plug 'tpope/vim-rails'
" https://github.com/tpope/vim-rails
" TODO
" -------------------------------------------------------------

" -------------------------------------------------------------
" Plug 'paredit.vim'
" http://www.vim.org/scripts/script.php?script_id=3998
" https://github.com/vim-scripts/paredit.vim
" Paredit Mode - Structured Editing of Lisp S-expressions 
" TODO
" -------------------------------------------------------------

" -------------------------------------------------------------
" Plug 'kovisoft/slimv'
" https://github.com/kovisoft/slimv
" http://www.vim.org/scripts/script.php?script_id=2531
" Superior Lisp Interaction Mode for Vim
" TODO
" -------------------------------------------------------------
"let g:slimv_leader = ",l"
""let g:slimv_lisp = "ccl"
"let g:slimv_impl = 'ccl'
"let g:slimv_swank_cmd = '!osascript -e "tell application \"Terminal\" to do script \"ccl --load ~/.vim/slime/start-swank.lisp\""'

" -------------------------------------------------------------
" Plug 'jmcantrell/vim-virtualenv'
" https://github.com/jmcantrell/vim-virtualenv
" -------------------------------------------------------------

" ==============================================================

" -------------------------------------------------------------
" Plug 'IndentAnything'
" http://www.vim.org/scripts/script.php?script_id=1839
" -------------------------------------------------------------

" -------------------------------------------------------------
" Plug 'matchit.zip'
" http://www.vim.org/scripts/script.php?script_id=39
" configure % to match more than just single characters
" -------------------------------------------------------------
  
" -------------------------------------------------------------
" Plug 'delimitMate.vim'
" https://github.com/Raimondi/delimitMate
" automatic closing of quotes, parenthesis, brackets, etc.
" -------------------------------------------------------------

" -------------------------------------------------------------
" Plug 'ShowMarks7'
" http://www.vim.org/scripts/script.php?script_id=152
" http://www.vim.org/scripts/script.php?script_id=3615
" https://github.com/vim-scripts/ShowMarks7
" * <Leader>mt - Toggles ShowMarks on and off
" * <Leader>mh - Hides an individual mark
" * <Leader>ma - Hides all marks in the current buffer
" * <Leader>mm - Mark with the next available name
" -------------------------------------------------------------
if has("gui_running") || has("gui_macvim")
	let showmarks_include = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	let g:showmarks_enable = 1
	let showmarks_ignore_type = "hqm"
endif

" -------------------------------------------------------------
" Plug 'tpope/vim-repeat'
" https://github.com/tpope/vim-repeat
" Repeat.vim remaps . in a way that plugins can tap into it
" -------------------------------------------------------------

" ==============================================================

" -------------------------------------------------------------
" Plug 'Lokaltog/vim-easymotion'
" https://github.com/Lokaltog/vim-easymotion
" https://github.com/Lokaltog/vim-easymotion/blob/master/doc/easymotion.txt
" * <trigger>f/F - Find {char} to the right/left
" * <trigger>s - Find {char} forward and backward
" * <trigger>w/W
" * <trigger>b/B
" * <trigger>e/E
" * <trigger>j - line motion
" * <trigger>k - line motion
" -------------------------------------------------------------
nmap ; <Plug>(easymotion-prefix)
vmap ; <Plug>(easymotion-prefix)
let g:EasyMotion_smartcase = 1

" -------------------------------------------------------------
" Plug 'terryma/vim-expand-region'
" https://github.com/terryma/vim-expand-region
" -------------------------------------------------------------
vmap K <Plug>(expand_region_expand)
vmap J <Plug>(expand_region_shrink)

" ==============================================================

" -------------------------------------------------------------
" Plug 'godlygeek/tabular'
" https://github.com/godlygeek/tabular
" * :Tabularize /, - left align, left align
" * :Tabularize /,/r0  - right align, right align
" * :Tabularize /,/r1c1l0  - right align, left align
" -------------------------------------------------------------
map <leader>tab :Tabularize / = <cr>

" -------------------------------------------------------------
" Plug 'scrooloose/nerdcommenter'
" https://github.com/scrooloose/nerdcommenter
" http://www.vim.org/scripts/script.php?script_id=1218
" * <leader>nc
" * <leader>nl
" * <leader>nm
" * <leader>ns
" * <leader>nu
" -------------------------------------------------------------
let NERDCreateDefaultMappings=0
nmap <leader>n<space> <plug>NERDCommenterToggle
vmap <leader>n<space> <plug>NERDCommenterToggle
nmap <leader>nc <plug>NERDCommenterComment
vmap <leader>nc <plug>NERDCommenterComment
nmap <leader>nm <plug>NERDCommenterMinimal
vmap <leader>nm <plug>NERDCommenterMinimal
nmap <leader>ns <plug>NERDCommenterSexy
vmap <leader>ns <plug>NERDCommenterSexy
nmap <leader>nu <plug>NERDCommenterUncomment
vmap <leader>nu <plug>NERDCommenterUncomment
nmap <leader>nl <plug>NERDCommenterAlignLeft
vmap <leader>nl <plug>NERDCommenterAlignLeft
nmap <leader>nb <plug>NERDCommenterAlignBoth
vmap <leader>nb <plug>NERDCommenterAlignBoth
nmap <leader>nn <plug>NERDCommenterNest 
vmap <leader>nn <plug>NERDCommenterNest
nmap <leader>ni <plug>NERDCommenterInvert
vmap <leader>ni <plug>NERDCommenterInvert

" -------------------------------------------------------------
" Plug 'tpope/vim-surround'
" https://github.com/tpope/vim-surround
" * cs<old><new> - change
" * ds<old> - remove 
" * ysiw<new> - text object
" * yss<new> - entire line
" -------------------------------------------------------------

" ==============================================================

" -------------------------------------------------------------
" Plug 'bling/vim-airline'
" https://github.com/bling/vim-airline
" Plug 'powerline/powerline'
" https://github.com/powerline/powerline
" TODO
" -------------------------------------------------------------
let g:airline#extensions#tabline#enabled = 0
"let g:Powerline_symbols = 'compatible'
"let g:Powerline_symbols = 'fancy'

" -------------------------------------------------------------
" Plug 'nathanaelkane/vim-indent-guides'
" https://github.com/nathanaelkane/vim-indent-guides
" visually displaying indent levels
" -------------------------------------------------------------
let g:indent_guides_auto_colors = 0
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_start_level = 2
let g:indent_guides_guide_size = 1

" -------------------------------------------------------------
" Plug 'myusuf3/numbers.vim'
" https://github.com/myusuf3/numbers.vim
" intelligently toggling line numbers
" -------------------------------------------------------------

" -------------------------------------------------------------
" Plug 'justincampbell/vim-eighties'
" https://github.com/justincampbell/vim-eighties
" -------------------------------------------------------------
let g:eighties_enabled = 1
let g:eighties_minimum_width = 80
let g:eighties_extra_width = 0 " Increase this if you want some extra room
let g:eighties_compute = 1 " Disable this if you just want the minimum + extra

" ==============================================================

" netrw setting
let g:netrw_winsize = 30
"nmap <silent> <leader>fe :Sexplore!<cr>

" NERDTree setting
"let NERDTreeMinimalUI = 1
let g:NERDTreeWinSize = 20
nmap <silent> <leader>nt :call OpenNERDTree()<cr>

function! OpenNERDTree()
    let tmp = g:eighties_minimum_width
    let g:eighties_minimum_width = 20
    :NERDTree
    let g:eighties_minimum_width = tmp
endfunction

" FuzzyFinder setting
nmap <leader>fb :FufBuffer<cr>
nmap <leader>ff :FufFile<cr>
nmap <leader>fd :FufDir<cr>
nmap <leader>fa :FufBookmark<cr>
nmap <leader>fm :FufAddBookmark<cr>
nmap <leader>fc :FufChangeList<cr>
"noremap <silent> <C-]> :FufTagWithCursorWord!<CR>

" ctrl-p
let g:ctrlp_working_path_mode = 2 " .git/ .hg/ .svn/ .bzr/ _darcs/ or your own marker_dir/ marker_file
let g:ctrlp_map = '<C-p>'

" command-T
"nmap <leader>tt :CommandT<cr>
"if has("gui_macvim")
	"map <D-T> :CommandT<CR>
"endif

" Most Recently Used (MRU)
nmap <silent> <leader>r :MRU<cr>

" -------------------------------------------------------------
" Plug 'Shougo/unite.vim'
" https://github.com/Shougo/unite.vim
" * :Unite
" -------------------------------------------------------------
nmap <leader>u :Unite 

" bufExplorer setting
let g:bufExplorerSortBy='mru'
let g:bufExplorerSplitRight=0        " Split left.
let g:bufExplorerSplitVertical=1     " Split vertically.
let g:bufExplorerSplitVertSize = 30  " Split width
let g:bufExplorerUseCurrentWindow=1  " Open in new window.
let g:bufExplorerMaxHeight=25
let g:bufExplorerResize=1
"autocmd BufWinEnter \[Buf\ List\] setl nonumber
" 默认键映射 <leader>bv :VSBufExplorer

" ag.vim
nnoremap <leader>/ :Ag
let g:agprg="ag --column"

" ack.vim
"nnoremap <leader>/ :Ack
"let g:ackprg = 'ag --nogroup --nocolor --column'

" tagbar
let g:tagbar_width = 20
let g:tagbar_singleclick = 1
let g:tagbar_iconchars = ['▾', '▸']
nnoremap <leader>tb :TagbarToggle<CR>
"autocmd FileType * nested :call tagbar#autoopen(0)

" ==============================================================

" -------------------------------------------------------------
" Plug 'SirVer/ultisnips'
" https://github.com/SirVer/ultisnips
" -------------------------------------------------------------
"let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
let g:UltiSnipsSnippetDirectories=["ultisnips"]

" -------------------------------------------------------------
" Plug 'honza/vim-snippets'
" https://github.com/honza/vim-snippets
" ./ultisnips/
" -------------------------------------------------------------

" -------------------------------------------------------------
" Plug 'Valloric/YouCompleteMe'
" https://github.com/Valloric/YouCompleteMe
" trigger:
" * identifier completer - before g:ycm_semantic_triggers
" * semantic engine (omnifunc for js) - after g:ycm_semantic_triggers
" -------------------------------------------------------------
let g:ycm_filetype_blacklist = {
    \ 'tagbar' : 1,
    \ 'qf' : 1,
    \ 'notes' : 1,
    \ 'markdown' : 1,
    \ 'mkd' : 1,
    \ 'unite' : 1,
    \ 'text' : 1,
    \ 'vimwiki' : 1,
    \ 'pandoc' : 1,
    \ 'infolog' : 1,
    \ 'mail' : 1
\}
let g:ycm_min_num_of_chars_for_completion = 1
let g:ycm_min_num_identifier_candidate_chars = 0
let g:ycm_complete_in_comments = 1
let g:ycm_complete_in_strings = 1
let g:ycm_collect_identifiers_from_comments_and_strings = 0
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_autoclose_preview_window_after_insertion = 1
"let g:ycm_cache_omnifunc = 1
let g:ycm_key_invoke_completion = '<C-Space>'
let g:ycm_key_list_select_completion = ['<Enter>', '<Down>']
let g:ycm_key_list_previous_completion = ['<S-Enter>', '<Up>']
let g:ycm_key_detailed_diagnostics = '<leader>yd'

" -------------------------------------------------------------
" Plug 'Shougo/neocomplcache.vim'
" https://github.com/Shougo/neocomplcache.vim
" https://github.com/Shougo/neocomplete.vim
" https://github.com/Shougo/neosnippet.vim
" https://github.com/Shougo/neosnippet-snippets
" -------------------------------------------------------------
"let g:acp_enableAtStartup = 0
"let g:neocomplcache_enable_at_startup = 1
"let g:neocomplcache_enable_smart_case = 1
"let g:neocomplcache_min_syntax_length = 1
"let g:neocomplcache_auto_completion_start_length = 1
"let g:neocomplcache_manual_completion_start_length = 0
"let g:neocomplcache_max_list = 20

"" key-mappings
"inoremap <expr><C-g> neocomplcache#undo_completion()
"inoremap <expr><C-l> neocomplcache#complete_common_string()
"inoremap <expr><C-h> neocomplcache#smart_close_popup()."\<C-h>"
"inoremap <expr><C-y> neocomplcache#close_popup()
"inoremap <expr><C-e> neocomplcache#cancel_popup()

""inoremap <expr><Space> pumvisible() ? "\<c-y>" : "\<Space>"
"inoremap <expr><Esc> pumvisible() ? "\<c-y>" : "\<Esc>"
"inoremap <expr><Enter> pumvisible() ? "\<c-n>" : "\<Enter>"
"inoremap <expr><s-Enter> pumvisible() ? "\<c-p>" : "\<s-Enter>"
""imap <expr><tab>  pumvisible() ? "\<c-n>" : "\<TAB>"
""imap <expr><s-tab>  pumvisible() ? "\<c-p>" : "\<s-TAB>"

" -------------------------------------------------------------
" Plug 'SyntaxComplete'
" http://www.vim.org/scripts/script.php?script_id=3172
" https://github.com/vim-scripts/SyntaxComplete
" -------------------------------------------------------------

" -------------------------------------------------------------
" Plug 'SQLComplete.vim'
" http://www.vim.org/scripts/script.php?script_id=1572
" https://github.com/vim-scripts/SQLComplete.vim
" -------------------------------------------------------------
"let g:sql_type_default = 'mysql'
"let g:ftplugin_sql_omni_key = '<C-C>'

" -------------------------------------------------------------
" Plug 'https://bitbucket.org/teramako/jscomplete-vim.git'
" https://bitbucket.org/teramako/jscomplete-vim
" -------------------------------------------------------------
let g:jscomplete_use = ['dom', 'es6th']

" -------------------------------------------------------------
" Plug 'myhere/vim-nodejs-complete'
" https://github.com/myhere/vim-nodejs-complete
" js_compl_fn:
" * javascriptcomplete#CompleteJS
" * syntaxcomplete#Complete
" * jscomplete#CompleteJS
" -------------------------------------------------------------
let g:nodejs_complete_config = {
\  'js_compl_fn': 'jscomplete#CompleteJS',
\  'max_node_compl_len': 15
\}

" -------------------------------------------------------------
" Plug 'marijnh/tern_for_vim'
" https://github.com/marijnh/tern_for_vim
" -------------------------------------------------------------
nnoremap <leader>td :TernDef<cr>
nnoremap <leader>tr :TernRefs<cr>

" ==============================================================

" session
let g:session_autoload = 'no'
nnoremap <leader>ss :SaveSession
nnoremap <leader>so :OpenSession
nnoremap <leader>sd :DeleteSession
nnoremap <leader>sc :CloseSession<cr>
nnoremap <leader>sv :ViewSession<cr>

" QuickRun
let g:quickrun_no_default_key_mappings = 1
silent! map <unique> <Leader>R <Plug>(quickrun)

" Gundo
noremap <silent> <F2> <ESC>:GundoToggle<CR>

" ==============================================================

" -------------------------------------------------------------
" Plug 'airblade/vim-gitgutter'
" https://github.com/airblade/vim-gitgutter
" -------------------------------------------------------------
let g:gitgutter_max_signs = 5000
let g:gitgutter_realtime = 0
"let g:gitgutter_eager = 0

" VCSCommand
let VCSCommandSVKExec='disabled no such executable'
nmap <leader>cd :VCSVimDiff

" fugitive
autocmd BufReadPost fugitive://* set bufhidden=delete

" ==============================================================

" tasklist
nmap <silent> <leader>tl <Plug>TaskList

"
nnoremap <leader><tab> :Sscratch<cr>

"
let g:calendar_diary = '~/.vim/diary'
