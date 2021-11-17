# PATH
export PATH="/opt/homebrew/lib:$PATH"

source $HOME/.zinit/bin/zinit.zsh

zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting

zinit light zsh-git-prompt/zsh-git-prompt
ZSH_THEME_GIT_PROMPT_PREFIX=" ("
ZSH_THEME_GIT_PROMPT_SUFFIX=")"
PROMPT='%{$fg_bold[red]%}%1~%b$(git_super_status) %{$fg_bold[cyan]%}»%{$reset_color%} '

zinit snippet OMZL::completion.zsh
zinit snippet OMZL::history.zsh

# asdf
[[ -f $HOME/.asdf/asdf.sh ]] && source $HOME/.asdf/asdf.sh
fpath=($HOME/.asdf/completions $fpath)
[[ -f $HOME/.asdf/plugins/java/set-java-home.zsh ]] && source $HOME/.asdf/plugins/java/set-java-home.zsh

# fzf
[ -f $HOME/.fzf.zsh ] && source $HOME/.fzf.zsh

# aliases
[[ -f $HOME/.aliases ]] && source $HOME/.aliases

# localrc
[[ -f $HOME/.localrc ]] && source $HOME/.localrc

autoload -Uz compinit && compinit
