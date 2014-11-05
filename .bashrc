[ -s "$HOME/.dotfiles/colors.bash" ] && source "$HOME/.dotfiles/colors.bash"

PS1=" ${bldpur}\W"
PS1+=" ${bldcyn}» ${txtrst}"

# export
export CLICOLOR=1
export LSCOLORS=dxfxcxdxbxegedabagacad

export TERM=xterm-256color

# alias
alias l="ls -lha"
alias :q="exit"

# fix git
export PATH="/usr/local/bin:$PATH"

# cask
export PATH="$(brew --prefix cask)/bin:$PATH"

# nvm
export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh

# rvm
if [ -d "$HOME/.rvm" ]; then
    # Load RVM into a shell session *as a function*
    [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

    # Add RVM to PATH for scripting
    export PATH="$PATH:$HOME/.rvm/bin"
fi
