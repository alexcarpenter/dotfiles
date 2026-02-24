# dotfiles

## Installation

```bash
git clone https://github.com/alexcarpenter/dotfiles ~/dotfiles
cd ~/dotfiles
```

### First time setup

```bash
./cli init
```

This will:
- Install Homebrew (if missing)
- Install packages from Brewfile
- Stow all dotfiles to your home directory
- Link the `dot` command to your PATH

### Stow packages

```bash
# Stow all packages
./cli stow

# Stow specific package
./cli stow zsh
./cli stow zed
```

## Commands

| Command | Description |
|---------|-------------|
| `./cli init` | Full system setup |
| `./cli stow [package]` | Symlink dotfiles to home |
| `./cli link` | Install dot to PATH |
| `./cli unlink` | Remove dot from PATH |
| `./cli doctor` | Run diagnostics |
| `./cli update` | Update Homebrew packages |
| `./cli gen-ssh-key [email]` | Generate SSH key |

## Updates

```bash
cd ~/dotfiles
git pull
./cli stow
```

## Add new package

```bash
# create folder at root with target-relative paths
mkdir -p <new-package>/.config/app

# stow it
./cli stow <new-package>

# commit
git add <new-package>
git commit -m "Add <new-package>"
```

## Backups

The stow command saves overwritten files to `~/dotfiles_backup_YYYYMMDD_HHMMSS/`
