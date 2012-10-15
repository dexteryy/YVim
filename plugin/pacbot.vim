" vim plugin for pacbot
" Maintainer: Dexter.Yy (dexter.yy at gmail.com)

function! EnablePAC()
	if &filetype == 'javascript'
		!sudo pacbot -u -o %
	elseif &filetype == 'yaml'
		!sudo pacbot %
	endif
endfunction


command! PACenable call EnablePAC() 
autocmd! bufwritepost *.pac :PACenable
autocmd! bufwritepost *.ypac :PACenable
