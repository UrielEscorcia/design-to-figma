# Sync rules

Figma is the source of truth for design data. Local `PRODUCT.md` / `DESIGN.md` and Claude's design-system context are derived from it.

## Directions

| Direction | Behavior |
|---|---|
| Figma → local `.md` | Automatic, at the end of every run (and when reading detects drift). |
| Figma → Claude's design-system context | Automatic where supported. Claude Code: run `/design-sync` with the updated `DESIGN.md`. Other surfaces: tell the user to load the updated `DESIGN.md` as the design system for Claude's design chats. Never target claude.ai/design projects. |
| Local `.md` → Figma | Never automatic. Show the diff, then ask: **push to Figma** or **discard**. |

## Read before every step

Before each design step, fetch fresh state: `get_variable_defs` (variables), `get_metadata` (pages, frames, components). Add `get_design_context` or `get_screenshot` for specific frames. Compare with the snapshot to find manual edits, and state them to the user in one or two lines before building on them.

## Snapshot

Keep a compact snapshot in the `DESIGN.md` sync header (section "Sync snapshot" in [DESIGN.template.md](../assets/DESIGN.template.md)), or in a sidecar `DESIGN.sync.json` if the file would get too long. Fields:

- `lastSync`: ISO 8601 timestamp.
- `variables`: collection name → list of `name=value` per mode.
- `styles`: text and effect style names.
- `components`: component and component-set names.
- `pages`: page names, each with its top-level frame names.

Keep it deterministic: sort every list alphabetically, use the names and values exactly as Figma returns them, and exclude node IDs, positions and anything volatile.

## Detecting changes

1. Build the same compact structure from fresh `get_variable_defs` and `get_metadata` output.
2. Diff against the snapshot: added, removed, renamed (a removed plus an added item of the same kind), and changed values.
3. Figma-side changes found: report them, update the local `.md` and the snapshot.
4. Local-side changes: compare the `.md` body against the snapshot-time content (rendered from the snapshot). Differences not present in Figma are local-only.

## Local-only changes

Show a short diff (what the `.md` says versus what Figma has), then ask once: "Push these to Figma, or discard them?"

- **Push:** apply via `use_figma` (load `figma-use` first), re-read, refresh the snapshot.
- **Discard:** restore the `.md` from Figma.
- Pure prose (rationale, naming notes) with no Figma counterpart is not a conflict; keep it.

## Conflicts (both sides changed)

- Design data (values, names, structure): Figma wins. Report what was replaced.
- Local prose: ask before dropping it. Default is to keep it and append the Figma value.
- Never resolve a conflict silently. List unresolved ones under "Pending conflicts" in the final report.

## Missing or stale header

- No sync header or snapshot: treat the first read as the baseline, write the header, and say so.
- Figma file not accessible (no permission, deleted): stop the run and report; do not rewrite local files from nothing.

## Write path

Write files only to the path confirmed in preflight. On the downloads rung, deliver the updated files in the reply and say which ones changed.
