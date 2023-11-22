#!/bin/zsh

### Zsh Unplugged
# declare a simple plugin-load function
function plugin-load {
  local repo plugdir initfile
  ZPLUGINDIR=${ZPLUGINDIR:-${ZDOTDIR:-$HOME/.config/zsh}/plugins}
  for repo in $@; do
    plugdir=$ZPLUGINDIR/${repo:t}
    initfile=$plugdir/${repo:t}.plugin.zsh
    if [[ ! -d $plugdir ]]; then
      echo "Cloning $repo..."
      git clone -q --depth 1 --recursive --shallow-submodules https://github.com/$repo $plugdir
    fi
    if [[ ! -e $initfile ]]; then
      local -a initfiles=($plugdir/*.plugin.{z,}sh(N) $plugdir/*.{z,}sh{-theme,}(N))
      (( $#initfiles )) || { echo >&2 "No init file found '$repo'." && continue }
      ln -sf "${initfiles[1]}" "$initfile"
    fi
    fpath+=$plugdir
    (( $+functions[zsh-defer] )) && zsh-defer . $initfile || . $initfile
  done
}

function plugin-update {
  ZPLUGINDIR=${ZPLUGINDIR:-$HOME/.config/zsh/plugins}
  for d in $ZPLUGINDIR/*/.git(/); do
    echo "Updating ${d:h:t}..."
    command git -C "${d:h}" pull --ff --recurse-submodules --depth 1 --rebase --autostash
  done
}

plugins=(
    zsh-users/zsh-completions
    zsh-users/zsh-autosuggestions
    zsh-users/zsh-syntax-highlighting

    zsh-git-prompt/zsh-git-prompt
    zdharma-continuum/history-search-multi-word
)

plugin-load $plugins

### Plugin Configuration
fpath=($ZPLUGINDIR/zsh-completions/src $fpath)

ZSH_THEME_GIT_PROMPT_PREFIX=" ("
ZSH_THEME_GIT_PROMPT_SUFFIX=")"
PROMPT='%{$fg_bold[red]%}%1~%b$(git_super_status) %{$fg_bold[cyan]%}»%{$reset_color%} '

### History
HISTSIZE=10000000
export SAVEHIST=$HISTSIZE
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE

### Completion
setopt AUTO_LIST
setopt AUTO_MENU

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
autoload -Uz compinit; compinit

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

alias vim=nvim

### ASDF
source_file $HOME/.asdf/asdf.sh
fpath=($HOME/.asdf/completions $fpath)
source_file $HOME/.asdf/plugins/java/set-java-home.zsh

## Emacs
if [[ "$INSIDE_EMACS" = 'vterm' ]]; then
    alias clear='vterm_printf "51;Evterm-clear-scrollback";tput clear'
fi

## Zoxide
eval "$(zoxide init zsh)"

### Localrc
source_file $HOME/.localrc
