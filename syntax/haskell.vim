" Vim syntax file
"
" Modification of vims Haskell syntax file:
"   - match types using regular expression
"   - highlight toplevel functions
"   - use "syntax keyword" instead of "syntax match" where appropriate
"   - functions and types in import and module declarations are matched
"   - removed hs_highlight_more_types (just not needed anymore)
"   - enable spell checking in comments and strings only
"
" TODO: find out which vim versions are still supported
"
" From Original file:
" ===================
"
" Language:		    Haskell
" Maintainer:		Haskell Cafe mailinglist <haskell-cafe@haskell.org>
" Last Change:		2010 Feb 21
" Original Author:	John Williams <jrw@pobox.com>
"
" Thanks to Ryan Crumley for suggestions and John Meacham for
" pointing out bugs. Also thanks to Ian Lynagh and Donald Bruce Stewart
" for providing the inspiration for the inclusion of the handling
" of C preprocessor directives, and for pointing out a bug in the
" end-of-line comment handling.
"
" Options-assign a value to these variables to turn the option on:
"
" hs_highlight_delimiters - Highlight delimiter characters--users
"			    with a light-colored background will
"			    probably want to turn this on.
" hs_highlight_boolean - Treat True and False as keywords.
" hs_highlight_types - Treat names of primitive types as keywords.
" hs_highlight_debug - Highlight names of debugging functions.
" hs_allow_hash_operator - Don't highlight seemingly incorrect C
"			   preprocessor directives but assume them to be
"			   operators
" 
" 

if version < 600
  syn clear
elseif exists("b:current_syntax")
  finish
endif

syntax sync fromstart "mmhhhh.... is this really ok to do so?

syn match  hsSpecialChar	contained "\\\([0-9]\+\|o[0-7]\+\|x[0-9a-fA-F]\+\|[\"\\'&\\abfnrtv]\|^[A-Z^_\[\\\]]\)"
syn match  hsSpecialChar	contained "\\\(NUL\|SOH\|STX\|ETX\|EOT\|ENQ\|ACK\|BEL\|BS\|HT\|LF\|VT\|FF\|CR\|SO\|SI\|DLE\|DC1\|DC2\|DC3\|DC4\|NAK\|SYN\|ETB\|CAN\|EM\|SUB\|ESC\|FS\|GS\|RS\|US\|SP\|DEL\)"
syn match  hsSpecialCharError	contained "\\&\|'''\+"
sy region  hsString		start=+"+  skip=+\\\\\|\\"+  end=+"+  contains=hsSpecialChar,@Spell
sy match   hsCharacter		"[^a-zA-Z0-9_']'\([^\\]\|\\[^']\+\|\\'\)'"lc=1 contains=hsSpecialChar,hsSpecialCharError
sy match   hsCharacter		"^'\([^\\]\|\\[^']\+\|\\'\)'" contains=hsSpecialChar,hsSpecialCharError

" (Qualified) identifiers (no default highlighting)
syn match ConId "\(\<[A-Z][a-zA-Z0-9_']*\.\)\=\<[A-Z][a-zA-Z0-9_']*\>"
syn match VarId "\(\<[A-Z][a-zA-Z0-9_']*\.\)\=\<[a-z][a-zA-Z0-9_']*\>"

" Infix operators--most punctuation characters and any (qualified) identifier
" enclosed in `backquotes`. An operator starting with : is a constructor,
" others are variables (e.g. functions).
syn match hsVarSym "\(\<[A-Z][a-zA-Z0-9_']*\.\)\=[-!#$%&\*\+/<=>\?@\\^|~.][-!#$%&\*\+/<=>\?@\\^|~:.]*"
syn match hsConSym "\(\<[A-Z][a-zA-Z0-9_']*\.\)\=:[-!#$%&\*\+./<=>\?@\\^|~:]*"
syn match hsVarSym "`\(\<[A-Z][a-zA-Z0-9_']*\.\)\=[a-z][a-zA-Z0-9_']*`"
syn match hsConSym "`\(\<[A-Z][a-zA-Z0-9_']*\.\)\=[A-Z][a-zA-Z0-9_']*`"

