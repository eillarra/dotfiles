#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"


ask_for_sudo


echo
print_step 'Install Xcode Command Line Tools'


#
# Install Xcode Command Line Tools
#
if ! xcode-select --print-path &> /dev/null; then
    xcode-select --install
else
    print_info 'Already installed'
fi
