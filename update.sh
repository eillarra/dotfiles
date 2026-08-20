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
print_info "Upgrading formulas and cask apps..."
run_indent brew upgrade --greedy
print_info "Cleaning up installation files..."
brew cleanup --prune=all &> /dev/null
print_success "Homebrew updated"

#
# uv tools
#
if command_exists uv; then
    print_info "Upgrading uv tools..."
    run_indent uv tool upgrade --all
    print_success "uv tools updated"
fi

echo
