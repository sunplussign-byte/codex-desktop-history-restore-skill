#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
SKILL_SRC="$REPO_ROOT/skill/codex-desktop-history-restore"
SKILL_DST="$HOME/.codex/skills/codex-desktop-history-restore"

if [[ ! -d "$SKILL_SRC" ]]; then
  echo "Skill source directory not found: $SKILL_SRC" >&2
  exit 1
fi

mkdir -p "$HOME/.codex/skills"

if [[ -L "$SKILL_DST" || -e "$SKILL_DST" ]]; then
  rm -rf "$SKILL_DST"
fi

ln -s "$SKILL_SRC" "$SKILL_DST"

echo "Installed:"
echo "  $SKILL_DST -> $SKILL_SRC"
