#!/bin/bash


#
# Install command line Developer Tools for XCode
#
source "$(dirname "${BASH_SOURCE[0]}")/scripts/xcode.sh"


#
# Install Homebrew formulas and Cask applications
#
source "$(dirname "${BASH_SOURCE[0]}")/scripts/brew.sh"


#
# Install packages for Atom editor
#
source "$(dirname "${BASH_SOURCE[0]}")/scripts/atom.sh"
