#!/bin/bash

#
# Install command line Developer Tools for Xcode
#
source "$(dirname "${BASH_SOURCE[0]}")/scripts/xcode.sh"

#
# Configure macOS
#
source "$(dirname "${BASH_SOURCE[0]}")/scripts/macos.sh"

#
# Install Homebrew formulas and Cask applications
#
source "$(dirname "${BASH_SOURCE[0]}")/scripts/brew.sh"

#
# Install CLI tools via uv
#
source "$(dirname "${BASH_SOURCE[0]}")/scripts/tools.sh"

#
# Create symlinks for .dotfiles
#
source "$(dirname "${BASH_SOURCE[0]}")/scripts/dotfiles.sh"

echo
