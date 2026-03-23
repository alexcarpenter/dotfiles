# Chezmoi Migration Plan

## Overview
Migrate from GNU Stow to [chezmoi](https://www.chezmoi.io/) for dotfiles management. This provides better templating, encryption support, and machine-specific configuration handling.

**Reference Implementation**: [max/dotfiles](https://github.com/max/dotfiles) - already fully migrated to chezmoi

---

## Phase 1: Setup & Installation

### 1.1 Install chezmoi
```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply alexcarpenter
```

### 1.2 Initialize chezmoi repo structure
- Convert existing dotfiles to chezmoi format
- Create `.chezmoi.toml.tmpl` for configuration prompts
- Create `.chezmoiignore` for excluded files
- Keep `.git` history intact

### 1.3 Configuration File
Create `.chezmoi.toml.tmpl` with prompts for:
- User name
- Email address
- Optional: machine name/hostname for conditional configs

Example structure:
```toml
{{ $name := promptString "Name" -}}
{{ $email := promptString "Email" -}}

[data.user]
  name = {{ $name | quote }}
  email = {{ $email | quote }}
```

---

## Phase 2: Migrate Key Files

### Current Structure → Chezmoi Structure

**Naming Convention**:
- `.zshrc` → `dot_zshrc`
- `karabiner.json` → `dot_config/karabiner/dot_karabiner.json`
- `vscode/settings.json` → `Library/Application Support/Code/User/dot_settings.json`

### 2.1 Migrate `.zshrc`
- **Source**: `./zsh/.zshrc`
- **Target**: `dot_zshrc` (or keep in `dot_config/zsh/.zshrc` if preferred)
- **Template**: Convert to `.zshrc.tmpl` if needs user/email substitution
- **Status**: ✓ Ready to migrate

### 2.2 Migrate karabiner.json
- **Source**: `./karabiner/.config/karabiner/karabiner.json`
- **Target**: `dot_config/karabiner/karabiner.json`
- **Template**: Convert to `.tmpl` for machine-specific keybindings (if needed)
- **Status**: ✓ Ready to migrate

### 2.3 Migrate VS Code settings.json
- **Source**: `./vscode/Library/Application Support/Code/User/settings.json`
- **Target**: `Library/Application Support/Code/User/dot_settings.json`
- **Template**: Convert to `.tmpl` for machine-specific settings
- **Status**: ✓ Ready to migrate

### 2.4 Migrate Remaining Configurations
- **git config** → `dot_config/git/config.tmpl` (add user.name, user.email templating)
- **Other packages** → Organize under `dot_config/` or appropriate directories
- **Brewfile** → `dot_Brewfile` (keep as-is or add templating)

---

## Phase 3: Template & Conditional Configurations

### 3.1 Add Templating to Key Files

**`.zshrc`** - Add user-specific variables:
```bash
# User info
export GIT_USER_NAME="{{ .user.name }}"
export GIT_USER_EMAIL="{{ .user.email }}"
```

**`karabiner.json`** - Add conditional profiles:
```json
{{ if eq .chezmoi.hostname "my-mbp" }}
  "profile": "MacBook Pro",
{{ else }}
  "profile": "iMac",
{{ end }}
```

**`settings.json`** - Add VS Code extensions per machine:
```json
{{ if eq .chezmoi.os "darwin" }}
  "extensions.recommendations": ["ms-vscode-remote.remote-ssh"],
{{ end }}
```

### 3.2 Machine Detection
Add `chezmoi.hostname` detection in `.chezmoi.toml.tmpl`:
```toml
[data]
  hostname = {{ .chezmoi.hostname | quote }}
```

---

## Phase 4: Directory Structure

Target final structure:
```
~/dotfiles/ (source repository)
├── .chezmoi.toml.tmpl          # Configuration template with prompts
├── .chezmoiignore              # Exclude files (README, docs, etc.)
├── dot_zshrc                   # → ~/.zshrc
├── dot_Brewfile                # → ~/Brewfile
├── dot_config/
│   ├── karabiner/
│   │   └── karabiner.json      # → ~/.config/karabiner/karabiner.json
│   ├── zsh/
│   │   └── .zshrc              # Alternative: → ~/.config/zsh/.zshrc
│   ├── git/
│   │   └── config.tmpl         # → ~/.config/git/config
│   ├── nvim/
│   └── ...other configs
├── Library/
│   └── Application Support/
│       └── Code/
│           └── User/
│               └── dot_settings.json  # → ~/Library/Application Support/Code/User/settings.json
├── README.md
└── docs/
    └── SETUP.md
```

**Key differences from current stow setup**:
- Remove package subdirectories (karabiner/, zsh/, vscode/)
- Flatten structure with chezmoi's naming convention
- Use `.tmpl` suffix for templated files
- Prefix dotfiles with `dot_`

---

## Phase 5: Ignore & Exclusions

Create `.chezmoiignore`:
```
README.md
CHEZMOI_MIGRATION_PLAN.md
docs/**
.git/**
.github/**

# OS-specific exclusions
{{ if ne .chezmoi.os "darwin" }}
Library/**
{{ end }}
```

---

---

## Phase 6: Update Installation Instructions

Update `README.md`:

### Before (Stow-based):
```bash
git clone https://github.com/alexcarpenter/dotfiles ~/dotfiles
cd ~/dotfiles
./cli init
```

### After (Chezmoi-based):

#### Installation Section:
```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply alexcarpenter
```

Or for manual setup:
```bash
chezmoi init --apply https://github.com/alexcarpenter/dotfiles.git
```

#### Update Section:
```bash
chezmoi update
```

#### Workflow Section (NEW):

Add a comprehensive "Multi-Device Sync" section to README:

```markdown
## Multi-Device Sync

Keep your configuration synchronized across Mac, iMac, work laptop, etc.

### Editing Dotfiles

⚠️ **Never edit files directly** (e.g., `nano ~/.zshrc`). Changes will be lost.

Always use chezmoi:
```bash
chezmoi edit ~/.zshrc              # Edit shell config
chezmoi edit ~/.config/karabiner/karabiner.json  # Edit Karabiner
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
```

### Include Command Reference

Create a table of common commands in README or separate COMMANDS.md:

| Task | Command |
|------|---------|
| Edit a dotfile | `chezmoi edit ~/.zshrc` |
| Sync latest updates | `chezmoi update` |
| Preview changes | `chezmoi diff` |
| Push your edits | `chezmoi cd && git push` |
| View current config | `chezmoi cat ~/.zshrc` |
| Add new file | `chezmoi add ~/.config/app/config` |


---

## Phase 7: Migration Steps

1. **Backup current state**
   ```bash
   cd ~/dotfiles
   git stash
   git tag pre-chezmoi-migration
   ```

2. **Reorganize files**
   - Rename directories to chezmoi convention
   - Add `dot_` prefix to dotfiles
   - Update file paths in directory structure

3. **Create configuration templates**
   - Add `.chezmoi.toml.tmpl`
   - Add `.chezmoiignore`
   - Convert key files to `.tmpl` format

4. **Test migration**
   ```bash
   cd ~/.local/share/chezmoi  # chezmoi source directory
   chezmoi diff                # Preview changes
   chezmoi apply              # Apply if satisfied
   ```

5. **Remove old CLI**
   ```bash
   rm ~/dotfiles/cli
   ./cli unlink  # Remove ~/bin/dot symlink
   ```

6. **Update git**
   ```bash
   git add .
   git commit -m "Migrate to chezmoi"
   git push
   ```

---

## Phase 8: Post-Migration Tasks

### 8.1 Cleanup
- Remove `cli` script (no longer needed)
- Remove old stow-based package directories
- Remove backup directories

### 8.2 Documentation
- Update README with chezmoi commands
- Create SETUP.md with machine-specific instructions
- Document template variables and conditional logic

### 8.3 Future Maintenance
- Use `chezmoi edit ~/.config/app/config` for making changes
- Use `chezmoi add ~/.config/newapp/config` to track new files
- Use `chezmoi diff` before applying changes
- Use `chezmoi update` to pull and apply changes

---

## Phase 9: Multi-Device Sync Workflow

This is **critical** for keeping dotfiles consistent across machines (MacBook, iMac, work laptop, etc.)

### 9.1 The Chezmoi Workflow (NOT Manual Editing)

⚠️ **IMPORTANT**: Never edit `~/.zshrc`, `~/.config/karabiner/karabiner.json`, or other managed files directly. Always use chezmoi.

#### Wrong Way ❌
```bash
# Don't do this!
nano ~/.zshrc
vi ~/.config/karabiner/karabiner.json
```
Changes will be lost on next `chezmoi apply` and won't sync to other devices.

#### Right Way ✅
```bash
# Always use chezmoi edit
chezmoi edit ~/.zshrc
chezmoi edit ~/.config/karabiner/karabiner.json

# Makes changes in $EDITOR, auto-applies, and updates source repo
```

### 9.2 Edit Workflow (Making Changes)

**Step 1: Edit the dotfile**
```bash
chezmoi edit ~/.zshrc
```
This:
- Opens `~/.local/share/chezmoi/dot_zshrc` in your `$EDITOR`
- Auto-saves when you close the editor
- Applies the changes immediately to `~/.zshrc`
- Updates the source repository at `~/.local/share/chezmoi/`

**Step 2: Verify changes**
```bash
# View the rendered file
chezmoi cat ~/.zshrc

# See diff from previous version
chezmoi diff

# Or check git log in chezmoi source
cd ~/.local/share/chezmoi
git log --oneline -5
git diff HEAD~1
```

**Step 3: Push to GitHub**
```bash
cd ~/.local/share/chezmoi
git push

# Or one-liner:
chezmoi cd && git push
```

### 9.3 Sync Workflow (Getting Updates on Other Devices)

**On any other machine** (iMac, work laptop, etc.):

```bash
# Pull latest changes and apply them
chezmoi update

# Or manually:
cd ~/.local/share/chezmoi
git pull
chezmoi apply
```

This single command:
- ✅ Pulls latest commit from GitHub
- ✅ Re-renders all templates (with current machine's variables)
- ✅ Applies changes to your actual dotfiles

### 9.4 Complete Example: Updating .zshrc Across Devices

**Device 1 (MacBook):**
```bash
# Edit on MacBook
chezmoi edit ~/.zshrc
# → Add a new alias, update PATH, etc.
# → File auto-applies to ~/.zshrc

# Push to GitHub
chezmoi cd && git push
# → Changes are now in the repository
```

**Device 2 (iMac):**
```bash
# Pull latest changes
chezmoi update
# → Pulls the new .zshrc from GitHub
# → Applies to ~/.zshrc automatically
# → You now have the same .zshrc on iMac

# Verify
chezmoi cat ~/.zshrc  # See the updated content
```

**Device 3 (Work Laptop):**
```bash
# Same as iMac
chezmoi update
# → Gets the latest .zshrc
```

### 9.5 Conflict Resolution (Multiple Edits)

If you edit on multiple devices before syncing:

**Device 1:**
```bash
chezmoi edit ~/.zshrc  # Add alias: `alias ll="ls -l"`
chezmoi cd && git push
```

**Device 2 (without pulling first):**
```bash
chezmoi edit ~/.zshrc  # Add alias: `alias la="ls -la"`
chezmoi cd && git push  # ❌ FAILS - behind remote
```

**Resolution:**
```bash
# On Device 2
cd ~/.local/share/chezmoi

# Merge the changes
git pull --rebase
# or
git pull  # Then resolve merge conflicts if any

# Apply merged changes
chezmoi apply

# Now push
git push
```

### 9.6 Machine-Specific Configurations

Use templates to keep shared files but allow machine-specific variations:

**Example: VS Code settings with machine-specific extensions**

File: `Library/Application Support/Code/User/dot_settings.json.tmpl`
```json
{
  "editor.fontSize": 12,
  "editor.theme": "Gruvbox Dark",
  
  {{ if eq .chezmoi.hostname "macbook-pro" }}
  "extensions.recommendations": [
    "ms-vscode-remote.remote-ssh",
    "ms-python.python"
  ],
  {{ else if eq .chezmoi.hostname "imac" }}
  "extensions.recommendations": [
    "svelte.svelte-vscode",
    "golang.go"
  ],
  {{ end }}
  
  "editor.formatOnSave": true
}
```

Then during initial setup, chezmoi prompts for hostname and renders appropriately for each machine.

### 9.7 Viewing Changes Before Applying

Before pulling from another device, see what would change:

```bash
chezmoi diff

# Example output:
# --- a/.zshrc
# +++ b/.zshrc
# @@ -42,3 +42,4 @@
#  # Previous line
# +new alias here

# If satisfied, apply:
chezmoi apply
```

### 9.8 Undoing Changes

If you make a mistake:

```bash
# Undo unapplied changes in source
cd ~/.local/share/chezmoi
git reset --hard HEAD

# Revert applied changes on system
chezmoi apply

# Or revert to previous version
cd ~/.local/share/chezmoi
git revert <commit-hash>
chezmoi apply
```

### 9.9 Emergency: Restore from Backup

Chezmoi creates backups before applying changes:

```bash
# Find backup files
ls -la ~

# Chezmoi backup format: <filename>.chezmoi.bak.<timestamp>
# Example: .zshrc.chezmoi.bak.2025-03-23T11:30:45Z

# Restore if needed
cp ~/.zshrc.chezmoi.bak.2025-03-23T11:30:45Z ~/.zshrc
```

---

## Phase 9 Summary: Sync Best Practices

| Task | Command |
|------|---------|
| **Edit a dotfile** | `chezmoi edit ~/.zshrc` |
| **Push changes to all devices** | `chezmoi cd && git push` |
| **Pull latest on any device** | `chezmoi update` |
| **Preview changes before applying** | `chezmoi diff` |
| **View rendered template** | `chezmoi cat ~/.zshrc` |
| **Check git history** | `chezmoi cd && git log` |
| **Undo mistakes** | `cd ~/.local/share/chezmoi && git reset --hard HEAD` |

### Workflow Summary:
1. **Never** edit dotfiles directly (e.g., `nano ~/.zshrc`)
2. **Always** use `chezmoi edit` to make changes
3. **Always** push after editing: `chezmoi cd && git push`
4. **Always** pull on other devices: `chezmoi update`
5. **Always** preview with `chezmoi diff` on new device before pulling

---

## Advantages of Chezmoi

✅ **No more Stow complexity** - Direct template rendering  
✅ **Built-in templating** - Prompt for variables, use Go templates  
✅ **OS-aware** - Conditional includes based on `{{ .chezmoi.os }}`  
✅ **Encryption support** - Can use age or gpg for sensitive files  
✅ **Machine-specific configs** - Conditional sections per hostname  
✅ **Better change management** - `diff` before applying  
✅ **One-line setup** - Easy to share and initialize on new machines  
✅ **Active maintenance** - Regular updates and community support  

---

## Commands Reference (Post-Migration)

### Basic Setup
```bash
# Initialize on new machine
chezmoi init --apply https://github.com/alexcarpenter/dotfiles.git

# Update from repo
chezmoi update
```

### Editing Dotfiles (The Right Way)
```bash
# Edit a dotfile (ALWAYS use this, never edit manually)
chezmoi edit ~/.zshrc
chezmoi edit ~/.config/karabiner/karabiner.json
chezmoi edit ~/Library/Application\ Support/Code/User/settings.json

# View rendered template
chezmoi cat ~/.zshrc

# See what changed
chezmoi diff

# Check git history in source
chezmoi cd && git log --oneline
```

### Syncing Across Devices

**When you make changes on one device:**
```bash
# Edit the file
chezmoi edit ~/.zshrc

# Push to GitHub
chezmoi cd && git push
```

**On other devices to get latest:**
```bash
# Pull and apply all updates
chezmoi update

# Or manually:
chezmoi cd && git pull
chezmoi apply
```

### Managing Files
```bash
# Add a new file to track
chezmoi add ~/.config/newapp/config

# Remove tracking (doesn't delete file)
chezmoi remove ~/.config/oldapp/config

# Forget all applied changes and reapply from source
chezmoi apply
```

### Troubleshooting
```bash
# Preview what would change
chezmoi diff

# View actual applied file
chezmoi cat ~/.zshrc

# Undo unapplied changes
cd ~/.local/share/chezmoi && git reset --hard HEAD

# Re-run initial setup prompts
chezmoi init
```

---

## Timeline Estimate

- **Phase 1** (Setup): 30 mins
- **Phase 2** (File migration): 1-2 hours
- **Phase 3** (Templating): 1-2 hours
- **Phase 4** (Structure): 1 hour
- **Phase 5** (Testing): 30 mins
- **Phase 6** (Documentation): 30 mins
- **Phase 7** (Migration steps): 1-2 hours
- **Phase 8** (Post-migration cleanup): 30 mins
- **Phase 9** (Multi-device sync docs): Already included

**Total**: ~6-9 hours for complete migration + documentation

---

## Next Steps

1. ✓ Review this plan
2. Review max/dotfiles structure for reference
3. Create new branch: `git checkout -b chezmoi-migration`
4. Begin Phase 1 (install chezmoi locally)
5. Start Phase 2 (reorganize files)
6. Test on dev machine before pushing
7. Update documentation
8. Merge and tag release

