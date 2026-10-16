# Workflow: single screen

Use when the user wants one screen or view. Read Figma before each step when a file exists.

## A. Project exists (Figma file or `DESIGN.md` with a Figma header)

1. Read Figma: `get_metadata`, `get_variable_defs`, `search_design_system`. Diff against the snapshot ([sync-rules.md](sync-rules.md)).
2. Reuse the system: tokens and components. Do not create new tokens when an existing one fits.
3. Design the screen. impeccable present: `shape` for the screen brief, then its new-work flow within the existing direction. Absent: short brief (2 questions) from the checklist.
4. Missing components: add only those the screen needs to `🧩 Components` (`figma-generate-library`), then build the screen in `📱 Screens` (`figma-generate-design`, with `figma-use`).
5. Screenshot, then sync per [sync-rules.md](sync-rules.md).

## B. No project: minimal bootstrap

The bootstrap creates only what this screen needs and can grow into a full project later.

1. **Context.**
   - impeccable present: run `init` for `PRODUCT.md`, then its new-work flow for direction and `extract` for the tokens and components the screen needs.
   - Absent: follow [minimal-system-checklist.md](minimal-system-checklist.md) (brief, palette, type scale, spacing, radius, needed components).
2. **Confirm** the brief and base tokens with the user before writing to Figma.
3. **Figma file.** `figma-create-new-file`, then the four pages from [figma-structure.md](figma-structure.md). Populate `📋 Brief & Rules` briefly and `🎨 Foundations` with only the base tokens. `🧩 Components` holds only the screen's components.
4. **Screen.** Build with `figma-generate-design` and `figma-use`.
5. **Local files.** Write `PRODUCT.md` and `DESIGN.md` from the templates with the Figma header, marked `scope: minimal` in the DESIGN.md sync header.
6. Sync and report.

## Growing into a full project

When the user later asks for more screens or a full system, switch to [workflow-project.md](workflow-project.md). Keep the existing tokens, extend the library, and clear the `scope: minimal` marker.
