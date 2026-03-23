# dotfiles

Configuration files managed by [chezmoi](https://www.chezmoi.io/) for a consistent development environment across devices.

## Installation

### Quick Start

Install chezmoi and apply dotfiles in one command:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply alexcarpenter
```

During setup, you'll be prompted for:
- **Name**: Your full name (for Git commits)
- **Email**: Your email address (for Git commits)

### Manual Setup

If you prefer manual installation:

```bash
# Install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin

# Initialize and apply dotfiles
chezmoi init --apply https://github.com/alexcarpenter/dotfiles.git
```

## Update Existing Installation

Pull and apply the latest changes:

```bash
chezmoi update
```

## What's Included

- **zsh** - Shell configuration (.zshrc)
- **karabiner** - Key remapping (karabiner.json)
- **vscode** - Editor settings (settings.json)
- **zed** - Zed editor configuration
- **claude** - Claude CLI skills
- **Brewfile** - macOS package dependencies

## Multi-Device Sync

Keep your configuration synchronized across Mac, iMac, work laptop, etc.

### Editing Dotfiles

⚠️ **Never edit files directly** (e.g., `nano ~/.zshrc`). Changes will be lost on next sync.

**Always use chezmoi:**

```bash
chezmoi edit ~/.zshrc
chezmoi edit ~/.config/karabiner/karabiner.json
chezmoi edit ~/Library/Application\ Support/Code/User/settings.json
```

This opens the file in your `$EDITOR` and auto-applies changes.

### Push Changes to All Devices

After editing:

```bash
chezmoi cd && git push
```

### Pull Latest on Other Devices

On any other machine:

```bash
chezmoi update
```

This pulls the latest changes and applies them automatically.

### Preview Changes

Before pulling, preview what would change:

```bash
chezmoi diff
```

### View Applied Files

See the current rendered version:

```bash
chezmoi cat ~/.zshrc
```

### Workflow Example

**On MacBook:**
```bash
chezmoi edit ~/.zshrc          # Add new alias
chezmoi diff                   # Review changes
chezmoi cd && git push         # Push to GitHub
```

**On iMac:**
```bash
chezmoi update                 # Pull and apply
chezmoi cat ~/.zshrc           # Verify new alias is there
```

Both machines now have identical configurations!

## Common Commands

| Task | Command |
|------|---------|
| Edit a dotfile | `chezmoi edit ~/.zshrc` |
| Sync latest updates | `chezmoi update` |
| Preview changes | `chezmoi diff` |
| Push your edits | `chezmoi cd && git push` |
| View current config | `chezmoi cat ~/.zshrc` |
| Add new file | `chezmoi add ~/.config/app/config` |

## Troubleshooting

### Check what would change

```bash
chezmoi diff
```

### View rendered template

```bash
chezmoi cat ~/.config/karabiner/karabiner.json
```

### Undo changes

```bash
cd ~/.local/share/chezmoi
git reset --hard HEAD
chezmoi apply
```

## More Information

- [chezmoi Documentation](https://www.chezmoi.io/user-guide/command-overview/)
- [chezmoi Quick Start](https://www.chezmoi.io/quick-start/)
