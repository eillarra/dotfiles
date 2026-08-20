#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

ask_for_sudo
export HOMEBREW_NO_AUTO_UPDATE=1

brew_install() {
    if brew ls --versions "$1" > /dev/null; then
        print_info "Formula \"$1\" already installed"
    else
        print_info "Formula \"$1\" is not installed. Installing…"
        run_indent brew install "$1"
        print_result $? "Install formula \"$1\""
    fi
}

brew_cask_install() {
    if brew ls --cask --versions "$1" > /dev/null 2>&1; then
        print_info "Cask \"$1\" already installed"
    else
        print_info "Cask \"$1\" is not installed. Installing…"
        run_indent brew install --cask "$1"
        print_result $? "Install cask \"$1\""
    fi
}

echo
print_step 'Homebrew'

#
# Install Homebrew
#
if command_exists brew; then
    print_info 'Homebrew is already installed'
else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" &> /dev/null
    print_result $? 'Homebrew installed'
fi

if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

#
# Install Homebrew formulas
#
formulas="
    cloc
    croc
    curl
    ffmpeg
    gettext
    gpg
    mysql@8.0
    node@24
    ollama
    openssh
    openssl
    pango
    postgresql@18
    pyenv
    pyenv-virtualenv
    redis
    sqlite
    uv
    webp
    wget
    yarn
    yt-dlp
"
for formula in $formulas
do
    brew_install $formula
done

#
# Install applications via Cask
#
applications="
    blackhole-2ch
    calibre
    dropbox
    firefox@developer-edition
    flux-app
    font-hack
    font-open-sans
    font-roboto
    google-chrome
    imageoptim
    inkscape
    libreoffice
    microsoft-teams
    nextcloud
    ngrok
    tableplus
    the-unarchiver
    vlc
    zed
    zoom
"
for application in $applications
do
    brew_cask_install $application
done

#
# Services
#
print_info "Starting services..."
brew services start mysql@8.0 &> /dev/null
brew services start ollama &> /dev/null
brew services start postgresql@18 &> /dev/null
brew services start redis &> /dev/null

#
# Clean up installation files
#
print_info "Cleaning up installation files..."
brew cleanup &> /dev/null
