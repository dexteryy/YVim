#!/usr/bin/env bash

set -e

if [ -L ~/.vimrc ]; then
    echo "Check ~/.vimrc"
elif [ -f ~/.vimrc ]; then
    echo "Error: ~/.vimrc exists"
    exit 0
else
    ln -s $(PWD)/vimrc ~/.vimrc
    echo "Create ~/.vimrc"
fi

if [ -L ~/.gvimrc ]; then
    echo "Check ~/.gvimrc"
elif [ -f ~/.gvimrc ]; then
    echo "Error: ~/.gvimrc exists"
    exit 0
else
    ln -s $(PWD)/gvimrc ~/.gvimrc
    echo "Create ~/.gvimrc"
fi

vim +PluginInstall +qall
