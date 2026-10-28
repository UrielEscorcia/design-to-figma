# Workflow: single screen

Use when the user wants one screen or view. The quality bar is the same as for a project, and the screen goes through the same loop ([screen-loop.md](screen-loop.md)). `DESIGN-PLAN.md` is optional here: write a short one only when a minimal project is bootstrapped. Read Figma before each step when a file exists ([sync-rules.md](sync-rules.md): enumerate pages first).

## A. Project exists (Figma file or `DESIGN.md` with a Figma header)

1. Read Figma: enumerate pages, read them, read variables and styles, and `search_design_system` for components. Diff against the snapshot ([sync-rules.md](sync-rules.md)).
2. Reuse the system: tokens, components and the recorded style ([style-discovery.md](style-discovery.md)). Do not create new tokens when an existing one fits. If no style is recorded, run style discovery.
3. Define the screen (step 1 of [screen-loop.md](screen-loop.md)). impeccable present: `shape` for the screen brief, then its new-work flow within the existing direction and style. Absent: short brief (2 questions) from the checklist.
4. Show 2 or 3 directions for the screen within the style as Claude Design artifacts ([proposals.md](proposals.md)); the user picks one.
5. Brief each builder, including delegated subagents, with the builder guidance in [tool-directory.md](tool-directory.md). Missing components: add only those the screen needs to `🧩 Components` (`figma-generate-library`), then build the chosen direction in `📱 Screens` (`figma-generate-design`, with `figma-use`).
6. Continue the screen loop from step 3 ([screen-loop.md](screen-loop.md)): verify against the quality gate ([quality-bar.md](quality-bar.md)), self-fix, the mandatory `polish` pass, the elevate pass, user review, final verify, dark mode when requested, check off.
7. Sync per [sync-rules.md](sync-rules.md), including the Design System artifact when kept ([design-system-artifact.md](design-system-artifact.md)).

## B. No project: minimal bootstrap

The bootstrap creates only what this screen needs and can grow into a full project later.

1. **Product brief (before style).** Ask who the users are, the problem, the essential screens, the product name, the UI language and locale (all UI copy uses it), whether dark mode is needed (ask; never assume), and whether to keep a Design System artifact ([design-system-artifact.md](design-system-artifact.md)).
   - impeccable present: run `init` for `PRODUCT.md`.
   - Absent: brief questions from [minimal-system-checklist.md](minimal-system-checklist.md).
2. **Style discovery.** Follow [style-discovery.md](style-discovery.md), using the brief (category references first, then style and the palette as swatches), and get the user's confirmation.
3. **Direction and proposals.**
   - impeccable present: its new-work flow for direction with the style pinned, and `extract` for the tokens and components the screen needs.
   - Absent: palette, type scale, spacing, radius and needed components from the checklist.
   - Define the screen first (step 1 of [screen-loop.md](screen-loop.md)), then show 2 or 3 directions as Claude Design artifacts ([proposals.md](proposals.md)); the user picks one. Run `critique` on it.
4. **Confirm** the brief, the chosen direction and the base tokens before writing to Figma.
5. **Figma file.** Ask the file name as its own question (suggest `<Product> — <Scope>`, for example `Tessera — Sign-in`), never folded into another question; only then, with several teams or plans, ask which one. Then `figma-create-new-file`, and the four pages from [figma-structure.md](figma-structure.md). Populate `📋 Brief & Rules` briefly (including style and references) and `🎨 Foundations` with only the base tokens (`Semantic` in a single-mode collection, or Light and Dark modes when dark mode was requested up front). `🧩 Components` holds only the screen's components.
6. **Screen.** Check fonts ([figma-structure.md](figma-structure.md)) and brief the builder as in part A step 5. Build the chosen direction with `figma-generate-design` and `figma-use`.
7. **Screen loop** from step 3 ([screen-loop.md](screen-loop.md)), as in step 6 of part A.
8. **Local files.** Write `PRODUCT.md` and `DESIGN.md` from the templates with the Figma header, marked `scope: minimal`. Record the dark mode answer in `PRODUCT.md`.
9. Sync (including the Design System artifact when kept, [design-system-artifact.md](design-system-artifact.md)) and report.

## Iterating

Change requests after the build follow [iteration.md](iteration.md).

## Growing into a full project

When the user later asks for more screens or a full system, switch to [workflow-project.md](workflow-project.md). Keep the existing tokens and style, extend the library, and clear the `scope: minimal` marker.
