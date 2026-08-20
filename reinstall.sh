#!/bin/bash

#
# Reinstall Homebrew formulas/casks, uv tools, and dotfile symlinks.
# Skips Xcode tools and macOS configuration (see install.sh for those).
#
source "$(dirname "${BASH_SOURCE[0]}")/scripts/brew.sh"
source "$(dirname "${BASH_SOURCE[0]}")/scripts/tools.sh"
source "$(dirname "${BASH_SOURCE[0]}")/scripts/dotfiles.sh"

echo
