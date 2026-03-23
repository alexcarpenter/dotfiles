# dotfiles

Cross-device dotfiles management with [chezmoi](https://www.chezmoi.io/).

## Quick Install

**New machine:**
```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply alexcarpenter
```

Prompts: Name, Email

**Existing machine:**
```bash
chezmoi update
```

## What's Included

- `.zshrc` - Shell config, aliases, PATH
- `.gitconfig` - Git identity (templated), safe push defaults
- `karabiner.json` - Key remapping
- `settings.json` - VS Code theme & fonts
- `Brewfile` - Packages (JetBrains Mono, ZSH plugins, etc.)

## Golden Rule

**Never edit dotfiles directly** — changes get lost.

❌ Don't: `nano ~/.zshrc`, `vim ~/.config/karabiner/karabiner.json`

✅ Do: `chezmoi edit ~/.zshrc`

## Workflow

### 1. Edit
```bash
chezmoi edit ~/.zshrc
```
Opens in `$EDITOR` (VS Code by default). Auto-applies on save.

### 2. Review
```bash
chezmoi diff        # See what changed
chezmoi cat ~/.zshrc   # View rendered file
```

### 3. Push
```bash
chezmoi cd && git push
```

### 4. Sync (other devices)
```bash
chezmoi update
```

Done! All machines identical.

## Examples

### Add alias on MacBook → Use on iMac

**MacBook:**
```bash
chezmoi edit ~/.zshrc
# Add: alias blog="cd ~/Sites/blog"

chezmoi cd && git push
```

**iMac:**
```bash
chezmoi update
chezmoi cat ~/.zshrc  # See new alias
```

### Update Karabiner everywhere

**Any machine:**
```bash
chezmoi edit ~/.config/karabiner/karabiner.json
chezmoi cd && git push
```

**Other machines:**
```bash
chezmoi update
```

## Commands

| Task | Command |
|------|---------|
| Edit dotfile | `chezmoi edit ~/.zshrc` |
| See changes | `chezmoi diff` |
| View file | `chezmoi cat ~/.zshrc` |
| Push | `chezmoi cd && git push` |
| Pull & apply | `chezmoi update` |
| Add new file | `chezmoi add ~/.config/app/config` |
| History | `chezmoi cd && git log --oneline` |
| Undo | `cd ~/.local/share/chezmoi && git reset --hard HEAD` |

## Troubleshooting

### "chezmoi: command not found"
```bash
export PATH="$HOME/.local/bin:$PATH"
```
Add to `.zshrc` permanently with `chezmoi edit ~/.zshrc`

### Changes not showing after `chezmoi update`
```bash
chezmoi apply      # Force reapply
exec zsh           # Restart shell
```

### Manual edits lost?
```bash
chezmoi apply      # Restore from source
```

### Out of sync across devices
```bash
chezmoi cd && git pull --rebase
chezmoi apply
```

### Preview before syncing
```bash
chezmoi diff       # See what would change
chezmoi update     # Then apply
```

## File Locations

Source directory: `~/.local/share/chezmoi/`

Repository files (with `dot_` prefix):
- `dot_zshrc` → `~/.zshrc`
- `dot_gitconfig.tmpl` → `~/.gitconfig` (templated)
- `dot_config/karabiner/karabiner.json` → `~/.config/karabiner/karabiner.json`
- `Library/Application\ Support/Code/User/dot_settings.json` → `~/Library/Application\ Support/Code/User/settings.json`
- `dot_Brewfile` → `~/Brewfile`

## Templating

Files ending in `.tmpl` use Go templates:
- `{{ .user.name }}` - Your name (from setup)
- `{{ .user.email }}` - Your email
- `{{ .chezmoi.os }}` - darwin, linux, etc. (conditional sections)
- `{{ .chezmoi.hostname }}` - Machine name (work vs personal)

Example (`.gitconfig.tmpl`):
```toml
[user]
  name = {{ .user.name }}
  email = {{ .user.email }}

{{ if eq .chezmoi.os "darwin" }}
[credential]
  helper = osxkeychain
{{ end }}
```

## Setup Prompts

First run saves to `~/.config/chezmoi/chezmoi.toml`:
```toml
[data.user]
  name = "Alex Carpenter"
  email = "im.alexcarpenter@gmail.com"

[data.machine]
  hostname = "Alexs-Mac-mini"
```

## Common Issues

**Git config not rendering correctly:**
```bash
chezmoi cat ~/.gitconfig  # Check rendered output
```

**New machine has wrong email:**
```bash
chezmoi init  # Re-run setup prompts
```

**Push blocked:**
```bash
chezmoi cd && git push
# If fails: check GitHub auth, SSH keys
```

## More Info

- [Chezmoi Docs](https://www.chezmoi.io/)
- [User Guide](https://www.chezmoi.io/user-guide/)
- [Templating](https://www.chezmoi.io/user-guide/templating/)
- [FAQ](https://www.chezmoi.io/faq/)

---

**Devices synced:** MacBook, iMac, Work Laptop

**Core files:** .zshrc, .gitconfig, karabiner.json, VS Code settings, Brewfile
