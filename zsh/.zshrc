#!/bin/zsh

### Zsh Unplugged
ZPLUGINDIR=${ZPLUGINDIR:-${ZDOTDIR:-$HOME/.config/zsh}/plugins}

if [[ ! -d $ZPLUGINDIR/zsh_unplugged ]]; then
    git clone --quiet https://github.com/mattmc3/zsh_unplugged $ZPLUGINDIR/zsh_unplugged
fi
source $ZPLUGINDIR/zsh_unplugged/zsh_unplugged.plugin.zsh

repos=(
    zsh-users/zsh-completions
    zsh-users/zsh-autosuggestions
    zsh-users/zsh-syntax-highlighting

    zsh-git-prompt/zsh-git-prompt
    zdharma-continuum/history-search-multi-word
)

plugin-load $repos

### Plugin Configuration
fpath=($ZPLUGINDIR/zsh-completions/src $fpath)

ZSH_THEME_GIT_PROMPT_PREFIX=" ("
ZSH_THEME_GIT_PROMPT_SUFFIX=")"
PROMPT='%{$fg_bold[red]%}%1~%b$(git_super_status) %{$fg_bold[cyan]%}»%{$reset_color%} '

### Functions
function source_file() {
    local file_path="$1"
    [[ -f "$file_path" ]] && source "$file_path"
}

### Alias
if type exa > /dev/null 2>&1; then
    alias ls="exa --color=always"
    alias l="ls -l --group-directories-first"
    alias ll="l -a"
fi

alias ta="tmux attach-session"
alias tn="tmux -u new -s \$(basename \$PWD)"

### ASDF
source_file $HOME/.asdf/asdf.sh
fpath=($HOME/.asdf/completions $fpath)
source_file $HOME/.asdf/plugins/java/set-java-home.zsh

### Localrc
source_file $HOME/.localrc

### Completion
setopt MENU_COMPLETE
setopt AUTO_LIST
setopt COMPLETE_IN_WORD

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
autoload -Uz compinit; compinit
