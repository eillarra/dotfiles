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
        brew cask install $1 &> /dev/null
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
# Intall Taps
#
taps="
    caskroom/cask
    caskroom/fonts
    homebrew/cask-versions
"
for tap in $taps
do
    brew tap $tap &> /dev/null
    print_result $? "Tap \"$tap\""
done


#
# Install Homebrew formulas
#
formulas="
    cloc
    ctags
    gettext
    heroku
    mysql@5.7
    openssl
    pyenv
    pipenv
    youtube-dl
"
for formula in $formulas
do
    brew_install $formula
done

# Special case: CURL
if ! brew list curl &> /dev/null; then
    print_info "Formula \"curl\" is not installed. Installing…"
    brew install curl --with-openssl
    brew link --force curl
    print_result $? "Install formula \"curl\""
else
    print_info "Formula \"curl\" already installed"
fi


#
# Install applications via Cask
#
applications="
    balenaetcher
    calibre
    citrix-workspace
    docker
    dropbox
    firefox-developer-edition
    flux
    font-hack
    font-open-sans
    font-roboto
    google-chrome
    google-cloud-sdk
    imageoptim
    java
    libreoffice
    microsoft-teams
    nextcloud
    ngrok
    openemu
    poedit
    postman
    sequel-pro
    skype
    sourcetree
    spotify
    telegram-desktop
    the-unarchiver
    visual-studio-code
    vlc
    xquartz
    inkscape
"
for application in $applications
do
    brew_cask_install $application
done


#
# Links
#
print_info "Creating links for services..."
brew services start mysql@5.7 &> /dev/null
brew link --force mysql@5.7 &> /dev/null


#
# Clean up installation files
#
print_info "Cleaning up installation files..."
brew cleanup &> /dev/null
