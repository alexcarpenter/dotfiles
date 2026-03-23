# Quick Reference: Updating & Syncing Dotfiles

This is your quick reference guide for updating .zshrc, karabiner.json, and VS Code settings across your MacBook, iMac, and other devices.

## ⚠️ Golden Rule

**NEVER edit dotfiles directly:**
```bash
# ❌ WRONG - Changes will be lost!
nano ~/.zshrc
vi ~/.config/karabiner/karabiner.json
code ~/Library/Application\ Support/Code/User/settings.json
```

**ALWAYS use chezmoi edit:**
```bash
# ✅ CORRECT - Changes sync across devices
chezmoi edit ~/.zshrc
chezmoi edit ~/.config/karabiner/karabiner.json
chezmoi edit ~/Library/Application\ Support/Code/User/settings.json
```

---

## The 4-Step Workflow

### Step 1: Edit on One Device

```bash
# Edit your file (opens in $EDITOR)
chezmoi edit ~/.zshrc

# Example: Add a new alias
# export EDITOR=vim
# alias ll="ls -lah"
# export PATH="$HOME/.local/bin:$PATH"
```

### Step 2: Review Changes

```bash
# See what you changed
chezmoi diff

# View the current applied file
chezmoi cat ~/.zshrc
```

### Step 3: Push to GitHub

```bash
# Push changes to all your devices
chezmoi cd && git push

# Or if that doesn't work:
cd ~/.local/share/chezmoi && git push
```

### Step 4: Sync on Other Devices

On your iMac, work laptop, or any other machine:

```bash
# Pull and apply the latest
chezmoi update

# Verify you have the changes
chezmoi cat ~/.zshrc
```

Done! All your machines now have the same .zshrc.

---

## Real-World Examples

### Example 1: Add an Alias on MacBook → Use on iMac

**MacBook:**
```bash
$ chezmoi edit ~/.zshrc
# Add line: alias blog="cd ~/Sites/blog"
# Save and exit editor

$ chezmoi diff
# Shows: +alias blog="cd ~/Sites/blog"

$ chezmoi cd && git push
# Changes pushed to GitHub
```

**iMac (later that day):**
```bash
$ chezmoi update
# Pulls latest .zshrc with your new alias

$ alias blog
# bash: alias: blog: not found (You need to source zshrc)

$ source ~/.zshrc
$ alias blog
# alias blog='cd ~/Sites/blog'

# Now you can use: blog
```

### Example 2: Update Karabiner Config on Work Laptop → All Devices

**Work Laptop:**
```bash
$ chezmoi edit ~/.config/karabiner/karabiner.json
# Modify key mappings...

$ chezmoi diff  # Review

$ chezmoi cd && git push  # Push
```

**MacBook (next morning):**
```bash
$ chezmoi update  # Get latest keybindings

# Karabiner automatically reloads (or restart it)
```

**iMac:**
```bash
$ chezmoi update  # Same keybindings everywhere
```

### Example 3: Update VS Code Settings Across Devices

**MacBook:**
```bash
$ chezmoi edit ~/Library/Application\ Support/Code/User/settings.json
# Add: "editor.fontSize": 13
# Change: "editor.tabSize": 2

$ chezmoi cd && git push
```

**iMac & Work Laptop:**
```bash
$ chezmoi update

# VS Code detects the file change and reloads settings
# You might need to reload the window (Cmd+R / Ctrl+R)
```

---

## Quick Command Reference

| Task | Command |
|------|---------|
| **Edit a file** | `chezmoi edit ~/.zshrc` |
| **See what changed** | `chezmoi diff` |
| **View the file** | `chezmoi cat ~/.zshrc` |
| **Push to GitHub** | `chezmoi cd && git push` |
| **Pull on other device** | `chezmoi update` |
| **Check git history** | `chezmoi cd && git log --oneline` |
| **Undo changes** | `cd ~/.local/share/chezmoi && git reset --hard HEAD` |

---

## Troubleshooting

### "chezmoi: command not found"
```bash
# Add to PATH:
export PATH="$HOME/.local/bin:$PATH"

# Add to ~/.zshrc permanently:
chezmoi edit ~/.zshrc
# Then add above line
```

