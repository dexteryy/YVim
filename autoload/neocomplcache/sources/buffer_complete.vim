"=============================================================================
" FILE: buffer_complete.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 09 Nov 2012.
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
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

" Important variables.
if !exists('s:buffer_sources')
  let s:buffer_sources = {}
endif

let s:source = {
      \ 'name' : 'buffer_complete',
      \ 'kind' : 'complfunc',
      \}

function! s:source.initialize()"{{{
  augroup neocomplcache"{{{
    " Caching events
    autocmd CursorHold *
          \ call s:check_cache()
    autocmd BufWritePost *
          \ call s:check_recache()
    autocmd InsertEnter,InsertLeave *
          \ call s:caching_current_buffer(
          \          line('.') - 1, line('.') + 1, 1)
  augroup END"}}}

  " Set rank.
  call neocomplcache#util#set_default_dictionary(
        \ 'g:neocomplcache_source_rank',
        \ 'buffer_complete', 5)

  " Create cache directory.
  if !isdirectory(neocomplcache#get_temporary_directory() . '/buffer_cache')
    call mkdir(neocomplcache#get_temporary_directory() . '/buffer_cache', 'p')
  endif

  " Initialize script variables."{{{
  let s:buffer_sources = {}
  let s:cache_line_count = 70
  let s:rank_cache_count = 1
  let s:disable_caching_list = {}
  let s:async_dictionary_list = {}
  "}}}

  call neocomplcache#set_completion_length('buffer_complete',
        \ g:neocomplcache_auto_completion_start_length)

  call s:check_source()
endfunction
"}}}

function! s:source.finalize()"{{{
  delcommand NeoComplCacheCachingBuffer
  delcommand NeoComplCachePrintSource
  delcommand NeoComplCacheOutputKeyword
  delcommand NeoComplCacheDisableCaching
  delcommand NeoComplCacheEnableCaching

  let s:buffer_sources = {}
endfunction"}}}

function! s:source.get_keyword_pos(cur_text)"{{{
  let [cur_keyword_pos, _] = neocomplcache#match_word(a:cur_text)

  return cur_keyword_pos
endfunction"}}}

function! s:source.get_complete_words(cur_keyword_pos, cur_keyword_str)"{{{
  call s:check_source()

  let keyword_list = []
  for [key, source] in s:get_sources_list()
    call neocomplcache#cache#check_cache_list('buffer_cache',
          \ source.path, s:async_dictionary_list, source.keyword_cache)

    let keyword_list += neocomplcache#dictionary_filter(
          \ source.keyword_cache, a:cur_keyword_str)
    if key == bufnr('%')
      let source.accessed_time = localtime()
    endif
  endfor

  return keyword_list
endfunction"}}}

function! neocomplcache#sources#buffer_complete#define()"{{{
  return s:source
endfunction"}}}

function! neocomplcache#sources#buffer_complete#caching_current_line()"{{{
  " Current line caching.
  return s:caching_current_buffer(line('.') - 1, line('.') + 1, 1)
endfunction"}}}
function! s:caching_current_buffer(start, end, is_auto)"{{{
  " Current line caching.

  if !s:exists_current_source()
    call s:check_source()

    if !s:exists_current_source()
      return
    endif
  endif

  let source = s:buffer_sources[bufnr('%')]
  let menu = '[B] ' . neocomplcache#util#strwidthpart(
        \ source.name, g:neocomplcache_max_menu_width)
  let keyword_pattern = source.keyword_pattern
  let keyword_pattern2 = '^\%('.keyword_pattern.'\m\)'
  let keywords = source.keyword_cache

  let completion_length = 2
  let line = join(getline(a:start, a:end))
  let match = match(line, keyword_pattern)
  while match >= 0"{{{
    let match_str = matchstr(line, keyword_pattern2, match)

    " Ignore too short keyword.
    if len(match_str) >= g:neocomplcache_min_keyword_length"{{{
      " Check dup.
      let key = tolower(match_str[: completion_length-1])
      if !has_key(keywords, key)
        let keywords[key] = {}
      endif
      if !has_key(keywords[key], match_str)
        " Append list.
        let keywords[key][match_str] =
              \ { 'word' : match_str, 'menu' : menu, 'rank' : 0 }
        if a:is_auto
          " Save line number.
          let keywords[key][match_str].line = a:start
        endif
      endif
    endif"}}}

    " Next match.
    let match = match(line, keyword_pattern, match + len(match_str))
  endwhile"}}}
endfunction"}}}

function! s:get_sources_list()"{{{
  let sources_list = []

  let filetypes_dict = {}
  for filetype in neocomplcache#get_source_filetypes(
        \ neocomplcache#get_context_filetype())
    let filetypes_dict[filetype] = 1
  endfor

  for [key, source] in items(s:buffer_sources)
    if has_key(filetypes_dict, source.filetype)
          \ || has_key(filetypes_dict, '_')
          \ || bufnr('%') == key
          \ || (source.name ==# '[Command Line]' && bufnr('#') == key)
      call add(sources_list, [key, source])
    endif
  endfor

  return sources_list
endfunction"}}}

function! s:initialize_source(srcname)"{{{
  let path = fnamemodify(bufname(a:srcname), ':p')
  let filename = fnamemodify(path, ':t')
  if filename == ''
    let filename = '[No Name]'
    let path .= '/[No Name]'
  endif

  let ft = getbufvar(a:srcname, '&filetype')
  if ft == ''
    let ft = 'nothing'
  endif

  let buflines = getbufline(a:srcname, 1, '$')
  let keyword_pattern = neocomplcache#get_keyword_pattern(ft)

  let s:buffer_sources[a:srcname] = {
        \ 'keyword_cache' : {},
        \ 'name' : filename, 'filetype' : ft,
        \ 'keyword_pattern' : keyword_pattern,
        \ 'end_line' : len(buflines),
        \ 'accessed_time' : 0,
        \ 'cached_time' : 0,
        \ 'path' : path, 'loaded_cache' : 0,
        \ 'cache_name' : neocomplcache#cache#encode_name(
        \   'buffer_cache', path),
        \}
endfunction"}}}

function! s:word_caching(srcname)"{{{
  " Initialize source.
  call s:initialize_source(a:srcname)

  let source = s:buffer_sources[a:srcname]

  if !filereadable(source.path)
        \ || getbufvar(a:srcname, '&buftype') =~ 'nofile'
    if a:srcname == bufnr('%')
      " Make buffer cache.
      call s:caching_current_buffer(1, min([1000, line('$')]), 0)
    endif

    return
  endif

  let source.cache_name =
        \ neocomplcache#cache#async_load_from_file(
        \     'buffer_cache', source.path,
        \     source.keyword_pattern, 'B')
  let source.cached_time = localtime()
  let source.end_line = len(getbufline(a:srcname, 1, '$'))
  let s:async_dictionary_list[source.path] = [{
        \ 'filename' : source.path,
        \ 'cachename' : source.cache_name,
        \ }]
