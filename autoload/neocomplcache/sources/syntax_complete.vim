"=============================================================================
" FILE: syntax_complete.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 05 Oct 2012.
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
if !exists('s:syntax_list')
  let s:syntax_list = {}
endif

let s:source = {
      \ 'name' : 'syntax_complete',
      \ 'kind' : 'plugin',
      \}

function! s:source.initialize()"{{{
  " Set rank.
  call neocomplcache#util#set_default_dictionary(
        \ 'g:neocomplcache_source_rank', 'syntax_complete', 7)

  " Set caching event.
  autocmd neocomplcache Syntax * call s:caching()

  " Create cache directory.
  if !isdirectory(neocomplcache#get_temporary_directory() . '/syntax_cache')
    call mkdir(neocomplcache#get_temporary_directory() . '/syntax_cache')
  endif

  " Initialize check.
  call s:caching()
endfunction"}}}

function! s:source.finalize()"{{{
  delcommand NeoComplCacheCachingSyntax
endfunction"}}}

function! s:source.get_keyword_list(cur_keyword_str)"{{{
  if neocomplcache#within_comment()
    return []
  endif

  let list = []

  let filetype = neocomplcache#get_context_filetype()
  if !has_key(s:syntax_list, filetype)
    let keyword_lists = neocomplcache#cache#index_load_from_cache(
          \ 'syntax_cache', filetype)
    if !empty(keyword_lists)
      " Caching from cache.
      let s:syntax_list[filetype] = keyword_lists
    endif
  endif

  for source in neocomplcache#get_sources_list(s:syntax_list, filetype)
    let list += neocomplcache#dictionary_filter(source, a:cur_keyword_str)
  endfor

  return list
endfunction"}}}

function! neocomplcache#sources#syntax_complete#define()"{{{
  return s:source
endfunction"}}}

function! s:caching()"{{{
  if &filetype == '' || &filetype ==# 'vim'
    return
  endif

  for filetype in neocomplcache#get_source_filetypes(&filetype)
    if !has_key(s:syntax_list, filetype)
      " Check old cache.
      let cache_name = neocomplcache#cache#encode_name('syntax_cache', &filetype)
      let syntax_files = split(
            \ globpath(&runtimepath, 'syntax/'.&filetype.'.vim'), '\n')
      if getftime(cache_name) < 0 || (!empty(syntax_files)
            \ && getftime(cache_name) <= getftime(syntax_files[0]))
        if filetype ==# &filetype
          " Caching from syn list.
          let s:syntax_list[filetype] = s:caching_from_syn(filetype)
        endif
      else
        let s:syntax_list[filetype] =
              \ neocomplcache#cache#index_load_from_cache('syntax_cache', filetype)
      endif
    endif
  endfor
endfunction"}}}

function! neocomplcache#sources#syntax_complete#recaching(filetype)"{{{
  if a:filetype == ''
    let filetype = &filetype
  else
    let filetype = a:filetype
  endif

  " Caching.
  let s:syntax_list[filetype] = s:caching_from_syn(filetype)
endfunction"}}}

function! s:caching_from_syn(filetype)"{{{
  call neocomplcache#print_caching(
        \ 'Caching syntax "' . a:filetype . '"... please wait.')

  " Get current syntax list.
  redir => syntax_list
  silent! syntax list
  redir END

  if syntax_list =~ '^E\d\+' || syntax_list =~ '^No Syntax items'
    return []
  endif

  let group_name = ''
  let keyword_pattern = neocomplcache#get_keyword_pattern(a:filetype)

  let dup_check = {}
  let menu = '[S] '

  let filetype_pattern = substitute(a:filetype, '\W', '\\A', 'g') . '\u'

  let keyword_lists = {}
  for line in split(syntax_list, '\n')
    if line =~ '^\h\w\+'
      " Change syntax group name.
      let group_name = matchstr(line, '^\S\+')
      let menu = printf('[S] %.'.g:neocomplcache_max_menu_width.'s', group_name)
      let line = substitute(line, '^\S\s*xxx', '', '')
    endif

    if line =~ 'Syntax items' || line =~ '^\s*links to' ||
          \ line =~ '^\s*nextgroup=' ||
          \ group_name !~# filetype_pattern
      " Next line.
      continue
    endif

    let line = substitute(line, 'contained\|skipwhite\|skipnl\|oneline', '', 'g')
    let line = substitute(line, '^\s*nextgroup=.*\ze\s', '', '')

    if line =~ '^\s*match'
      let line = s:substitute_candidate(matchstr(line, '/\zs[^/]\+\ze/'))
    elseif line =~ '^\s*start='
      let line =
            \s:substitute_candidate(matchstr(line, 'start=/\zs[^/]\+\ze/')) . ' ' .
            \s:substitute_candidate(matchstr(line, 'end=/zs[^/]\+\ze/'))
    endif

    " Add keywords.
    let match_num = 0
    let completion_length = 2
    let match_str = matchstr(line, keyword_pattern, match_num)
    while match_str != ''
      " Ignore too short keyword.
      if len(match_str) >= g:neocomplcache_min_syntax_length
            \ && !has_key(dup_check, match_str)
            \&& match_str =~ '^[[:print:]]\+$'
        let keyword = { 'word' : match_str, 'menu' : menu }

        let key = tolower(keyword.word[: completion_length-1])
        if !has_key(keyword_lists, key)
          let keyword_lists[key] = []
        endif
        call add(keyword_lists[key], keyword)

        let dup_check[match_str] = 1
      endif

      let match_num += len(match_str)

      let match_str = matchstr(line, keyword_pattern, match_num)
    endwhile
  endfor

  " Save syntax cache.
  let unpack_lists = neocomplcache#unpack_dictionary(keyword_lists)
  if !empty(unpack_lists)
    call neocomplcache#cache#save_cache('syntax_cache', &filetype, unpack_lists)
  endif

  call neocomplcache#print_caching('')

  return keyword_lists
