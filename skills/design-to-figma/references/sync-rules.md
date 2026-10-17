# Sync rules

Figma is the source of truth for design data. Local `PRODUCT.md` / `DESIGN.md` and Claude's design-system context are derived from it.

## Directions

| Direction | Behavior |
|---|---|
| Figma → local `.md` | Automatic, at the end of every run (and when reading detects drift). |
| Figma → Claude's design-system context | Not a required step. Claude's design chats can use the updated `DESIGN.md`; tell the user it is available. Only for a user who already keeps a claude.ai/design design-system project, mention `/design-sync` as optional. Never call the `DesignSync` tool and never target claude.ai/design projects. |
| Local `.md` → Figma | Never automatic. Show the diff, then ask: **push to Figma** or **discard**. |

## Read before every step

Before each design step, fetch fresh state. `get_metadata` without a `nodeId` lists only the first page, because Figma loads pages incrementally. Never infer from it that other pages are missing or deleted.

1. **Enumerate pages.** Load `figma-use`, then run a read-only `use_figma` script that returns `figma.root.children.map(p => ({id: p.id, name: p.name}))`.
2. **Read each page.** `get_metadata(nodeId=<pageId>)` for every page returned (frames, components). Take `get_screenshot` for specific frames.
3. **Read variables and styles.** A read-only `use_figma` script using `figma.variables.getLocalVariableCollectionsAsync`, `figma.variables.getLocalVariablesAsync`, `figma.getLocalTextStylesAsync` and `figma.getLocalEffectStylesAsync`; or `get_variable_defs` for a node.
4. **Compare** with the snapshot to find manual edits, and state them to the user in one or two lines before building on them.

A page that is in the snapshot but missing from step 1 is reported as missing only after the page list itself came from the script, never from an unscoped `get_metadata` call. Do not use `get_design_context` for reading state; it requires the `figma-design-to-code` skill and produces code-oriented output.

## Snapshot

Keep a compact snapshot of Figma as it was at the last sync. It is the **base** for every comparison. Store it in the "Sync snapshot" section of `DESIGN.md` ([DESIGN.template.md](../assets/DESIGN.template.md)). When that section exceeds 150 lines, move it to a sidecar `DESIGN.sync.json` next to `DESIGN.md` and leave a one-line pointer in the section. Fields:

- `lastSync`: ISO 8601 timestamp. Sync state lives only here and in the local files' frontmatter, never on the Brief page: Figma → local syncs never write to Figma, so a timestamp there would go stale.
- `variables`: collection name → variable name → `{ mode: value }`.
- `styles`: text and effect style names.
- `components`: component and component-set names.
- `pages`: page names, each with its top-level frame names.

Keep it deterministic: sort every list alphabetically, use the names and values exactly as Figma returns them, and exclude node IDs, positions and anything volatile.

## Detecting changes (three-way)

The snapshot is the base. Compare each tracked item (variable value, style, component, page or frame name) across three versions: **base** (snapshot), **Figma** (fresh `get_variable_defs` + `get_metadata`, normalized like the snapshot), and **local** (the values written in the `.md`).

| Base vs Figma | Base vs local | Meaning | Action |
|---|---|---|---|
| same | same | No change | Nothing |
| different | same | Manual Figma edit | Report it, update the `.md` and the snapshot |
| same | different | Local-only edit | Show the diff and ask: push to Figma or discard |
| different | different | Both changed | Conflict: Figma wins for design data; ask before dropping local prose |

Renames show up as one removed plus one added item of the same kind; report them as a rename when the values match. Prose with no tracked counterpart (rationale, guidance) is not compared.

## Local-only changes

Show a short diff (what the `.md` says versus what Figma has), then ask once: "Push these to Figma, or discard them?"

- **Push:** apply via `use_figma` (load `figma-use` first), re-read, refresh the snapshot.
- **Discard:** restore the `.md` from Figma.
- Prose with no Figma counterpart (rationale, naming notes) is not a conflict; keep it local.
- **Exception, usage rules:** a usage-rule line added locally to `DESIGN.md` (for example a "Do" or "Don't" rule such as "Success green is never used for buttons") is offered for the Brief page's Usage rules section, with the same diff-and-ask as any local → Figma change. If the user discards it, it stays in `DESIGN.md` as local prose.

## Conflicts (both sides changed)

- Design data (values, names, structure): Figma wins. Report what was replaced.
- Local prose: ask before dropping it. Default is to keep it and append the Figma value.
- Never resolve a conflict silently. List unresolved ones under "Pending conflicts" in the final report.

## Missing or stale header

- No sync header or snapshot: treat the first read as the baseline, write the header, and say so.
- Figma file not accessible (no permission, deleted, or the MCP fails): stop the run and report it. Leave the local files and the snapshot untouched; never rewrite them from nothing.
- Snapshot present but unreadable or malformed: do not guess. Treat the run as having no base: report every difference between Figma and local as a conflict and ask.

## Write path

Never write absolute local paths, usernames or machine details into Figma (Brief page, layer names, descriptions). Refer to local files by name, relative to the project folder.

Write files only to the path confirmed in preflight. On the downloads rung, deliver the updated files in the reply and say which ones changed.
