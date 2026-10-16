# Workflow: full project

Use when the user wants a design system plus several screens. Read Figma before each numbered step when a file exists.

## 1. Brief → PRODUCT.md

- impeccable present: run `init`; it interviews and writes `PRODUCT.md`.
- Absent: ask the 3–4 brief questions in [minimal-system-checklist.md](minimal-system-checklist.md) and fill [PRODUCT.template.md](../assets/PRODUCT.template.md).
- Optional discovery for the overall experience: impeccable `shape`.
- Wait for answers before continuing; do not invent product decisions.

## 2. Visual direction and design system definition

- impeccable present: follow its new-work flow for direction; `extract` or `document` to turn decisions or existing code into tokens and component lists.
- Absent: use the palette, type, spacing and radius steps in the checklist.
- Preview options in Claude Design if useful. Record the chosen direction in [DESIGN.template.md](../assets/DESIGN.template.md) form.
- Confirm the direction with the user before writing to Figma.

## 3. Figma file and foundations

1. No file yet: load `figma-create-new-file`, then `create_new_file`. Record the URL and file key.
2. Create the page structure from [figma-structure.md](figma-structure.md).
3. Load `figma-use` and `figma-generate-library`. Build `🎨 Foundations` (variable collections, text and effect styles) and `🧩 Components` (variants bound to variables).
4. Fill `📋 Brief & Rules` from [brief-page.template.md](../assets/brief-page.template.md).
5. Verify with `get_variable_defs`, `get_metadata` and `get_screenshot`.

## 4. Screens

1. Read the library state again (`search_design_system`, `get_variable_defs`).
2. Load `figma-use` and `figma-generate-design`. Build each screen in `📱 Screens`, section by section, from library components and variables. No hardcoded values when a token exists.
3. If a screen needs a missing component, add it to the library first, then use the instance.
4. Screenshot each screen and compare with the intent.

## 5. Optional review pass

- impeccable present: run `critique` and/or `audit` on the design intent or previews, then `polish`. Apply accepted changes in Figma, one batch.
- Absent: do one self-review against the Done criteria in the checklist.
- Bounded: at most one review pass and one fix batch per run.

## 6. Sync

Follow [sync-rules.md](sync-rules.md): update `PRODUCT.md` / `DESIGN.md` from Figma, refresh header and snapshot, update Claude's design-system context, then report per the Output Contract in `SKILL.md`.

## Iterating on an existing project

Before step 1, read Figma, diff against the snapshot, summarize manual edits, then resume at the step that matches the request.
