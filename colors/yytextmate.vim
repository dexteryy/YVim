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
	:hi Normal guifg=#f9f9f9 guibg=#080A20
	:hi Cursor guibg=Yellow
	:hi Visual guibg=#2D498B gui=none
	:hi Pmenu guifg=#333333 guibg=#E3E3E3
	:hi PmenuSel guifg=#ffffff guibg=#0264A2
	
	:hi CursorLine guibg=#16182D
	":hi LineNr guifg=grey20
	:hi LineNr guifg=#666666 guibg=#eeeeee
	:hi VertSplit guibg=#E6E6E6 guifg=#666666 gui=none
	:hi Folded guifg=grey40 guibg=black
	:hi FoldColumn guifg=grey20 guibg=black
	:hi SignColumn guibg=#666666 guibg=#E6E6E6
	:hi IncSearch guibg=black guifg=yellow 
	:hi ModeMsg guifg=goldenrod
	:hi MoreMsg guifg=Green guibg=black
	:hi NonText guifg=RoyalBlue guibg=#151825
	:hi Question guifg=springgreen
	:hi Search guibg=#0099ff guifg=White
	:hi SpecialKey guifg=#D3FE36
	:hi Title guifg=#ff9900 gui=bold
	:hi Statement guifg=#FFE619
	":hi Statement       guifg=#F92672               gui=bold
	:hi htmlStatement guifg=#99B5D9
	:hi String guifg=#2CDF41
	:hi Comment guifg=grey35 gui=italic
	:hi CommentDoc guifg=grey20 guibg=black gui=italic
	:hi CommentDocTags guifg=grey35 guibg=black
	:hi Conditional guifg=#FFE619
	:hi Repeat guifg=#FFE619
	:hi Constant guifg=#D4FF36
	:hi Boolean guifg=#D4FF36
	:hi Number guifg=#D4FF36
	:hi Special guifg=#99B5D9
	:hi Identifier guifg=#ff9900 gui=bold
	:hi Include guifg=red
	:hi PreProc guifg=grey
	:hi Operator gui=bold guifg=#FFE619
	:hi Keyword gui=bold guifg=#FFE619
	:hi Define guifg=#FFE619 gui=bold
	:hi Type guifg=#99B5D9 "gui=bold guifg=#FFE619
	:hi Function guifg=#FF6900 gui=NONE
	:hi Structure guifg=#FF6900 gui=bold
	:hi Label guifg=#FF6900
	:hi Exception guifg=#CC1D20
	:hi Builtin guifg=#99B5D9

	:hi Ignore guifg=grey40
	":hi StatusLineNC guibg=#E6E6E6 guifg=#000000 gui=none
	":hi StatusLine guibg=#E6E6E6 guifg=#000000 gui=none 
	":hi StatusLine      guifg=#CD5907 guibg=fg
	:hi StatusLine    guifg=#808080 guibg=#080808
	:hi StatusLineNC    guifg=#808080 guibg=#080808
	
	:hi Todo guifg=orangered guibg=yellow2
	:hi WarningMsg guifg=#CC1D20
	:hi Debug guifg=#CC1D20
	:hi ErrorMsg guifg=#F9F9F9 guibg=#BF0013
	:hi Error guifg=#F9F9F9 guibg=#BF0013 
	:hi SpellErrors guifg=#F9F9F9 guibg=#BF0013
end
