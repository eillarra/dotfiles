#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/scripts/utils.sh"


ask_for_sudo


echo
print_step 'Software update'


#
# macOS Software Update
#
print_info "Updating from App Store..."
softwareupdate -i -a &> /dev/null
print_success "macOS applications updated"


#
# Homebrew
#
print_info "Updating Homebrew..."
brew update &> /dev/null
print_info "Updating installed formulas..."
brew upgrade &> /dev/null
print_info "Cleaning up installation files..."
brew cleanup &> /dev/null
print_success "Homebrew updated"


#
# Atom
#
print_info "Updating Atom packages..."
apm upgrade --no-confirm &> /dev/null
print_success "Atom updated"


echo
