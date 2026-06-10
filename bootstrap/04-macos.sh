#!/usr/bin/env bash
source "$(dirname "$0")/_lib.sh"

TITLE="04-macos — system defaults"
section "$TITLE"

info "applying macOS defaults (uncomment to activate)..."

# ── Finder ─────────────────────────────────────────────────

# Show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Search current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable extension change warning
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

check "finder preferences applied"

# ── Dock ───────────────────────────────────────────────────

# Auto-hide
# defaults write com.apple.dock autohide -bool true

# No delay on auto-hide
# defaults write com.apple.dock autohide-delay -float 0

# Don't show recent apps
defaults write com.apple.dock show-recents -bool false

check "dock preferences applied"

# ── Keyboard ───────────────────────────────────────────────

# Fast key repeat
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Disable auto-correct
# defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

check "keyboard preferences applied"

# ── Screenshots ────────────────────────────────────────────

# Save to ~/Screenshots instead of desktop
# mkdir -p "$HOME/Screenshots"
# defaults write com.apple.screencapture location -string "$HOME/Screenshots"

# Disable shadow in screenshots
# defaults write com.apple.screencapture disable-shadow -bool true

# check "screenshot preferences applied"

# ── Restart affected apps ──────────────────────────────────

info "you may need to restart Finder and Dock for all changes:"
info "  killall Finder"
info "  killall Dock"

section_done "$TITLE"
