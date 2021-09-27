#!/bin/bash

exec > >(tee -i $HOME/dotfiles_install.log)
exec 2>&1
set -x

## remove codespaces built-ins
rm -f $HOME/.zshrc

ln -s $(pwd)/.zshrc $HOME/.zshrc
ln -s $(pwd)/.aliases $HOME/.aliases

sudo chsh -s "$(which zsh)" "$(whoami)"