endfunction"}}}

" LengthOrder."{{{
function! s:compare_length(i1, i2)
  return a:i1.word < a:i2.word ? 1 : a:i1.word == a:i2.word ? 0 : -1
endfunction"}}}

function! s:substitute_candidate(candidate)"{{{
  let candidate = a:candidate

  " Collection.
  let candidate = substitute(candidate,
        \'\\\@<!\[[^\]]*\]', ' ', 'g')

  " Delete.
  let candidate = substitute(candidate,
        \'\\\@<!\%(\\[=?+]\|\\%[\|\\s\*\)', '', 'g')
  " Space.
  let candidate = substitute(candidate,
        \'\\\@<!\%(\\[<>{}]\|[$^]\|\\z\?\a\)', ' ', 'g')

  if candidate =~ '\\%\?('
    let candidate = join(s:split_pattern(candidate))
  endif

  " \
  let candidate = substitute(candidate, '\\\\', '\\', 'g')
  " *
  let candidate = substitute(candidate, '\\\*', '*', 'g')
  return candidate
endfunction"}}}

function! s:split_pattern(keyword_pattern)"{{{
  let original_pattern = a:keyword_pattern
  let result_patterns = []
  let analyzing_patterns = [ '' ]

  let i = 0
  let max = len(original_pattern)
  while i < max
    if match(original_pattern, '^\\%\?(', i) >= 0
      " Grouping.
      let end = s:match_pair(original_pattern, '\\%\?(', '\\)', i)
      if end < 0
        "call neocomplcache#print_error('Unmatched (.')
        return [ a:keyword_pattern ]
      endif

      let save_pattern = analyzing_patterns
      let analyzing_patterns = []
      for keyword in split(original_pattern[matchend(original_pattern, '^\\%\?(', i) : end], '\\|')
        for prefix in save_pattern
          call add(analyzing_patterns, prefix . keyword)
        endfor
      endfor

      let i = end + 1
    elseif match(original_pattern, '^\\|', i) >= 0
      " Select.
      let result_patterns += analyzing_patterns
      let analyzing_patterns = [ '' ]
      let original_pattern = original_pattern[i+2 :]
      let max = len(original_pattern)

      let i = 0
    elseif original_pattern[i] == '\' && i+1 < max
      let save_pattern = analyzing_patterns
      let analyzing_patterns = []
      for prefix in save_pattern
        call add(analyzing_patterns, prefix . original_pattern[i] . original_pattern[i+1])
      endfor

      " Escape.
      let i += 2
    else
      let save_pattern = analyzing_patterns
      let analyzing_patterns = []
      for prefix in save_pattern
        call add(analyzing_patterns, prefix . original_pattern[i])
      endfor

      let i += 1
    endif
  endwhile

  let result_patterns += analyzing_patterns
  return result_patterns
endfunction"}}}

function! s:match_pair(string, start_pattern, end_pattern, start_cnt)"{{{
  let end = -1
  let start_pattern = '\%(' . a:start_pattern . '\)'
  let end_pattern = '\%(' . a:end_pattern . '\)'

  let i = a:start_cnt
  let max = len(a:string)
  let nest_level = 0
  while i < max
    let start = match(a:string, start_pattern, i)
    let end = match(a:string, end_pattern, i)

    if start >= 0 && (end < 0 || start < end)
      let i = matchend(a:string, start_pattern, i)
      let nest_level += 1
    elseif end >= 0 && (start < 0 || end < start)
      let nest_level -= 1

      if nest_level == 0
        return end
      endif

      let i = matchend(a:string, end_pattern, i)
    else
      break
    endif
  endwhile

  if nest_level != 0
    return -1
  else
    return end
  endif
endfunction"}}}

" Global options definition."{{{
if !exists('g:neocomplcache_min_syntax_length')
  let g:neocomplcache_min_syntax_length = 4
endif
"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
