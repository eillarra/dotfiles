#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"


echo
print_step 'Create symlinks to .dotfiles'


DIR="$(cd $(dirname "${BASH_SOURCE[0]}")/../files/; pwd)"

for dotfile in "$DIR"/.[^.]*
do
    if [[ -f $dotfile && $dotfile != *".DS_Store"* ]]
    then
        basename="$(basename $dotfile)"
        ln -sf $dotfile ~/$basename
        print_info "Symlink created for $basename"
    fi
done

VSCODE_DESTINATION="$(cd ~/Library/Application\ Support/Code/User; pwd)"
ln -sf "$DIR/vscode/keybindings.json" "$VSCODE_DESTINATION/keybindings.json"
ln -sf "$DIR/vscode/settings.json" "$VSCODE_DESTINATION/settings.json"
print_info "Symlink created for VS Code settings"
