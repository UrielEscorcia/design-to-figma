# Workflow: full project

Use when the user wants a design system plus several screens. Read Figma before each numbered step when a file exists ([sync-rules.md](sync-rules.md): enumerate pages first).

## 1. Brief → PRODUCT.md

- impeccable present: run `init`; it interviews and writes `PRODUCT.md`.
- Absent: ask the brief questions in [minimal-system-checklist.md](minimal-system-checklist.md) and fill [PRODUCT.template.md](../assets/PRODUCT.template.md).
- Ask who the users are, the problem, the essential screens, the product name and the UI language and locale (all UI copy uses it). The brief always comes before style discovery. Ask whether dark mode is needed; record the answer in `PRODUCT.md`. Ask once whether to keep a Design System artifact synced from Figma ([design-system-artifact.md](design-system-artifact.md)); record the answer.
- Optional discovery for the overall experience: impeccable `shape`.
- Wait for answers before continuing; do not invent product decisions.

## 2. Style discovery

Follow [style-discovery.md](style-discovery.md), using the brief from step 1: research real category products and get the list confirmed, then ask the style, research current references, present the style with popular products and traits, and get the user's confirmation, and get the palette confirmed as swatches. Record it in `PRODUCT.md`.

## 3. Direction and proposals

- impeccable present: follow its new-work flow for direction, with the confirmed style pinned ([quality-bar.md](quality-bar.md)); `extract` or `document` to turn decisions or existing code into tokens and component lists.
- Absent: use the palette, type, spacing and radius steps in the checklist.
- Show 2 or 3 distinct directions within the style, sharing the confirmed palette, as Claude Design artifacts ([proposals.md](proposals.md)). The user picks one, asks for changes, or asks for more.
- Record the chosen direction in [DESIGN.template.md](../assets/DESIGN.template.md) form. Run `critique` on it (with impeccable; built-in checklist otherwise) and apply the fixes before building.
- Confirm the direction with the user before writing to Figma.

## 4. Figma file and foundations

1. No file yet: ask the file name as its own question (suggest `<Product> — <Scope>`, for example `Tessera — Sign-in`), never folded into another question. Only then, with several teams or plans, ask which one owns the file. Then load `figma-create-new-file` and call `create_new_file`. Record the URL and file key.
2. Create the page structure from [figma-structure.md](figma-structure.md).
3. Check fonts ([figma-structure.md](figma-structure.md)). Load `figma-use` and `figma-generate-library`. Build `🎨 Foundations` (variable collections, with `Semantic` in a single-mode collection, or Light and Dark modes when dark mode was requested up front; text and effect styles) and `🧩 Components` (variants bound to variables).
4. Fill `📋 Brief & Rules` from [brief-page.template.md](../assets/brief-page.template.md), including the style and references.
5. Once the foundations are user-approved, run the first Design System artifact sync when kept ([design-system-artifact.md](design-system-artifact.md)).
6. Verify by enumerating pages and reading them, plus `get_screenshot` ([sync-rules.md](sync-rules.md)).

## 5. Screen list and plan

Agree the screen list with the user (from the essential screens in the brief), then create `DESIGN-PLAN.md` from [DESIGN-PLAN.template.md](../assets/DESIGN-PLAN.template.md) in the project folder (or deliver it as a download). Ask whether dark mode is needed if not yet recorded; never assume it. Keep the plan current after every state change.

## 6. Per-screen loop

Run [screen-loop.md](screen-loop.md) for each screen in turn, in `📱 Screens`: define, build, agent verify, self-fix, the mandatory `polish` pass, user review, final verify, and Dark when requested. The loop has its own budget ([screen-loop.md](screen-loop.md)). Read the library state again before each build (`search_design_system`, variables and styles by read-only script). Do not start the next screen before the user approves the current one, unless the user explicitly says to batch.

## 7. Final cross-screen critique

After the last screen is `final-verified`, run one critique across all screens for consistency (type, spacing, components, tone), with `critique` on screenshots (and `audit` for accessibility) or the built-in checklist. Apply accepted fixes in one batch and show the result to the user.

## 8. Iterate

Change requests after the build ("change the primary color", "make the cards denser") follow [iteration.md](iteration.md).

## 9. Sync

Follow [sync-rules.md](sync-rules.md): update `PRODUCT.md` / `DESIGN.md` from Figma, refresh the frontmatter and snapshot, run the final Design System artifact sync when kept ([design-system-artifact.md](design-system-artifact.md)), mark the plan, then report per the Output Contract in `SKILL.md`.

## Iterating on an existing project

Before step 1, read Figma, diff against the snapshot, summarize manual edits, then read `DESIGN-PLAN.md` if it exists and resume at the next unfinished item, or at the step that matches the request. If the plan was delivered as a download (no writable folder), ask the user to attach or paste `DESIGN-PLAN.md`; if they cannot, rebuild the state from Figma (pages, screens present) and the local files, show it and confirm before continuing. A new design request still passes style confirmation (reuse the recorded style) and proposals.
