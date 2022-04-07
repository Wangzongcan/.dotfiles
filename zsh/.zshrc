#!/bin/zsh

### Functions
function source_file() {
  local file_path="$1"
  [[ -f "$file_path" ]] && source "$file_path"
}

### Aliases
if type gls > /dev/null 2>&1; then
  alias ls="gls"
fi
alias ls="ls --color=auto"
alias l="ls -hl --group-directories-first"
alias ll="l -a"

alias ta="tmux attach-session"
alias tn="tmux -u new -s \$(basename \$PWD)"

alias vim="nvim"

### Zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
source_file "${ZINIT_HOME}/zinit.zsh"

zinit ice lucid wait='0'
zinit light zsh-users/zsh-completions

zinit ice lucid wait="0" atload='_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions

zinit ice lucid wait='0' atinit='zpcompinit'
zinit light zsh-users/zsh-syntax-highlighting

zinit light zdharma-continuum/history-search-multi-word

zinit light zsh-git-prompt/zsh-git-prompt
ZSH_THEME_GIT_PROMPT_PREFIX=" ("
ZSH_THEME_GIT_PROMPT_SUFFIX=")"
PROMPT='%{$fg_bold[red]%}%1~%b$(git_super_status) %{$fg_bold[cyan]%}»%{$reset_color%} '

zinit snippet PZTM::completion

### ASDF
source_file $HOME/.asdf/asdf.sh
fpath=($HOME/.asdf/completions $fpath)
source_file $HOME/.asdf/plugins/java/set-java-home.zsh

### Localrc
source_file $HOME/.localrc

autoload -Uz compinit; compinit
zinit cdreplay -q
