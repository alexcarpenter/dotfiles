# dotfiles

1. Clone
git clone https://github.com/alexcarpenter/dotfiles ~/dotfiles
cd ~/dotfiles

2. Preview (safe)
./bootstrap.sh --dry-run

3. Apply
./bootstrap.sh        # interactive
./bootstrap.sh --yes  # non-interactive

4. Stow (manual)
# preview
stow -n -v -t $HOME <package>
# apply
stow -v -t $HOME <package>
# remove
stow -D -v -t $HOME <package>

5. Brewfile
# install all
brew update
brew bundle --file=./Brewfile
# capture current machine
brew bundle dump --file=./Brewfile --force --describe

6. Backups
bootstrap saves overwritten files to ~/dotfiles_backup_YYYYMMDD_HHMMSS/

7. Add package
# create top-level folder with target-relative paths, then:
stow -n -v -t $HOME <new-package>
stow -v -t $HOME <new-package>
git add <new-package> && git commit -m "Add <new-package>"
