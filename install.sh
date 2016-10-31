#!/bin/bash


# Install command line Developer Tools for XCode
xcode-select --install


# Install Homebrew
sudo chown -R $(whoami) /usr/local
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew update
brew doctor


# Intall Taps
brew tap caskroom/cask
brew tap caskroom/fonts
brew tap homebrew/science


# Install fonts
for font in font-open-sans font-roboto
do
    brew cask install $font
done


# Install applications via Cask
for application in atom cakebrew calibre citrix-receiver dropbox github-desktop firefox flux google-chrome keepassx kindle lego-digital-designer libreoffice ngrok owncloud pgadmin3 postman rstudio sequel-pro skype the-unarchiver transmission vlc
do
    brew cask install $application
done

brew cask cleanup


# Install Homebrew formulas
for formula in certbot gettext go mysql node postgresql pyenv pyenv-virtualenv r siege
do
    read -p "Install '$formula' formula (y/n)? " CONT
    if [[ "$CONT" == "y" ]]; then
        brew install $formula
    fi
done

brew cleanup


# Install Python versions
for python in 2.7.12 3.5.2
do
    read -p "Install Python version '$python' (y/n)? " CONT
    if [[ "$CONT" == "y" ]]; then
        pyenv install $python
    fi
done


# Update .bash_profile
echo 'eval "$(pyenv init -)";' >> ~/.bash_profile
echo 'eval "$(pyenv virtualenv-init -)";' >> ~/.bash_profile


# Start `mysql` and `postgresql`
for service in mysql postgresql
do
    read -p "Do you want to automatically start '$service' service (y/n)? " CONT
    if [[ "$CONT" == "y" ]]; then
        brew services start $service
    fi
done


# Install Node packages
for nodepackage in angular-cli cordova firebase-tools ionic
do
    read -p "Install '$nodepackage' Node package (y/n)? " CONT
    if [[ "$CONT" == "y" ]]; then
        npm install -g $nodepackage
    fi
done


# Install Atom plugins
for atompackage in linter angular-2-typescript-snippets atom-django atom-typescript autoclose-html color-picker django-templates editorconfig linter-pylama minimap Sublime-Style-Column-Selection
do
    apm install $atompackage
done

apm disable whitespace
