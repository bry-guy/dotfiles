## plugins
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
unsetopt beep
zstyle :compinstall filename '/home/brain/.zshrc'

autoload -Uz compinit promptinit
compinit
promptinit

## detect OS
[ -f $HOME/.os_detect ] && source $HOME/.os_detect

## config files
[ -f $HOME/.secrets ] && . $HOME/.secrets
[ -f $HOME/.aliases ] && . $HOME/.aliases

## lang
export LANG="en_US.UTF-8"

## History search using text behind cursor
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward

## Match case-insensitive 
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 

## vim cursor
vim_ins_mode="%{$fg[magenta]%}\$%{$reset_color%}"
vim_cmd_mode="%{$fg[yellow]%}\$%{$reset_color%}"
vim_mode=$vim_ins_mode

function zle-keymap-select {
  vim_mode="${${KEYMAP/vicmd/${vim_cmd_mode}}/(main|viins)/${vim_ins_mode}}"
  zle reset-prompt
}
zle -N zle-keymap-select

function zle-line-finish {
  vim_mode=$vim_ins_mode
}
zle -N zle-line-finish

function TRAPINT() {
  vim_mode=$vim_ins_mode
  return $(( 128 + $1 ))
} 


# Theming
## Prompt
function git_branch() {
	git symbolic-ref --short HEAD 2> /dev/null
}

function git_root() {
		git_root=$(git rev-parse --show-toplevel 2>/dev/null)

		if [ -n "${git_root// }" ]; then
				basename $git_root
		else
				basename $(pwd)
		fi
}

setopt prompt_subst
PROMPT='%{%F{cyan}%}$(git_root)%{%F{none}%} %{%F{green}%}$(git_branch)%{%F{none}%} ${vim_mode} '

## Title Bar
case ${TERM} in
 alacritty)
	  precmd () {
		  print -Pn "\e]0;$USER@$HOST:$(dirs)\a"
	  }
          ;;
 xterm-256color) precmd () {
		  echo -ne "\033]0;$(dirs)\007"
	  }
          ;;
esac

### zsh
export KEYTIMEOUT=1

### cscope
export CSCOPE_EDITOR=usr/bin/nvim

### coreutils
export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"

### brew
export PATH="/usr/local/bin:$PATH"
export PATH="/usr/local/Cellar:$PATH"

### mysql
export PATH="/usr/local/opt/mysql@5.7/bin:$PATH"

### Neovim
export EDITOR=$HOME/.local/bin/nvim
export VISUAL=$HOME/.local/bin/nvim

### FZF settings (configured for fzf.vim)
export FZF_DEFAULT_COMMAND='rg --files --hidden --smart-case'

### ruby
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

### java
if [ -n "$OS_MAC" ]; then
		export JAVA_11_HOME="/Library/Java/JavaVirtualMachines/openjdk-11.jdk/Contents/Home" 
		export JAVA_HOME="$(find /Library/Java/JavaVirtualMachines -iname 'openjdk-*' 2>/dev/null | sort --reverse | head -n 1)/Contents/Home" 
elif [ -n "$OS_LINUX" ]; then
		export JAVA_11_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
		export JAVA_HOME=$(find /usr/lib/jvm -type d -iname 'java-1*' 2>/dev/null | sort --reverse | head -n 1) 
fi

export PATH="$JAVA_HOME/bin:$PATH" 

export GRADLE_HOME="$HOME/.local/lib/gradle/gradle-7.4.1"
export PATH="$GRADLE_HOME/bin:$PATH"

### nvm/npm
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

## misc
export MANPAGER='nvim +Man!'

## local apps
export PATH="$HOME/.local/bin:$PATH"

