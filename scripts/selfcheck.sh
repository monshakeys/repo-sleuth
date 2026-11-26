#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.}"
MISSING_TOOLS=0
MISSING_LIST=()

to_brew_pkg() {
  case "$1" in
    sg) echo "ast-grep" ;;
    rg) echo "ripgrep" ;;
    ug) echo "ugrep" ;;
    fd) echo "fd" ;;
    *) echo "$1" ;;
  esac
}

check_cmd() {
  local name="$1"
  if command -v "$name" >/dev/null 2>&1; then
    echo "[OK] $name: $("$name" --version 2>/dev/null | head -n 1)"
  else
    echo "[FAIL] $name not found"
    MISSING_TOOLS=1
    MISSING_LIST+=("$name")
  fi
}

echo "== repo-sleuth selfcheck =="
check_cmd fd
check_cmd rg
check_cmd ug
check_cmd sg

if [[ $MISSING_TOOLS -ne 0 ]]; then
  BREW_PACKAGES=()
  for tool in "${MISSING_LIST[@]}"; do
    BREW_PACKAGES+=("$(to_brew_pkg "$tool")")
  done
  echo
  echo "[ERROR] Some required tools are missing. Install them first."
  if command -v brew >/dev/null 2>&1; then
    echo "[HINT] Homebrew detected. Install missing tools with:"
    echo "       brew install ${BREW_PACKAGES[*]}"
  else
    echo "[HINT] Homebrew not found. Install Homebrew first, then run:"
    echo "       brew install ${BREW_PACKAGES[*]}"
  fi
  exit 1
fi

if [[ ! -d "$ROOT" ]]; then
  echo
  echo "[ERROR] Target directory '$ROOT' does not exist."
  exit 1
fi

echo
echo "== smoke tests on: $ROOT =="

fd -t f . "$ROOT" >/dev/null || true
rg --count "TODO|FIXME|import" "$ROOT" >/dev/null || true
ug -c -Z2 "functoin|intialize" "$ROOT" >/dev/null || true
sg run -p 'import $A' --lang python "$ROOT" >/dev/null || true

echo "[OK] smoke tests completed"
