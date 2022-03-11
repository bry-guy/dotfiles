## plugins
# export ZPLUG_HOME=/usr/local/opt/zplug
# source $ZPLUG_HOME/init.zsh

# zplug "jeffreytse/zsh-vi-mode"
# bindkey -v
# export ZVM_TERM=xterm-256color

# zplug load --verbose

## auto-generated
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
unsetopt beep
zstyle :compinstall filename '/home/brain/.zshrc'

autoload -Uz compinit promptinit
compinit
promptinit

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
git_branch() {
	git symbolic-ref --short HEAD 2> /dev/null
}

git_root() {
		basename $(git rev-parse --show-toplevel)
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
# export PATH="/usr/local/opt/mysql@5.7:$PATH"
export PATH="/usr/local/opt/mysql@5.7/bin:$PATH"


### Neovim
export EDITOR=/usr/local/bin/nvim
export VISUAL=/usr/local/bin/nvim

### FZF settings (configured for fzf.vim)
export FZF_DEFAULT_COMMAND='rg --files --hidden --smart-case'

### ruby
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

## misc
export MANPAGER='nvim +Man!'

