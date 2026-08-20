#!/bin/bash
# See: https://github.com/alrra/dotfiles/blob/master/src/os/utils.sh

ask_for_sudo() {
    # Ask for the administrator password upfront.
    sudo -v &> /dev/null

    # Update existing `sudo` time stamp
    # until this script has finished.
    # https://gist.github.com/cowboy/3118588
    while true; do
        sudo -n true
        sleep 60
        kill -0 "$$" || exit
    done &> /dev/null &
}

command_exists() {
    type "$1" &> /dev/null
}

# Run a command, indenting its output 4 spaces so it nests under a print_info line.
# Returns the command's exit status (not awk's).
run_indent() {
    "$@" 2>&1 | awk '{ print "    " $0; fflush() }'
    return ${PIPESTATUS[0]}
}

print_in_color() {
    printf "%b" \
        "$(tput setaf "$2" 2> /dev/null)" \
        "$1" \
        "$(tput sgr0 2> /dev/null)"
}

print_in_cyan() {
    print_in_color "$1" 6
}

print_in_green() {
    print_in_color "$1" 2
}

print_in_purple() {
    print_in_color "$1" 5
}

print_in_red() {
    print_in_color "$1" 1
}

print_step() {
    print_in_purple "==> $1\n"
}

print_info() {
    print_in_cyan "[i] $1\n"
}

print_success() {
    print_in_green "[✔] $1\n"
}

print_error() {
    print_in_red "[✖] $1\n"
}

print_result() {
    if [ "$1" -eq 0 ]; then
        print_success "$2"
    else
        print_error "$2"
    fi

    return "$1"
}