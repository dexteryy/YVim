
# YVim

Out-of-the-box `~/.vim` directory for MacVim (corresponding [~/.atom](https://github.com/dexteryy/dot-atom))

![YVim screenhhost](https://raw.github.com/dexteryy/YVim/master/screenshot.png)

## Prepare

* MacVim with ruby/python/lua (`brew install macvim --with-lua  --with-luajit && brew linkapps macvim`)
<!-- * [YCM's build environment](https://github.com/Valloric/YouCompleteMe#mac-os-x-super-quick-installation) (XCode, CMake, Go, etc.) -->

## Install

* `git clone https://github.com/dexteryy/YVim.git ~/.vim`
* `cd ~/.vim && ./install.sh`

## Features and keybindings

See [vimrc](https://github.com/dexteryy/YVim/blob/master/vimrc) and [gvimrc](https://github.com/dexteryy/YVim/blob/master/gvimrc)

## Tips

Atom-style:

* `<D-n>`                                   -  New tab
* `<D-N>`                                   -  New window
* `<D-o>`                                   -  Unite file
* `<D-O>`                                   -  Unite directory -> Vimfiler
* `<D-T>`                                   -  CtrlP MRU
* `<D-w>`                                   -  Quit current buffer window
* `<D-W>`                                   -  Close MacVim window
* `<D-z>`                                   -  Undo
* `<D-y>`                                   -  Redo
* `<D-C-Space>`                             -  Emoji & Special Characters
* `<D-/>`                                   -  Toggle comments
* `<D-M-[>` / `<D-M-]>`                     -  Fold / Unfold
* `<D-M-{>` / `<D-M-}>`                     -  Fold All / Unfold All
* `<D-M-,>`                                 -  Open .vimrc in new tab (Setting View)
* `<D-M-.>`                                 -  :map (Keybinding Resolver)
* `<D-M-i>`                                 -  Search for files (vimscripts, docs, snippets...) in runtimepath
* `<D-\>`                                   -  Toggle NerdTree
* `<D-f>`                                   -  CtrlP: Search for a line in all listed buffers
* `<D-F>`                                   -  ag.vim
* `<D-M-f>`                                 -  replace
* `<D-p>`                                   -  CtrlP (fuzzy file finder)
* `<D-b>`                                   -  Unite tab buffer
* `<D-P>`                                   -  Unite (Command Palette)
* `<C-h>` / `<C-M-h>`                       -  Look up in Dash
* `<D-E>`                                   -  Emmet expand

Vi-style:
* `,f` + `f|d|r|v|l|c|u|e|g|b|t|w|m|j|:|p`  -  CtrlP + Unite
* `,/`                                      -  Ag / Ack
* `,d` + `f|g`                              -  Dash
* `;` + `f|s|w|W|b|B|j|k`                   -  EasyMotion
* `.m` + `v|m|a|t|h`                        -  :marks + ShowMarks7
* `.n` + `Space|c|m|s|u`                    -  NERDCommenter + NERDTree
* `.s` + `s|c|o|d|`                         -  session
* `.g` + `s|l|h|v|d|b|r|s|p|s`              -  fugitive + extradite + gitgutter
* `.t` + `b|l|d|r`                          -  Tagbar, Tasklist, Tern
* `<C-A>` / `<C-D>` / `<C-X>`               -  multiple cursors
* `,q`
* `<F2>`                                    -  QuickRun
* `<F3>`                                    -  lint
* `<F4>`                                    -  make
* `<F5>`                                    -  Quickfix window
* `<F6>`                                    -  Loction List window
* `<F7>`                                    -  add breakpoint
* `<F8>`                                    -  add log
* `<F9>`                                    -  remove breakpoint / log
* `<F10>`                                   -  Gundo

Visual-mode:
* `K` / `J`                                 -  expand region
* `cs*` / `ds*` / `ys*`                     -  surround
* `<Enter>` + `r|<Space>|,|=|:|...`         -  easy align

Ex-style:
* `:Q`
* `:R`
* `:W`
* `:PlugUpdate`
* `:SuperTab`
* `:StripWhitespace`
* `:Gist`
* `:GHD` / `GHA`
* `:tabe NewVrc.rest`
* `:Toc`
* `:CSVTabulariz`
* `:Scratch`
* `:Thematic`


