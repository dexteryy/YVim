" Python compile & debug tools 
" Maintainer: Dexter.Yy
" Mail:   dexter.yy@gmail.com
" Web:    http://www.limboy.com
" Version: 0.1
"
" Usage:
"

python << EOF
import time
import vim
def pySetBreakpoint():
	nLine = int(vim.eval('line(".")'))
	strLine = vim.current.line
	strWhite = ""
	for char in strLine:
		if char == ' ' or char == "\t":
			strWhite += char
		else:
			break

	vim.current.buffer.append(
		"%(space)spdb.set_trace() %(mark)s Breakpoint %(mark)s" 
		% {'space': strWhite, 'mark': '#' * 10}, nLine - 1)

	added = 1
	nLine = 0
	for strLine in vim.current.buffer:
		nLine += 1
		if not 'import' in strLine: # or strLine[0] == "#":
			if not added:
				vim.current.buffer.append( 'import pdb', nLine - 1)
				vim.command('normal j1')
				break
		elif 'pdb' in strLine:
			break
		else:
			added = 0

def pyRemoveBreakpoints():
    nCurrentLine = int(vim.eval('line(".")'))
    nLines = []
    nLine = 1
    for strLine in vim.current.buffer:
        if strLine == 'import pdb' or strLine.lstrip()[:15] == 'pdb.set_trace()':
            nLines.append( nLine)
        nLine += 1
    nLines.reverse()
    for nLine in nLines:
        vim.command('normal %dG' % nLine)
        vim.command('normal dd')
        if nLine < nCurrentLine:
            nCurrentLine -= 1
    vim.command('normal %dG' % nCurrentLine)
EOF


function! s:SetMyMake()
	let s:cpo_save = &cpo
	set cpo-=C
	setlocal makeprg=python\ %
	"setlocal errorformat=%f(%l):\ %m
	setlocal errorformat=
		\%A\ \ File\ \"%f\"\\\,\ line\ %l\\\,%m,
		\%C\ \ \ \ %.%#,
		\%+Z%.%#Error\:\ %.%#,
		\%A\ \ File\ \"%f\"\\\,\ line\ %l,
		\%+C\ \ %.%#,
		\%-C%p^,
		\%Z%m,
		\%-G%.%#
	let &cpo = s:cpo_save
	unlet s:cpo_save
	let g:current_compiler = "python"
endfunction

function! MyPyMake()
	if !exists("g:current_compiler")
		call s:SetMyMake()
	elseif  g:current_compiler != 'python'
		call s:SetMyMake()
	en
	make
endfunction

function! MyPyLint()
	!pep8 %
endfunction

function! MyPyDebug()
	!python %
endfunction


function! MyPySetBreakPoint()
	py pySetBreakpoint()
endfunction


function! MyPyRemoveBreakPoint()
	py pyRemoveBreakpoints()
endfunction

let b:myMake='MyPyMake'
let b:myLint='MyPyLint'
let b:myDebug='MyPyDebug'
let b:mySetBreakPoint='MyPySetBreakPoint'
let b:myRemoveBreakPoint='MyPyRemoveBreakPoint'

