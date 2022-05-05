## plugins
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt append_history
setopt share_history
unsetopt beep
zstyle :compinstall filename '/home/brain/.zshrc'

## asdf for compinit
fpath=(${ASDF_DIR}/completions $fpath)

autoload -Uz compinit promptinit colors
compinit
promptinit
colors

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

bindkey -v
vim_ins_mode="%{$fg[green]%}$%{$reset_color%}"
vim_cmd_mode="%{$fg[magenta]%}$%{$reset_color%}"
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

# I needed this at one point and I'm not sure why
# function TRAPINT() {
#   vim_mode=$vim_ins_mode
#   return $(( 128 + $1 ))
# } 

# Theming
## Prompt
function git_branch() {
	git symbolic-ref --short HEAD 2> /dev/null
}

setopt prompt_subst
RPROMPT='%{%F{cyan}%}$(pwd)%{%F{none}%} %{%F{green}%}$(git_branch)%{%F{none}%}'
PROMPT='${vim_mode} '

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
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"

### java
if [ -n "$OS_MAC" ]; then
		export JAVA_11_HOME="$(brew --prefix openjdk@11)/libexec/openjdk.jdk/Contents/Home"
		export JAVA_HOME="$(brew --prefix openjdk)/libexec/openjdk.jdk/Contents/Home"
elif [ -n "$OS_LINUX" ]; then
		# export JAVA_11_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
		export JAVA_HOME="$(find /usr/lib/jvm -type d -iname 'java-1*' 2>/dev/null | sort --reverse | head -n 1)"
fi

export PATH="$JAVA_HOME/bin:$PATH" 

export GRADLE_HOME="$HOME/.local/lib/gradle/gradle-7.4.1"
export PATH="$GRADLE_HOME/bin:$PATH"

## misc
export MANPAGER='nvim +Man!'

## local apps
export PATH="$HOME/.local/bin:$PATH"

#

## asdf
. $HOME/.asdf/asdf.sh
