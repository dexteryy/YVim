# How to compile YouCompleteMe

### For Mac OS X and Homebrew Python/MacVim

Download [Clang Binaries for MacOS X/x86_64](http://llvm.org/releases/download.html#3.2). Archive file into `~/Downloads/TD/clang+llvm-3.2-x86_64-apple-darwin11/`

```
brew rm python
brew install python
brew install macvim --with-python3 --with-lua --with-cscope --override-system-vim --custom-icons

cd ~
mkdir ycm_build
mkdir -p ~/ycm_temp/llvm_root_dir

mv ~/Downloads/TD/clang+llvm-3.2-x86_64-apple-darwin11/* ~/ycm_temp/llvm_root_dir/

cd ycm_build

cmake -G "Unix Makefiles" -DPATH_TO_LLVM_ROOT=~/ycm_temp/llvm_root_dir -DPYTHON_INCLUDE_DIR=/usr/local/Frameworks/Python.framework/Headers -DPYTHON_LIBRARY=/usr/local/Frameworks/Python.framework/Python . ~/.vim/bundle/YouCompleteMe/cpp

make ycm_core

cd ~/.vim/bundle/YouCompleteMe
cp ~/ycm_temp/llvm_root_dir/lib/libclang.dylib ~/.vim/bundle/YouCompleteMe/python

gvim
```

