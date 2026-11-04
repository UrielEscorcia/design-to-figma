#!/usr/bin/env bash
# Stages the attachments of the real Desktop prompt (product PDF, module PDF, UI reference image) in the workspace.
set -euo pipefail
cp "$(dirname "$0")"/fixtures/* .
