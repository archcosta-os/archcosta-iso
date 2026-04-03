# ArchCosta Zsh Configuration
# Disable zsh-newuser-install plugin to prevent first-run wizard
zstyle ':prezto:module:zsh-newuser-install' enabled 'no'

# History
HISTFILE=~/.zhistory
HISTSIZE=10000
SAVEHIST=10000

# Basic options
setopt APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS

# Key bindings
bindkey -e

# Completions
autoload -Uz compinit
compinit

# Colors
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

#aliases
alias ls='ls --color=auto'
alias ll='ls -la'
alias la='ls -a'
