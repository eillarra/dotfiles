#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"


ext_install() {
    if [ -d ~/.atom/packages/$1 ]; then
        print_info "Extension \"$1\" already installed"
    else
        print_info "Extension \"$1\" is not installed. Installing…"
        code --install-extension $1
        print_result $? "Install extension \"$1\""
    fi
}


echo
print_step 'VS Code editor'


#
# Install editor extensions
#
extensions="
    EditorConfig.EditorConfig
    PeterJausovec.vscode-docker
    bibhasdn.django-html
    bibhasdn.django-snippets
    ms-python.python
    ms-vscode.azure-account
    wholroyd.jinja
"
for extension in $extensions
do
    ext_install $extension
done


# Create a symlink for .atom/config.cson
# file=~/.atom/config.cson
# dotfile="$(cd $(dirname "${BASH_SOURCE[0]}")/../files/; pwd)/.atom/config.cson"
# symlink $dotfile $file
# print_info "Symlink created for $file"
