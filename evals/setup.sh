#!/usr/bin/env bash
# Stages two plugins in each trigger case's plugins/ (gitignored): a snapshot of this plugin and a copy of
# the installed official Figma plugin. A case that lists plugins: loads only those, not the eval target,
# so both must be listed to compete as in a real session. Rerun after every skill change. Never commit or
# bundle the copies.
set -euo pipefail
cd "$(dirname "$0")"
src="$(ls -d "$HOME"/.claude/plugins/cache/claude-plugins-official/figma/*/ 2>/dev/null | sort -V | tail -1)"
[[ -n "$src" ]] || { echo "Install the Figma plugin first: claude plugin install figma@claude-plugins-official"; exit 1; }
for case in */case.yaml; do
  dir="$(dirname "$case")"
  grep -q 'plugins/figma' "$case" || continue
  rm -rf "$dir/plugins" && mkdir -p "$dir/plugins/design-to-figma"
  cp -R "$src" "$dir/plugins/figma"
  cp -R ../.claude-plugin ../skills "$dir/plugins/design-to-figma/"
  echo "Staged design-to-figma and Figma plugin $(basename "$src") in evals/$dir/plugins"
done
