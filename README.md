# .dotfiles

My personal macOS setup: shell config and aliases, Homebrew formulas and casks, uv/npm CLI tools, and AI agent skills — managed through a single `dot` command.

In a fresh installation, I just need to clone this repo and run the install script:

```bash
cd
git clone https://github.com/eillarra/dotfiles .dotfiles
bash .dotfiles/install.sh
```

Then restart your shell: the `dot` command becomes available.

## Reinstall

Re-run Homebrew formulas/casks and dotfile symlinks
(without Xcode/macOS setup):

```bash
dot reinstall
```

## Updates

Update macOS + Homebrew packages:

```bash
dot update
```
