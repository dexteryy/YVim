" javascript compile & debug tools 
" Maintainer: Dexter.Yy
" Mail:   dexter.yy@gmail.com
" Web:    http://www.limboy.com
" Version: 0.1
"
" Usage:
"

python << EOF
import os, vim

def jsDebug():
	pass

def jsInsertCode(code, cmt):
	nLine = int(vim.eval('line(".")'))
	strLine = vim.current.line
	strWhite = ""
	for char in strLine:
		if char == ' ' or char == "\t":
			strWhite += char
		else:
			break

	vim.current.buffer.append(
		"%(space)s%(code)s; %(cmt)s" 
		% {'space': strWhite, 'code': code, 'cmt': '// ' + cmt}, 
		nLine - 1)

def jsSetBreakpoint():
	jsInsertCode('debugger', 'Breakpoint')

vim.command('let b:myLogCount = 0')
def jsSetLog():
	vim.command('let b:myLogCount += 1')
	jsInsertCode('console.info("log: " + %s)' 
		% str(vim.eval('b:myLogCount')), 'log')

def jsRemoveAllDebug():
    nCurrentLine = int(vim.eval('line(".")'))
    nLines = []
    nLine = 1
    for strLine in vim.current.buffer:
        if (r'console.' == strLine.lstrip()[:8]
			or 'debugger;' == strLine.lstrip()[:9]) \
		   	and r'//' in strLine:
			nLines.append(nLine)
        nLine += 1
    nLines.reverse()
    for nLine in nLines:
        vim.command('normal %dG' % nLine)
        vim.command('normal dd')
        if nLine < nCurrentLine:
            nCurrentLine -= 1
    vim.command('normal %dG' % nCurrentLine)
    vim.command('let b:myLogCount = 0')

EOF

function! s:SetMyMake()
	let s:cpo_save = &cpo
	set cpo-=C
	setlocal makeprg=jsl\ -nologo\ -nofilelisting\ -nosummary\ -nocontext\ -conf\ '$HOME/.jsl-conf'\ -process\ %
	setlocal errorformat=%f(%l):\ %m
	let &cpo = s:cpo_save
	unlet s:cpo_save
	let g:current_compiler = "jsl"
endfunction

function! MyJsMake()
	call MyJsLint()
	!python $TUICOMPILER/tuicompiler.py % -n
endfunction

function! MyJsLint()
	if !exists("g:current_compiler")
		call s:SetMyMake()
	elseif  g:current_compiler != 'jsl'
		call s:SetMyMake()
	en
	make
endfunction

function! MyJsDebug()
	py jsDebug()
endfunction

function! MyJsSetBreakPoint()
	py jsSetBreakpoint()
endfunction

function! MyJsSetLog()
	py jsSetLog()
endfunction

function! MyJsRemoveBreakPoint()
	py jsRemoveAllDebug()
endfunction

let b:myMake='MyJsMake'
let b:myLint='MyJsLint'
let b:myDebug='MyJsDebug'
let b:mySetBreakPoint='MyJsSetBreakPoint'
let b:mySetLog='MyJsSetLog'
let b:myRemoveBreakPoint='MyJsRemoveBreakPoint'
