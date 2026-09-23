#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../files/"; pwd)"

#
# Custom agents
#

echo
print_step 'Create AGENTS symlinks'

mkdir -p ~/.agents
mkdir -p ~/.claude
mkdir -p ~/.config/zed
ln -sfn "$DIR/agents/skills" ~/.agents/skills
ln -sfn "$DIR/agents/skills" ~/.claude/skills
ln -sf "$DIR/zed/AGENTS.md" ~/.config/zed/AGENTS.md
ln -sf "$DIR/zed/AGENTS.md" ~/.claude/CLAUDE.md
print_info "Symlinks created for AGENTS"

#
# OpenSpec skills (universal, via ~/.agents/skills symlink)
#

echo
print_step "Install OpenSpec skills"
(cd "$HOME" && openspec init --tools agents)
rm -rf "$HOME/openspec"
print_info "OpenSpec skills installed"
