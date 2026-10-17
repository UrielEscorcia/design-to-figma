# Workflow: full project

Use when the user wants a design system plus several screens. Read Figma before each numbered step when a file exists ([sync-rules.md](sync-rules.md): enumerate pages first).

## 1. Brief → PRODUCT.md

- impeccable present: run `init`; it interviews and writes `PRODUCT.md`.
- Absent: ask the 3–4 brief questions in [minimal-system-checklist.md](minimal-system-checklist.md) and fill [PRODUCT.template.md](../assets/PRODUCT.template.md).
- Optional discovery for the overall experience: impeccable `shape`.
- Wait for answers before continuing; do not invent product decisions.

## 2. Style discovery

Follow [style-discovery.md](style-discovery.md): ask the style, research current references, present the style with popular products and traits, and get the user's confirmation. Record it in `PRODUCT.md`.

## 3. Direction and proposals

- impeccable present: follow its new-work flow for direction, with the confirmed style pinned ([quality-bar.md](quality-bar.md)); `extract` or `document` to turn decisions or existing code into tokens and component lists.
- Absent: use the palette, type, spacing and radius steps in the checklist.
- Show 2 or 3 distinct directions within the style as Claude Design artifacts ([proposals.md](proposals.md)). The user picks one, asks for changes, or asks for more.
- Record the chosen direction in [DESIGN.template.md](../assets/DESIGN.template.md) form. Run `critique` on it (mandatory with impeccable; built-in checklist otherwise) and apply the fixes before building.
- Confirm the direction with the user before writing to Figma.

## 4. Figma file and foundations

1. No file yet: suggest a file name (`<Product> — <Scope>`, for example `Tessera — Sign-in`) and ask the user to confirm or change it. With several teams or plans, ask which one owns the file. Then load `figma-create-new-file` and call `create_new_file`. Record the URL and file key.
2. Create the page structure from [figma-structure.md](figma-structure.md).
3. Load `figma-use` and `figma-generate-library`. Build `🎨 Foundations` (variable collections, text and effect styles) and `🧩 Components` (variants bound to variables).
4. Fill `📋 Brief & Rules` from [brief-page.template.md](../assets/brief-page.template.md), including the style and references.
5. Verify by enumerating pages and reading them, plus `get_screenshot` ([sync-rules.md](sync-rules.md)).

## 5. Screens

1. Read the library state again (`search_design_system`, variables and styles by read-only script).
2. Load `figma-use` and `figma-generate-design`. Build each screen in `📱 Screens` from the chosen direction, section by section, from library components and variables. No hardcoded values when a token exists.
3. If a screen needs a missing component, add it to the library first, then use the instance.
4. Screenshot each screen and compare with the chosen direction.

## 6. Critique and polish (mandatory)

- impeccable present: run `critique` (and `audit` for accessibility), apply the accepted fixes in Figma as one batch, then run `polish` and apply it. Both must be done before the design is reported as done.
- Absent: run the built-in critique checklist in [quality-bar.md](quality-bar.md) on the Figma build and fix in one batch.
- Bounded: one critique, one fix batch, one polish pass per run.

## 7. Iterate

Change requests after the build ("change the primary color", "make the cards denser") follow [iteration.md](iteration.md).

## 8. Sync

Follow [sync-rules.md](sync-rules.md): update `PRODUCT.md` / `DESIGN.md` from Figma, refresh the frontmatter and snapshot, then report per the Output Contract in `SKILL.md`.

## Iterating on an existing project

Before step 1, read Figma, diff against the snapshot, summarize manual edits, then resume at the step that matches the request. A new design request still passes style confirmation (reuse the recorded style) and proposals.
