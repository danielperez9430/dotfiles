# dotfiles

macOS developer bootstrap — idempotent, readable, extensible.

## Quick start

```bash
git clone https://github.com/danielperez9430/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh          # apply everything
./install.sh --dry-run  # preview only — see what would run
```

## What it does

Runs every script in `bootstrap/` in order:

| Script | What |
|---|---|
| `00-brew.sh` | Installs Homebrew + packages from `configs/Brewfile` |
| `01-shell.sh` | Symlinks `.zshrc` |
| `02-node.sh` | Installs fnm + latest Node LTS |
| `03-claude.sh` | Symlinks Claude Code settings + skills |
| `04-macos.sh` | macOS defaults (Finder, Dock, keyboard) |

All scripts are **idempotent** — running `install.sh` twice is safe: already-installed tools are skipped with a `→ skip` message.

## Adding a new tool

1. Add the formula/cask to `configs/Brewfile` (if on brew)
2. Create `bootstrap/05-your-tool.sh`
3. Run `./install.sh` — it picks up new scripts automatically

Script template:

```bash
#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_lib.sh"

section "05-your-tool"

if command -v your-tool &> /dev/null; then
  skip "your-tool already installed"
else
  brew install your-tool
  check "your-tool installed"
fi

section_done
```

## Backing up current state

```bash
./backup/capture.sh
```

This scans your system and copies into the repo:
- `~/.zshrc` → `configs/zshrc`
- `~/.claude/settings.json` → `configs/claude/settings.json`
- `~/.agents/skills/` → `configs/claude/skills/`

Run `git diff` to review, `git commit` to save.

## Structure

```
dotfiles/
  install.sh           ← entry point (iterates bootstrap/)
  bootstrap/           ← ordered, idempotent install scripts
    _lib.sh            ← shared helpers (check, skip, fail, section)
    00-brew.sh
    01-shell.sh
    02-node.sh
    03-claude.sh
    04-macos.sh
  configs/             ← dotfiles and config (the actual files)
    Brewfile
    zshrc
    claude/
      settings.json
      skills/
        apple-container/
          SKILL.md
  backup/
    capture.sh         ← scans system → copies into configs/
```

## Requirements

- macOS (Apple Silicon or Intel)
- Internet connection
- Administrator password (for Homebrew and some casks)
