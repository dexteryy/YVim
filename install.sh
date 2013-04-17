#!/usr/bin/env bash

set -e

ln -s $(PWD)/vimrc ~/.vimrc

ln -s $(PWD)/gvimrc ~/.gvimrc

vim -c ':BundleInstall'
