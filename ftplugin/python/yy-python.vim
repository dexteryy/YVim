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

def pyInsertCode(code, cmt, lib=None):
	nLine = int(vim.eval('line(".")'))
	strLine = vim.current.line
	strWhite = ""
	for char in strLine:
		if char == ' ' or char == "\t":
			strWhite += char
		else:
			break

	vim.current.buffer.append(
		"%(space)s%(code)s %(cmt)s" 
		% {'space': strWhite, 'code': code, 'cmt': r'########## ' + cmt}, nLine - 1)

	if lib:
		added = 1
		nLine = 0
		for strLine in vim.current.buffer:
			nLine += 1
			if not 'import' in strLine: # or strLine[0] == "#":
				if not added:
					vim.current.buffer.append( 'import ' + lib, nLine - 1)
					vim.command('normal j1')
					break
			elif lib in strLine:
				break
			else:
				added = 0

def pySetBreakpoint():
	pyInsertCode('pdb.set_trace()', 'Breakpoint', 'pdb')

vim.command('let b:myLogCount = 0')
def pySetLog():
	vim.command('let b:myLogCount += 1')
	pyInsertCode('print("log: " + %s)' 
		% str(vim.eval('b:myLogCount')), 'log')

def pyRemoveBreakpoints():
    nCurrentLine = int(vim.eval('line(".")'))
    nLines = []
    nLine = 1
    for strLine in vim.current.buffer:
        if 'import pdb' == strLine.lstrip()[:10] \
			or 'pdb.set_trace()' == strLine.lstrip()[:15] \
			or "### log" == strLine.rstrip()[-7:]:
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

function! MyPySetLog()
	py pySetLog()
endfunction

function! MyPyRemoveBreakPoint()
	py pyRemoveBreakpoints()
endfunction

let b:myMake='MyPyMake'
let b:myLint='MyPyLint'
let b:myDebug='MyPyDebug'
let b:mySetBreakPoint='MyPySetBreakPoint'
let b:mySetLog='MyPySetLog'
let b:myRemoveBreakPoint='MyPyRemoveBreakPoint'

