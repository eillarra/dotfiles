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
    certbot
    gettext
    go
    mysql
    node
    postgresql
    pyenv
    pyenv-virtualenv
    r
    siege
"
for formula in $formulas
do
    brew_install $formula
done


#
# Install applications via Cask
#
applications="
    atom
    calibre
    citrix-receiver
    dropbox
    firefox
    flux
    google-chrome
    keepassx
    kindle
    lego-digital-designer
    libreoffice
    ngrok
    owncloud
    pgadmin3
    postman
    rstudio
    sequel-pro
    skype
    sourcetree
    the-unarchiver
    transmission
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
