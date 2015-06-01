

# YVim

Out-of-the-box ~/.vim directory for MacVim

![YVim screenhhost](https://raw.github.com/dexteryy/YVim/master/screenshot.png)

## Install

```
git clone https://github.com/dexteryy/YVim.git ~/.vim
cd ~/.vim
git submodule update --init
./install.sh
```

### Optional steps

[Build YouCompleteMe](https://github.com/Valloric/YouCompleteMe#installation)
For example:
```
cd bundle/YouCompleteMe
git submodule update --init --recursive
brew install cmake
./install.sh --gocode-completer --clang-completer
```

[Build Tern](https://github.com/marijnh/tern_for_vim)
For example:
```
cd bundle/tern_for_vim
npm install
```
## features and keybindings

See [vimrc](https://github.com/dexteryy/YVim/blob/master/vimrc) and [gvimrc](https://github.com/dexteryy/YVim/blob/master/gvimrc)



