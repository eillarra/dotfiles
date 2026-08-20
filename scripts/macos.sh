#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

ask_for_sudo

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

# Close any open System Settings panes, to prevent them from overriding
# settings we’re about to change (renamed from System Preferences in macOS 13)
osascript -e 'tell application "System Settings" to quit' 2> /dev/null
osascript -e 'tell application "System Preferences" to quit' 2> /dev/null

# Set boot audio volume to zero
sudo nvram SystemAudioVolume=" "

# Disable smart quotes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

defaults write NSGlobalDomain AppleInterfaceStyle Dark
defaults write com.apple.universalaccess reduceTransparency -bool true
print_info "Interface style set to \"Dark\""

# Disable Spotlight indexing on the root volume
# (launchctl unload of mds is blocked by SIP on modern macOS)
mdutil -i off / &> /dev/null
print_info 'Spotlight indexing disabled on /'

# Disable Siri
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

# Always use the column view
defaults write com.apple.finder FXPreferredViewStyle Clmv

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Avoid creating .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Don't default to saving documents to iCloud
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

#
# Trackpad
#
print_success 'Trackpad'

# Enable App Expose
defaults write com.apple.dock showAppExposeGestureEnabled -bool true

#
# Screenshots
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
defaults write com.apple.screensaver askForPasswordDelay -int 0

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