# === Dependencies ===

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
[[ ":$PATH:" != *":$PNPM_HOME:"* ]] && export PATH="$PNPM_HOME:$PATH"

# bun
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# === Oh-My-Zsh ===

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"
plugins=(git jump zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

DEFAULT_USER=`whoami`

# === Aliases ===

alias lg="lazygit"
alias mc="make checkpoint"
alias n="pnpm "
