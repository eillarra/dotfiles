#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

echo
print_step 'Create symlinks to .dotfiles'

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../files/"; pwd)"

for dotfile in "$DIR"/.[^.]*
do
    if [[ -f $dotfile && $dotfile != *".DS_Store"* ]]
    then
        basename="$(basename "$dotfile")"
        ln -sf "$dotfile" ~/$basename
        print_info "Symlink created for $basename"
    fi
done

mkdir -p ~/.agents
mkdir -p ~/.claude
ln -sfn "$DIR/agents/skills" ~/.agents/skills
ln -sfn "$DIR/agents/skills" ~/.claude/skills
print_info "Symlink created for agent skills"

mkdir -p ~/.cache/nltk_data
print_info "NLTK data cache directory created"