" Reserved symbols--cannot be overloaded.
syn match hsDelimiter  "(\|)\|\[\|\]\|,\|;\|_\|{\|}"

sy region hsInnerParen start="(" end=")" contained contains=hsInnerParen,hsConSym,hsType,hsVarSym
sy region hs_InfixOpFunctionName start="^(" end=")\s*[^:`]\(\W\&\S\&[^'\"`()[\]{}@]\)\+"re=s
    \ contained keepend contains=hsInnerParen,hs_HlInfixOp

sy match hs_hlFunctionName "[a-z_]\(\S\&[^,\(\)\[\]]\)*" contained 
sy match hs_FunctionName "^[a-z_]\(\S\&[^,\(\)\[\]]\)*" contained contains=hs_hlFunctionName
sy match hs_HighliteInfixFunctionName "`[a-z_][^`]*`" contained
sy match hs_InfixFunctionName "^\S[^=]*`[a-z_][^`]*`"me=e-1 contained contains=hs_HighliteInfixFunctionName,hsType,hsConSym,hsVarSym,hsString,hsCharacter
sy match hs_HlInfixOp "\(\W\&\S\&[^`(){}'[\]]\)\+" contained contains=hsString
sy match hs_InfixOpFunctionName "^\(\(\w\|[[\]{}]\)\+\|\(\".*\"\)\|\('.*'\)\)\s*[^:]=*\(\W\&\S\&[^='\"`()[\]{}@]\)\+"
    \ contained contains=hs_HlInfixOp,hsCharacter

sy match hs_OpFunctionName        "(\(\W\&[^(),\"]\)\+)" contained
sy region hs_Function start="^["'a-z_([{]" end="=\(\s\|\n\|\w\|[([]\)" keepend extend
        \ contains=hs_OpFunctionName,hs_InfixOpFunctionName,hs_InfixFunctionName,hs_FunctionName,hsType,hsConSym,hsVarSym,hsString,hsCharacter

sy match hs_DeclareFunction "^[a-z_(]\S*\(\s\|\n\)*::" contains=hs_FunctionName,hs_OpFunctionName

" hi hs_InfixOpFunctionName guibg=yellow
" hi hs_Function guibg=green
" hi hs_InfixFunctionName guibg=red
" hi hs_DeclareFunction guibg=red

sy keyword hsStructure data class where instance default deriving
sy keyword hsTypedef type newtype

sy keyword hsInfix infix infixl infixr
sy keyword hsStatement  do case of let in
sy keyword hsConditional if then else

if exists("hs_highlight_types")
  " Primitive types from the standard prelude and libraries.
  sy match hsType "\<[A-Z]\(\S\&[^,.]\)*\>"
  sy match hsType "()"
endif

" Not real keywords, but close.
if exists("hs_highlight_boolean")
  " Boolean constants from the standard prelude.
  syn keyword hsBoolean True False
endif

sy keyword hsModuleStartLabel module contained
sy keyword hsExportModuleLabel module contained
sy keyword hsModuleWhereLabel where contained
sy match hsImport		"\<import\>\(.\|[^(]\)*\((.*)\)\?" contains=hsImportLabel,hsImportMod,hsModuleName,hsImportList
sy keyword hsImportLabel import contained
sy keyword hsImportMod		as qualified hiding contained
sy match   hsModuleName  excludenl "\([A-Z]\w*\.\?\)*" contained 
sy region hsImportListInner start="(" end=")" contained keepend extend contains=hs_OpFunctionName
sy region  hsImportList matchgroup=hsImportListParens start="("rs=s+1 end=")"re=e-1
        \ contained 
        \ keepend extend
        \ contains=hsType,hsLineComment,hsBlockComment,hs_hlFunctionName,hsImportListInner
