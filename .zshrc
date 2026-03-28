# zmodload zsh/zprof

# ===============================
# Source Architecture-Specific Configurations
# ===============================

if [ -f "$HOME/.zsh_arch" ]; then
    source "$HOME/.zsh_arch"
else
    echo "Warning: ~/.zsh_arch not found. Please run ./script/setup."
fi

# ===============================
# PATH Configurations
# ===============================

export PATH="$HOME/.local/bin:$PATH"
export HOMEBREW_BREWFILE="$HOME/.brewfile"

# ===============================
# Mise En Place
# ===============================

if [ -n "$(command -v mise)" ]; then
		eval "$(mise activate zsh)"
fi

# ===============================
# Golang
# ===============================
if [ -n "$(command -v go)" ]; then
    export GOPATH=$(go env GOPATH)
    export PATH="$GOPATH/bin:$PATH"
fi

# ===============================
# Java
# ===============================

export PATH="$PATH:/Users/bryan/Library/Application Support/Coursier/bin"



# ===============================
# Antidote Plugin Setup
# ===============================

if [ -n "$(command -v antidote)" ]; then
		antidote load ${ZDOTDIR:-$HOME}/.zsh_plugins.txt
fi

## ==============================
## zsh-fzf-history-search
## ==============================
## Make sure to use double quotes
export ZSH_FZF_HISTORY_SEARCH_EVENT_NUMBERS=0
export ZSH_FZF_HISTORY_SEARCH_DATES_IN_SEARCH=0
export ZSH_FZF_HISTORY_SEARCH_REMOVE_DUPLICATES=1

## ==============================
## ZSH History
## ==============================
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

# ===============================
# Prompt, Completions, Colors, Etc
# ===============================
# Add your custom completions directory (e.g. containing the official _git) to your fpath
# fpath=(~/.zsh $fpath)
# if type brew &>/dev/null; then
# 		FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
# fi

# Set compinstall filename and match style
# zstyle :compinstall filename "$HOME/.zshrc"
# zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Load only native zsh completions (no bash completions)
autoload -Uz compinit promptinit colors

# Use a cached dump if available for faster startup
compdump="$HOME/.zcompdump"
if [[ -f "$compdump" && -z "$(find "$compdump" -mtime +7 -print 2>/dev/null)" ]]; then
    compinit -C -d "$compdump"
else
    compinit -d "$compdump"
fi

# Initialize prompt and colors
promptinit
colors

bindkey -v



# ===============================
# Shortcuts
# ===============================
[ -f $HOME/.aliases ] && . $HOME/.aliases
[ -f $HOME/.fns ] && . $HOME/.fns

if [[ -n $WORK ]]; then
		. $HOME/.aliases_work
fi

# ===============================
# Theming
# ===============================
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

# ===============================
# AI
# ===============================
export OPENCODE_DISABLE_LSP_DOWNLOAD=true


# ===============================
# Misc
# ===============================
if [ -n "$(command -v direnv)" ]; then
		eval "$(direnv hook zsh)"
fi

if [ -n "$(command -v op)" ]; then
		eval "$(op completion zsh)"; compdef _op op

		load-gemini-api-key() {
				if [ -n "${GEMINI_API_KEY:-}" ]; then
						return 0
				fi

				local gemini_api_key_value
				gemini_api_key_value="$(op read --no-newline 'op://bry-guy/GEMINI_API_KEY/credential' 2>/dev/null || true)"
				if [ -n "$gemini_api_key_value" ]; then
						export GEMINI_API_KEY="$gemini_api_key_value"
						return 0
				fi

				return 1
		}
fi

if [ -n "$(command -v gh)" ]; then
		load-gh-token() {
				if [ -n "${HOMEBREW_GITHUB_API_TOKEN:-}" ]; then
						return 0
				fi

				local gh_token
				gh_token="$(gh auth token 2>/dev/null || true)"
				if [ -n "$gh_token" ]; then
						export HOMEBREW_GITHUB_API_TOKEN="$gh_token"
						return 0
				fi

				return 1
		}
fi

if [ -n "$(command -v rg)" ]; then
		export FZF_DEFAULT_COMMAND='rg --files --hidden --smart-case'
fi

if [[ -o interactive ]] && [ -n "$(command -v brew)" ]; then
		export DOTFILES_BREW_STATE_DIR="$HOME/.local/state/dotfiles"
		export DOTFILES_BREW_DIRTY_FILE="$DOTFILES_BREW_STATE_DIR/brew-dirty"
		export DOTFILES_BREW_LAST_RUN_FILE="$DOTFILES_BREW_STATE_DIR/brew-audit-last-run"

		brew() {
				local cmd command_status
				cmd="${1:-}"

				command brew "$@"
				command_status=$?

				if [ "$command_status" -eq 0 ] && [ -z "${DOTFILES_BREW_NO_DIRTY:-}" ]; then
						case "$cmd" in
							install|reinstall|uninstall|tap|untap|upgrade)
								mkdir -p "$DOTFILES_BREW_STATE_DIR"
								touch "$DOTFILES_BREW_DIRTY_FILE"
								;;
						esac
				fi

				return "$command_status"
		}

		dotfiles_brew_reminder_precmd() {
				local profile command reminder

				if [ -n "${DOTFILES_BREW_REMINDER_SHOWN:-}" ]; then
						return
				fi

				if [ -f "$HOME/.config/dotfiles/brew-profile" ]; then
						profile="$(awk 'NF { print; exit }' "$HOME/.config/dotfiles/brew-profile")"
				fi
				if [ -n "${profile:-}" ]; then
						command="script/brew-audit $profile"
				else
						command="script/brew-audit <profile>"
				fi

				if [ -f "$DOTFILES_BREW_DIRTY_FILE" ]; then
						reminder="brew changed; run $command"
				elif [ ! -f "$DOTFILES_BREW_LAST_RUN_FILE" ] || [[ -n "$(find "$DOTFILES_BREW_LAST_RUN_FILE" -mtime +7 -print 2>/dev/null)" ]]; then
						reminder="brew audit overdue; run $command"
				fi

				if [ -n "${reminder:-}" ]; then
						print -P "%F{yellow}$reminder%f"
						export DOTFILES_BREW_REMINDER_SHOWN=1
				fi
		}

		add-zsh-hook precmd dotfiles_brew_reminder_precmd
fi

# fnox activation is project-local via direnv/.envrc

# zprof
