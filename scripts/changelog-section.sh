#!/usr/bin/env bash
# Prints the CHANGELOG.md entry body for one version (the lines under "## [X.Y.Z]" up to the next entry).
# Prints nothing for a version without an entry.
set -euo pipefail
cd "$(dirname "$0")/.."
v="${1:?usage: scripts/changelog-section.sh <version>}"
V="$v" awk '
  /^## \[/ { if (f) exit; if (index($0, "## [" ENVIRON["V"] "]") == 1) { f = 1; next } }
  f
' CHANGELOG.md | sed -e '/./,$!d'
