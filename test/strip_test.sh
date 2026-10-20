#!/bin/bash
# Runs strip.sh with the action's default patterns.
set -uo pipefail
DIR="$(cd "$(dirname "$0")/.." && pwd)"
STRIP='\[\[sc-[0-9]+\]\]\(https://app\.shortcut\.com/[^)]*\) ?'
FORBID='shortcut\.com'
fail=0

run() {
  local out
  out="$(mktemp)"
  CHANGES="$1" STRIP_PATTERN="$STRIP" FORBID_PATTERN="$FORBID" GITHUB_OUTPUT="$out" bash "$DIR/strip.sh" 2>&1 >/dev/null
  local status=$?
  sed '1d;$d' "$out"
  return $status
}

check() {
  if [ "$2" = "$3" ]; then echo "ok: $1"; else echo "FAIL: $1"; echo "  expected: $3"; echo "  got:      $2"; fail=1; fi
}

got="$(run '- [[sc-5973]](https://app.shortcut.com/ppx-digital/story/5973) Publish semver releases')"
check "strips Shortcut links" "$got" "- Publish semver releases"

got="$(run $'### 🐛 Fixed\n- Report the real version\n- 100% of offers')"
check "leaves other notes alone" "$got" $'### 🐛 Fixed\n- Report the real version\n- 100% of offers'

if run '- See https://app.shortcut.com/ppx-digital/story/1' >/dev/null; then
  echo "FAIL: a bare Shortcut link should fail"; fail=1
else
  echo "ok: fails on a Shortcut link it cannot strip"
fi

exit $fail
