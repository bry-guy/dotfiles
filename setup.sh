#!/bin/bash

exec > >(tee -i $HOME/dotfiles_install.log)
exec 2>&1
set -x

## remove codespaces built-ins
rm -f $HOME/.zshrc

ln -s $(pwd)/.zshrc $HOME/.zshrc
ln -s $(pwd)/.aliases $HOME/.aliases

## install neovim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage
./nvim.appimage --appimage-extract
sudo mv squashfs-root /usr/local/ 
sudo ln -s /usr/local/squashfs-root/AppRun /usr/bin/nvim

sudo chsh -s "$(which zsh)" "$(whoami)"
