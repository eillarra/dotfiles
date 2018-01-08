#!/bin/bash


#
# Install command line Developer Tools for XCode
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
# Install some useful Python libraries
#
source "$(dirname "${BASH_SOURCE[0]}")/scripts/python.sh"


#
# Configure editor
#
source "$(dirname "${BASH_SOURCE[0]}")/scripts/editor.sh"


#
# Create symlinks for .dotfiles
#
source "$(dirname "${BASH_SOURCE[0]}")/scripts/dotfiles.sh"


echo