### Changes not showing on other device after update
```bash
# Try reapplying:
chezmoi apply

# Or restart your shell:
exec $SHELL

# Or manually source:
source ~/.zshrc
```

### Changes didn't push
```bash
# Check status:
chezmoi cd && git status

# Try again:
chezmoi cd && git push

# If remote error, check:
cd ~/.local/share/chezmoi && git remote -v
```

### Want to see what changed before updating
```bash
# On device B (before pulling):
chezmoi diff

# Then review before applying:
chezmoi update
```

---

## Your Three Key Files

### 1. ~/.zshrc (Shell Configuration)
```bash
# Edit:
chezmoi edit ~/.zshrc

# View:
chezmoi cat ~/.zshrc

# Location: dot_zshrc in repository
```

**Contains:**
- Aliases
- Shell functions
- PATH settings
- Environment variables
- History settings

**Sync with:**
```bash
chezmoi cd && git push  # Push
chezmoi update          # Pull
```

### 2. ~/.config/karabiner/karabiner.json (Key Remapping)
```bash
# Edit:
chezmoi edit ~/.config/karabiner/karabiner.json

# View:
chezmoi cat ~/.config/karabiner/karabiner.json

# Location: dot_config/karabiner/karabiner.json in repository
```

**Contains:**
- Key mappings
- Keyboard profiles
- Modifier key settings

**Sync with:**
```bash
chezmoi cd && git push  # Push
chezmoi update          # Pull
```

### 3. ~/Library/Application Support/Code/User/settings.json (VS Code)
```bash
# Edit:
chezmoi edit ~/Library/Application\ Support/Code/User/settings.json

# View:
chezmoi cat ~/Library/Application\ Support/Code/User/settings.json

# Location: Library/Application\ Support/Code/User/dot_settings.json in repository
```

**Contains:**
- Editor settings
- Theme preferences
- Font settings
- Extension configurations

**Sync with:**
```bash
chezmoi cd && git push  # Push
chezmoi update          # Pull
```

---

## Daily Workflow

```bash
# Morning: Get latest from other devices
chezmoi update

# Work: Make changes as needed
chezmoi edit ~/.zshrc
# ... edit the file ...

# Review before saving
chezmoi diff

# Push your changes
chezmoi cd && git push

# Before switching devices: Update
chezmoi update
```

---

## Important Notes

1. **Chezmoi is automatic** - When you use `chezmoi edit`, it automatically:
   - Applies changes to your actual files
   - Saves to the repository
   - Updates git

2. **GitHub is your sync hub** - All devices pull/push from GitHub, so:
   - Always push when you make changes: `chezmoi cd && git push`
   - Always pull before switching devices: `chezmoi update`

3. **Templates work** - Your files use Go templates, so you can:
   - Have machine-specific sections
   - Use variables for paths
   - Create conditional configurations

4. **Safety first** - Chezmoi is safe because:
   - It backs up before applying
   - You can review with `chezmoi diff`
   - You can undo with `git reset --hard HEAD`

---

## When Things Go Wrong

### I edited the file manually (didn't use chezmoi edit)
```bash
# Chezmoi can fix it:
chezmoi apply  # Reapply from source

# Or restore from backup:
ls -la ~/.*.chezmoi.bak.*
```

### I pushed bad changes
```bash
chezmoi cd
git log --oneline        # Find the bad commit
git revert <commit-hash> # Undo it
git push                 # Push the undo
```

### Multiple devices out of sync
```bash
# On the "wrong" device:
chezmoi update           # Pull latest
chezmoi diff             # Review
chezmoi apply            # Apply if OK
```

---

## Summary

**Remember:**
- Edit with `chezmoi edit` (never manually)
- Push with `chezmoi cd && git push`
- Sync with `chezmoi update`
- Review with `chezmoi diff`

That's it! Your .zshrc, karabiner config, and VS Code settings stay perfectly synced across all your devices.

For more info, see:
- `README.md` - Overview and installation
- `SETUP.md` - Complete usage guide
- `CHEZMOI_MIGRATION_PLAN.md` - Technical details
