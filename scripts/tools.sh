#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

uv_tool_install() {
    name="${1%%[*}"
    if uv tool list 2>/dev/null | grep -q "^$name"; then
        print_info "uv tool \"$name\" already installed"
    else
        print_info "uv tool \"$name\" is not installed. Installing…"
        run_indent uv tool install "$1"
        print_result $? "Install uv tool \"$name\""
    fi
}

echo
print_step 'uv tools'

#
# Install CLI tools via `uv tool` (isolated envs, binaries on ~/.local/bin)
#
tools="
    headroom-ai[code,proxy,pytorch-mps]
"
for tool in $tools
do
    uv_tool_install "$tool"
done
