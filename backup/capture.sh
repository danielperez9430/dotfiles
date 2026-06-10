#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

check() { printf "  ${GREEN}✓${NC} %s\n" "$1"; }
skip()  { printf "  ${YELLOW}→${NC} %s\n" "$1"; }
info()  { printf "  ${CYAN}ℹ${NC} %s\n" "$1"; }

echo ""
printf "${BOLD}── capture — scan system → dotfiles${NC}\n"
echo ""

# ── Brewfile ───────────────────────────────────────────────

if command -v brew &> /dev/null; then
  info "Brewfile not auto-captured — review and edit it manually:"
  info "  $DOTFILES/configs/Brewfile"
  info "  hint: brew bundle dump --force --file=/tmp/Brewfile.full"
else
  skip "brew not found — skipping Brewfile"
fi

# ── .zshrc ─────────────────────────────────────────────────

if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
  cp "$HOME/.zshrc" "$DOTFILES/configs/zshrc"
  check ".zshrc captured"
elif [ -L "$HOME/.zshrc" ]; then
  skip ".zshrc is a symlink — already managed by dotfiles"
else
  skip ".zshrc not found"
fi

# ── Claude settings ────────────────────────────────────────

if [ -f "$HOME/.claude/settings.json" ] && [ ! -L "$HOME/.claude/settings.json" ]; then
  cp "$HOME/.claude/settings.json" "$DOTFILES/configs/claude/settings.json"
  check "claude settings.json captured"
elif [ -L "$HOME/.claude/settings.json" ]; then
  skip "claude settings.json is a symlink — already managed by dotfiles"
else
  skip "claude settings.json not found"
fi

# ── Claude skills ──────────────────────────────────────────

SKILL_SRC="$HOME/.agents/skills"
SKILL_DST="$DOTFILES/configs/claude/skills"

if [ -d "$SKILL_SRC" ]; then
  SKILL_COUNT=0
  for skill_dir in "$SKILL_SRC/"*; do
    [ -d "$skill_dir" ] || continue
    SKILL_NAME=$(basename "$skill_dir")
    rm -rf "$SKILL_DST/$SKILL_NAME"
    cp -R "$skill_dir" "$SKILL_DST/$SKILL_NAME"
    check "skill captured: $SKILL_NAME"
    SKILL_COUNT=$((SKILL_COUNT + 1))
  done
  info "$SKILL_COUNT skill(s) captured"
else
  skip "no skills directory at ~/.agents/skills — skipping"
fi

# ── Done ───────────────────────────────────────────────────

echo ""
printf "${BOLD}next steps:${NC}\n"
echo "  cd ~/dotfiles && git diff"
echo "  git add -A && git commit -m 'capture: $(date +%Y-%m-%d)'"
echo "  git push"
echo ""
