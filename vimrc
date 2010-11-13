"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer: Dexter.Yy <dexter.yy at gmail.com>
" Last Change: $LastChangedDate$ $Rev$
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" default
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible
set history=400
if has('mouse')
  set mouse=a
endif
set backspace=indent,eol,start
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching

map Q gq
inoremap <C-U> <C-G>u<C-U>

if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

if has("autocmd")
  filetype plugin indent on
  augroup vimrcEx
  au!
  autocmd FileType text setlocal textwidth=78
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif
  augroup END
else
  set autoindent		" always set autoindenting on
endif " has("autocmd")

if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

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

" Move Backup Files to ~/.vim/backups/
set backupdir=~/.vim/backups
set dir=~/.vim/backups
set nobackup 
"set nowritebackup 

set undodir=~/.vim/undos
set undofile

set shiftwidth=4
set tabstop=4
set nowrap
set wildmenu
set matchpairs=(:),{:},[:],<:>
set whichwrap=b,s,<,>,[,]
set foldmethod=indent
set diffopt+=iwhite,vertical " 忽略缩进的差异
"set cursorbind
set gdefault

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if has("gui_running") || has("gui_macvim")
	colorscheme yytextmate
	let g:colors_name="yytextmate"
else
	colorscheme slate
endif

if MySys() == "mac"
	set guifont=TextMate_Regular:h13
	set guifontwide=Hei_Regular:h13
elseif MySys() == "linux"
	set guifont=Monospace
endif

