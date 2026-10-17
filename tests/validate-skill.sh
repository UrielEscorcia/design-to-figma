#!/usr/bin/env bash
# Validates one skill directory against the portability rules shared by
# Claude Code and claude.ai/Desktop skill upload (see D10 in odd/tasks/design-to-figma.md).
# Usage: tests/validate-skill.sh <skill-dir>   Exit: 0 valid, 1 invalid.
set -euo pipefail

dir="${1:?usage: validate-skill.sh <skill-dir>}"
file="$dir/SKILL.md"
allowed=" name description license compatibility metadata allowed-tools "
errors=()

[[ -f "$file" ]] || { echo "FAIL $dir: SKILL.md not found"; exit 1; }

frontmatter="$(awk 'NR==1 && $0!="---"{exit} NR>1 && $0=="---"{exit} NR>1{print}' "$file")"
[[ -n "$frontmatter" ]] || errors+=("missing YAML frontmatter")

while IFS= read -r key; do
  [[ -z "$key" ]] && continue
  [[ "$allowed" == *" $key "* ]] || errors+=("frontmatter key not allowed outside Claude Code: $key")
done < <(printf '%s\n' "$frontmatter" | sed -nE 's/^([A-Za-z_-]+):.*/\1/p')

value_of() { printf '%s\n' "$frontmatter" | sed -nE "s/^$1:[[:space:]]*//p" | head -1 | sed -E 's/^["'\'']//; s/["'\'']$//'; }

name="$(value_of name)"
[[ "$name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || errors+=("name must be lowercase kebab-case: '$name'")
(( ${#name} <= 64 )) || errors+=("name exceeds 64 characters")
[[ "$name" == "$(basename "$dir")" ]] || errors+=("name '$name' must match folder '$(basename "$dir")'")

description="$(value_of description)"
[[ -n "$description" && "$description" != ">"* && "$description" != "|"* ]] \
  || errors+=("description must be a non-empty single line")
(( ${#description} <= 200 )) || errors+=("description exceeds 200 characters (${#description})")

lines=$(wc -l < "$file" | tr -d ' ')
(( lines <= 500 )) || errors+=("SKILL.md has $lines lines (max 500)")

while IFS= read -r target; do
  [[ -z "$target" || "$target" == http* || "$target" == mailto:* ]] && continue
  [[ -e "$dir/${target%%#*}" ]] || errors+=("broken link: $target")
done < <(grep -oE '\]\([^)]+\)' "$file" | sed -E 's/^\]\(//; s/\)$//' || true)

if (( ${#errors[@]} )); then
  printf 'FAIL %s\n' "$dir"; printf '  - %s\n' "${errors[@]}"; exit 1
fi
echo "PASS $dir"
