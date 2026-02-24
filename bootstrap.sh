#!/usr/bin/env bash
#
# bootstrap.sh
#
# Bootstraps a macOS machine (or your local environment) from this repo:
# - Installs Homebrew (if missing)
# - Runs `brew bundle` against the repository Brewfile
# - Ensures GNU Stow is installed
# - Backs up conflicting files under $HOME and then `stow`s selected packages
#
# Principles:
# - Safe by default: runs dry-runs and creates timestamped backups before overwriting.
# - Idempotent: re-running won't clobber without explicit confirmation.
# - Configurable via environment variables and CLI flags.
#
# Usage:
#   ./bootstrap.sh               # interactive mode: shows dry-run, prompts before applying
#   ./bootstrap.sh --yes        # skip confirmation prompts and apply
#   ./bootstrap.sh --dry-run    # show actions but don't modify anything
#   ./bootstrap.sh --packages zsh,karabiner  # only stow these packages
#
set -euo pipefail

#######################################
# Configuration (tweakable)
#######################################
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="${REPO_ROOT}/Brewfile"
STOW_TARGET="${STOW_TARGET:-$HOME}"            # destination for stow (defaults to $HOME)
DEFAULT_IGNORE_PACKAGES=("node_modules" ".git" ".github")  # top-level dirs to ignore as stow packages
BACKUP_DIR_BASE="${HOME}/dotfiles_backup"      # final dir will include timestamp
DRY_RUN=false
AUTO_YES=false
SKIP_BREW=false
REQUESTED_PACKAGES=()                          # if empty -> auto-discover
VERBOSE=true

#######################################
# Helpers
#######################################
log() {
  printf '%s\n' "$*"
}

err() {
  printf 'ERROR: %s\n' "$*" >&2
}

warn() {
  printf 'WARNING: %s\n' "$*" >&2
}

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  -n, --dry-run           Show what would be done without changing anything.
  -y, --yes               Assume "yes" to all prompts (non-interactive).
  -p, --packages LIST     Comma-separated list of packages to stow (e.g. "zsh,karabiner").
  -s, --skip-brew         Skip Homebrew bundle installation.
  -h, --help              Show this help and exit.

Examples:
  $(basename "$0")
  $(basename "$0") --dry-run
  $(basename "$0") --yes --packages zsh,karabiner

Notes:
  - This script expects the repository top-level to contain stow packages as directories,
    e.g. 'zsh/', 'karabiner/', 'vscode/' where paths inside those folders map to $HOME
    (use nested directories such as 'vscode/Library/Application Support/Code/User').
EOF
}

# simple arg parser
while [ "$#" -gt 0 ]; do
  case "$1" in
    -n|--dry-run) DRY_RUN=true; shift ;;
    -y|--yes) AUTO_YES=true; shift ;;
    -s|--skip-brew) SKIP_BREW=true; shift ;;
    -p|--packages)
      if [ -z "${2:-}" ]; then err "Missing value for --packages"; exit 2; fi
      IFS=',' read -r -a REQUESTED_PACKAGES <<< "$2"
      shift 2
      ;;
    -h|--help) usage; exit 0 ;;
    *) err "Unknown arg: $1"; usage; exit 2 ;;
  esac
done

# ensure stow command exists early if we won't rely on brew to install it
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

confirm_or_exit() {
  if [ "$AUTO_YES" = true ]; then
    return 0
  fi
  printf "%s [y/N]: " "$1"
  read -r reply || return 1
  case "$reply" in
    [yY]) return 0 ;;
    *) err "Aborted."; exit 1 ;;
  esac
}

#######################################
# Step 1: Ensure Homebrew (optional)
#######################################
if ! command_exists brew; then
  log "Homebrew not found."
  if [ "$DRY_RUN" = true ]; then
    log "DRY RUN: Would install Homebrew using the official installer."
  else
    if confirm_or_exit "Install Homebrew now?"; then
      log "Installing Homebrew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      log "Homebrew installed."
    fi
  fi
else
  log "Homebrew found."
fi

#######################################
# Step 2: Run `brew bundle` to install Brewfile items
#######################################
if [ "$SKIP_BREW" = true ]; then
  log "Skipping brew bundle (--skip-brew specified)."
elif [ -f "$BREWFILE" ]; then
  log "Found Brewfile at ${BREWFILE}."
  if [ "$DRY_RUN" = true ]; then
    log "DRY RUN: Would run 'brew update' and 'brew bundle --file=${BREWFILE}'."
  else
    log "Running Homebrew update..."
    brew update || warn "brew update failed; continuing."
    log "Installing items from Brewfile..."
    brew bundle --file="${BREWFILE}"
  fi
else
  warn "No Brewfile found at ${BREWFILE}; skipping brew bundle step."
fi

#######################################
# Step 3: Ensure GNU Stow is installed
#######################################
if ! command_exists stow; then
  if [ "$DRY_RUN" = true ]; then
    log "DRY RUN: Would install GNU Stow via Homebrew (brew install stow)."
  else
    log "GNU Stow not found; installing via Homebrew..."
    if ! brew install stow; then
      err "Failed to install GNU Stow."
      exit 1
    fi
  fi
