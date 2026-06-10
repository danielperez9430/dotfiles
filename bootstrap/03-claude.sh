#!/usr/bin/env bash
source "$(dirname "$0")/_lib.sh"

TITLE="03-claude — Claude Code settings + skills"
section "$TITLE"

CLAUDE_DIR="$HOME/.claude"
AGENTS_SKILLS="$HOME/.agents/skills"
DOTFILES_CLAUDE="$DOTFILES/configs/claude"

# ── settings.json ──────────────────────────────────────────

if [ -f "$DOTFILES_CLAUDE/settings.json" ]; then
  ln -sf "$DOTFILES_CLAUDE/settings.json" "$CLAUDE_DIR/settings.json"
  check "settings.json → dotfiles"
else
  skip "no settings.json in dotfiles — skipping"
fi

# ── skills ─────────────────────────────────────────────────

if [ -d "$DOTFILES_CLAUDE/skills" ]; then
  mkdir -p "$AGENTS_SKILLS"
  mkdir -p "$CLAUDE_DIR/skills"

  SKILL_COUNT=0
  for skill_dir in "$DOTFILES_CLAUDE/skills/"*; do
    [ -d "$skill_dir" ] || continue
    SKILL_NAME=$(basename "$skill_dir")

    # Copy skill to agents directory
    rm -rf "$AGENTS_SKILLS/$SKILL_NAME"
    cp -R "$skill_dir" "$AGENTS_SKILLS/$SKILL_NAME"
    check "skill: $SKILL_NAME"

    # Create symlink in claude directory
    ln -sf "../../.agents/skills/$SKILL_NAME" "$CLAUDE_DIR/skills/$SKILL_NAME"

    SKILL_COUNT=$((SKILL_COUNT + 1))
  done

  info "$SKILL_COUNT skill(s) installed"
else
  skip "no skills directory in dotfiles — skipping"
fi

section_done "$TITLE"
