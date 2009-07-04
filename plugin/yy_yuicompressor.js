" File:          yy_yuicompressor.vim
" Author:        Dexter.Yy
" Last Modified: July 4, 2009
"
if !exists("yuicompressor_command")
  let yuicompressor_command = 'java -jar /Users/dexteryy/Sites/tools/yuicompressor-2.4.2/build/yuicompressor-2.4.2.jar'
endif

if !exists("yuicompressor_charset")
  let yuicompressor_charset = 'gbk'
endif

if !exists("yuicompressor_command_options")
  let yuicompressor_command_options = '--charset ' . g:yuicompressor_charset
endif

command! -nargs=* YUICOMPRESSOR call YUICompressor(<f-args>)

function! YUICompressor(options)
	let current_file = shellescape(expand('%:p'))

	if strlen(matchstr(a:options, '.js$'))
		let cmd_output = system(g:yuicompressor_command . ' ' . g:yuicompressor_command_options . ' -o ' . a:options . ' ' . current_file)
		exe "10split " . a:options
		exe "set wrap"
	else 
		if strlen(a:options)
			let g:yuicompressor_command_options = '--charset ' . a:options
		endif

		let tmpminfile = tempname()
		let cmd_output = system(g:yuicompressor_command . ' ' . g:yuicompressor_command_options . ' ' . current_file)
		if strlen(cmd_output) > 0
			exe "redir! > " . tmpminfile 
				silent echo cmd_output
			redir END

			exe "30split " . tmpminfile
			exe "set wrap"

			call delete(tmpminfile)
		else 
			echoerr current_file . 'NOT Comporessed'
		endif

	endif

endfunction

