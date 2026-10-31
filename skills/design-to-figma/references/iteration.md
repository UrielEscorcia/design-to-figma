# Iteration in Figma

After the first build, the user changes the design by asking in natural language: "change this screen's color to X", "remove the borders of these form fields and rearrange them". Apply these directly in Figma, then sync. This is the small route of [routing.md](routing.md): the settled gates (brief, style, palette, proposals) are not asked again.

## Steps

1. **Identify the target.** Ask for a link or selection if the request does not say which frame, component or token it concerns.
2. **Read current state first.** Enumerate pages and read the affected frames as described in [sync-rules.md](sync-rules.md); take a `get_screenshot` of the target. Note manual edits that differ from the snapshot and keep them.
3. **Diagnose before fixing.** For a visual defect, inspect the node's ancestors first: `clipsContent`, padding, bounds and z-order on each parent frame, then the node's effects. Name the cause before changing anything.
4. **Choose the right level.** Prefer the smallest local fix; ask before any global change to tokens, styles or components.
   - A color, spacing or radius meant everywhere: edit the **variable** (token), so every bound node follows.
   - One component's look: edit the **component** (or the main component of a set), so all instances follow.
   - One place only: edit the **instance** or the node, and say it is a local override.
   - If a request touches shared tokens or components, deletes content or changes the brand foundations, it is high risk: measure its reach and get the user's yes as in step 4 of [routing.md](routing.md) before applying.
5. **Apply with `use_figma`.** Load `figma-use` first. Keep values bound to variables, keep auto layout and text styles. Do not delete or replace content the user did not mention, and never hide or delete content to make a layout fit without asking.
6. **Verify.** `get_screenshot` of the changed frames; compare with the request.
7. **Quality check.** For visual changes, run the critique checklist in [quality-bar.md](quality-bar.md) on the changed area; apply fixes in one batch.
8. **Sync.** Update `DESIGN.md` and the snapshot per [sync-rules.md](sync-rules.md) (Figma → local), and report what changed under the Output Contract.
9. **App-wide requests become rules.** When a user change applies to the whole app rather than one screen (layout, copy, language, spacing, behavior), record it as an app-wide rule in `DESIGN.md` (behavior or usage rules) and in the Brief page's usage rules, apply it to every screen already built, and respect it in later screens without being asked again. Screens it changes that were already past `built` go back to `built` in the plan: run agent verify on them again and show them in the next user review, so no state claims approval of a version the user has not seen. Ask when it is unclear whether a request is screen-only or app-wide.

## Examples

- Gray squares at a card's bottom corners: they came from parent frames clipping the card's shadow at its bottom edge, not from the shadow. Fix the clipping or padding of the ancestor (a local fix); do not remove the shadow or change the shadow token.

- "Change this screen's color to X": if the screen's colors are bound to semantic variables, change the semantic variable or the primitive it maps to and check contrast; if only this screen should change, create or use a screen-level override and say so.
- "Remove the borders of these form fields and rearrange them": edit the `Form/Input` component (borders, fill or underline for separation), then rearrange the fields in the screen frame with auto layout. Check focus and error states still read clearly without borders.
