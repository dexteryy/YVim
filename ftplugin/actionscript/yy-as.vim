" actionscript compile & debug tools 
" Maintainer: Dexter.Yy
" Mail:   dexter.yy@gmail.com
" Web:    http://www.limboy.com
" Version: 0.1
"
" Usage:
"

python << EOF
import os, vim

def asMake():
	swfname = vim.eval("matchstr(bufname('%'), '[^\.]\+') . '.swf'")
	vim.command('!/Users/dexteryy/code/cmd/flex/bin/mxmlc -static-link-runtime-shared-libraries %; open ' + swfname) 

def asDebug():
	pass

def asInsertCode(code, cmt, lib=None):
	nLine = int(vim.eval('line(".")'))
	strLine = vim.current.line
	strWhite = ""
	for char in strLine:
		if char == ' ' or char == "\t":
			strWhite += char
		else:
			break

	vim.current.buffer.append(
		"%(space)s%(code)s %(cmt)s" % {
			'space': strWhite,
			'code': code if type(code) == str else 'ExternalInterface.call("%s", "%s");' % (code[0], code[1]),
		   	'cmt': r'// ' + cmt
		}, nLine - 1)

	if lib:
		added = 1
		nLine = 0
		for strLine in vim.current.buffer:
			nLine += 1
			if not 'import' in strLine: # or strLine[0] == "#":
				if not added:
					vim.current.buffer.append( 'import ' + lib + ';', nLine - 1)
					vim.command('normal j1')
					break
			elif lib in strLine:
				break
			else:
				added = 0

def asSetBreakpoint():
	asInsertCode('debugger', 'Breakpoint')

vim.command('let b:myLogCount = 0')
def asSetLog():
	vim.command('let b:myLogCount += 1')
	asInsertCode(['console.info', 'aslog: ' + str(vim.eval('b:myLogCount'))], 'log', 'flash.external.ExternalInterface')

def asRemoveAllDebug():
    nCurrentLine = int(vim.eval('line(".")'))
    nLines = []
    nLine = 1
    for strLine in vim.current.buffer:
        if (r'trace(' == strLine.lstrip()[:8]
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

function! MyAsMake()
	py asMake()
endfunction

function! MyAsLint()
	if !exists("g:current_compiler")
		call s:SetMyMake()
	elseif  g:current_compiler != 'jsl'
		call s:SetMyMake()
	en
	make
endfunction

function! MyAsDebug()
	py asDebug()
endfunction

function! MyAsSetBreakPoint()
	py asSetBreakpoint()
endfunction

function! MyAsSetLog()
	py asSetLog()
endfunction

function! MyAsRemoveBreakPoint()
	py asRemoveAllDebug()
endfunction

let b:myMake='MyAsMake'
let b:myLint='MyAsLint'
let b:myDebug='MyAsDebug'
let b:mySetBreakPoint='MyAsSetBreakPoint'
let b:mySetLog='MyAsSetLog'
let b:myRemoveBreakPoint='MyAsRemoveBreakPoint'
