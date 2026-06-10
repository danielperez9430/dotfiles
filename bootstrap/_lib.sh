#!/usr/bin/env bash
# Shared helpers for bootstrap scripts
# Source this: source "$(dirname "$0")/_lib.sh"

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

check() { printf "  ${GREEN}✓${NC} %s\n" "$1"; }
skip()  { printf "  ${YELLOW}→${NC} %s\n" "$1"; }
fail()  { printf "  ${RED}✗${NC} %s\n" "$1"; }
info()  { printf "  ${CYAN}ℹ${NC} %s\n" "$1"; }

section() {
  echo ""
  printf "${BOLD}── %s${NC}\n" "$1"
  echo ""
}

section_done() {
  echo ""
  printf "${GREEN}✓ %s complete${NC}\n" "$1"
}
