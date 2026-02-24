#!/bin/bash
set -e

ZSH_PLUGINS_DIR="$HOME/.oh-my-zsh/custom/plugins"

install_plugin() {
  local repo=$1
  local name=$(basename "$repo")
  local target="$ZSH_PLUGINS_DIR/$name"
  if [ ! -d "$target" ]; then
    git clone "https://github.com/$repo" "$target"
  fi
}

install_plugin "zsh-users/zsh-autosuggestions"
install_plugin "zsh-users/zsh-syntax-highlighting"
