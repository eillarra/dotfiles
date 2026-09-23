#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

uv_tool_install() {
    name="${1%%[*}"
    if uv tool list 2>/dev/null | grep -q "^$name"; then
        print_info "uv tool \"$name\" already installed"
    else
        print_info "uv tool \"$name\" is not installed. Installing…"
        run_indent uv tool install --python-preference only-managed "$1"
        print_result $? "Install uv tool \"$name\""
    fi
}

npm_tool_install() {
    if npm list -g --depth=0 2>/dev/null | grep -q " $1@"; then
        print_info "npm tool \"$1\" already installed"
    else
        print_info "npm tool \"$1\" is not installed. Installing…"
        run_indent npm install -g "$1"
        print_result $? "Install npm tool \"$1\""
    fi
}

#
# Install CLI tools via `uv tool` (isolated envs, binaries on ~/.local/bin)
#

echo
print_step 'uv tools'

tools="
    headroom-ai[code,proxy,pytorch-mps]
"
for tool in $tools
do
    uv_tool_install "$tool"
done
