"=============================================================================
" FILE: neocomplcache.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 29 Aug 2012.
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
" Version: 7.1, for Vim 7.2
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

scriptencoding utf-8

function! s:initialize_variables()"{{{
  let s:is_enabled = 1
  let s:complfunc_sources = {}
  let s:plugin_sources = {}
  let s:ftplugin_sources = {}
  let s:loaded_ftplugin_sources = {}
  let s:sources_lock = {}
  let s:cur_keyword_str = ''
  let s:complete_words = []
  let s:complete_results = {}
  let s:cur_text = ''
  let s:old_cur_text = ''
  let s:moved_cur_text = ''
  let s:changedtick = b:changedtick
  let s:is_text_mode = 0
  let s:within_comment = 0
  let s:skip_next_complete = 0
  let s:is_prefetch = 0
  let s:use_sources = {}
  let s:update_time_save = &updatetime
  let s:filetype_frequencies = {}
  let s:cur_keyword_pos = -1
endfunction"}}}

if !exists('s:is_enabled')
  let s:is_enabled = 0
  call s:initialize_variables()
endif

function! neocomplcache#enable() "{{{
  " Auto commands."{{{
  augroup neocomplcache
    autocmd!
    autocmd InsertLeave * call s:on_insert_leave()
    autocmd CursorMovedI * call s:on_moved_i()
  augroup END

  if g:neocomplcache_enable_insert_char_pre
        \ && (v:version > 703 || v:version == 703 && has('patch418'))
    autocmd neocomplcache InsertCharPre *
          \ call s:do_auto_complete('InsertCharPre')
  elseif g:neocomplcache_enable_cursor_hold_i
    augroup neocomplcache
      autocmd CursorHoldI *
            \ call s:do_auto_complete('CursorHoldI')
      autocmd InsertEnter *
            \ call s:change_update_time()
      autocmd InsertLeave *
            \ call s:restore_update_time()
    augroup END
  else
    autocmd neocomplcache CursorMovedI *
          \ call s:do_auto_complete('CursorMovedI')
  endif

  if (v:version > 703 || v:version == 703 && has('patch598'))
    autocmd neocomplcache CompleteDone *
          \ call s:on_complete_done()
  endif
  "}}}

  call s:initialize_variables()

  " Initialize sources table."{{{
  " Search autoload.
  for file in split(globpath(&runtimepath, 'autoload/neocomplcache/sources/*.vim'), '\n')
    let source_name = fnamemodify(file, ':t:r')
    if !has_key(s:plugin_sources, source_name)
          \ && neocomplcache#is_source_enabled(source_name)
      let source = call('neocomplcache#sources#' . source_name . '#define', [])
      if empty(source)
        " Ignore.
      elseif source.kind ==# 'complfunc'
        let s:complfunc_sources[source_name] = source
      elseif source.kind ==# 'ftplugin'
        let s:ftplugin_sources[source_name] = source

        " Clear loaded flag.
        let s:ftplugin_sources[source_name].loaded = 0
      elseif source.kind ==# 'plugin'
            \ && neocomplcache#is_source_enabled('keyword_complete')
        let s:plugin_sources[source_name] = source
      endif
    endif
  endfor
  "}}}

  " Initialize keyword patterns."{{{
  if !exists('g:neocomplcache_keyword_patterns')
    let g:neocomplcache_keyword_patterns = {}
  endif
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'default',
        \'\k\+')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'lisp,scheme,clojure,int-gosh,int-clisp,int-clj',
        \'[[:alpha:]+*/@$_=.!?-][[:alnum:]+*/@$_:=.!?-]*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'ruby,int-irb',
        \'^=\%(b\%[egin]\|e\%[nd]\)\|\%(@@\|[:$@]\)\h\w*\|\h\w*\%(::\w*\)*[!?]\?')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'php,int-php',
        \'</\?\%(\h[[:alnum:]_-]*\s*\)\?\%(/\?>\)\?\|\$\h\w*\|\h\w*\%(\%(\\\|::\)\w*\)*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'perl,int-perlsh',
        \'<\h\w*>\?\|[$@%&*]\h\w*\|\h\w*\%(::\w*\)*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'perl6,int-perl6',
        \'<\h\w*>\?\|[$@%&][!.*?]\?\h[[:alnum:]_-]*\|\h[[:alnum:]_-]*\%(::[[:alnum:]_-]*\)*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'pir',
        \'[$@%.=]\?\h\w*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'pasm',
        \'[=]\?\h\w*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'vim,help',
        \'-\h[[:alnum:]-]*=\?\|\c\[:\%(\h\w*:\]\)\?\|&\h[[:alnum:]_:]*\|'
        \'<SID>\%(\h\w*\)\?\|<Plug>([^)]*)\?\|<\h[[:alnum:]_-]*>\?\|\h[[:alnum:]_:#]*!\?\|$\h\w*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'tex',
        \'\\\a{\a\{1,2}}\|\\[[:alpha:]@][[:alnum:]@]*\%({\%([[:alnum:]:_]\+\*\?}\?\)\?\)\?\|\a[[:alnum:]:_]*\*\?')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'sh,zsh,int-zsh,int-bash,int-sh',
        \'\$\w\+\|[[:alpha:]_.-][[:alnum:]_.-]*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'vimshell',
        \'\$\$\?\w*\|[[:alpha:]_.\\/~-][[:alnum:]_.\\/~-]*\|\d\+\%(\.\d\+\)\+')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'ps1,int-powershell',
        \'\[\h\%([[:alnum:]_.]*\]::\)\?\|[$%@.]\?[[:alpha:]_.:-][[:alnum:]_.:-]*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'c',
        \'^\s*#\s*\h\w*\|\h\w*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'cpp',
        \'^\s*#\s*\h\w*\|\h\w*\%(::\w*\)*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'objc',
        \'^\s*#\s*\h\w*\|\h\w*\|@\h\w*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'objcpp',
        \'^\s*#\s*\h\w*\|\h\w*\%(::\w*\)*\|@\h\w*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'objj',
        \'\h\w*\|@\h\w*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'d',
        \'\h\w*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'python,int-python,int-ipython',
        \'[@]\?\h\w*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'cs',
        \'\h\w*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'java',
        \'[@]\?\h\w*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'javascript,actionscript,int-js,int-kjs,int-rhino',
        \'\h\w*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'coffee,int-coffee',
        \'[@]\?\h\w*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'awk',
        \'\h\w*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'haskell,int-ghci',
        \'\%(\u\w*\.\)\+[[:alnum:]_'']*\|[[:alpha:]_''][[:alnum:]_'']*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'ml,ocaml,int-ocaml,int-sml,int-smlsharp',
        \'[''`#.]\?\h[[:alnum:]_'']*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'erlang,int-erl',
        \'^\s*-\h\w*\|\%(\h\w*:\)*\h\w\|\h[[:alnum:]_@]*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'html,xhtml,xml,markdown,eruby',
        \'</\?\%([[:alnum:]_:-]\+\s*\)\?\%(/\?>\)\?\|&\h\%(\w*;\)\?\|\h[[:alnum:]_-]*="\%([^"]*"\?\)\?\|\h[[:alnum:]_:-]*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'css,stylus',
        \'[@#.]\?[[:alpha:]_:-][[:alnum:]_:-]*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'tags',
        \'^[^!][^/[:blank:]]*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'pic',
        \'^\s*#\h\w*\|\h\w*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'arm',
        \'\h\w*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'asmh8300',
        \'[[:alpha:]_.][[:alnum:]_.]*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'masm',
        \'\.\h\w*\|[[:alpha:]_@?$][[:alnum:]_@?$]*\|\h\w*:\h\w*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'nasm',
        \'^\s*\[\h\w*\|[%.]\?\h\w*\|\%(\.\.@\?\|%[%$!]\)\%(\h\w*\)\?\|\h\w*:\h\w*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'asm',
        \'[%$.]\?\h\w*\%(\$\h\w*\)\?')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'gas',
        \'[$.]\?\h\w*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'gdb,int-gdb',
        \'$\h\w*\|[[:alnum:]:._-]\+')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'make',
        \'[[:alpha:]_.-][[:alnum:]_.-]*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'scala,int-scala',
        \'\h\w*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'int-termtter',
        \'\h[[:alnum:]_/-]*\|\$\a\+\|#\h\w*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'int-earthquake',
        \'[:#$]\h\w*\|\h[[:alnum:]_/-]*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'dosbatch,int-cmdproxy',
        \'\$\w+\|[[:alpha:]_./-][[:alnum:]_.-]*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'vb',
        \'\h\w*\|#\h\w*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'lua',
        \'\h\w*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \ 'zimbu',
        \'\h\w*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'konoha',
        \'[*$@%]\h\w*\|\h\w*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'cobol',
        \'\a[[:alnum:]-]*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'coq',
        \'\h[[:alnum:]_'']*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'tcl',
        \'[.-]\h\w*\|\h\w*')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_keyword_patterns,
        \'nyaos,int-nyaos',
        \'\h\w*')
  "}}}

  " Initialize next keyword patterns."{{{
  if !exists('g:neocomplcache_next_keyword_patterns')
    let g:neocomplcache_next_keyword_patterns = {}
  endif
  call neocomplcache#set_dictionary_helper(g:neocomplcache_next_keyword_patterns, 'perl',
        \'\h\w*>')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_next_keyword_patterns, 'perl6',
        \'\h\w*>')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_next_keyword_patterns, 'vim,help',
        \'\w*()\?\|\w*:\]\|[[:alnum:]_-]*[)>=]')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_next_keyword_patterns, 'python',
        \'\w*()\?')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_next_keyword_patterns, 'tex',
        \'[[:alnum:]:_]\+[*[{}]')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_next_keyword_patterns, 'html,xhtml,xml,mkd',
        \'[[:alnum:]_:-]*>\|[^"]*"')
  "}}}

  " Initialize same file type lists."{{{
  if !exists('g:neocomplcache_same_filetype_lists')
    let g:neocomplcache_same_filetype_lists = {}
  endif
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists,
        \ 'c', 'cpp')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists,
        \ 'cpp', 'c')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists,
        \ 'erb', 'ruby,html,xhtml')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists,
        \ 'html,xml', 'xhtml')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists,
        \ 'html,xhtml', 'css,stylus')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists,
        \ 'stylus', 'css')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists,
        \ 'xhtml', 'html,xml')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists,
        \ 'help', 'vim')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists,
        \ 'tex', 'bib,plaintex')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists,
        \ 'plaintex', 'bib,tex')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists,
        \ 'lingr-say', 'lingr-messages,lingr-members')

  " Interactive filetypes.
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists,
        \ 'int-irb', 'ruby')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists,
        \ 'int-ghci,int-hugs', 'haskell')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists,
        \ 'int-python,int-ipython', 'python')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists,
        \ 'int-gosh', 'scheme')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists,
        \ 'int-clisp', 'lisp')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists,
        \ 'int-erl', 'erlang')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists,
        \ 'int-zsh', 'zsh')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists,
        \ 'int-bash', 'bash')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists,
        \ 'int-sh', 'sh')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists,
        \ 'int-cmdproxy', 'dosbatch')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists,
        \ 'int-powershell', 'powershell')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists,
        \ 'int-perlsh', 'perl')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists,
        \ 'int-perl6', 'perl6')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists,
        \ 'int-ocaml', 'ocaml')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists,
        \ 'int-clj', 'clojure')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists,
        \ 'int-sml,int-smlsharp', 'sml')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists,
        \ 'int-js,int-kjs,int-rhino', 'javascript')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists,
        \ 'int-coffee', 'coffee')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists,
        \ 'int-gdb', 'gdb')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists,
        \ 'int-scala', 'scala')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists,
        \ 'int-nyaos', 'nyaos')
  call neocomplcache#set_dictionary_helper(g:neocomplcache_same_filetype_lists,
        \ 'int-php', 'php')
  "}}}

  " Initialize context filetype lists."{{{
  if exists('g:neocomplcache_filetype_include_lists')
    let g:neocomplcache_context_filetype_lists =
          \ g:neocomplcache_filetype_include_lists
  endif
  if !exists('g:neocomplcache_context_filetype_lists')
    let g:neocomplcache_context_filetype_lists = {}
  endif
  call neocomplcache#set_dictionary_helper(g:neocomplcache_context_filetype_lists,
        \ 'c,cpp', [
        \ {'filetype' : 'masm', 'start' : '_*asm_*\s\+\h\w*', 'end' : '$'},
        \ {'filetype' : 'masm', 'start' : '_*asm_*\s*\%(\n\s*\)\?{', 'end' : '}'},
        \ {'filetype' : 'gas', 'start' : '_*asm_*\s*\%(_*volatile_*\s*\)\?(', 'end' : ');'},
        \])
  call neocomplcache#set_dictionary_helper(g:neocomplcache_context_filetype_lists,
        \ 'd', [
        \ {'filetype' : 'masm', 'start' : 'asm\s*\%(\n\s*\)\?{', 'end' : '}'},
        \])
  call neocomplcache#set_dictionary_helper(g:neocomplcache_context_filetype_lists,
        \ 'perl6', [
        \ {'filetype' : 'pir', 'start' : 'Q:PIR\s*{', 'end' : '}'},
        \])
  call neocomplcache#set_dictionary_helper(g:neocomplcache_context_filetype_lists,
        \ 'vimshell', [
        \ {'filetype' : 'vim', 'start' : 'vexe \([''"]\)', 'end' : '\\\@<!\1'},
        \ {'filetype' : 'vim', 'start' : ' :\w*', 'end' : '\n'},
        \ {'filetype' : 'vim', 'start' : ' vexe\s\+', 'end' : '\n'},
        \])
  call neocomplcache#set_dictionary_helper(g:neocomplcache_context_filetype_lists,
        \ 'eruby', [
        \ {'filetype' : 'ruby', 'start' : '<%[=#]\?', 'end' : '%>'},
        \])
  call neocomplcache#set_dictionary_helper(g:neocomplcache_context_filetype_lists,
        \ 'vim', [
        \ {'filetype' : 'python', 'start' : '^\s*python3\? <<\s*\(\h\w*\)', 'end' : '^\1'},
        \ {'filetype' : 'ruby', 'start' : '^\s*ruby <<\s*\(\h\w*\)', 'end' : '^\1'},
        \])
  call neocomplcache#set_dictionary_helper(g:neocomplcache_context_filetype_lists,
        \ 'html,xhtml', [
        \ {'filetype' : 'javascript', 'start' : '<script type="text/javascript">', 'end' : '</script>'},
        \ {'filetype' : 'css', 'start' : '<style type="text/css">', 'end' : '</style>'},
        \])
  call neocomplcache#set_dictionary_helper(g:neocomplcache_context_filetype_lists,
        \ 'python', [
        \ {'filetype' : 'vim', 'start' : 'vim.command\s*(\([''"]\)', 'end' : '\\\@<!\1\s*)'},
        \ {'filetype' : 'vim', 'start' : 'vim.eval\s*(\([''"]\)', 'end' : '\\\@<!\1\s*)'},
        \])
  call neocomplcache#set_dictionary_helper(g:neocomplcache_context_filetype_lists,
        \ 'help', [
        \ {'filetype' : 'vim', 'start' : '^>', 'end' : '^<'},
        \])
  call neocomplcache#set_dictionary_helper(g:neocomplcache_context_filetype_lists,
        \ 'nyaos,int-nyaos', [
        \ {'filetype' : 'lua', 'start' : '\<lua_e\s\+\(["'']\)', 'end' : '^\1'},
        \])
  "}}}

  " Initialize delimiter patterns."{{{
  if !exists('g:neocomplcache_delimiter_patterns')
    let g:neocomplcache_delimiter_patterns = {}
  endif
  call neocomplcache#set_dictionary_helper(g:neocomplcache_delimiter_patterns,
        \ 'vim,help', ['#'])
  call neocomplcache#set_dictionary_helper(g:neocomplcache_delimiter_patterns,
        \ 'erlang,lisp,int-clisp', [':'])
  call neocomplcache#set_dictionary_helper(g:neocomplcache_delimiter_patterns,
        \ 'lisp,int-clisp', ['/', ':'])
  call neocomplcache#set_dictionary_helper(g:neocomplcache_delimiter_patterns,
        \ 'clojure,int-clj', ['/', '\.'])
  call neocomplcache#set_dictionary_helper(g:neocomplcache_delimiter_patterns,
        \ 'perl,cpp', ['::'])
  call neocomplcache#set_dictionary_helper(g:neocomplcache_delimiter_patterns,
        \ 'php', ['\', '::'])
  call neocomplcache#set_dictionary_helper(g:neocomplcache_delimiter_patterns,
        \ 'java,d,javascript,actionscript,ruby,eruby,haskell,int-ghci,coffee,zimbu,konoha',
        \ ['\.'])
  call neocomplcache#set_dictionary_helper(g:neocomplcache_delimiter_patterns,
        \ 'lua', ['\.', ':'])
  call neocomplcache#set_dictionary_helper(g:neocomplcache_delimiter_patterns,
        \ 'perl6', ['\.', '::'])
  "}}}

  " Initialize ctags arguments."{{{
  if !exists('g:neocomplcache_ctags_arguments_list')
    let g:neocomplcache_ctags_arguments_list = {}
  endif
  call neocomplcache#set_dictionary_helper(
        \ g:neocomplcache_ctags_arguments_list, 'default', '')
  call neocomplcache#set_dictionary_helper(
        \ g:neocomplcache_ctags_arguments_list, 'vim',
        \"--extra=fq --fields=afmiKlnsStz --regex-vim='/function!? ([a-z#:_0-9A-Z]+)/\\1/function/'")
  if neocomplcache#util#is_mac()
    call neocomplcache#set_dictionary_helper(
          \ g:neocomplcache_ctags_arguments_list, 'c',
          \'--c-kinds=+p --fields=+iaS --extra=+q -I__DARWIN_ALIAS,__DARWIN_ALIAS_C,__DARWIN_ALIAS_I,__DARWIN_INODE64
          \ -I__DARWIN_1050,__DARWIN_1050ALIAS,__DARWIN_1050ALIAS_C,__DARWIN_1050ALIAS_I,__DARWIN_1050INODE64
          \ -I__DARWIN_EXTSN,__DARWIN_EXTSN_C
          \ -I__DARWIN_LDBL_COMPAT,__DARWIN_LDBL_COMPAT2')
  else
    call neocomplcache#set_dictionary_helper(
          \ g:neocomplcache_ctags_arguments_list, 'c',
          \'-R --sort=1 --c-kinds=+p --fields=+iaS --extra=+q -I __wur')
  endif
  call neocomplcache#set_dictionary_helper(
        \ g:neocomplcache_ctags_arguments_list, 'cpp',
        \'-R --sort=1 --c++-kinds=+p --fields=+iaS --extra=+q -I __wur --language-force=C++')
  "}}}

  " Initialize text mode filetypes."{{{
  if !exists('g:neocomplcache_text_mode_filetypes')
    let g:neocomplcache_text_mode_filetypes = {}
  endif
  call neocomplcache#set_dictionary_helper(
        \ g:neocomplcache_text_mode_filetypes,
        \ 'text,help,tex,gitcommit,vcs-commit', 1)
  "}}}

  " Initialize tags filter patterns."{{{
  if !exists('g:neocomplcache_tags_filter_patterns')
    let g:neocomplcache_tags_filter_patterns = {}
  endif
  call neocomplcache#set_dictionary_helper(g:neocomplcache_tags_filter_patterns, 'c,cpp', 
        \'v:val.word !~ ''^[~_]''')
  "}}}

  " Initialize ignore composite filetypes
  if !exists('g:neocomplcache_ignore_composite_filetype_lists')
    let g:neocomplcache_ignore_composite_filetype_lists = {}
  endif

  " Add commands."{{{
  command! -nargs=? Neco call s:display_neco(<q-args>)
  command! -nargs=1 NeoComplCacheAutoCompletionLength
        \ call s:set_auto_completion_length(<args>)
  "}}}

  " Must g:neocomplcache_auto_completion_start_length > 1.
  if g:neocomplcache_auto_completion_start_length < 1
    let g:neocomplcache_auto_completion_start_length = 1
  endif
  " Must g:neocomplcache_min_keyword_length > 1.
  if g:neocomplcache_min_keyword_length < 1
    let g:neocomplcache_min_keyword_length = 1
  endif

  " Save options.
  let s:completefunc_save = &completefunc
  let s:completeopt_save = &completeopt

  " Set completefunc.
  let &completefunc = 'neocomplcache#manual_complete'
  let &l:completefunc = 'neocomplcache#manual_complete'

  " Set options.
  set completeopt-=menu
  set completeopt+=menuone

  " For auto complete keymappings.
  inoremap <expr><silent> <Plug>(neocomplcache_start_unite_complete)
        \ unite#sources#neocomplcache#start_complete()
  inoremap <expr><silent> <Plug>(neocomplcache_start_unite_quick_match)
        \ unite#sources#neocomplcache#start_quick_match()
  inoremap <expr><silent> <Plug>(neocomplcache_start_unite_snippet)
        \ unite#sources#snippet#start_complete()
  inoremap <silent> <Plug>(neocomplcache_start_auto_complete)
        \ <C-x><C-u><C-r>=neocomplcache#popup_post()<CR>
  inoremap <silent> <Plug>(neocomplcache_start_omni_complete)
        \ <C-x><C-o><C-r>=neocomplcache#popup_post()<CR>

  " Initialize.
  for source in values(neocomplcache#available_complfuncs())
    if has_key(source, 'initialize')
      call source.initialize()
    endif
  endfor
endfunction"}}}

function! neocomplcache#disable()"{{{
  if !neocomplcache#is_enabled()
    call neocomplcache#print_warning('neocomplcache is disabled! This command is ignored.')
    return
  endif

  let s:is_enabled = 0

  " Restore options.
  let &completefunc = s:completefunc_save
  let &completeopt = s:completeopt_save

  augroup neocomplcache
    autocmd!
  augroup END

  delcommand NeoComplCacheDisable
  delcommand Neco
  delcommand NeoComplCacheAutoCompletionLength

  for source in values(neocomplcache#available_complfuncs())
    if has_key(source, 'finalize')
      call source.finalize()
    endif
  endfor
  for source in values(neocomplcache#available_ftplugins())
    if source.loaded
      if has_key(source, 'finalize')
        call source.finalize()
      endif
    endif
  endfor
endfunction"}}}

function! neocomplcache#manual_complete(findstart, base)"{{{
  if a:findstart
    if !neocomplcache#is_enabled()
      let s:cur_keyword_str = ''
      let s:complete_words = []
      let s:is_prefetch = 0
      let &l:completefunc = 'neocomplcache#manual_complete'
      return (g:neocomplcache_enable_prefetch
            \ || g:neocomplcache_enable_insert_char_pre) ?
            \ -1 : -3
    endif

    " Get cur_keyword_pos.
    if s:is_prefetch && !empty(s:complete_results)
      " Use prefetch results.
    else
      let s:complete_results =
            \ neocomplcache#get_complete_results(s:get_cur_text())
    endif
    let cur_keyword_pos =
          \ neocomplcache#get_cur_keyword_pos(s:complete_results)

    if cur_keyword_pos < 0
      let s:cur_keyword_str = ''
      let s:complete_words = []
      let s:is_prefetch = 0
      let s:complete_results = {}
      return g:neocomplcache_enable_prefetch ? -1 : -3
    endif

    return cur_keyword_pos
  endif

  let cur_keyword_pos = neocomplcache#get_cur_keyword_pos(s:complete_results)
  let s:complete_words = neocomplcache#get_complete_words(
          \ s:complete_results, cur_keyword_pos, a:base)
  let s:cur_keyword_str = a:base
  let s:is_prefetch = 0

  if v:version > 703 || v:version == 703 && has('patch418')
    let dict = { 'words' : s:complete_words }

    if len(s:complete_words) >= g:neocomplcache_max_list
          \ && (g:neocomplcache_enable_cursor_hold_i
          \ || v:version > 703 || v:version == 703 && has('patch561'))
      " Note: If Vim is less than 7.3.561, it have broken register "." problem.
      let dict.refresh = 'always'
    endif
    return dict
  else
    return s:complete_words
  endif
endfunction"}}}

function! neocomplcache#sources_manual_complete(findstart, base)"{{{
  if a:findstart
    if !neocomplcache#is_enabled()
      let s:cur_keyword_str = ''
      let s:complete_words = []
      return -2
    endif

    " Get cur_keyword_pos.
    let complete_results = neocomplcache#get_complete_results(
          \ s:get_cur_text(), s:use_sources)
    let s:cur_keyword_pos =
          \ neocomplcache#get_cur_keyword_pos(complete_results)

    if s:cur_keyword_pos < 0
      let s:cur_keyword_str = ''
      let s:complete_words = []
      let s:complete_results = {}

      return -2
    endif

    let s:complete_results = complete_results

    return s:cur_keyword_pos
  endif

  let s:cur_keyword_pos =
        \ neocomplcache#get_cur_keyword_pos(s:complete_results)
  let complete_words = neocomplcache#get_complete_words(
        \ s:complete_results, s:cur_keyword_pos, a:base)

  let s:complete_words = complete_words
  let s:cur_keyword_str = a:base

  return complete_words
endfunction"}}}

function! neocomplcache#auto_complete(findstart, base)"{{{
  return neocomplcache#manual_complete(a:findstart, a:base)
endfunction"}}}

function! s:do_auto_complete(event)"{{{
  if (&buftype !~ 'nofile\|nowrite' && b:changedtick == s:changedtick)
        \ || neocomplcache#is_locked()
    return
  endif

  " Detect completefunc.
  if &l:completefunc != 'neocomplcache#manual_complete'
        \ && &l:completefunc != 'neocomplcache#auto_complete'
    if g:neocomplcache_force_overwrite_completefunc
          \ || &l:completefunc == ''
          \ || &l:completefunc ==# 'neocomplcache#sources_manual_complete'
      " Set completefunc.
      let &l:completefunc = 'neocomplcache#manual_complete'
    else
      " Warning.
      redir => output
      99verbose setl completefunc
      redir END
      call neocomplcache#print_error(output)
      call neocomplcache#print_error(
            \ 'Another plugin set completefunc! Disabled neocomplcache.')
      NeoComplCacheLock
      return
    endif
  endif

  " Detect AutoComplPop.
  if exists('g:acp_enableAtStartup') && g:acp_enableAtStartup
    call neocomplcache#print_error(
          \ 'Detected enabled AutoComplPop! Disabled neocomplcache.')
    NeoComplCacheLock
    return
  endif

  " Detect set paste.
  if &paste
    redir => output
      99verbose set paste
    redir END
    call neocomplcache#print_error(output)
    call neocomplcache#print_error(
          \ 'Detected set paste! Disabled neocomplcache.')
    return
  endif

  " Get cursor word.
  let cur_text = s:get_cur_text()
  if a:event ==# 'InsertCharPre'
    if v:char =~ '[[:cntrl:]]'
      return
    endif

    let cur_text .= v:char
  endif

  " Prevent infinity loop.
  if cur_text == ''
        \ || cur_text == s:old_cur_text
        \ || (neocomplcache#is_eskk_enabled() &&
        \      !neocomplcache#is_eskk_convertion(cur_text))
        \ || (!neocomplcache#is_eskk_enabled() &&
        \      neocomplcache#is_multibyte_input(cur_text))
        \ || g:neocomplcache_lock_iminsert && &l:iminsert
    let s:cur_keyword_str = ''
    let s:complete_words = []
    return
  endif

  let s:old_cur_text = cur_text
  if s:skip_next_complete
    let s:skip_next_complete = 0
    return
  endif

  if neocomplcache#is_omni_complete(cur_text)
    call feedkeys("\<Plug>(neocomplcache_start_omni_complete)")
    return
  endif

  " Check complete position.
  let complete_results = s:set_complete_results_pos(cur_text)
  if empty(complete_results)
    return
  endif

  let &l:completefunc = 'neocomplcache#auto_complete'

  if neocomplcache#is_prefetch()
    " Do prefetch.
    let s:complete_results =
          \ neocomplcache#get_complete_results(s:get_cur_text())

    if empty(s:complete_results)
      " Skip completion.
      let &l:completefunc = 'neocomplcache#manual_complete'
      let s:complete_words = []
      let s:is_prefetch = 0
      return
    endif
  endif

  let s:is_prefetch = neocomplcache#is_prefetch()
  let s:changedtick = b:changedtick

  " Set options.
  set completeopt-=menu
  set completeopt-=longest
  set completeopt+=menuone

  " Start auto complete.
  if neocomplcache#is_prefetch()
    call feedkeys((g:neocomplcache_enable_auto_select ?
          \ "\<C-x>\<C-u>\<C-p>\<Down>" :
          \ "\<C-x>\<C-u>\<C-p>"), 'n')
  else
    call feedkeys("\<Plug>(neocomplcache_start_auto_complete)")
  endif

  let s:changedtick = b:changedtick
endfunction"}}}

" Source helper."{{{
function! neocomplcache#available_complfuncs()"{{{
  return s:complfunc_sources
endfunction"}}}
function! neocomplcache#available_ftplugins()"{{{
  return s:ftplugin_sources
endfunction"}}}
function! neocomplcache#available_loaded_ftplugins()"{{{
  return s:loaded_ftplugin_sources
endfunction"}}}
function! neocomplcache#available_plugins()"{{{
  return s:plugin_sources
endfunction"}}}
function! neocomplcache#available_sources()"{{{
  call s:set_context_filetype()
  return extend(extend(copy(s:complfunc_sources), s:plugin_sources),
        \ s:loaded_ftplugin_sources)
endfunction"}}}
function! neocomplcache#keyword_escape(cur_keyword_str)"{{{
  " Escape."{{{
  let keyword_escape = escape(a:cur_keyword_str, '~" \.^$[]')
  if g:neocomplcache_enable_wildcard
    let keyword_escape = substitute(substitute(keyword_escape, '.\zs\*', '.*', 'g'), '\%(^\|\*\)\zs\*', '\\*', 'g')
    if '-' !~ '\k'
      let keyword_escape = substitute(keyword_escape, '.\zs-', '.\\+', 'g')
    endif
  else
    let keyword_escape = escape(keyword_escape, '*')
  endif"}}}

  " Fuzzy completion.
  let keyword_len = len(keyword_escape)
  if g:neocomplcache_enable_fuzzy_completion
        \ && (g:neocomplcache_fuzzy_completion_start_length
        \          <= keyword_len && keyword_len < 20)
    let fuzzy_start = g:neocomplcache_fuzzy_completion_start_length
    if fuzzy_start <= 1
      let keyword_escape =
            \ substitute(keyword_escape, '\w',
            \   '\\%(\0\\|\U\0\E\\l*\\|\0\\w*\\W\\)', 'g')
    elseif keyword_len < 8
      let keyword_escape = keyword_escape[: fuzzy_start - 2]
            \ . substitute(keyword_escape[fuzzy_start-1 :], '\w',
            \     '\\%(\0\\|\U\0\E\\l*\\|\0\\w*\\W\\)', 'g')
    else
      let keyword_escape = keyword_escape[: 3] .
            \ substitute(keyword_escape[4:12], '\w',
            \     '\\%(\0\\|\U\0\E\\l*\\|\0\\w*\\W\\)', 'g') . keyword_escape[13:]
    endif
  else
    " Underbar completion."{{{
    if g:neocomplcache_enable_underbar_completion
          \ && keyword_escape =~ '_'
      let keyword_escape_orig = keyword_escape
      let keyword_escape = substitute(keyword_escape,
            \ '[^_]\zs_', '[^_]*_', 'g')
    endif
    if g:neocomplcache_enable_underbar_completion
          \ && '-' =~ '\k' && keyword_escape =~ '-'
      let keyword_escape = substitute(keyword_escape,
            \ '[^-]\zs-', '[^-]*-', 'g')
    endif
    "}}}
    " Camel case completion."{{{
    if g:neocomplcache_enable_camel_case_completion
          \ && keyword_escape =~ '\u'
      let keyword_escape = substitute(keyword_escape, '\u\?\zs\U*',
            \ '\\%(\0\\l*\\|\U\0\E\\u*_\\?\\)', 'g')
    endif
    "}}}
  endif

  call neocomplcache#print_debug(keyword_escape)
  return keyword_escape
endfunction"}}}
function! neocomplcache#keyword_filter(list, cur_keyword_str)"{{{
  let cur_keyword_str = a:cur_keyword_str

  if neocomplcache#complete_check()
    return []
  endif

  " Delimiter check.
  let filetype = neocomplcache#get_context_filetype()
  if has_key(g:neocomplcache_delimiter_patterns, filetype)"{{{
    for delimiter in g:neocomplcache_delimiter_patterns[filetype]
      let cur_keyword_str = substitute(cur_keyword_str,
            \ delimiter, '*' . delimiter, 'g')
    endfor
  endif"}}}

  if cur_keyword_str == ''
    return a:list
  elseif neocomplcache#check_match_filter(cur_keyword_str)
    " Match filter.
    let expr = printf('v:val.word =~ %s',
          \ string('^' . neocomplcache#keyword_escape(cur_keyword_str)))
    if neocomplcache#is_auto_complete()
      " Don't complete cursor word.
      let expr .= ' && v:val.word !=? a:cur_keyword_str'
    endif

    return filter(a:list, expr)
  else
    " Use fast filter.
    return neocomplcache#head_filter(a:list, cur_keyword_str)
  endif
endfunction"}}}
function! neocomplcache#dup_filter(list)"{{{
  let dict = {}
  for keyword in a:list
    if !has_key(dict, keyword.word)
      let dict[keyword.word] = keyword
    endif
  endfor

  return values(dict)
endfunction"}}}
function! neocomplcache#check_match_filter(cur_keyword_str)"{{{
  return neocomplcache#keyword_escape(a:cur_keyword_str) =~ '[^\\]\*\|\\+'
endfunction"}}}
function! neocomplcache#check_completion_length_match(cur_keyword_str, completion_length)"{{{
  return neocomplcache#keyword_escape(
        \ a:cur_keyword_str[: a:completion_length-1]) =~
        \'[^\\]\*\|\\+\|\\%(\|\\|'
endfunction"}}}
function! neocomplcache#head_filter(list, cur_keyword_str)"{{{
  if &ignorecase
   let expr = printf('!stridx(tolower(v:val.word), %s)',
          \ string(tolower(a:cur_keyword_str)))
  else
    let expr = printf('!stridx(v:val.word, %s)',
          \ string(a:cur_keyword_str))
  endif

  if neocomplcache#is_auto_complete()
    " Don't complete cursor word.
    let expr .= ' && v:val.word !=? a:cur_keyword_str'
  endif

  return filter(a:list, expr)
endfunction"}}}
function! neocomplcache#fuzzy_filter(list, cur_keyword_str)"{{{
  let ret = []

  let cur_keyword_str = a:cur_keyword_str[2:]
  let max_str2 = len(cur_keyword_str)
  let len = len(a:cur_keyword_str)
  let m = range(max_str2+1)
  for keyword in filter(a:list, 'len(v:val.word) >= '.max_str2)
    let str1 = keyword.word[2 : len-1]

    let i = 0
    while i <= max_str2+1
      let m[i] = range(max_str2+1)

      let i += 1
    endwhile
    let i = 0
    while i <= max_str2+1
      let m[i][0] = i
      let m[0][i] = i

      let i += 1
    endwhile

    let i = 1
    let max = max_str2 + 1
    while i < max
      let j = 1
      while j < max
        let m[i][j] = min([m[i-1][j]+1, m[i][j-1]+1,
              \ m[i-1][j-1]+(str1[i-1] != cur_keyword_str[j-1])])

        let j += 1
      endwhile

      let i += 1
    endwhile
    if m[-1][-1] <= 2
      call add(ret, keyword)
    endif
  endfor

  return ret
endfunction"}}}
function! neocomplcache#dictionary_filter(dictionary, cur_keyword_str, completion_length)"{{{
  if empty(a:dictionary)
    return []
  endif

  if len(a:cur_keyword_str) < a:completion_length ||
        \ neocomplcache#check_completion_length_match(
        \   a:cur_keyword_str, a:completion_length)
    return neocomplcache#keyword_filter(
          \ neocomplcache#unpack_dictionary(a:dictionary), a:cur_keyword_str)
  endif

  let key = tolower(a:cur_keyword_str[: a:completion_length-1])

  if !has_key(a:dictionary, key)
    return []
  endif

  let list = a:dictionary[key]
  if type(list) == type({})
    " Convert dictionary dictionary.
    unlet list
    let list = values(a:dictionary[key])
  endif

  return (len(a:cur_keyword_str) == a:completion_length && &ignorecase)?
        \ list : neocomplcache#keyword_filter(copy(list), a:cur_keyword_str)
endfunction"}}}
function! neocomplcache#unpack_dictionary(dict)"{{{
  let ret = []
  for l in values(a:dict)
    let ret += type(l) == type([]) ? l : values(l)
  endfor

  return ret
endfunction"}}}
function! neocomplcache#add_dictionaries(dictionaries)"{{{
  if empty(a:dictionaries)
    return {}
  endif

  let ret = a:dictionaries[0]
  for dict in a:dictionaries[1:]
    for [key, value] in items(dict)
      if has_key(ret, key)
        let ret[key] += value
      else
        let ret[key] = value
      endif
    endfor
  endfor

  return ret
endfunction"}}}

" Rank order."{{{
function! neocomplcache#compare_rank(i1, i2)
  let diff = get(a:i2, 'rank', 0) - get(a:i1, 'rank', 0)
  if !diff
    let diff = (a:i1.word ># a:i2.word) ? 1 : -1
  endif
  return diff
endfunction"}}}
" Pos order."{{{
function! s:compare_pos(i1, i2)
  return a:i1[0] == a:i2[0] ? a:i1[1] - a:i2[1] : a:i1[0] - a:i2[0]
endfunction"}}}
" Word order."{{{
function! neocomplcache#compare_word(i1, i2)
  return (a:i1.word ># a:i2.word) ? 1 : -1
endfunction"}}}
" Source rank order."{{{
function! s:compare_source_rank(i1, i2)
  return neocomplcache#get_source_rank(a:i2[0]) -
        \ neocomplcache#get_source_rank(a:i1[0])
endfunction"}}}
" Nothing order."{{{
function! neocomplcache#compare_nothing(i1, i2)
  return 0
endfunction"}}}

function! neocomplcache#rand(max)"{{{
  if !has('reltime')
    " Same value.
    return 0
  endif

  let time = reltime()[1]
  return (time < 0 ? -time : time)% (a:max + 1)
endfunction"}}}
function! neocomplcache#system(...)"{{{
  let V = vital#of('neocomplcache')
  return call(V.system, a:000)
endfunction"}}}
function! neocomplcache#has_vimproc(...)"{{{
  " Initialize.
  if !exists('g:neocomplcache_use_vimproc')
    " Check vimproc.
    try
      call vimproc#version()
      let exists_vimproc = 1
    catch
      let exists_vimproc = 0
    endtry

    let g:neocomplcache_use_vimproc = exists_vimproc
  endif

  return g:neocomplcache_use_vimproc
endfunction"}}}

function! neocomplcache#get_cur_text(...)"{{{
  " Return cached text.
  return (a:0 == 0 && mode() ==# 'i' && exists('s:cur_text')) ?
        \ s:cur_text : s:get_cur_text()
endfunction"}}}
function! neocomplcache#get_next_keyword()"{{{
  " Get next keyword.
  let pattern = '^\%(' . neocomplcache#get_next_keyword_pattern() . '\m\)'

  return matchstr('a'.getline('.')[len(neocomplcache#get_cur_text()) :], pattern)[1:]
endfunction"}}}
function! neocomplcache#get_completion_length(plugin_name)"{{{
  if !exists('b:neocomplcache')
    call s:initialize_buffer_variable()
  endif

  if neocomplcache#is_auto_complete()
        \ && b:neocomplcache.completion_length >= 0
    return b:neocomplcache.completion_length
  elseif has_key(g:neocomplcache_source_completion_length,
        \ a:plugin_name)
    return g:neocomplcache_source_completion_length[a:plugin_name]
  elseif has_key(s:ftplugin_sources, a:plugin_name)
        \ || has_key(s:complfunc_sources, a:plugin_name)
    return 0
  elseif neocomplcache#is_auto_complete()
    return g:neocomplcache_auto_completion_start_length
  else
    return g:neocomplcache_manual_completion_start_length
  endif
endfunction"}}}
function! neocomplcache#set_completion_length(plugin_name, length)"{{{
  if !has_key(g:neocomplcache_source_completion_length, a:plugin_name)
    let g:neocomplcache_source_completion_length[a:plugin_name] = a:length
  endif
endfunction"}}}
function! neocomplcache#get_auto_completion_length(plugin_name)"{{{
  if has_key(g:neocomplcache_source_completion_length, a:plugin_name)
    return g:neocomplcache_source_completion_length[a:plugin_name]
  elseif g:neocomplcache_enable_fuzzy_completion
    return 1
  else
    return g:neocomplcache_auto_completion_start_length
  endif
endfunction"}}}
function! neocomplcache#get_keyword_pattern(...)"{{{
  let filetype = a:0 != 0? a:000[0] : neocomplcache#get_context_filetype()

  return s:unite_patterns(g:neocomplcache_keyword_patterns, filetype)
endfunction"}}}
function! neocomplcache#get_next_keyword_pattern(...)"{{{
  let filetype = a:0 != 0? a:000[0] : neocomplcache#get_context_filetype()
  let next_pattern = s:unite_patterns(g:neocomplcache_next_keyword_patterns, filetype)

  return (next_pattern == '' ? '' : next_pattern.'\m\|')
        \ . neocomplcache#get_keyword_pattern(filetype)
endfunction"}}}
function! neocomplcache#get_keyword_pattern_end(...)"{{{
  let filetype = a:0 != 0? a:000[0] : neocomplcache#get_context_filetype()

  return '\%('.neocomplcache#get_keyword_pattern(filetype).'\m\)$'
endfunction"}}}
function! neocomplcache#get_prev_word(cur_keyword_str)"{{{
  let keyword_pattern = neocomplcache#get_keyword_pattern()
  let line_part = neocomplcache#get_cur_text()[: -1-len(a:cur_keyword_str)]
  let prev_word_end = matchend(line_part, keyword_pattern)
  if prev_word_end > 0
    let word_end = matchend(line_part, keyword_pattern, prev_word_end)
    if word_end >= 0
      while word_end >= 0
        let prev_word_end = word_end
        let word_end = matchend(line_part, keyword_pattern, prev_word_end)
      endwhile
    endif

    let prev_word = matchstr(line_part[: prev_word_end-1], keyword_pattern . '$')
  else
    let prev_word = '^'
  endif

  return prev_word
endfunction"}}}
function! neocomplcache#match_word(cur_text, ...)"{{{
  let pattern = a:0 >= 1 ? a:1 : neocomplcache#get_keyword_pattern_end()

  " Check wildcard.
  let cur_keyword_pos = s:match_wildcard(a:cur_text, pattern, match(a:cur_text, pattern))

  let cur_keyword_str = a:cur_text[cur_keyword_pos :]

  return [cur_keyword_pos, cur_keyword_str]
endfunction"}}}
function! neocomplcache#is_enabled()"{{{
  return s:is_enabled
endfunction"}}}
function! neocomplcache#is_locked(...)"{{{
  if !exists('b:neocomplcache')
    call s:initialize_buffer_variable()
  endif

  let bufnr = a:0 > 0 ? a:1 : bufnr('%')
  return !s:is_enabled
        \ || g:neocomplcache_disable_auto_complete
        \ || b:neocomplcache.lock
        \ || (g:neocomplcache_lock_buffer_name_pattern != '' &&
        \   bufname(bufnr) =~ g:neocomplcache_lock_buffer_name_pattern)
        \ || &l:omnifunc ==# 'fuf#onComplete'
endfunction"}}}
function! neocomplcache#is_plugin_locked(source_name)"{{{
  if !s:is_enabled
    return 1
  endif

  let bufnr = bufnr('%')
  return has_key(s:sources_lock, bufnr)
        \ && has_key(s:sources_lock[bufnr], a:source_name)
        \ && s:sources_lock[bufnr][a:source_name]
endfunction"}}}
function! neocomplcache#is_auto_select()"{{{
  return g:neocomplcache_enable_auto_select && !neocomplcache#is_eskk_enabled()
endfunction"}}}
function! neocomplcache#is_auto_complete()"{{{
  return &l:completefunc == 'neocomplcache#auto_complete'
endfunction"}}}
function! neocomplcache#is_sources_complete()"{{{
  return &l:completefunc == 'neocomplcache#sources_manual_complete'
endfunction"}}}
function! neocomplcache#is_eskk_enabled()"{{{
  return exists('*eskk#is_enabled') && eskk#is_enabled()
endfunction"}}}
function! neocomplcache#is_eskk_convertion(cur_text)"{{{
  return neocomplcache#is_eskk_enabled()
        \   && eskk#get_preedit().get_henkan_phase() !=#
        \             g:eskk#preedit#PHASE_NORMAL
endfunction"}}}
function! neocomplcache#is_multibyte_input(cur_text)"{{{
  return (exists('b:skk_on') && b:skk_on)
        \     || char2nr(split(a:cur_text, '\zs')[-1]) > 0x80
endfunction"}}}
function! neocomplcache#is_text_mode()"{{{
  return s:is_text_mode
endfunction"}}}
function! neocomplcache#is_windows()"{{{
  return neocomplcache#util#is_windows()
endfunction"}}}
function! neocomplcache#is_win()"{{{
  return neocomplcache#is_windows()
endfunction"}}}
function! neocomplcache#is_prefetch()"{{{
  return g:neocomplcache_enable_prefetch
        \ || &l:formatoptions =~# 'a'
endfunction"}}}
function! neocomplcache#is_omni_complete(cur_text)"{{{
  if !neocomplcache#is_source_enabled('omni_complete')
    return 0
  endif

  let filetype = neocomplcache#get_context_filetype()

  if &filetype !=# filetype
    " &omnifunc is irregal.
    return 0
  endif

  let omnifunc = &l:omnifunc

  if has_key(g:neocomplcache_omni_patterns, omnifunc)
    let pattern = g:neocomplcache_omni_patterns[omnifunc]
  elseif filetype != '' && has_key(g:neocomplcache_omni_patterns, filetype)
    let pattern = g:neocomplcache_omni_patterns[filetype]
  else
    return 0
  endif

  " For rubycomplete only.
  return &l:omnifunc ==# 'rubycomplete#Complete'
        \ && a:cur_text =~ pattern
endfunction"}}}
function! neocomplcache#is_source_enabled(plugin_name)"{{{
  return !get(g:neocomplcache_source_disable, a:plugin_name, 0)
endfunction"}}}
function! neocomplcache#exists_echodoc()"{{{
  return exists('g:loaded_echodoc') && g:loaded_echodoc
endfunction"}}}
function! neocomplcache#within_comment()"{{{
  return s:within_comment
endfunction"}}}
function! neocomplcache#print_caching(string)"{{{
  if g:neocomplcache_enable_caching_message
    redraw
    echon a:string
  endif
endfunction"}}}
function! neocomplcache#print_error(string)"{{{
  echohl Error | echomsg a:string | echohl None
endfunction"}}}
function! neocomplcache#print_warning(string)"{{{
  echohl WarningMsg | echomsg a:string | echohl None
endfunction"}}}
function! neocomplcache#trunk_string(string, max)"{{{
  return printf('%.' . a:max-10 . 's..%%s', a:string, a:string[-8:])
endfunction"}}}
function! neocomplcache#head_match(checkstr, headstr)"{{{
  let checkstr = &ignorecase ?
        \ tolower(a:checkstr) : a:checkstr
  let headstr = &ignorecase ?
        \ tolower(a:headstr) : a:headstr
  return stridx(checkstr, headstr) == 0
endfunction"}}}
function! neocomplcache#get_source_filetypes(filetype)"{{{
  let filetype = (a:filetype == '') ? 'nothing' : a:filetype

  let filetype_dict = {}

  let filetypes = [filetype]
  if filetype =~ '\.'
    if has_key(g:neocomplcache_ignore_composite_filetype_lists, filetype)
      let filetypes = [g:neocomplcache_ignore_composite_filetype_lists[filetype]]
    else
      " Set compound filetype.
      let filetypes += split(filetype, '\.')
    endif
  endif

  for ft in filter(copy(filetypes),
        \ 'has_key(g:neocomplcache_same_filetype_lists, v:val)')
    for same_ft in split(g:neocomplcache_same_filetype_lists[ft], ',')
      if index(filetypes, same_ft) < 0
        " Add same filetype.
        call add(filetypes, same_ft)
      endif
    endfor
  endfor

  return filetypes
endfunction"}}}
function! neocomplcache#get_sources_list(dictionary, filetype)"{{{
  let list = []
  for filetype in neocomplcache#get_source_filetypes(a:filetype)
    if has_key(a:dictionary, filetype)
      call add(list, a:dictionary[filetype])
    endif
  endfor

  return list
endfunction"}}}
function! neocomplcache#escape_match(str)"{{{
  return escape(a:str, '~"*\.^$[]')
endfunction"}}}
function! neocomplcache#get_context_filetype(...)"{{{
  if !exists('b:neocomplcache')
    call s:initialize_buffer_variable()
  endif

  if a:0 != 0 || b:neocomplcache.context_filetype == ''
    call s:set_context_filetype()
  endif

  return b:neocomplcache.context_filetype
endfunction"}}}
function! neocomplcache#get_source_rank(plugin_name)"{{{
  if has_key(g:neocomplcache_source_rank, a:plugin_name)
    return g:neocomplcache_source_rank[a:plugin_name]
  elseif has_key(s:complfunc_sources, a:plugin_name)
    return 10
  elseif has_key(s:ftplugin_sources, a:plugin_name)
    return 100
  elseif has_key(s:plugin_sources, a:plugin_name)
    return neocomplcache#get_source_rank('keyword_complete')
  else
    " unknown.
    return 1
  endif
endfunction"}}}
function! neocomplcache#get_syn_name(is_trans)"{{{
  return len(getline('.')) < 200 ?
        \ synIDattr(synIDtrans(synID(line('.'), mode() ==# 'i' ?
        \          col('.')-1 : col('.'), a:is_trans)), 'name') : ''
endfunction"}}}
function! neocomplcache#print_debug(expr)"{{{
  if g:neocomplcache_enable_debug
    echomsg string(a:expr)
  endif
endfunction"}}}
function! neocomplcache#get_temporary_directory()"{{{
  let directory = neocomplcache#util#substitute_path_separator(
        \ neocomplcache#util#expand(g:neocomplcache_temporary_dir))
  if !isdirectory(directory)
    call mkdir(directory, 'p')
  endif

  return directory
endfunction"}}}
function! neocomplcache#complete_check()"{{{
  return !neocomplcache#is_prefetch() && complete_check()
endfunction"}}}

" For unite source.
function! neocomplcache#get_complete_results(cur_text, ...)"{{{
  let complete_results = call(
        \ 's:set_complete_results_pos', [a:cur_text] + a:000)
  call s:set_complete_results_words(complete_results)

  return filter(complete_results,
        \ '!empty(v:val.complete_words)')
endfunction"}}}
function! neocomplcache#get_cur_keyword_pos(complete_results)"{{{
  if empty(a:complete_results)
    return -1
  endif

  let cur_keyword_pos = col('.')
  for result in values(a:complete_results)
    if cur_keyword_pos > result.cur_keyword_pos
      let cur_keyword_pos = result.cur_keyword_pos
    endif
  endfor

  return cur_keyword_pos
endfunction"}}}
function! neocomplcache#get_complete_words(complete_results, cur_keyword_pos, cur_keyword_str) "{{{
  let frequencies = s:get_frequencies()

  let sources = neocomplcache#available_sources()

  " Append prefix.
  let complete_words = []
  let len_words = 0
  for [source_name, result] in sort(items(a:complete_results),
        \ 's:compare_source_rank')
    let result.complete_words = deepcopy(result.complete_words)
    if result.cur_keyword_pos > a:cur_keyword_pos
      let prefix = a:cur_keyword_str[: result.cur_keyword_pos
            \                            - a:cur_keyword_pos - 1]

      for keyword in result.complete_words
        let keyword.word = prefix . keyword.word
      endfor
    endif

    for keyword in filter(copy(result.complete_words),
          \ 'has_key(frequencies, v:val.word)')
      let keyword.rank = frequencies[keyword.word]
    endfor

    let compare_func = get(sources[source_name], 'compare_func',
          \ g:neocomplcache_compare_function)
    if compare_func !=# 'neocomplcache#compare_nothing'
      call sort(result.complete_words, compare_func)
    endif

    let complete_words += s:remove_next_keyword(
          \ source_name, result.complete_words)
    let len_words += len(result.complete_words)

    if g:neocomplcache_max_list > 0
          \ && len_words > g:neocomplcache_max_list
      break
    endif
  endfor

  if neocomplcache#complete_check()
    return []
  endif

  if g:neocomplcache_max_list > 0
    let complete_words = complete_words[: g:neocomplcache_max_list]
  endif

  " Check dup and set icase.
  let dup_check = {}
  let words = []
  let icase = g:neocomplcache_enable_ignore_case &&
        \!(g:neocomplcache_enable_smart_case && a:cur_keyword_str =~ '\u')
        \ && !neocomplcache#is_text_mode()
  for keyword in complete_words
    if has_key(keyword, 'kind') && keyword.kind == ''
      " Remove kind key.
      call remove(keyword, 'kind')
    endif

    if keyword.word != ''
          \&& (!has_key(dup_check, keyword.word)
          \    || (has_key(keyword, 'dup') && keyword.dup))
      let dup_check[keyword.word] = 1

      let keyword.icase = icase
      if !has_key(keyword, 'abbr')
        let keyword.abbr = keyword.word
      endif

      call add(words, keyword)
    endif
  endfor
  let complete_words = words

  " Delimiter check.
  let filetype = neocomplcache#get_context_filetype()
  if has_key(g:neocomplcache_delimiter_patterns, filetype)"{{{
    for delimiter in g:neocomplcache_delimiter_patterns[filetype]
      " Count match.
      let delim_cnt = 0
      let matchend = matchend(a:cur_keyword_str, delimiter)
      while matchend >= 0
        let matchend = matchend(a:cur_keyword_str, delimiter, matchend)
        let delim_cnt += 1
      endwhile

      for keyword in complete_words
        let split_list = split(keyword.word, delimiter, 1)
        if len(split_list) > 1
          let delimiter_sub = substitute(delimiter, '\\\([.^$]\)', '\1', 'g')
          let keyword.word = join(split_list[ : delim_cnt], delimiter_sub)
          let keyword.abbr = join(
                \ split(keyword.abbr, delimiter, 1)[ : delim_cnt],
                \ delimiter_sub)

          if g:neocomplcache_max_keyword_width >= 0
                \ && len(keyword.abbr) > g:neocomplcache_max_keyword_width
            let keyword.abbr = substitute(keyword.abbr,
                  \ '\(\h\)\w*'.delimiter, '\1'.delimiter_sub, 'g')
          endif
          if delim_cnt+1 < len(split_list)
            let keyword.abbr .= delimiter_sub . '~'
            let keyword.dup = 0

            if g:neocomplcache_enable_auto_delimiter
              let keyword.word .= delimiter_sub
            endif
          endif
        endif
      endfor
    endfor
  endif"}}}

  if neocomplcache#complete_check()
    return []
  endif

  " Convert words.
  if neocomplcache#is_text_mode() "{{{
    if a:cur_keyword_str =~ '^\l\+$'
      for keyword in complete_words
        let keyword.word = tolower(keyword.word)
        let keyword.abbr = tolower(keyword.abbr)
      endfor
    elseif a:cur_keyword_str =~ '^\u\+$'
      for keyword in complete_words
        let keyword.word = toupper(keyword.word)
        let keyword.abbr = toupper(keyword.abbr)
      endfor
    elseif a:cur_keyword_str =~ '^\u\l\+$'
      for keyword in complete_words
        let keyword.word = toupper(keyword.word[0]).tolower(keyword.word[1:])
        let keyword.abbr = toupper(keyword.abbr[0]).tolower(keyword.abbr[1:])
      endfor
    endif
  endif"}}}

  if g:neocomplcache_max_keyword_width >= 0 "{{{
    " Abbr check.
    let abbr_pattern = printf('%%.%ds..%%s',
          \ g:neocomplcache_max_keyword_width-15)
    for keyword in complete_words
      if len(keyword.abbr) > g:neocomplcache_max_keyword_width
        if keyword.abbr =~ '[^[:print:]]'
          " Multibyte string.
          let len = neocomplcache#util#wcswidth(keyword.abbr)

          if len > g:neocomplcache_max_keyword_width
            let keyword.abbr = neocomplcache#util#truncate(
                  \ keyword.abbr, g:neocomplcache_max_keyword_width - 2) . '..'
          endif
        else
          let keyword.abbr = printf(abbr_pattern,
                \ keyword.abbr, keyword.abbr[-13:])
        endif
      endif
    endfor
  endif"}}}

  return complete_words
endfunction"}}}
function! s:set_complete_results_words(complete_results)"{{{
  " Try source completion.
  for [source_name, result] in items(a:complete_results)
    if neocomplcache#complete_check()
      return
    endif

    " Save options.
    let ignorecase_save = &ignorecase

    if neocomplcache#is_text_mode()
      let &ignorecase = 1
    elseif g:neocomplcache_enable_smart_case
          \ && result.cur_keyword_str =~ '\u'
      let &ignorecase = 0
    else
      let &ignorecase = g:neocomplcache_enable_ignore_case
    endif

    let pos = getpos('.')

    try
      let words = result.source.get_complete_words(
            \ result.cur_keyword_pos, result.cur_keyword_str)
    catch
      call neocomplcache#print_error(v:throwpoint)
      call neocomplcache#print_error(v:exception)
      call neocomplcache#print_error(
            \ 'Error occured in complfunc''s get_complete_words()!')
      call neocomplcache#print_error(
            \ 'Source name is ' . source_name)
      return
    finally
      if getpos('.') != pos
        call setpos('.', pos)
      endif
    endtry

    let &ignorecase = ignorecase_save

    let result.complete_words = words
  endfor
endfunction"}}}
function! s:set_complete_results_pos(cur_text, ...)"{{{
  " Set context filetype.
  call s:set_context_filetype()

  let sources = copy(get(a:000, 0, extend(copy(neocomplcache#available_complfuncs()),
        \ neocomplcache#available_loaded_ftplugins())))
  if neocomplcache#is_eskk_enabled() && eskk#get_mode() !=# 'ascii'
    " omni_complete only.
    let sources = filter(sources, 'v:key ==# "omni_complete"')
  endif
  if a:0 < 1
    call filter(sources, 'neocomplcache#is_source_enabled(v:key)
          \  && !neocomplcache#is_plugin_locked(v:key)')
  endif

  " Try source completion."{{{
  let complete_results = {}
  for [source_name, source] in items(sources)
    let pos = getpos('.')

    try
      let cur_keyword_pos = source.get_keyword_pos(a:cur_text)
    catch
      call neocomplcache#print_error(v:throwpoint)
      call neocomplcache#print_error(v:exception)
      call neocomplcache#print_error(
            \ 'Error occured in complfunc''s get_keyword_pos()!')
      call neocomplcache#print_error(
            \ 'Source name is ' . source_name)
      return complete_results
    finally
      if getpos('.') != pos
        call setpos('.', pos)
      endif
    endtry

    if cur_keyword_pos < 0
      continue
    endif

    let cur_keyword_str = a:cur_text[cur_keyword_pos :]
    if neocomplcache#is_auto_complete() &&
          \ neocomplcache#util#mb_strlen(cur_keyword_str)
          \     < neocomplcache#get_completion_length(source_name)
      " Skip.
      continue
    endif

    let complete_results[source_name] = {
          \ 'complete_words' : [],
          \ 'cur_keyword_pos' : cur_keyword_pos,
          \ 'cur_keyword_str' : cur_keyword_str,
          \ 'source' : source,
          \}
  endfor
  "}}}

  return complete_results
endfunction"}}}

" Set default pattern helper.
function! neocomplcache#set_dictionary_helper(variable, keys, value)"{{{
  return neocomplcache#util#set_default_dictionary_helper(a:variable, a:keys, a:value)
endfunction"}}}

" Complete filetype helper.
function! neocomplcache#filetype_complete(arglead, cmdline, cursorpos)"{{{
  " Dup check.
  let ret = {}
  for item in map(split(globpath(&runtimepath, 'syntax/*.vim'), '\n'), 'fnamemodify(v:val, ":t:r")')
    if !has_key(ret, item) && item =~ '^'.a:arglead
      let ret[item] = 1
    endif
  endfor

  return sort(keys(ret))
endfunction"}}}
"}}}

" Command functions."{{{
function! neocomplcache#toggle_lock()"{{{
  if !neocomplcache#is_enabled()
    call neocomplcache#enable()
    return
  endif

  if !exists('b:neocomplcache')
    call s:initialize_buffer_variable()
  endif

  if b:neocomplcache.lock
    echo 'neocomplcache is locked!'
    call neocomplcache#lock()
  else
    echo 'neocomplcache is unlocked!'
    call neocomplcache#unlock()
  endif
endfunction"}}}
function! neocomplcache#lock()"{{{
  if !neocomplcache#is_enabled()
    call neocomplcache#print_warning(
          \ 'neocomplcache is disabled! This command is ignored.')
    return
  endif

  if !exists('b:neocomplcache')
    call s:initialize_buffer_variable()
  endif

  let b:neocomplcache.lock = 1
endfunction"}}}
function! neocomplcache#unlock()"{{{
  if !neocomplcache#is_enabled()
    call neocomplcache#print_warning(
          \ 'neocomplcache is disabled! This command is ignored.')
    return
  endif

  if !exists('b:neocomplcache')
    call s:initialize_buffer_variable()
  endif

  let b:neocomplcache.lock = 0
endfunction"}}}
function! neocomplcache#lock_source(source_name)"{{{
  if !neocomplcache#is_enabled()
    call neocomplcache#print_warning('neocomplcache is disabled! This command is ignored.')
    return
  endif

  if !has_key(s:sources_lock, bufnr('%'))
    let s:sources_lock[bufnr('%')] = {}
  endif

  let s:sources_lock[bufnr('%')][a:source_name] = 1
endfunction"}}}
function! neocomplcache#unlock_source(source_name)"{{{
  if !neocomplcache#is_enabled()
    call neocomplcache#print_warning('neocomplcache is disabled! This command is ignored.')
    return
  endif

  if !has_key(s:sources_lock, bufnr('%'))
    let s:sources_lock[bufnr('%')] = {}
  endif

  let s:sources_lock[bufnr('%')][a:source_name] = 0
endfunction"}}}
function! s:display_neco(number)"{{{
  let cmdheight_save = &cmdheight

  let animation = [
    \[
        \[
        \ "   A A",
        \ "~(-'_'-)"
        \],
        \[
        \ "      A A",
        \ "   ~(-'_'-)",
        \],
        \[
        \ "        A A",
        \ "     ~(-'_'-)",
        \],
        \[
        \ "          A A  ",
        \ "       ~(-'_'-)",
        \],
        \[
        \ "             A A",
        \ "          ~(-^_^-)",
        \],
    \],
    \[
        \[
        \ "   A A",
        \ "~(-'_'-)",
        \],
        \[
        \ "      A A",
        \ "   ~(-'_'-)",
        \],
        \[
        \ "        A A",
        \ "     ~(-'_'-)",
        \],
        \[
        \ "          A A  ",
        \ "       ~(-'_'-)",
        \],
        \[
        \ "             A A",
        \ "          ~(-'_'-)",
        \],
        \[
        \ "          A A  ",
        \ "       ~(-'_'-)"
        \],
        \[
        \ "        A A",
        \ "     ~(-'_'-)"
        \],
        \[
        \ "      A A",
        \ "   ~(-'_'-)"
        \],
        \[
        \ "   A A",
        \ "~(-'_'-)"
        \],
    \],
    \[
        \[
        \ "   A A",
        \ "~(-'_'-)",
        \],
        \[
        \ "        A A",
        \ "     ~(-'_'-)",
        \],
        \[
        \ "             A A",
        \ "          ~(-'_'-)",
        \],
        \[
        \ "                  A A",
        \ "               ~(-'_'-)",
        \],
        \[
        \ "                       A A",
        \ "                    ~(-'_'-)",
        \],
        \["                           A A",
        \ "                        ~(-'_'-)",
        \],
    \],
    \[
        \[
        \ "",
        \ "   A A",
        \ "~(-'_'-)",
        \],
        \["      A A",
        \ "   ~(-'_'-)",
        \ "",
        \],
        \[
        \ "",
        \ "        A A",
        \ "     ~(-'_'-)",
        \],
        \[
        \ "          A A  ",
        \ "       ~(-'_'-)",
        \ "",
        \],
        \[
        \ "",
        \ "             A A",
        \ "          ~(-^_^-)",
        \],
    \],
    \[
        \[
        \ "   A A        A A",
        \ "~(-'_'-)  -8(*'_'*)"
        \],
        \[
        \ "     A A        A A",
        \ "  ~(-'_'-)  -8(*'_'*)"
        \],
        \[
        \ "       A A        A A",
        \ "    ~(-'_'-)  -8(*'_'*)"
        \],
        \[
        \ "     A A        A A",
        \ "  ~(-'_'-)  -8(*'_'*)"
        \],
        \[
        \ "   A A        A A",
        \ "~(-'_'-)  -8(*'_'*)"
        \],
    \],
    \[
        \[
        \ "  A\\_A\\",
        \ "(=' .' ) ~w",
        \ "(,(\")(\")",
        \],
    \],
  \]

  let number = (a:number != '') ? a:number : len(animation)
  let anim = get(animation, number, animation[neocomplcache#rand(len(animation) - 1)])
  let &cmdheight = len(anim[0])

  for frame in anim
    echo repeat("\n", &cmdheight-2)
    redraw
    echon join(frame, "\n")
    sleep 300m
  endfor
  redraw

  let &cmdheight = cmdheight_save
endfunction"}}}
function! neocomplcache#set_file_type(filetype)"{{{
  if !exists('b:neocomplcache')
    call s:initialize_buffer_variable()
  endif

  let b:neocomplcache.filetype = a:filetype
endfunction"}}}
function! s:set_auto_completion_length(len)"{{{
  if !exists('b:neocomplcache')
    call s:initialize_buffer_variable()
  endif

  let b:neocomplcache.completion_length = a:len
endfunction"}}}
"}}}

" Key mapping functions."{{{
function! neocomplcache#smart_close_popup()"{{{
  return g:neocomplcache_enable_auto_select ?
        \ neocomplcache#cancel_popup() : neocomplcache#close_popup()
endfunction
"}}}
function! neocomplcache#close_popup()"{{{
  let s:skip_next_complete = 1
  let s:cur_keyword_str = ''
  let s:complete_words = []

  return pumvisible() ? "\<C-y>" : ''
endfunction
"}}}
function! neocomplcache#cancel_popup()"{{{
  let s:skip_next_complete = 1
  let s:cur_keyword_str = ''
  let s:cur_keyword_pos = -1
  let s:complete_words = []

  return pumvisible() ? "\<C-e>" : ''
endfunction
"}}}

function! neocomplcache#undo_completion()"{{{
  if !exists(':NeoComplCacheDisable')
    return ''
  endif

  " Get cursor word.
  let [cur_keyword_pos, cur_keyword_str] =
        \ neocomplcache#match_word(s:get_cur_text())
  let old_keyword_str = s:cur_keyword_str
  let s:cur_keyword_str = cur_keyword_str

  return (pumvisible() ? "\<C-e>" : '')
        \. repeat("\<BS>", len(cur_keyword_str)) . old_keyword_str
endfunction"}}}

function! neocomplcache#complete_common_string()"{{{
  if !exists(':NeoComplCacheDisable')
    return ''
  endif

  " Save options.
  let ignorecase_save = &ignorecase

  " Get cursor word.
  let [cur_keyword_pos, cur_keyword_str] =
        \ neocomplcache#match_word(s:get_cur_text())

  if neocomplcache#is_text_mode()
    let &ignorecase = 1
  elseif g:neocomplcache_enable_smart_case && cur_keyword_str =~ '\u'
    let &ignorecase = 0
  else
    let &ignorecase = g:neocomplcache_enable_ignore_case
  endif

  let complete_words = neocomplcache#keyword_filter(
        \ copy(s:complete_words), cur_keyword_str)

  if empty(complete_words)
    let &ignorecase = ignorecase_save

    return ''
  endif

  let common_str = complete_words[0].word
  for keyword in complete_words[1:]
    while !neocomplcache#head_match(keyword.word, common_str)
      let common_str = common_str[: -2]
    endwhile
  endfor
  if &ignorecase
    let common_str = tolower(common_str)
  endif

  let &ignorecase = ignorecase_save

  if common_str == ''
    return ''
  endif

  return (pumvisible() ? "\<C-e>" : '')
        \ . repeat("\<BS>", len(cur_keyword_str)) . common_str
endfunction"}}}

" Wrapper functions.
function! neocomplcache#manual_filename_complete()"{{{
  return neocomplcache#start_manual_complete('filename_complete')
endfunction"}}}
function! neocomplcache#manual_omni_complete()"{{{
  return neocomplcache#start_manual_complete('omni_complete')
endfunction"}}}
function! neocomplcache#manual_keyword_complete()"{{{
  return neocomplcache#start_manual_complete('keyword_complete')
endfunction"}}}

" Manual complete wrapper.
function! neocomplcache#start_manual_complete(...)"{{{
  " Set context filetype.
  call s:set_context_filetype()

  " Set function.
  let &l:completefunc = 'neocomplcache#sources_manual_complete'

  let s:use_sources = {}
  let all_sources = extend(copy(neocomplcache#available_complfuncs()),
        \ neocomplcache#available_loaded_ftplugins())
  let sources = get(a:000, 0, keys(all_sources))
  for source_name in type(sources) == type([]) ?
   \ sources : [sources]
    if has_key(all_sources, source_name)
      let s:use_sources[source_name] = all_sources[source_name]
    else
      call neocomplcache#print_warning(printf(
            \ "Invalid completefunc name %s is given.", a:complfunc_name))
      return ''
    endif
  endfor

  " Start complete.
  return "\<C-x>\<C-u>\<C-p>"
endfunction"}}}
function! neocomplcache#start_manual_complete_list(cur_keyword_pos, cur_keyword_str, complete_words)"{{{
  let [s:cur_keyword_pos, s:cur_keyword_str, s:complete_words] =
        \ [a:cur_keyword_pos, a:cur_keyword_str, a:complete_words]

  " Set function.
  let &l:completefunc = 'neocomplcache#auto_complete'

  " Start complete.
  return "\<C-x>\<C-u>\<C-p>"
endfunction"}}}
"}}}

" Event functions."{{{
function! s:on_moved_i()"{{{
  " Get cursor word.
  let cur_text = s:get_cur_text()

  " Make cache.
  if cur_text =~ '^\s*$\|\s\+$'
    if neocomplcache#is_source_enabled('buffer_complete')
      " Caching current cache line.
      call neocomplcache#sources#buffer_complete#caching_current_line()
    endif
    if neocomplcache#is_source_enabled('member_complete')
      " Caching current cache line.
      call neocomplcache#sources#member_complete#caching_current_line()
    endif
  endif
endfunction"}}}
function! s:on_insert_leave()"{{{
  let s:cur_text = ''
  let s:cur_keyword_str = ''
  let s:complete_words = []
  let s:is_text_mode = 0
  let s:skip_next_complete = 0
  let s:is_prefetch = 0
  let s:cur_keyword_pos = -1
endfunction"}}}
function! s:on_complete_done()"{{{
  " Get cursor word.
  let [_, candidate] =
        \ neocomplcache#match_word(s:get_cur_text())
  if candidate == ''
    return
  endif

  let frequencies = s:get_frequencies()
  if !has_key(frequencies, candidate)
    let frequencies[candidate] = 0
  endif

  let frequencies[candidate] += 1
endfunction"}}}
function! s:change_update_time()"{{{
  if &updatetime > g:neocomplcache_cursor_hold_i_time
    " Change updatetime.
    let s:update_time_save = &updatetime
    let &updatetime = g:neocomplcache_cursor_hold_i_time
  endif
endfunction"}}}
function! s:restore_update_time()"{{{
  if &updatetime < s:update_time_save
    " Restore updatetime.
    let &updatetime = s:update_time_save
  endif
endfunction"}}}
function! s:remove_next_keyword(source_name, list)"{{{
  " Remove next keyword.
  let pattern = '^\%(' .
        \ (a:source_name  == 'filename_complete' ?
        \   neocomplcache#get_next_keyword_pattern('filename') :
        \   neocomplcache#get_next_keyword_pattern()) . '\m\)'

  let next_keyword_str = matchstr('a'.
        \ getline('.')[len(neocomplcache#get_cur_text(1)) :], pattern)[1:]
  if next_keyword_str == ''
    return a:list
  endif

  let next_keyword_str = substitute(escape(next_keyword_str,
        \ '~" \.^$*[]'), "'", "''", 'g').'$'

  " No ignorecase.
  let ignorecase_save = &ignorecase
  let &ignorecase = 0

  for r in a:list
    if r.word =~ next_keyword_str
      let r.word = r.word[:match(r.word, next_keyword_str)-1]
    endif
  endfor

  let &ignorecase = ignorecase_save

  return a:list
endfunction"}}}
function! neocomplcache#popup_post()"{{{
  return  !pumvisible() ? "" :
        \ (!g:neocomplcache_enable_auto_select
        \  || neocomplcache#is_eskk_enabled()) ? "\<C-p>" :
        \ "\<C-p>\<Down>"
endfunction"}}}
"}}}

" Internal helper functions."{{{
function! s:get_cur_text()"{{{
  let s:cur_text =
        \ (mode() ==# 'i' ? (col('.')-1) : col('.')) >= len(getline('.')) ?
        \      getline('.') :
        \      matchstr(getline('.'),
        \         '^.*\%' . col('.') . 'c' . (mode() ==# 'i' ? '' : '.'))

  " Save cur_text.
  return s:cur_text
endfunction"}}}
function! s:set_context_filetype()"{{{
  if !exists('b:neocomplcache')
    call s:initialize_buffer_variable()
  endif

  let old_filetype = (b:neocomplcache.filetype == '') ?
        \ &filetype : b:neocomplcache.filetype
  if old_filetype == ''
    let old_filetype = 'nothing'
  endif

  let dup_check = {}
  while 1
    let new_filetype = s:get_context_filetype(old_filetype)

    " Check filetype root.
    if get(dup_check, old_filetype, '') ==# new_filetype
      let b:neocomplcache.context_filetype = old_filetype
      break
    endif

    " Save old -> new filetype graph.
    let dup_check[old_filetype] = new_filetype
    let old_filetype = new_filetype
  endwhile

  " Set text mode or not.
  let syn_name = neocomplcache#get_syn_name(1)
  let s:is_text_mode =
        \ get(g:neocomplcache_text_mode_filetypes,
        \ b:neocomplcache.context_filetype, 0)
  let s:within_comment = (syn_name ==# 'Comment')

  " Set filetype plugins.
  let s:loaded_ftplugin_sources = {}
  for [source_name, source] in
        \ items(filter(copy(neocomplcache#available_ftplugins()),
        \ 'has_key(v:val.filetypes, b:neocomplcache.context_filetype)'))
    let s:loaded_ftplugin_sources[source_name] = source

    if !source.loaded
      " Initialize.
      if has_key(source, 'initialize')
        call source.initialize()
      endif

      let source.loaded = 1
    endif
  endfor

  return b:neocomplcache.context_filetype
endfunction"}}}
function! s:get_context_filetype(filetype)"{{{
  let filetype = a:filetype
  if filetype == ''
    let filetype = 'nothing'
  endif

  " Default.
  let context_filetype = filetype
  if neocomplcache#is_eskk_enabled()
    let context_filetype = 'eskk'
    let filetype = 'eskk'
  elseif has_key(g:neocomplcache_context_filetype_lists, filetype)
        \ && !empty(g:neocomplcache_context_filetype_lists[filetype])

    let pos = [line('.'), col('.')]
    for include in g:neocomplcache_context_filetype_lists[filetype]
      let start_backward = searchpos(include.start, 'bnW')

      " Check start <= line <= end.
      if start_backward[0] == 0 || s:compare_pos(start_backward, pos) > 0
        continue
      endif

      let end_pattern = include.end
      if end_pattern =~ '\\1'
        let match_list = matchlist(getline(start_backward[0]), include.start)
        let end_pattern = substitute(end_pattern, '\\1', '\=match_list[1]', 'g')
      endif
      let end_forward = searchpos(end_pattern, 'nW')

      if end_forward[0] == 0 || s:compare_pos(pos, end_forward) < 0
        let end_backward = searchpos(end_pattern, 'bnW')

        if end_backward[0] == 0 || s:compare_pos(start_backward, end_backward) > 0
          let context_filetype = include.filetype
          let filetype = include.filetype
          break
        endif
      endif
    endfor
  endif

  return context_filetype
endfunction"}}}
function! s:match_wildcard(cur_text, pattern, cur_keyword_pos)"{{{
  let cur_keyword_pos = a:cur_keyword_pos
  if neocomplcache#is_eskk_enabled() || !g:neocomplcache_enable_wildcard
    return cur_keyword_pos
  endif

  while cur_keyword_pos > 1 && a:cur_text[cur_keyword_pos - 1] == '*'
    let left_text = a:cur_text[: cur_keyword_pos - 2]
    if left_text == '' || left_text !~ a:pattern
      break
    endif

    let cur_keyword_pos = match(left_text, a:pattern)
  endwhile

  return cur_keyword_pos
endfunction"}}}
function! s:unite_patterns(pattern_var, filetype)"{{{
  let keyword_patterns = []
  let dup_check = {}

  " Compound filetype.
  for ft in split(a:filetype, '\.')
    if has_key(a:pattern_var, ft) && !has_key(dup_check, ft)
      let dup_check[ft] = 1
      call add(keyword_patterns, a:pattern_var[ft])
    endif

    " Same filetype.
    if has_key(g:neocomplcache_same_filetype_lists, ft)
      for ft in split(g:neocomplcache_same_filetype_lists[ft], ',')
        if has_key(a:pattern_var, ft) && !has_key(dup_check, ft)
          let dup_check[ft] = 1
          call add(keyword_patterns, a:pattern_var[ft])
        endif
      endfor
    endif
  endfor

  if empty(keyword_patterns) && has_key(a:pattern_var, 'default')
    call add(keyword_patterns, g:neocomplcache_keyword_patterns['default'])
  endif

  return join(keyword_patterns, '\m\|')
endfunction"}}}
function! s:get_frequencies()"{{{
  let filetype = neocomplcache#get_context_filetype()
  if !has_key(s:filetype_frequencies, filetype)
    let s:filetype_frequencies[filetype] = {}
  endif

  return s:filetype_frequencies[filetype]
endfunction"}}}
function! s:initialize_buffer_variable()"{{{
  let b:neocomplcache = {
        \ 'lock' : 0,
        \ 'filetype' : '',
        \ 'context_filetype' : '',
        \ 'completion_length' : -1,
        \}
endfunction"}}}
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