sy region hsExportListInner start="(" end=")" contained keepend extend 
sy region hsExportListInner start="(" end=")" contained keepend extend contains=hs_OpFunctionName
sy match hsExportModule "\<module\>\(\s\|\t\|\n\)*.*" contained contains=hsExportModuleLabel,hsModuleName
sy region hsExportList matchgroup=hsExportListParens start="("rs=s+1 end=")"re=e-1
        \ contained
        \ keepend extend
        \ contains=hsBlockComment,hsLineComment,hsType,hs_hlFunctionName,hsExportListInner,hsExportModule

sy keyword hsFFIForeign foreign contained
sy keyword hsFFIImportExport import export contained
sy keyword hsFFICallConvention ccall stdcall contained
sy keyword hsFFISafety safe unsafe contained
sy region  hsFFIString		start=+"+  skip=+\\\\\|\\"+  end=+"+  contained contains=hsSpecialChar
sy match hsFFI excludenl "\<foreign\>\(.\&[^\"]\)*\"\(.\)*\"\(\s\|\n\)*\(.\)*::"
  \ keepend
  \ contains=hsFFIForeign,hsFFIImportExport,hsFFICallConvention,hsFFISafety,hsFFIString,hs_OpFunctionName,hs_hlFunctionName

" hsModule regex MUST match all possible symbols between 'module' and 'where'
" else overlappings with other syntax elements will break correct hsModule 
" syntax highliting or evaluation of regex will stall vim.
"
" regex parts:
"   1: match keyword "module"
"   2: match modulename (optionaly comma separated)
"   3.1 and 3.2: parens of optional symbol list
"   4: final keyword "where"
"   5: any alphanumeric symbol
"   6: symbol list delimiter ","
"   7: any symbol non-alphanumeric symbol enclosed in parenthesis. e.g. (*)
"   8: optional line comment
"
"                                                                         |   optional Symbol List                            |
"                             |   1    |            |   2   |             |3.1| 5  6 :  7  :   8                          |3.2|            |   4   |
syn match hsModule excludenl "\<module\>\(\s\|\n\)*\(\<.*\>\)\(\s\|\n\)*\((\(\w\|,\|(\W*)\|--.*\n\|\.\|{\|}\|-\|\#\|'\|\s\|\n\)*)\)\?\(\s\|\n\)*\<where\>" 
    \ contains=hsModuleStartLabel,hsModuleWhereLabel,hsModuleName,hsExportList,hsModuleStart

"hi hsModule guibg=red

sy match   hsNumber		"\<[0-9]\+\>\|\<0[xX][0-9a-fA-F]\+\>\|\<0[oO][0-7]\+\>"
sy match   hsFloat		"\<[0-9]\+\.[0-9]\+\([eE][-+]\=[0-9]\+\)\=\>"

" Comments
sy keyword hsCommentTodo    TODO FIXME XXX TBD contained
sy match   hsLineComment      "---*\([^-!#$%&\*\+./<=>\?@\\^|~].*\)\?$" contains=hsCommentTodo,@Spell
sy region  hsBlockComment     start="{-"  end="-}" contains=hsBlockComment,hsCommentTodo,@Spell
sy region  hsPragma	       start="{-#" end="#-}"


if exists("hs_highlight_debug")
  " Debugging functions from the standard prelude.
  syn keyword hsDebug undefined error trace
endif



" C Preprocessor directives. Shamelessly ripped from c.vim and trimmed
" First, see whether to flag directive-like lines or not
if (!exists("hs_allow_hash_operator"))
    syn match	cError		display "^\s*\(%:\|#\).*$"