endfunction"}}}

function! s:check_changed_buffer(bufnumber)"{{{
  let source = s:buffer_sources[a:bufnumber]

  let ft = getbufvar(a:bufnumber, '&filetype')
  if ft == ''
    let ft = 'nothing'
  endif

  let filename = fnamemodify(bufname(a:bufnumber), ':t')
  if filename == ''
    let filename = '[No Name]'
  endif

  return s:buffer_sources[a:bufnumber].name != filename
        \ || s:buffer_sources[a:bufnumber].filetype != ft
endfunction"}}}

function! s:check_source()"{{{
  let bufnumber = bufnr('%')

  " Check new buffer.
  let bufname = fnamemodify(bufname(bufnumber), ':p')
  if (!has_key(s:buffer_sources, bufnumber)
        \ || s:check_changed_buffer(bufnumber))
        \ && !has_key(s:disable_caching_list, bufnumber)
        \ && (!neocomplcache#is_locked(bufnumber) ||
        \    g:neocomplcache_disable_auto_complete)
        \ && !getwinvar(bufwinnr(bufnumber), '&previewwindow')
        \ && getfsize(bufname) <
        \      g:neocomplcache_caching_limit_file_size
    " Caching.
    call s:word_caching(bufnumber)
  endif

  if !has_key(s:buffer_sources, bufnumber)
    return
  endif

  let source = s:buffer_sources[bufnumber]
  call neocomplcache#cache#check_cache_list('buffer_cache',
        \ source.path, s:async_dictionary_list, source.keyword_cache)
