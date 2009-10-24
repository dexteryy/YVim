" Filetype settings
if exists("did_load_filetypes")
    finish
endif
 
" Associate unknown filetypes
augroup filetypedetect
    au! BufRead,BufNewFile *.vm 	setfiletype html
augroup END

