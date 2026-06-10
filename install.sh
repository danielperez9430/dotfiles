#!/usr/bin/env bash
set -euo pipefail

export DOTFILES="$(cd "$(dirname "$0")" && pwd)"

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

# Ensure all scripts are executable (git doesn't always preserve +x)
chmod +x "$DOTFILES"/install.sh 2>/dev/null || true
chmod +x "$DOTFILES"/bootstrap/*.sh 2>/dev/null || true
chmod +x "$DOTFILES"/backup/*.sh 2>/dev/null || true

SCRIPTS=("$DOTFILES/bootstrap/"*.sh)
ALL=()
for s in "${SCRIPTS[@]}"; do
  [[ "$(basename "$s")" != "_lib.sh" ]] && ALL+=("$s")
done

echo ""
echo "${CYAN}⚡ dotfiles${NC} — macOS developer bootstrap"
echo "   ${#ALL[@]} scripts"
if $DRY_RUN; then
  echo "   ${YELLOW}--dry-run${NC}  → showing what would run, not executing"
fi
echo ""

for script in "${ALL[@]}"; do
  if $DRY_RUN; then
    echo "  ${YELLOW}→${NC} would run: $(basename "$script")"
  else
    bash "$script"
  fi
done

if $DRY_RUN; then
  echo ""
  echo "${YELLOW}dry run complete${NC} — remove --dry-run to apply"
else
  echo ""
  echo "${GREEN}✓ all done${NC} — restart your terminal or run: exec zsh"
fi
echo ""
