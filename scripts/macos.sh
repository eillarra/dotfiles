#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"


echo
print_step 'Configure macOS'

ask_for_sudo


#
# Folder structure
#
print_success 'Create custom folders'
mkdir -p ~/Code
mkdir -p ~/Dropbox


#
# Language & l10n
#
print_success 'Language & l10n'

# Set language and text formats
defaults write NSGlobalDomain AppleLanguages -array "en"
defaults write NSGlobalDomain AppleLocale -string "en_BE@currency=EUR"
defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
defaults write NSGlobalDomain AppleMetricUnits -bool true
print_info 'en_BE, EUR, metric units'

# Set the timezone; see `sudo systemsetup -listtimezones` for other values
sudo systemsetup -settimezone "Europe/Brussels" > /dev/null

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false


#
# UI/UX
#
print_success 'General UI/UX'
# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Set boot audio volume to zero
sudo nvram SystemAudioVolume=" "

# Disable smart quotes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

defaults write NSGlobalDomain AppleInterfaceStyle Dark
defaults write NSGlobalDomain AppleEnableMenuBarTransparency -bool false
print_info "Interface style set to \"Dark\""

launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist 2> /dev/null
print_info 'Notification Center disabled'

defaults write com.apple.assistant.support "Assistant Enabled" -bool false
defaults write com.apple.Siri StatusMenuVisible -bool false
print_info 'Siri disabled'


#
# Finder
#
print_success 'Finder'

defaults write com.apple.finder ShowAllFiles -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowPreviewPane -bool true
defaults write com.apple.finder ShowTabView -bool true
defaults write com.apple.finder SidebarWidth -int 175;

# Show all filename extensions in Finder
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Disable the warning before emptying the Trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Empty Trash securely by default
defaults write com.apple.finder EmptyTrashSecurely -bool true

# Always use the column view
defaults write com.apple.finder FXPreferredViewStyle Clmv

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Avoid creating .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true


#
# Screeshots
#
print_success 'Screenshots'

# Save screenshots to the selected folder
defaults write com.apple.screencapture location -string "${HOME}/Downloads"

# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"


#
# Restart system apps
#
print_success 'Restart apps'
for app in Dock Finder SystemUIServer; do
    killall "${app}" &> /dev/null
done
