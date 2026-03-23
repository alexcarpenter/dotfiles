# Chezmoi Setup & Usage Guide

This guide covers how to use chezmoi to manage your dotfiles across devices.

## Initial Setup (New Machine)

### Option 1: One-Command Setup (Recommended)

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply alexcarpenter
```

This script will:
1. Download and install chezmoi
2. Clone the dotfiles repository
3. Prompt you for Name and Email
4. Apply all dotfiles to your home directory

### Option 2: Manual Setup

```bash
# Install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin

# Initialize chezmoi from the dotfiles repo
chezmoi init --apply https://github.com/alexcarpenter/dotfiles.git

# Follow the prompts:
# - Name: Your full name
# - Email: Your email address
```

## Managing Dotfiles

### ⚠️ Critical Rule: Always Use Chezmoi

**NEVER** edit dotfiles directly:
```bash
# ❌ DON'T DO THIS - Changes will be lost!
nano ~/.zshrc
vi ~/.config/karabiner/karabiner.json
```

**ALWAYS** use chezmoi to edit:
```bash
# ✅ DO THIS - Changes sync across devices
chezmoi edit ~/.zshrc
chezmoi edit ~/.config/karabiner/karabiner.json
chezmoi edit ~/Library/Application\ Support/Code/User/settings.json
```

## Workflow: Making Changes

### Step 1: Edit a Dotfile

```bash
chezmoi edit ~/.zshrc
```

This opens the file in your `$EDITOR` (vim, nano, vscode, etc.).

What happens:
- Chezmoi opens the source file (located in `~/.local/share/chezmoi/`)
- You edit it
- When you save and exit, chezmoi applies changes to `~/.zshrc`
- Changes are committed to the chezmoi source repository

### Step 2: Review Changes

```bash
# See what changed
chezmoi diff

# View the actual applied file
chezmoi cat ~/.zshrc
```

### Step 3: Push to GitHub

```bash
# Navigate to chezmoi source directory and push
chezmoi cd && git push

# Or as a one-liner:
cd ~/.local/share/chezmoi && git push
```

Now your changes are on GitHub!

### Step 4: Sync on Other Devices

On any other machine:

```bash
# Pull and apply latest changes
chezmoi update
```

This command:
- ✅ Pulls latest commits from GitHub
- ✅ Re-renders templates with current machine variables
- ✅ Applies all changes to dotfiles

Done! Your configs are now synced.

## Common Tasks

### View Current Configuration

See the rendered version of any dotfile:

```bash
chezmoi cat ~/.zshrc
chezmoi cat ~/.config/karabiner/karabiner.json
chezmoi cat ~/Library/Application\ Support/Code/User/settings.json
```

### Add a New File

To start tracking a new configuration:

```bash
chezmoi add ~/.config/newapp/config.toml
```

This:
- Copies the file to chezmoi source
- Tracks it for future updates
- Commits it to git

### Check Diff Before Syncing

Before pulling on another machine:

```bash
chezmoi diff

# Example output:
# --- a/.zshrc
# +++ b/.zshrc
# @@ -42,3 +42,4 @@
#  export MY_VAR="value"
# +new line here
```

### Remove a File From Tracking

```bash
chezmoi remove ~/.config/oldapp/config
```

This stops tracking the file but doesn't delete it from your system.

### View Git History

```bash
chezmoi cd && git log --oneline

# Or with more detail:
chezmoi cd && git log --stat
```

## Troubleshooting

### "Command not found: chezmoi"

Chezmoi may not be in your PATH. Try:

```bash
~/.local/bin/chezmoi --version

