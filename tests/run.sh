#!/usr/bin/env bash
# Test runner: fixture self-tests, real skills, then the official plugin validator.
set -uo pipefail
cd "$(dirname "$0")/.."
status=0

expect() { # expect <pass|fail> <skill-dir>
  if tests/validate-skill.sh "$2" >/dev/null 2>&1; then got=pass; else got=fail; fi
  if [[ "$got" == "$1" ]]; then echo "ok   fixture $(basename "$2") -> $1"
  else echo "FAIL fixture $(basename "$2"): expected $1, got $got"; status=1; fi
}

expect pass tests/fixtures/valid
expect fail tests/fixtures/extra-key
expect fail tests/fixtures/long-description
expect fail tests/fixtures/broken-link
expect fail tests/fixtures/too-long

shopt -s nullglob
skills=(skills/*/)
(( ${#skills[@]} )) || { echo "FAIL no skills found under skills/"; status=1; }
for s in ${skills[@]+"${skills[@]}"}; do tests/validate-skill.sh "${s%/}" || status=1; done

if command -v claude >/dev/null; then
  claude plugin validate --strict .claude-plugin/plugin.json || status=1
  claude plugin validate --strict .claude-plugin/marketplace.json || status=1
else
  echo "SKIP claude plugin validate (claude CLI not found)"
fi

exit $status