else
  log "GNU Stow found."
fi

#######################################
# Step 4: Determine packages to stow
#######################################
discover_packages() {
  # discover top-level directories that look like stow packages
  local -a pkgs=()
  while IFS= read -r -d '' entry; do
    name="$(basename "$entry")"
    # skip ignored names
    skip=false
    for ign in "${DEFAULT_IGNORE_PACKAGES[@]}"; do
      if [ "$name" = "$ign" ]; then skip=true; break; fi
    done
    [ "$name" = "Brewfile" ] && skip=true
    [ "$name" = "README.md" ] && skip=true
    [ "$name" = "bootstrap.sh" ] && skip=true
    [ "$name" = ".git" ] && skip=true
    if [ "$skip" = false ]; then
      pkgs+=("$name")
    fi
  done < <(find "$REPO_ROOT" -maxdepth 1 -mindepth 1 -type d -print0)
  printf '%s\n' "${pkgs[@]}"
}

if [ "${#REQUESTED_PACKAGES[@]}" -gt 0 ]; then
  PACKAGES=("${REQUESTED_PACKAGES[@]}")
else
  # auto-discover
  mapfile -t PACKAGES < <(discover_packages)
fi

if [ "${#PACKAGES[@]}" -eq 0 ]; then
  warn "No stow packages found in the repository root. Nothing to stow."
  exit 0
fi

log "Packages to process: ${PACKAGES[*]}"

#######################################
# Step 5: Backup existing files that would be overwritten
#######################################
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="${BACKUP_DIR_BASE}_${TIMESTAMP}"
if [ "$DRY_RUN" = true ]; then
  log "DRY RUN: Would create backup directory: ${BACKUP_DIR}"
else
  mkdir -p "${BACKUP_DIR}"
  log "Created backup directory: ${BACKUP_DIR}"
fi

# helper to back up one target (file or symlink or directory)
backup_target() {
  local target="$1"
  local rel="$2"       # relative path under package (for naming)
  local dest="${BACKUP_DIR}/${rel}"
  if [ "$DRY_RUN" = true ]; then
    log "DRY RUN: Would back up '${target}' to '${dest}'."
    return 0
  fi
  mkdir -p "$(dirname "$dest")"
  if [ -L "$target" ]; then
    rm -v -- "$target"
  else
    mv -v -- "$target" "$dest"
  fi
}

# For each package, show a stow dry-run then back up existing targets
for pkg in "${PACKAGES[@]}"; do
  pkg_dir="$REPO_ROOT/$pkg"
  if [ ! -d "$pkg_dir" ]; then
    warn "Skipping package '${pkg}' because '${pkg_dir}' does not exist or is not a directory."
    continue
  fi

  log "=== Preview stow for package: ${pkg} ==="
  stow -n -v -t "${STOW_TARGET}" "$pkg" || true

  # Build list of files/directories stow would link by finding all files in the package
  # We capture regular files and directories. Use null-delimited to be safe with spaces.
  while IFS= read -r -d '' file; do
    relpath="${file#${pkg_dir}/}"
    target="${STOW_TARGET}/${relpath}"

    # If the target exists (file, dir, or symlink), back it up.
    if [ -e "$target" ] || [ -L "$target" ]; then
      log "Found existing target: ${target} (will be backed up)"
      backup_target "$target" "$pkg/$relpath"
    fi
  done < <(find "$pkg_dir" -mindepth 1 -print0)
done

#######################################
# Step 6: Apply stow for each package
#######################################
if [ "$DRY_RUN" = true ]; then
  log "DRY RUN: Skipping actual stow apply step. Re-run without --dry-run to apply changes."
  exit 0
fi

if [ "$AUTO_YES" = false ]; then
  confirm_or_exit "Proceed to create symlinks with stow for packages: ${PACKAGES[*]}?"
fi

# Apply stow for real
for pkg in "${PACKAGES[@]}"; do
  pkg_dir="$REPO_ROOT/$pkg"
  if [ ! -d "$pkg_dir" ]; then
    warn "Skipping package '${pkg}' - directory missing."
    continue
  fi
  log "Stowing package: ${pkg} -> target: ${STOW_TARGET}"
  stow -v -t "${STOW_TARGET}" "$pkg"
done

log "Bootstrap complete."
log "Backups were saved to: ${BACKUP_DIR}"
log "If anything looks wrong, restore files from the backup directory."

#######################################
# Post-bootstrap tips
#######################################
cat <<EOF

Next steps (suggested):

- Verify your shells and editors work as expected. Restart your terminal if needed.
- If you added macOS services in Brewfile, make sure to run any recommended service setup (e.g. `brew services start ...`).
- To add a package to the repository:
    - Create a top-level directory (e.g. 'git') and put the files with their target paths relative to the package root.
    - From the repo root: stow -v -t \$HOME git
    - Commit and push the changes to the repo, so other machines pick it up.

If you want, run this script on a fresh machine to provision it. For reproducible provisioning in automation, you can run:
  REPO_ROOT=/path/to/this/repo STOW_TARGET=/Users/you ./bootstrap.sh --yes

EOF
