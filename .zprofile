if [ "$(uname -s)" = 'Linux' ] && [ ! -f /etc/fedora-release ]; then
		eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
		source $HOMEBREW_PREFIX/antidote/share/antidote/antidote.zsh
elif [ "$(uname -s)" = 'Linux' ] && [ -f /etc/fedora-release ]; then
		source $HOME/.antidote/antidote.zsh
elif [ "$(uname -m)" = 'arm64' ]; then
		eval "$(/opt/homebrew/bin/brew shellenv)"
		source $HOMEBREW_PREFIX/opt/antidote/share/antidote/antidote.zsh
elif [ "$(uname -m)" = 'x86_64' ]; then
		eval "$(/usr/local/bin/brew shellenv)"
		source $HOMEBREW_PREFIX/opt/antidote/share/antidote/antidote.zsh
fi
