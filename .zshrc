# zmodload zsh/zprof # debug enable

## plugins
source ~/.zplug/init.zsh
zplug "joshskidmore/zsh-fzf-history-search"

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# Then, source plugins and add commands to $PATH
zplug load

## bind vi keys
bindkey -v

## zsh-fzf-history-search
## Make sure to use double quotes
export ZSH_FZF_HISTORY_SEARCH_BIND="^R"
export ZSH_FZF_HISTORY_SEARCH_EVENT_NUMBERS=0
export ZSH_FZF_HISTORY_SEARCH_DATES_IN_SEARCH=0
export ZSH_FZF_HISTORY_SEARCH_REMOVE_DUPLICATES=1


## history
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt append_history
setopt share_history

## History search using text behind cursor
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward
# bindkey "^r" history-incremental-search-backward

unsetopt beep
zstyle :compinstall filename '/home/brain/.zshrc'

## asdf for compinit
fpath=(${ASDF_DIR}/completions $fpath)
# autoload -U +X bashcompinit && bashcompinit
# https://medium.com/@dannysmith/little-thing-2-speeding-up-zsh-f1860390f92
autoload -Uz compinit bashcompinit promptinit colors
# for dump in ~/.zcompdump(N.mh+24); do
#   compinit
# done
rm -f ~/.zcompdump(N.mh+24)
compinit
bashcompinit
promptinit
colors

## detect OS and arch
[ -f $HOME/.detect_os ] && source $HOME/.detect_os
[ -f $HOME/.detect_arch ] && source $HOME/.detect_arch

## config files
[ -f $HOME/.secrets ] && . $HOME/.secrets
[ -f $HOME/.aliases ] && . $HOME/.aliases
[ -f $HOME/.fns ] && . $HOME/.fns

## lang
export LANG="en_US.UTF-8"


## Match case-insensitive 
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 

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

function git_repo() {
		git rev-parse --show-toplevel 2>/dev/null | xargs basename
}

function current_process() {
    ps -o comm= -p $$
}

setopt prompt_subst
autoload -Uz add-zsh-hook
function aws_prompt_precmd() {
		if [[ -n $AWS_VAULT ]]; then
				if [[ $AWS_VAULT == *prod* ]]; then
						# Set to bold and red
						PROMPT="%B%F{red}[$AWS_VAULT]%f%b ${vim_mode} "
				else
						# Set to bold and yellow
						PROMPT="%B%F{yellow}[$AWS_VAULT]%f%b ${vim_mode} "
				fi
		else
				PROMPT="${vim_mode} "
		fi
}

add-zsh-hook precmd aws_prompt_precmd

## Title Bar
case ${TERM} in
 alacritty)
		 precmd () {
				 print -Pn "\e]0;%~\a"
		 }
		 ;;
 *-256color)
		 precmd () {
				 print -Pn "\e]0;%~\a"
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
export EDITOR=nvim
export VISUAL=nvim

### FZF settings (configured for fzf.vim)
export FZF_DEFAULT_COMMAND='rg --files --hidden --smart-case'

### ruby
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"

### java
. ~/.asdf/plugins/java/set-java-home.zsh

# if [ -n "$OS_MAC" ]; then
# 		export JAVA_11_HOME="$(brew --prefix openjdk@11)/libexec/openjdk.jdk/Contents/Home"
# 		export JAVA_HOME="$(brew --prefix openjdk)/libexec/openjdk.jdk/Contents/Home"
# elif [ -n "$OS_LINUX" ]; then
# 		# export JAVA_11_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
# 		export JAVA_HOME="$(find /usr/lib/jvm -type d -iname 'java-1*' 2>/dev/null | sort --reverse | head -n 1)"
# fi

# export PATH="$JAVA_HOME/bin:$PATH" 

# export GRADLE_HOME="$HOME/.local/lib/gradle/gradle-7.4.1"
# export PATH="$GRADLE_HOME/bin:$PATH"

## misc
export MANPAGER='nvim +Man!'

## local apps
export PATH="$HOME/.local/bin:$PATH"

# postgres
export PG_HOME="$(brew --prefix)/var/postgres"

## direnv
eval "$(direnv hook zsh)"

## onepass
eval "$(op completion zsh)"; compdef _op op

## terraform
complete -o nospace -C /opt/homebrew/bin/terraform terraform

## asdf
. $(brew --prefix asdf)/libexec/asdf.sh

## asdf golang
. ~/.asdf/plugins/golang/set-env.zsh

## brew
export PATH="/usr/local/sbin:$PATH"

## functions
#
## declare fbar function
aws-set-creds() { eval $(aws-sso-creds export --profile $1) }

# zprof # debug enable
# macOS
export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
# linux
# export SSH_AUTH_SOCK=~/.1password/agent.sock

# rancher
export PATH="$HOME/.rd/bin:$PATH"
