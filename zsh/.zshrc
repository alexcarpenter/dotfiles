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
plugins=(git jump zoxide zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

DEFAULT_USER=`whoami`

prompt_dir() {
  prompt_segment blue black '%1~'
}

# === Aliases ===

alias lg="lazygit"
alias ll="eza -l --icons --git"
alias la="eza -la --icons --git"
alias mc="make checkpoint"
alias n="pnpm "

# === Zoxide ===
eval "$(zoxide init zsh)"