set anti
set linespace=2 
set cursorline
"set number
set rnu
set numberwidth=4
set equalalways
set guitablabel=%t

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" filetype and syntax
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:javascript_enable_domhtmlcss=1
let g:xml_use_xhtml = 1 "for xml.vim

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" MacVim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if has("gui_macvim")

	set columns=171
	set lines=58
	winpos 52 42 

	let macvim_skip_cmd_opt_movement = 1
	let macvim_hig_shift_movement = 1

	set transparency=9
	set guioptions-=T "egmrt
	"set guioptions+=b 
	
	macm File.New\ Tab						key=<D-T>
	macm File.Save<Tab>:w					key=<D-s>
	macm File.Save\ As\.\.\.<Tab>:sav		key=<D-S>
	macm Edit.Undo<Tab>u					key=<D-z> action=undo:
	macm Edit.Redo<Tab>^R					key=<D-Z> action=redo:
	macm Edit.Cut<Tab>"+x					key=<D-x> action=cut:
	macm Edit.Copy<Tab>"+y					key=<D-c> action=copy:
	macm Edit.Paste<Tab>"+gP				key=<D-v> action=paste:
	macm Edit.Select\ All<Tab>ggVG			key=<D-A> action=selectAll:
	macm Window.Toggle\ Full\ Screen\ Mode	key=<D-F>
	macm Window.Select\ Next\ Tab			key=<D-}>
	macm Window.Select\ Previous\ Tab		key=<D-{>
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" autocmd
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

autocmd! bufwritepost .vimrc source ~/.vimrc
autocmd! bufwritepost vimrc source ~/.vimrc

let g:jslint_neverAutoRun=1

autocmd BufEnter * lcd %:p:h

" filetype
autocmd BufNewFile,BufRead *.vm setlocal ft=html
autocmd BufNewFile,BufRead *.xul setlocal ft=xml
autocmd BufNewFile,BufRead *.as	setlocal ft=actionscript
autocmd BufNewFile,BufRead *.json setlocal ft=javascript
autocmd BufNewFile,BufRead *.pac setlocal ft=javascript
autocmd BufNewFile,BufRead *.ypac setlocal ft=yaml


" language support
autocmd FileType python setlocal expandtab shiftwidth=4 tabstop=4 softtabstop=4 textwidth=79
autocmd FileType ruby setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType yaml setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2

" for AutoComplPop
"autocmd FileType html setlocal omnifunc=htmlcomplete#CompleteTags
"autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
"autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" commands
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" sudo save
command W :w! /tmp/sudoSave \| let $fileToSave=expand('%') \| let $fileToSaveBackup=expand('%').'~' \| !sudo cp $fileToSave $fileToSaveBackup && sudo cp /tmp/sudoSave $fileToSave<CR><ESC>:e!<CR>


function! GetMySession(spath, ssname)
	if a:ssname == 0
		let a:sname = ""
	else
		let a:sname = "-".a:ssname
	endif
	execute "source $".a:spath."/session".a:sname.".vim"
	execute "rviminfo $".a:spath."/session".a:sname.".viminfo"
	execute "echo \"Load Success\: $".a:spath."/session".a:sname.".vim\""
endfunction

function! SetMySession(spath, ssname)
	if a:ssname == 0
		let a:sname = ""
	else
		let a:sname = "-".a:ssname
	endif
	execute "cd $".a:spath
	execute "mksession! $".a:spath."/session".a:sname.".vim"
	execute "wviminfo! $".a:spath."/session".a:sname.".viminfo"
	execute "echo \"Save Success\: $".a:spath."/session".a:sname.".vim\""
endfunction
" load session from path
command! -nargs=+ LOAD call GetMySession(<f-args>) 
" save session
command! -nargs=+ SAVE call SetMySession(<f-args>) 


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

function! MyMake()
	exe 'call ' . b:myMake . '()'
endfunction

function! MyLint()
	exe 'call ' . b:myLint . '()'
endfunction

function! MyDebug()
	exe 'call ' . b:myDebug . '()'
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
" macro
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" $static.getURL to uidev.tudou.com
let @u = "0y$opk,n j0f$df'ihttp://uidev.tudou.comf'xx"
" copy current file to uidev.tudou.com
let @p = ":!cp % /Volumes/ui.tudou.com/%:p:h:h:t/%:p:h:t/"

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" map
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let mapleader=","
let g:mapleader=","

"map <leader>, ,

map <silent> <leader>rc :tabe ~/.vim/vimrc<cr>
map <leader>q :q<cr>

nnoremap <leader><space> :noh<cr>

nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
map <D-H> <C-h>
map <D-J> <C-j>
map <D-K> <C-k>
map <D-L> <C-l>

nnoremap <D-V> <C-w>v

" for YankRing
map <D-p> <C-p>

nnoremap <leader><tab> :Sscratch<cr>



" for make & debug
noremap <silent> <F2> <ESC>:call MyLint()<CR>
noremap <silent> <F3> :call MyDebug()<CR>
noremap <silent> <F4> :call MyMake()<CR>
noremap <silent> <F5> <ESC>:call QFSwitch()<CR>
noremap <silent> <F6> :call MySetBreakPoint()<CR>
noremap <silent> <F7> :call MySetLog()<CR>
noremap <silent> <F8> :call MyRemoveBreakPoint()<CR>


nmap <tab> 		v>
nmap <s-tab> 	v<
vmap <tab> 		>gv 
vmap <s-tab> 	<gv

nnoremap / /\v
vnoremap / /\v

inoremap ( ()<ESC>i
"inoremap ) <c-r>=ClosePair(')')<cr>
inoremap { {}<ESC>i
"inoremap } <c-r>=ClosePair('}')<cr>
inoremap [ []<ESC>i
"inoremap ] <c-r>=ClosePair(']')<cr>
inoremap " ""<ESC>i
"inoremap < <><esc>i
"inoremap > <c-r>=ClosePair('>')<cr>

"inoremap <expr><CR> StructStart() ? '<CR><ESC>kA<CR>' : '<CR>'

" map cmd to ctrl
if has("gui_macvim")
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
	cmap <D-d> <C-d>
	imap <D-e> <C-e>
	imap <D-y> <C-y>
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" plugin setting
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:JSLintHighlightErrorLine = 0

let g:yankring_history_dir = '~/.vim/yankring'

let g:ragtag_global_maps = 1

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
"

" tasklist
nmap <silent> <leader>tl <Plug>TaskList


" taglists setting
nmap <silent> <leader>tg :TlistToggle<CR>
"let Tlist_Use_SingleClick=1
"Tlist_Process_File_Always=1
let Tlist_File_Fold_Auto_Close=1
let Tlist_Exit_OnlyWindow = 1
let Tlist_Show_Menu=1
let Tlist_GainFocus_On_ToggleOpen=1
let Tlist_Close_OnSelect=1
let Tlist_Compact_Format=1
let Tlist_Use_Right_Window = 1
let Tlist_WinWidth = 30
let Tlist_Inc_Winwidth = 0

let g:tlist_javascript_settings = 'javascript;f:function;c:class;o:object;m:method;s:string;a:array;n:constant'

" winManager setting
"let g:winManagerWindowLayout="BufExplorer,FileExplorer|taglist" 
"let g:winManagerWidth = 30
"let g:defaultExplorer = 0
"nmap <silent> <leader>wm :WMToggle<cr> 

" netrw setting
let g:netrw_winsize = 30
"nmap <silent> <leader>fe :Sexplore!<cr>

" NERDTree setting
nmap <silent> <leader>nt :NERDTree<cr>

" Most Recently Used (MRU)
nmap <silent> <leader>r :MRU<cr>

" FuzzyFinder setting
nmap <leader>fb :FufBuffer<cr>
nmap <leader>ff :FufFile<cr>
nmap <leader>fd :FufDir<cr>
nmap <leader>fa :FufBookmark<cr>
nmap <leader>fm :FufAddBookmark<cr>
nmap <leader>fc :FufChangeList<cr>
"noremap <silent> <C-]> :FufTagWithCursorWord!<CR>


nnoremap <silent> <leader>yr :YRShow<cr>
inoremap <silent> <leader>yr <ESC>:YRShow<cr>



" command-T
"nmap <leader>tt :CommandT<cr>
if has("gui_macvim")
	map <D-t> :CommandT<CR>
endif

" showmarks
if has("gui_running") || has("gui_macvim")
	let showmarks_include = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	let g:showmarks_enable = 1
	let showmarks_ignore_type = "hqm"
endif
"<Leader>mt   - 打开/关闭ShowMarks插件
"<Leader>mo   - 强制打开ShowMarks插件
"<Leader>mh   - 清除当前行的标记
"<Leader>ma   - 清除当前缓冲区中所有的标记
"<Leader>mm   - 在当前行打一个标记，使用下一个可用的标记名



"let NERDCreateDefaultMappings=0
let NERDShutUp=1
let g:NERDCommenterLeader="<leader>n" " change NERD_commenter.vim

let VCSCommandSVKExec='disabled no such executable'
nmap <leader>cd :VCSVimDiff

" Disable AutoComplPop. 
let g:acp_enableAtStartup = 0 
" Use neocomplcache. 
let g:neocomplcache_enable_at_startup = 1 
" Use smartcase. 
let g:neocomplcache_enable_smart_case = 1 
" Use camel case completion. 
let g:neocomplcache_enable_camel_case_completion = 1 
" Use underbar completion. 
let g:neocomplcache_enable_underbar_completion = 1 
" Set minimum syntax keyword length. 
let g:neocomplcache_min_syntax_length = 3 
let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*' 
"

"imap <expr><Esc> pumvisible() ? "<c-y>" : "<Esc>"

"imap <expr><Enter> pumvisible() ? "<c-n>" : "<Enter>"
"imap <expr><s-Enter> pumvisible() ? "<c-p>" : "<s-Enter>"
"smap <expr><Enter> pumvisible() ? "<c-n>" : "<Enter>"
"smap <expr><s-Enter> pumvisible() ? "<c-p>" : "<s-Enter>"

" AutoComplPop like behavior. 
"let g:neocomplcache_enable_auto_select = 1 


" supertab
"let g:SuperTabDefaultCompletionType = '<C-X><C-U>'


let g:calendar_diary = '~/.vim/diary'


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function Send_to_Screen(text)
  if !exists("g:screen_sessionname") || !exists("g:screen_windowname")
    call Screen_Vars()
  end

  echo system("screen -S " . g:screen_sessionname . " -p " . g:screen_windowname . " -X stuff '" . substitute(a:text, "'", "'\\\\''", 'g') . "'")
endfunction

function Screen_Session_Names(A,L,P)
  return system("screen -ls | awk '/Attached/ {print $1}'")
endfunction

function Screen_Vars()
  if !exists("g:screen_sessionname") || !exists("g:screen_windowname")
    let g:screen_sessionname = ""
    let g:screen_windowname = "0"
  end

  let g:screen_sessionname = input("session name: ", "", "custom,Screen_Session_Names")
  let g:screen_windowname = input("window name: ", g:screen_windowname)
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

vmap <C-c><C-c> "ry :call Send_to_Screen(@r)<CR>
nmap <C-c><C-c> vip<C-c><C-c>

nmap <C-c>v :call Screen_Vars()<CR>


