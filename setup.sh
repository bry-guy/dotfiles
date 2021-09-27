#!/bin/bash

exec > >(tee -i $HOME/dotfiles_install.log)
exec 2>&1
set -x

sudo chsh -s "$(which zsh)" "$(whoami)"
