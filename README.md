

# YVim

Out-of-the-box ~/.vim directory for MacVim

![YVim screenhhost](https://raw.github.com/dexteryy/YVim/master/screenshot.png)

## Prepare

* MacVim with ruby/python/lua (`brew install macvim --with-lua  --with-luajit && brew linkapps macvim`)
* [YCM's build environment](https://github.com/Valloric/YouCompleteMe#mac-os-x-super-quick-installation) (XCode, CMake, Go, etc.)

## Install

* `git clone https://github.com/dexteryy/YVim.git ~/.vim`
* `cd ~/.vim && ./install.sh`

## Features and keybindings

See [vimrc](https://github.com/dexteryy/YVim/blob/master/vimrc) and [gvimrc](https://github.com/dexteryy/YVim/blob/master/gvimrc)

## Tips

Atom-style:

TBD

Vi-style:
* `,f` sequences / `<C-p>` - CtrlP + Unite  
* `,/` / `<D-f>` - Ag / Ack  
* `;` sequences - EasyMotion  
* `.m` sequences - ShowMarks7  
* `.n` sequences - NERDCommenter + NERDTree  
* `.s` sequences - session  
* `.g` sequences - fugitive + gitgutter  
* `.t` sequences - Tagbar, Tasklist, Tern  
* `<C-A/D/X>` - multiple cursors  
* `<C-e>` sequences - emmet  
* `<C-j/k/h/l>` - `<C-w>j/k/h/l`  
* `<C-v/s>` - `<C-w>v/s`  
* `,q`  
* `<F2>` - QuickRun  
* `<F3>` - lint  
* `<F4>` - make  
* `<F5>` - Quickfix window  
* `<F6>` - Loction List window  
* `<F7>` - add breakpoint  
* `<F8>` - add log  
* `<F9>` - remove breakpoint / log  
* `<F10>` - Gundo  

Visual-mode:
* `K` / `J` - expand region  
* `cs*` / `ds*` / `ys*` - surround  

Ex-style:
* `:Q`  
* `:R`  
* `:W`  
* `:PlugUpdate`  
* `:SuperTab`  
* `:Tabularize`  
* `:StripWhitespace`  
* `:Toc`  
* `:CSVTabulariz`  
* `:Scratch`  


