#!/bin/bash

exec > >(tee -i $HOME/dotfiles_install.log)
exec 2>&1
set -x

## remove codespaces built-ins
rm -f $HOME/.zshrc

## setup
mkdir $HOME/.config/nvim

## link the things
ln -s $(pwd)/.zshrc $HOME/.zshrc
ln -s $(pwd)/.aliases $HOME/.aliases
ln -s $(pwd)/.config/nvim/* $HOME/.config/nvim/

## neovim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage
./nvim.appimage --appimage-extract
sudo mv squashfs-root /usr/local/squashfs-nvim
sudo ln -s /usr/local/squashfs-nvim/AppRun /usr/local/bin/nvim

### install vim-plug
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

### install plugins
nvim --headless +PlugInstall +qa

sudo chsh -s "$(which zsh)" "$(whoami)"

