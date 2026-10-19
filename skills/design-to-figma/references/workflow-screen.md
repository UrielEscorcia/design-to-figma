# Workflow: single screen

Use when the user wants one screen or view. The quality bar is the same as for a project. Read Figma before each step when a file exists ([sync-rules.md](sync-rules.md): enumerate pages first).

## A. Project exists (Figma file or `DESIGN.md` with a Figma header)

1. Read Figma: enumerate pages, read them, read variables and styles, and `search_design_system` for components. Diff against the snapshot ([sync-rules.md](sync-rules.md)).
2. Reuse the system: tokens, components and the recorded style ([style-discovery.md](style-discovery.md)). Do not create new tokens when an existing one fits. If no style is recorded, run style discovery.
3. Design the screen. impeccable present: `shape` for the screen brief, then its new-work flow within the existing direction and style. Absent: short brief (2 questions) from the checklist.
4. Show 2 or 3 directions for the screen within the style as Claude Design artifacts ([proposals.md](proposals.md)); the user picks one.
5. Brief each builder, including delegated subagents, with the builder guidance in [tool-directory.md](tool-directory.md) (impeccable's `reference/craft-floor.md`, `reference/layout.md`, `reference/typeset.md` and the platform reference, plus `PRODUCT.md`, `DESIGN.md` and the direction). Missing components: add only those the screen needs to `🧩 Components` (`figma-generate-library`), then build the chosen direction in `📱 Screens` (`figma-generate-design`, with `figma-use`).
6. `critique` and `polish` (mandatory with impeccable; built-in checklist otherwise), fixes applied in Figma in one batch, then the quality gate ([quality-bar.md](quality-bar.md)).
7. Screenshot, then sync per [sync-rules.md](sync-rules.md).

## B. No project: minimal bootstrap

The bootstrap creates only what this screen needs and can grow into a full project later.

1. **Product brief (before style).** Ask who the users are, the problem, the essential screens and the product name.
   - impeccable present: run `init` for `PRODUCT.md`.
   - Absent: brief questions from [minimal-system-checklist.md](minimal-system-checklist.md).
2. **Style discovery.** Follow [style-discovery.md](style-discovery.md), using the brief, and get the user's confirmation.
3. **Direction and proposals.**
   - impeccable present: its new-work flow for direction with the style pinned, and `extract` for the tokens and components the screen needs.
   - Absent: palette, type scale, spacing, radius and needed components from the checklist.
   - Show 2 or 3 directions as Claude Design artifacts ([proposals.md](proposals.md)); the user picks one. Run `critique` on it.
4. **Confirm** the brief, the chosen direction and the base tokens before writing to Figma.
5. **Figma file.** Ask the file name as its own question (suggest `<Product> — <Scope>`, for example `Tessera — Sign-in`), never folded into another question; only then, with several teams or plans, ask which one. Then `figma-create-new-file`, and the four pages from [figma-structure.md](figma-structure.md). Populate `📋 Brief & Rules` briefly (including style and references) and `🎨 Foundations` with only the base tokens. `🧩 Components` holds only the screen's components.
6. **Screen.** Check fonts ([figma-structure.md](figma-structure.md)) and brief the builder as in part A step 5. Build the chosen direction with `figma-generate-design` and `figma-use`.
7. **Critique and polish** (mandatory), as in step 6 of part A.
8. **Local files.** Write `PRODUCT.md` and `DESIGN.md` from the templates with the Figma header, marked `scope: minimal`.
9. Sync and report.

## Iterating

Change requests after the build follow [iteration.md](iteration.md).

## Growing into a full project

When the user later asks for more screens or a full system, switch to [workflow-project.md](workflow-project.md). Keep the existing tokens and style, extend the library, and clear the `scope: minimal` marker.
