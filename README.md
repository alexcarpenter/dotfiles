# dotfiles

## Installation

```bash
git clone https://github.com/alexcarpenter/dotfiles ~/dotfiles
cd ~/dotfiles
```

### Bootstrap (first time)

```bash
./bootstrap.sh --dry-run  # preview
./bootstrap.sh --yes      # apply
```

### Stow packages

```bash
# preview
stow -n -v -t $HOME <package>

# apply
stow -v -t $HOME <package>

# remove
stow -D -v -t $HOME <package>
```

## Updates

```bash
cd ~/dotfiles
git pull
stow -v -t $HOME zsh       # re-link shell
stow -v -t $HOME zed       # re-link editor
stow -v -t $HOME vscode    # re-link editor
stow -v -t $HOME karabiner # re-link karabiner
```

## Brew

```bash
brew update
brew bundle --file=./Brewfile
```

Capture current:

```bash
brew bundle dump --file=./Brewfile --force --describe
```

## Add new package

```bash
# create folder at root with target-relative paths
mkdir -p <new-package>/.config/app
# add files to <new-package>/.config/app/

# stow it
stow -n -v -t $HOME <new-package>
stow -v -t $HOME <new-package>

# commit
git add <new-package>
git commit -m "Add <new-package>"
```

## Backups

Bootstrap saves overwritten files to `~/dotfiles_backup_YYYYMMDD_HHMMSS/`
