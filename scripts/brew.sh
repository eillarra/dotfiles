#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"


brew_install() {
    if ! brew list $1 &> /dev/null; then
        print_info "Formula \"$1\" is not installed. Installing…"
        brew install $1
        print_result $? "Install formula \"$1\""
    else
        print_info "Formula \"$1\" already installed"
    fi
}

brew_cask_install() {
    if ! brew cask list $1 &> /dev/null; then
        print_info "Cask \"$1\" is not installed. Installing…"
        brew cask install $1
        print_result $? "Install cask \"$1\""
    else
        print_info "Cask \"$1\" already installed"
    fi
}


echo
print_step 'Homebrew'


#
# Install Homebrew
#
if [ ! -f "`which -s brew`" ]; then
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
brew tap caskroom/cask &> /dev/null
brew tap caskroom/fonts &> /dev/null
brew tap homebrew/science &> /dev/null


#
# Install Homebrew formulas
#
formulas="
    cloc
    gettext
    go
    heroku
    openssl
    pyenv
    pyenv-virtualenv
    python3
    siege
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
    atom
    calibre
    citrix-receiver
    docker
    dropbox
    firefox
    flux
    google-chrome
    kindle
    kitematic
    lego-digital-designer
    libreoffice
    ngrok
    owncloud
    pgadmin4
    postman
    sequel-pro
    skype
    sourcetree
    the-unarchiver
    vlc
"
for application in $applications
do
    brew_cask_install $application
done


#
# Install fonts
#
fonts="
    font-open-sans
    font-roboto
"
for font in $fonts
do
    brew_cask_install $font
done


#
# Clean up installation files
#
print_info "Cleaning up installation files..."
brew cleanup &> /dev/null
brew cask cleanup &> /dev/null
