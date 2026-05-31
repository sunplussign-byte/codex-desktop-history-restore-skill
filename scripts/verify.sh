#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

required_files=(
  "$ROOT/README.md"
  "$ROOT/CHANGELOG.md"
  "$ROOT/VERSION"
  "$ROOT/LICENSE"
  "$ROOT/install.sh"
  "$ROOT/skill/codex-desktop-history-restore/SKILL.md"
  "$ROOT/skill/codex-desktop-history-restore/agents/openai.yaml"
  "$ROOT/skill/codex-desktop-history-restore/references/operator-playbook.md"
)

for file in "${required_files[@]}"; do
  if [[ ! -e "$file" ]]; then
    echo "Missing required file: $file" >&2
    exit 1
  fi
done

bash -n "$ROOT/install.sh"
bash -n "$ROOT/scripts/verify.sh"

echo "verify_ok=true"
