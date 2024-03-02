# Environment Variables
export LANG="en_US.UTF-8"
export KEYTIMEOUT=1
export CSCOPE_EDITOR=/usr/bin/nvim
export EDITOR=nvim
export VISUAL=nvim
export FZF_DEFAULT_COMMAND='rg --files --hidden --smart-case'
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"
export MANPAGER='nvim +Man!'
export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
export AICHAT_CONFIG_DIR="$HOME/.config/aichat/"
export AICHAT_ROLES_FILE="$HOME/.config/aichat/roles.yaml"
export PG_HOME="$(brew --prefix)/var/postgres"

# Path configurations
export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
export PATH="/usr/local/bin:$PATH"
export PATH="/usr/local/Cellar:$PATH"
export PATH="/usr/local/opt/mysql@5.7/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH="$HOME/.rd/bin:$PATH"

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