endfunction"}}}
function! s:check_cache()"{{{
  let release_accessd_time =
        \ localtime() - g:neocomplcache_release_cache_time

  for [key, source] in items(s:buffer_sources)
    " Check deleted buffer and access time.
    if !bufloaded(str2nr(key))
          \ || (source.accessed_time > 0 &&
          \ source.accessed_time < release_accessd_time)
      " Remove item.
      call remove(s:buffer_sources, key)
    endif
  endfor

  if !s:exists_current_source()
    return
  endif

  let bufnumber = bufnr('%')
  let source = s:buffer_sources[bufnumber]

  " Check current line caching.
  for cache in values(source.keyword_cache)
    call filter(cache, "!has_key(v:val, 'line')
          \ || stridx(getline(v:val.line), v:val.word) >= 0
          \ || search('\\<'.neocomplcache#util#escape_pattern(
          \     v:val.word).'\\>', 'wn', 0, 300) > 0")
  endfor
endfunction"}}}
function! s:check_recache()"{{{
  if !s:exists_current_source()
    return
  endif

  let release_accessd_time =
        \ localtime() - g:neocomplcache_release_cache_time

  let source = s:buffer_sources[bufnr('%')]

  " Check buffer access time.
  if source.cached_time > 0 &&
        \ (source.cached_time < release_accessd_time
        \  || (abs(source.end_line - line('$')) * 10)/source.end_line > 1)
    " Buffer recache.
    call s:word_caching(bufnr('%'))
  endif
endfunction"}}}

function! s:exists_current_source()"{{{
  return has_key(s:buffer_sources, bufnr('%'))
endfunction"}}}

" Command functions."{{{
function! neocomplcache#sources#buffer_complete#caching_buffer(name)"{{{
  if a:name == ''
    let number = bufnr('%')
  else
    let number = bufnr(a:name)

    if number < 0
      let bufnr = bufnr('%')

      " No swap warning.
      let save_shm = &shortmess
      set shortmess+=A

      " Open new buffer.
      execute 'silent! edit' fnameescape(a:name)

      let &shortmess = save_shm

      if bufnr('%') != bufnr
        setlocal nobuflisted
        execute 'buffer' bufnr
      endif
    endif

    let number = bufnr(a:name)
  endif

  " Word recaching.
  call s:word_caching(number)
  call s:caching_current_buffer(1, line('$'), 0)
endfunction"}}}
function! neocomplcache#sources#buffer_complete#print_source(name)"{{{
  if a:name == ''
    let number = bufnr('%')
  else
    let number = bufnr(a:name)

    if number < 0
      call neocomplcache#print_error('Invalid buffer name.')
      return
    endif
  endif

  if !has_key(s:buffer_sources, number)
    return
  endif

  silent put=printf('Print neocomplcache %d source.', number)
  for key in keys(s:buffer_sources[number])
    silent put =printf('%s => %s', key, string(s:buffer_sources[number][key]))
  endfor
endfunction"}}}
function! neocomplcache#sources#buffer_complete#output_keyword(name)"{{{
  if a:name == ''
    let number = bufnr('%')
  else
    let number = bufnr(a:name)

    if number < 0
      call neocomplcache#print_error('Invalid buffer name.')
      return
    endif
  endif

  if !has_key(s:buffer_sources, number)
    return
  endif

  " Output buffer.
  for keyword in neocomplcache#unpack_dictionary(
        \ s:buffer_sources[number].keyword_cache)
    silent put=string(keyword)
  endfor
endfunction "}}}
function! neocomplcache#sources#buffer_complete#disable_caching(name)"{{{
  if a:name == ''
    let number = bufnr('%')
  else
    let number = bufnr(a:name)

    if number < 0
      call neocomplcache#print_error('Invalid buffer name.')
      return
    endif
  endif

  let s:disable_caching_list[number] = 1

  if has_key(s:buffer_sources, number)
    " Delete source.
    call remove(s:buffer_sources, number)
  endif
endfunction"}}}
function! neocomplcache#sources#buffer_complete#enable_caching(name)"{{{
  if a:name == ''
    let number = bufnr('%')
  else
    let number = bufnr(a:name)

    if number < 0
      call neocomplcache#print_error('Invalid buffer name.')
      return
    endif
  endif

  if has_key(s:disable_caching_list, number)
    call remove(s:disable_caching_list, number)
  endif
endfunction"}}}
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
