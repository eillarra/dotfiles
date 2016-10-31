#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"


apm_install() {
    if [ -d ~/.atom/packages/$1 ]; then
        print_info "Package \"$1\" already installed"
    else
        print_info "Package \"$1\" is not installed. Installing…"
        apm install $1
        print_result $? "Install package \"$1\""
    fi
}


echo
print_step 'Atom editor'


#
# Install Atom packages
#
for atompackage in linter angular-2-typeScript-snippets atom-django atom-typescript autoclose-html color-picker django-templates editorconfig linter-pylama minimap Sublime-Style-Column-Selection
do
    apm_install $atompackage
done


# Disable "whitespace" core package, to avoid conflicts with "editorconfig"
for atompackage in whitespace
do
    apm disable $atompackage &> /dev/null
    print_info "Package \"$atompackage\" disabled"
done
