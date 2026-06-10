#!/usr/bin/env bash
source "$(dirname "$0")/_lib.sh"

TITLE="02-node — fnm + Node LTS"
section "$TITLE"

# ── fnm ────────────────────────────────────────────────────

if command -v fnm &> /dev/null; then
  skip "fnm already installed — $(fnm --version)"
else
  info "fnm not found — install it via brew (add 'fnm' to Brewfile)"
  info "or: curl -fsSL https://fnm.vercel.app/install | bash"
fi

# ── Node LTS ───────────────────────────────────────────────

# Ensure fnm is available in this session
export PATH="$HOME/.local/share/fnm:$PATH" 2>/dev/null || true
eval "$(fnm env 2>/dev/null)" 2>/dev/null || true

if command -v node &> /dev/null; then
  CURRENT=$(node --version)
  check "node $CURRENT"
else
  info "installing Node LTS via fnm..."
  fnm install --lts
  fnm default lts-latest
  check "node $(node --version)"
fi

section_done "$TITLE"
