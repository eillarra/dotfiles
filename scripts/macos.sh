#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"


echo
print_step 'Configure macOS'


#
# Folder structure
#
print_success 'Create custom folders'
mkdir -p ~/Code


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

# Set the timezone; see `systemsetup -listtimezones` for other values
systemsetup -settimezone "Europe/Brussels" &> /dev/null

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

mdutil -i off / &> /dev/null
launchctl unload -w /System/Library/LaunchDaemons/com.apple.metadata.mds.plist &> /dev/null
print_info 'Spotlight server disabled'

launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist &> /dev/null
print_info 'Notification Center disabled'

defaults write com.apple.assistant.support "Assistant Enabled" -bool false
defaults write com.apple.Siri StatusMenuVisible -bool false
print_info 'Siri disabled'


#
# Finder
#
print_success 'Finder'

chflags nohidden ~/Library
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowPreviewPane -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowTabView -bool true
defaults write com.apple.finder SidebarWidth -int 175

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

# Don't default to saving documents to iCloud
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false


#
# Screeshots
#
print_success 'Screenshots'

# Save screenshots to the selected folder
defaults write com.apple.screencapture location -string "${HOME}/Downloads"

# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"


#
# Screensaver
#
print_success 'Screensaver'

# Set your screen to lock as soon as the screensaver starts
defaults write com.apple.screensaver askForPassword -bool true
defaults write com.apple.screensaver askForPasswordDelay -bool false


#
# Miscellaneous
#

# Disable crash reporter
defaults write com.apple.CrashReporter DialogType none

# Disable Bonjour multicast advertisements
sudo defaults write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements -bool true


#
# Restart system apps
#
print_success 'Restart apps'
for app in Dock Finder SystemUIServer; do
    killall "${app}" &> /dev/null
done
