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
ln -s $(pwd)/.config/nvim/init.vim $HOME/.config/nvim/init.vim
ln -s $(pwd)/.config/nvim/__plugins.vim $HOME/.config/nvim/__plugins.vim
ln -s $(pwd)/.config/nvim/_fzf.vim $HOME/.config/nvim/_fzf.vim
ln -s $(pwd)/.config/nvim/_theming.vim $HOME/.config/nvim/_theming.vim


## neovim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage
./nvim.appimage --appimage-extract
sudo mv squashfs-root /usr/local/ 
sudo ln -s /usr/local/squashfs-root/AppRun /usr/local/bin/nvim

### install vim-plug
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

### install plugins
nvim --headless +PlugInstall +q

sudo chsh -s "$(which zsh)" "$(whoami)"