# Or add to PATH:
export PATH="$HOME/.local/bin:$PATH"
```

Add this to your shell config if you want it permanent.

### Changes Not Applied

Sometimes chezmoi doesn't auto-apply. Force it:

```bash
chezmoi apply
```

### Undo Changes

Revert unapplied changes in the source:

```bash
cd ~/.local/share/chezmoi
git reset --hard HEAD  # Undo all uncommitted changes
```

Then reapply:

```bash
chezmoi apply
```

### Template Errors

If you see template errors when running `chezmoi apply`, check your configuration:

```bash
# Validate templates
chezmoi cat ~/.zshrc  # Should show rendered output

# Check config
cat ~/.config/chezmoi/chezmoi.toml
```

### Out of Sync Across Devices

If Device A and Device B have different edits:

**On Device B (the one behind):**
```bash
chezmoi cd && git pull --rebase

# Or if that fails:
chezmoi cd && git pull  # Then resolve merge conflicts

# Apply the merged changes
chezmoi apply
```

## Multi-Device Workflow Example

### Scenario: You have MacBook, iMac, Work Laptop

**Day 1: MacBook**
```bash
# Add new alias to zshrc
chezmoi edit ~/.zshrc

# Push to GitHub
chezmoi cd && git push
```

**Day 1: iMac (later)**
```bash
# Pull latest
chezmoi update

# Verify you have the new alias
chezmoi cat ~/.zshrc  # See the new alias
```

**Day 2: Work Laptop**
```bash
# Morning: Get latest changes
chezmoi update

# Edit something
chezmoi edit ~/.config/karabiner/karabiner.json

# Push
chezmoi cd && git push

# Back on MacBook:
chezmoi update  # Get the work laptop's keybinding changes
```

All machines now have the same configuration!

## Tips & Tricks

### 1. Set Your Editor

Chezmoi uses `$EDITOR` environment variable:

```bash
# In your .zshrc or shell config:
export EDITOR="vim"   # or: nano, code, nvim, etc.
```

### 2. Quick Navigation to Source

```bash
chezmoi cd  # Opens a shell in ~/.local/share/chezmoi/

# Or as a one-liner:
cd ~/.local/share/chezmoi
```

### 3. Automate Updates

Run this daily to stay in sync:

```bash
chezmoi update
```

Or add a cron job / scheduled task (varies by OS).

### 4. Backup Before Major Changes

Before making big edits:

```bash
chezmoi cd && git tag backup-$(date +%Y%m%d)
git push --tags
```

Now you can revert if needed.

### 5. View Unapplied Changes

See what would change without applying:

```bash
chezmoi diff

# Even before pulling from GitHub:
chezmoi cd && git log -p --oneline | head -50
```

## Useful Chezmoi Commands

```bash
# Initialization & setup
chezmoi init                          # Re-run setup prompts
chezmoi init --apply <repo-url>       # Initialize from repository

# Managing files
chezmoi add <file>                    # Start tracking a file
chezmoi remove <file>                 # Stop tracking a file
chezmoi edit <file>                   # Edit and apply changes

# Viewing & applying
chezmoi cat <file>                    # View rendered file
chezmoi diff                          # See all changes
chezmoi apply                         # Apply all changes

# Git operations
chezmoi cd                            # Navigate to source directory
chezmoi update                        # Pull and apply from GitHub

# Debugging
chezmoi doctor                        # Diagnose issues
chezmoi verify                        # Verify all files applied correctly
```

## Next Steps

1. ✅ Run initial setup command
2. ✅ Verify dotfiles are applied correctly
3. ✅ On second device: run `chezmoi update`
4. ✅ Make a test edit: `chezmoi edit ~/.zshrc`
5. ✅ Push: `chezmoi cd && git push`
6. ✅ Sync on other device: `chezmoi update`

You're now managing dotfiles with chezmoi! 🎉

## Resources

- [Chezmoi Official Documentation](https://www.chezmoi.io/)
- [Chezmoi User Guide](https://www.chezmoi.io/user-guide/)
- [Chezmoi Templating](https://www.chezmoi.io/user-guide/templating/)
- [Chezmoi FAQ](https://www.chezmoi.io/faq/)
