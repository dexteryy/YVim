" vim600: set foldmethod=marker:
" Simple SVN utility for vim.  0.003001
" tag@cpan.org

" svn.vim - Relatively simple script for interacting with SVN. 
" ----------------------------------------------------------------------------
" "THE BEER-WARE LICENSE" (Revision 43) borrowed from FreeBSD's jail.c:
" <tag@cpan.org> wrote this file.  As long as you retain this notice you
" can do whatever you want with this stuff. If we meet some day, and you think
" this stuff is worth it, you can buy me a beer in return.   Scott S. McCoy
" ----------------------------------------------------------------------------
"  See doc/svn.txt for documentation


let g:CommitWindow = 0
let g:svnVersion = 0.002

" Section: Command Registers {{{
com! -nargs=* SVN       call SvnMain(<f-args>)
com! -nargs=* Svn       call SvnMain(<f-args>)
com! -nargs=* Commit    call SvnCommit(<f-args>)
com! -nargs=* Update    call SvnUpdate()    
com! -nargs=* Add       call SvnAdd()
com! -nargs=* Log       call SvnLog()    
com! -nargs=* Complete  call SvnComplete()    

" }}}
" Section: KeyMappings {{{

if exists("$VIM_SVN_KEY")
    let maplocalleader = $VIM_SVN_KEY
endif

map <Leader><LocalLeader>c :Svn commit<CR>
map <Leader><LocalLeader>C :Svn complete<CR>
map <Leader><LocalLeader>u :Svn update<CR>
map <Leader><LocalLeader>l :Svn log<CR>
map <Leader><LocalLeader>a :Svn add<CR>

" }}}
" Section: Handling Routines {{{

fu! SvnLog()
    new
    r!svn log
    0
endfunction

fu! SvnAdd(...)
    w
    if a:0 == 0
        exe "! svn add %"
    else
        let filename = a:1
        exe "! svn add " . filename
    endif
endfunction    

fu! SvnCommit(...)
    new

    silent! r!svn status | grep -vE '^\?'

    call append(0,"")
    call append(1,"--This line, and those below, will be ignored--")
    0

    echo "use :Complete to finish"
    let g:CommitWindow = winnr()
endfunction

fu! SvnComplete()
    if winnr() == g:CommitWindow
        call append(0,"#!/bin/sh")
        call append(1, "cat <<SVN > $1")
        call cursor(5000000, 0)
        call append(line("."), "SVN")
        w svnedit.sh
        silent! ! chmod 755 svnedit.sh;EDITOR=$PWD/svnedit.sh svn commit;rm svnedit.sh;svn update
        close!
        let g:CommitWindow = 0

    else
        echoerr "Not currently in a commit window!"
    endif    
endfunction
    

fu! SvnUpdate()
    ! svn update
endfunction    

" }}}
" Section: Main SVN Handler {{{

fu! SvnMain(...)
    if a:0 != 0
        let svn_c = a:1

        if svn_c == "commit"
            call SvnCommit()
        
        elseif svn_c == "checkout"
            if a:0 > 1
                let svn_rs = a:2
                exe "!svn checkout " . svn_rs
            else
                echomsg "Usage: SVN checkout <repository>"
            endif    
            
        elseif svn_c == "update"
            call SvnUpdate()
     
        elseif svn_c == "log"
            call SvnLog()

        elseif svn_c == "complete"
            call SvnComplete()

        elseif svn_c == "add"
            if a:0 > 1
                call SvnAdd(a:2)
            else
                call SvnAdd()
            endif

        elseif svn_c == "help"
            help svn
        
        else
            let i = a:0
            let svn_c = ""

            while i
                exe "let svn_c = a:" . i . " . \" \" . svn_c"
                let i = i - 1
            endwhile

            exe "!svn " . svn_c
        endif    
    else
        echomsg "Usage: SVN <command> same as bin/svn"
    endif
endfunction    

" }}}
