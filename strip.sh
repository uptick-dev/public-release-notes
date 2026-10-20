#!/bin/bash
# Removes STRIP_PATTERN from CHANGES and writes the result to the "changes" output.
# Fails when FORBID_PATTERN still matches, so an internal link that the pattern
# did not catch never reaches a public release.
set -euo pipefail

: "${CHANGES:=}" "${STRIP_PATTERN:=}" "${FORBID_PATTERN:=}"
PUBLIC_CHANGES="$CHANGES"
if [ -n "$STRIP_PATTERN" ]; then
  PUBLIC_CHANGES="$(printf '%s' "$CHANGES" | sed -E "s#${STRIP_PATTERN}##g")"
fi

if [ -n "$FORBID_PATTERN" ] && printf '%s' "$PUBLIC_CHANGES" | grep -Eqi "$FORBID_PATTERN"; then
  echo "::error::The release notes still match '$FORBID_PATTERN'. Remove it from the changelog fragment."
  exit 1
fi

DELIMITER="PUBLIC_CHANGES_$(od -An -N8 -tx1 /dev/urandom | tr -d ' \n')"
{
  echo "changes<<$DELIMITER"
  printf '%s\n' "$PUBLIC_CHANGES"
  echo "$DELIMITER"
} >> "${GITHUB_OUTPUT:-/dev/stdout}"
