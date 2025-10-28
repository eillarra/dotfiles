#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"


brew_install() {
    if brew ls --versions $1 > /dev/null; then
        print_info "Formula \"$1\" already installed"
    else
        print_info "Formula \"$1\" is not installed. Installing…"
        brew install $1 &> /dev/null
        print_result $? "Install formula \"$1\""
    fi
}

brew_cask_install() {
    if brew ls --versions $1 > /dev/null; then
        print_info "Cask \"$1\" already installed"
    else
        print_info "Cask \"$1\" is not installed. Installing…"
        brew install --cask $1 &> /dev/null
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
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" &> /dev/null
    print_result $? 'Homebrew installed'
fi

print_info "Updating Homebrew..."
brew update &> /dev/null
print_info "Updating installed formulas..."
brew upgrade &> /dev/null


#
# Install Homebrew formulas
#
formulas="
    cloc
    croc
    curl
    ffmpeg
    gettext
    gdal
    gpg
    mysql
    node
    openssh
    openssl
    postgresql
    postgis
    pyenv
    pyenv-virtualenv
    sqlite
    libspatialite
    uv
    yarn
    yt-dlp
    webp
"
for formula in $formulas
do
    brew_install $formula
done


#
# Install applications via Cask
#
applications="
    balenaetcher
    calibre
    citric-workspace
    docker
    dropbox
    firefox@developer-edition
    flux
    font-hack
    font-open-sans
    font-roboto
    google-chrome
    imageoptim
    libreoffice
    microsoft-teams
    nextcloud
    ngrok
    poedit
    postman
    skype
    sourcetree
    spotify
    tableplus
    the-unarchiver
    visual-studio-code
    vlc
    webex
    zoom
    xquartz
    inkscape
"
for application in $applications
do
    brew_cask_install $application
done


#
# Services
#
print_info "Starting services..."
brew services start mysql &> /dev/null
brew services start postgresql &> /dev/null


#
# Clean up installation files
#
print_info "Cleaning up installation files..."
brew cleanup &> /dev/null
