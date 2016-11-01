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
        symlink $dotfile ~/$basename
        print_info "Symlink created for $basename"
    fi
done
