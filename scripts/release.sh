#!/usr/bin/env bash
# Publishes one version: tag vX.Y.Z on the given commit and a GitHub release whose notes are the
# CHANGELOG.md entry, with the Desktop zip (design-to-figma/ at its root) attached.
# Usage: scripts/release.sh [--dry-run] <version> [commit]   (commit defaults to HEAD)
# An existing tag or release is skipped, so reruns are safe. Set RELEASE_LATEST=false to keep an
# older version from being marked as the latest release (used by the backfill).
set -euo pipefail
cd "$(dirname "$0")/.."
dry=false
if [[ "${1:-}" == "--dry-run" ]]; then dry=true; shift; fi
v="${1:?usage: scripts/release.sh [--dry-run] <version> [commit]}"
c="$(git rev-parse --verify "${2:-HEAD}^{commit}")"
tag="v$v"

notes="$(scripts/changelog-section.sh "$v")"
[[ -n "$notes" ]] || { echo "No CHANGELOG.md entry for $v; add '## [$v]' first." >&2; exit 1; }
cv="$(git show "$c:.claude-plugin/plugin.json" | grep -oE '"version": *"[^"]+"' | grep -oE '[0-9][^"]*')"
[[ "$cv" == "$v" ]] || { echo "Commit $c has plugin version $cv, not $v." >&2; exit 1; }

tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
zip="$tmp/design-to-figma-$v.zip"
git archive --format=zip -o "$zip" "$c:skills" design-to-figma
printf '%s\n' "$notes" > "$tmp/notes.md"

if $dry; then
  files="$(unzip -Z1 "$zip" | grep -vc '/$')"
  unzip -Z1 "$zip" | grep -qx 'design-to-figma/SKILL.md' || { echo "Zip lacks design-to-figma/SKILL.md." >&2; exit 1; }
  echo "tag $tag -> $c"
  echo "zip $(basename "$zip"): $files files, SKILL.md at design-to-figma/SKILL.md"
  echo "notes: $(wc -l < "$tmp/notes.md" | tr -d ' ') lines"
  exit 0
fi

if gh release view "$tag" >/dev/null 2>&1; then
  echo "Skip $tag: the release already exists."; exit 0
fi
# A tag exists without a release when an earlier run failed after tagging: finish that release,
# but only when the tag points at the same commit.
remote_tag="$(git ls-remote --tags origin "refs/tags/$tag^{}" "refs/tags/$tag" | awk 'NR==1 {print $1}')"
if [[ -n "$remote_tag" ]]; then
  peeled="$(git ls-remote --tags origin "refs/tags/$tag^{}" | awk '{print $1}')"
  [[ "${peeled:-$remote_tag}" == "$c" ]] || { echo "Tag $tag exists on ${peeled:-$remote_tag}, not $c; fix it by hand." >&2; exit 1; }
  echo "Tag $tag exists without a release; creating the release for it."
fi
gh release create "$tag" "$zip" --target "$c" --title "$tag" --notes-file "$tmp/notes.md" --latest="${RELEASE_LATEST:-true}"
echo "Released $tag at $c."
