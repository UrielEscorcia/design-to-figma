---
figma_url: <https://www.figma.com/design/FILE_KEY/NAME>
figma_file_key: <FILE_KEY>
last_sync: <ISO 8601 timestamp, e.g. 2026-01-31T12:00:00Z>
dark_mode: <yes | no | undecided>
design_system_artifact: <yes | no | unavailable>
---

# Design plan: <Project title>

Tracker for the sections to design. Update the state after every change; read this file first on resume and continue with the next unfinished item.

States: `Brief`, `Style and references`, `Palette and foundations` and `Components` use `pending → user-approved`. Screens use `pending → built → agent-verified → user-approved → final-verified`. Closing items use `pending → done`. Per-screen loop: [screen-loop.md](../references/screen-loop.md).

## Requests

The user's words, verbatim and never paraphrased ([routing.md](../references/routing.md) step 5). Append corrections, decisions and high-risk confirmations as L2, L3 and so on.

- **L1** (<date>) "<original request, verbatim>"

## Foundations

- [ ] Brief: `pending`
- [ ] Style and references: `pending`
- [ ] Palette and foundations: `pending`
- Chosen direction: <name>; comps in `directions/` (artifact: <url>)
- [ ] Components: `pending`

## Screens

### <Flow> / <Screen>

- State: `pending`
- Definition (agreed with the user on <date>, from L<n>): <purpose, primary action, content, states, edge cases>
- Figma calls used: <count, for the next screens' estimate>
- Notes: <open gaps, decisions>
- Dark (only when dark mode was requested): `pending`

## Closing

- [ ] Final cross-screen review: `pending`
- [ ] Sync local files: `pending`
