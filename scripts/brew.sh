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

cd /opt/homebrew/bin/
PATH=$PATH:/opt/homebrew/bin
echo export PATH=$PATH:/opt/homebrew/bin >> ~/.zshrc

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
    mysql@8.0
    node@24
    openssh
    openssl
    pango
    postgresql@18
    postgis
    pyenv
    pyenv-virtualenv
    redis
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
    dropbox
    firefox@developer-edition
    flux
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
    poedit
    postman
    sourcetree
    tableplus
    the-unarchiver
    visual-studio-code
    vlc
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
brew services start postgresql@18 &> /dev/null
brew services start redis &> /dev/null


#
# Clean up installation files
#
print_info "Cleaning up installation files..."
brew cleanup &> /dev/null
