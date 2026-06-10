#!/usr/bin/env bash
source "$(dirname "$0")/_lib.sh"

TITLE="00-brew — Homebrew + packages"
section "$TITLE"

# ── Install Homebrew ──────────────────────────────────────

if command -v brew &> /dev/null; then
  skip "homebrew already installed — $(brew --version | head -1)"
else
  info "installing homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  check "homebrew installed"
fi

# ── Bundle ─────────────────────────────────────────────────

BREWFILE="$DOTFILES/configs/Brewfile"

if [ -f "$BREWFILE" ]; then
  info "installing packages from Brewfile..."
  brew bundle --file="$BREWFILE" || true
  check "brew bundle done"
else
  skip "no Brewfile found — skipping bundle"
fi

section_done "$TITLE"
