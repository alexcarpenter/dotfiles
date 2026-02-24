# dotfiles

## Installation

```bash
git clone https://github.com/alexcarpenter/dotfiles ~/dotfiles
cd ~/dotfiles
```

### First time setup

```bash
./dot init
```

This will:
- Install Homebrew (if missing)
- Install packages from Brewfile
- Stow all dotfiles to your home directory
- Link the `dot` command to your PATH

### Stow packages

```bash
# Stow all packages
./dot stow

# Stow specific package
./dot stow zsh
./dot stow zed
```

## Commands

| Command | Description |
|---------|-------------|
| `./dot init` | Full system setup |
| `./dot stow [package]` | Symlink dotfiles to home |
| `./dot link` | Install dot to PATH |
| `./dot unlink` | Remove dot from PATH |
| `./dot doctor` | Run diagnostics |
| `./dot update` | Update Homebrew packages |
| `./dot gen-ssh-key [email]` | Generate SSH key |

## Updates

```bash
cd ~/dotfiles
git pull
./dot stow
```

## Add new package

```bash
# create folder at root with target-relative paths
mkdir -p <new-package>/.config/app

# stow it
./dot stow <new-package>

# commit
git add <new-package>
git commit -m "Add <new-package>"
```

## Backups

The stow command saves overwritten files to `~/dotfiles_backup_YYYYMMDD_HHMMSS/`
