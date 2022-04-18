if [ "$(uname -s)" = 'Linux' ]; then
		eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
eval $(/opt/homebrew/bin/brew shellenv)
