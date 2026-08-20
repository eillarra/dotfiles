# .dotfiles

This is how I personalize my system.
In a fresh installation, I just need to clone this repo and run the install script:

```bash
cd
git clone https://github.com/eillarra/dotfiles .dotfiles
bash .dotfiles/install.sh
```

## Reinstall

Re-run Homebrew formulas/casks and dotfile symlinks
(without Xcode/macOS setup):

```bash
dot_reinstall
```

## Updates

Update macOS + Homebrew packages:

```bash
dot_update
```
