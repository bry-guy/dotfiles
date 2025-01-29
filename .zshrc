# Path configurations
export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
export PATH="/usr/local/bin:$PATH"
export PATH="/usr/local/Cellar:$PATH"
export PATH="/usr/local/opt/mysql@5.7/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH="$HOME/.rd/bin:$PATH"
export FZF_DEFAULT_COMMAND='rg --files --hidden --smart-case'
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"
export AICHAT_CONFIG_DIR="$HOME/.config/aichat/"
export AICHAT_ROLES_FILE="$HOME/.config/aichat/roles.yaml"
export PG_HOME="$(brew --prefix)/var/postgres"
export HOMEBREW_BREWFILE="$HOME/.brewfile"

# asdf
ASDF_FORCE_PREPEND=yes . $(brew --prefix asdf)/libexec/asdf.sh

## golang
. ~/.asdf/plugins/golang/set-env.zsh
export GOPATH=$(asdf where golang)/packages
export GOROOT=$(asdf where golang)/go
export GOMODCACHE=$(asdf where golang)/packages/pkg/mod
export PATH=$PATH:$(go env GOPATH)/bin

## java 
. ~/.asdf/plugins/java/set-java-home.zsh


# zmodload zsh/zprof # debug enable

# Source zplug
source ~/.zplug/init.zsh

# Define plugins
zplug "joshskidmore/zsh-fzf-history-search"

# Check if the plugins are installed and install them if they are not
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    else
        echo; echo "Skipping plugin installation."
    fi
fi

# Load the plugins
zplug load

## bind vi keys
bindkey -v

## zsh-fzf-history-search
## Make sure to use double quotes
# export ZSH_FZF_HISTORY_SEARCH_BIND="^R"
export ZSH_FZF_HISTORY_SEARCH_EVENT_NUMBERS=0
export ZSH_FZF_HISTORY_SEARCH_DATES_IN_SEARCH=0
export ZSH_FZF_HISTORY_SEARCH_REMOVE_DUPLICATES=1

## history
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY  # Write to the history file immediately, not when the shell exits.
setopt HIST_FIND_NO_DUPS  # Do not display duplicates in the history list.
setopt HIST_IGNORE_ALL_DUPS  # Remove old duplicates leaving just the most recent entry in the history.


## History search using text behind cursor
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward

unsetopt beep
zstyle :compinstall filename '/home/brain/.zshrc'
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # match case-insensitive 

## zsh completions
fpath=(${ASDF_DIR}/completions $fpath)
fpath=(~/.zsh/completions $fpath)



### https://medium.com/@dannysmith/little-thing-2-speeding-up-zsh-f1860390f92
autoload -Uz compinit bashcompinit promptinit colors
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

## Theming
## Prompt customization functions and settings
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

## Title Bar customization based on the terminal type
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

## vim mode indicators
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

## direnv
eval "$(direnv hook zsh)"

## onepass
eval "$(op completion zsh)"; compdef _op op

## terraform
complete -o nospace -C /opt/homebrew/bin/terraform terraform

## support-cli (agentsync)
export DOPPLER_TOKEN="$(doppler configure get token --plain)"
export HOMEBREW_GITHUB_API_TOKEN="$(gh auth token)"
export AUTH_USER_EMAIL=bryan.smith@agentsync.io