endif
" Accept %: for # (C99)
syn region	cPreCondit	start="^\s*\(%:\|#\)\s*\(if\|ifdef\|ifndef\|elif\)\>" skip="\\$" end="$" end="//"me=s-1 contains=cComment,cCppString,cCommentError
syn match	cPreCondit	display "^\s*\(%:\|#\)\s*\(else\|endif\)\>"
syn region	cCppOut		start="^\s*\(%:\|#\)\s*if\s\+0\+\>" end=".\@=\|$" contains=cCppOut2
syn region	cCppOut2	contained start="0" end="^\s*\(%:\|#\)\s*\(endif\>\|else\>\|elif\>\)" contains=cCppSkip
syn region	cCppSkip	contained start="^\s*\(%:\|#\)\s*\(if\>\|ifdef\>\|ifndef\>\)" skip="\\$" end="^\s*\(%:\|#\)\s*endif\>" contains=cCppSkip
syn region	cIncluded	display contained start=+"+ skip=+\\\\\|\\"+ end=+"+
syn match	cIncluded	display contained "<[^>]*>"
syn match	cInclude	display "^\s*\(%:\|#\)\s*include\>\s*["<]" contains=cIncluded
syn cluster	cPreProcGroup	contains=cPreCondit,cIncluded,cInclude,cDefine,cCppOut,cCppOut2,cCppSkip,cCommentStartError
syn region	cDefine		matchgroup=cPreCondit start="^\s*\(%:\|#\)\s*\(define\|undef\)\>" skip="\\$" end="$"
syn region	cPreProc	matchgroup=cPreCondit start="^\s*\(%:\|#\)\s*\(pragma\>\|line\>\|warning\>\|warn\>\|error\>\)" skip="\\$" end="$" keepend

syn region	cComment	matchgroup=cCommentStart start="/\*" end="\*/" contains=cCommentStartError,cSpaceError contained
syntax match	cCommentError	display "\*/" contained
syntax match	cCommentStartError display "/\*"me=e-1 contained
syn region	cCppString	start=+L\="+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end='$' contains=cSpecial contained


if version >= 508 || !exists("did_hs_syntax_inits")
  if version < 508
    let did_hs_syntax_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink hs_hlFunctionName    Function
  HiLink hs_HighliteInfixFunctionName Function
  HiLink hs_HlInfixOp       Function
  HiLink hs_OpFunctionName  Function
  HiLink hsTypedef          Typedef
  HiLink hsVarSym           hsOperator
  HiLink hsConSym           hsOperator
  if exists("hs_highlight_delimiters")
    " Some people find this highlighting distracting.
	HiLink hsDelimiter        Delimiter
  endif

  HiLink hsModuleStartLabel Structure
  HiLink hsExportModuleLabel Keyword
  HiLink hsModuleWhereLabel Structure
  HiLink hsModuleName       Normal

  HiLink hsImportLabel      Include
  HiLink hsImportMod        Include

  HiLink hsOperator         Operator

  HiLink hsInfix            Keyword
  HiLink hsStructure        Structure
  HiLink hsStatement        Statement
  HiLink hsConditional      Conditional

  HiLink hsSpecialCharError Error
  HiLink hsSpecialChar      SpecialChar
  HiLink hsString           String
  HiLink hsFFIString        String
  HiLink hsCharacter        Character
  HiLink hsNumber           Number
  HiLink hsFloat            Float

  HiLink hsLiterateComment		  hsComment
  HiLink hsBlockComment     hsComment
  HiLink hsLineComment      hsComment
  HiLink hsComment          Comment
  HiLink hsCommentTodo      Todo
  HiLink hsPragma           SpecialComment
  HiLink hsBoolean			  Boolean
  HiLink hsType             Type

  HiLink hsDebug            Debug

  HiLink cCppString         hsString
  HiLink cCommentStart      hsComment
  HiLink cCommentError      hsError
  HiLink cCommentStartError hsError
  HiLink cInclude           Include
  HiLink cPreProc           PreProc
  HiLink cDefine            Macro
  HiLink cIncluded          hsString
  HiLink cError             Error
  HiLink cPreCondit         PreCondit
  HiLink cComment           Comment
  HiLink cCppSkip           cCppOut
  HiLink cCppOut2           cCppOut
  HiLink cCppOut            Comment

  HiLink hsFFIForeign       Keyword
  HiLink hsFFIImportExport  Structure
  HiLink hsFFICallConvention Keyword
  HiLink hsFFISafety         Keyword

  delcommand HiLink
endif

let b:current_syntax = "haskell"

