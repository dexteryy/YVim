" Vim color scheme
" Name:         yytextmate.vim
" Maintainer:  	Dexter.Yy <dexter.yy@gmail.com> 
" Link:         http://www.limboy.com
" (originally looked at Ralph Amissah <ralph@amissah.com>)

:set background=dark
:highlight clear
if version > 580
 hi clear
 if exists("syntax_on")
 syntax reset
 endif
endif
if has("gui_running")
	:hi Normal guifg=#F8F8F8 guibg=#090B18
	:hi Cursor guifg=Black guibg=Yellow
	
	:hi LineNr guifg=#333333
  	":hi LineNr guibg=#323232 guifg=#888888
	:hi VertSplit guibg=#c2bfa5 guifg=grey40 gui=none
	:hi Folded guibg=black guifg=grey40
	:hi FoldColumn guibg=black guifg=grey20 
	:hi IncSearch guibg=black guifg=yellow 
	:hi ModeMsg guifg=goldenrod
	:hi MoreMsg guifg=SeaGreen
	:hi NonText guifg=RoyalBlue guibg=#151825
	:hi Question guifg=springgreen
	:hi Search guibg=#0099ff guifg=White
	:hi Visual gui=none guifg=khaki guibg=olivedrab
	
	:hi SpecialKey guifg=#cbfe29
	:hi Title guifg=#ff9900 gui=bold
	:hi Statement guifg=#ff6600
	:hi htmlStatement guifg=#60a3f6
	:hi String guifg=#61ce38
	:hi Comment guifg=grey35 
	:hi CommentDoc guifg=grey50 
	:hi Conditional guifg=#ffee14
	:hi Constant guifg=#cbfe29
	:hi Special guifg=#86A7D0
	:hi Identifier guifg=#ff9900 gui=bold
	:hi Include guifg=red
	:hi PreProc guifg=grey
	:hi Operator gui=bold guifg=#ff9900
	:hi Define guifg=#ffde00 gui=bold
	:hi Type guifg=#60a3f6
	:hi Function guifg=#ffde00 gui=NONE
	:hi Structure gui=bold guifg=#ff6600

	:hi Ignore guifg=grey40
	:hi StatusLineNC guibg=#c2bfa5 guifg=grey40 gui=none
	:hi StatusLine guibg=#c2bfa5 guifg=black gui=none 
	:hi Todo guifg=orangered guibg=yellow2
	:hi WarningMsg guifg=salmon
	:hi ErrorMsg guifg=White guibg=Red
	:hi Error guifg=White guibg=Red 
	:hi SpellErrors guifg=White guibg=Red
end
