#!/usr/bin/env bash
# Test runner: fixture self-tests, real skills, then the official plugin validator.
set -uo pipefail
cd "$(dirname "$0")/.."
status=0

expect() { # expect <pass|fail> <skill-dir> [reason-pattern]
  local out got
  if out="$(tests/validate-skill.sh "$2" 2>&1)"; then got=pass; else got=fail; fi
  if [[ "$got" != "$1" ]]; then
    echo "FAIL fixture $(basename "$2"): expected $1, got $got"; status=1
  elif [[ -n "${3:-}" ]] && ! grep -q -- "$3" <<<"$out"; then
    echo "FAIL fixture $(basename "$2"): failed for the wrong reason (wanted '$3')"; echo "$out"; status=1
  else
    echo "ok   fixture $(basename "$2") -> $1${3:+ ($3)}"
  fi
}

expect pass tests/fixtures/valid
expect fail tests/fixtures/extra-key "key not allowed"
expect fail tests/fixtures/long-description "exceeds 200"
expect fail tests/fixtures/broken-link "broken link"
# Oversized fixture is generated at runtime to keep 500 filler lines out of the repo.
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/too-long" && touch "$tmp/too-long/reference.md"
sed 's/^name: valid$/name: too-long/' tests/fixtures/valid/SKILL.md > "$tmp/too-long/SKILL.md"
seq 1 500 >> "$tmp/too-long/SKILL.md"
expect fail "$tmp/too-long" "max 500"

shopt -s nullglob
skills=(skills/*/)
(( ${#skills[@]} )) || { echo "FAIL no skills found under skills/"; status=1; }
for s in ${skills[@]+"${skills[@]}"}; do tests/validate-skill.sh "${s%/}" || status=1; done

# design-to-figma content: required files exist and SKILL.md links every supporting file.
d=skills/design-to-figma
required=(
  SKILL.md
  references/preflight.md references/tool-directory.md references/workflow-project.md
  references/workflow-screen.md references/sync-rules.md references/figma-structure.md
  references/minimal-system-checklist.md
  assets/PRODUCT.template.md assets/DESIGN.template.md assets/brief-page.template.md
)
for f in "${required[@]}"; do
  [[ -f "$d/$f" ]] || { echo "FAIL missing required file: $d/$f"; status=1; }
done
if [[ -f "$d/SKILL.md" ]]; then
  for f in "$d"/references/*.md "$d"/assets/*; do
    [[ -e "$f" ]] || continue
    rel="${f#"$d"/}"
    grep -qF "]($rel)" "$d/SKILL.md" || { echo "FAIL SKILL.md does not link $rel"; status=1; }
  done
fi

if command -v claude >/dev/null; then
  claude plugin validate --strict .claude-plugin/plugin.json || status=1
  claude plugin validate --strict .claude-plugin/marketplace.json || status=1
else
  echo "SKIP claude plugin validate (claude CLI not found)"
fi

exit $status
