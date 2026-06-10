#!/usr/bin/env bash
source "$(dirname "$0")/_lib.sh"

TITLE="01-shell — zsh"
section "$TITLE"

ZSHRC_SRC="$DOTFILES/configs/zshrc"
ZSHRC_DST="$HOME/.zshrc"

# ── .zshrc ─────────────────────────────────────────────────

if [ -f "$ZSHRC_DST" ] && [ ! -L "$ZSHRC_DST" ]; then
  BACKUP="$HOME/.zshrc.backup.$(date +%Y%m%d-%H%M%S)"
  cp "$ZSHRC_DST" "$BACKUP"
  info "backed up existing .zshrc → $(basename "$BACKUP")"
fi

ln -sf "$ZSHRC_SRC" "$ZSHRC_DST"
check ".zshrc → dotfiles/configs/zshrc"

section_done "$TITLE"
