# Iteration in Figma

After the first build, the user changes the design by asking in natural language: "change this screen's color to X", "remove the borders of these form fields and rearrange them". Apply these directly in Figma, then sync.

## Steps

1. **Identify the target.** Ask for a link or selection if the request does not say which frame, component or token it concerns.
2. **Read current state first.** Enumerate pages and read the affected frames as described in [sync-rules.md](sync-rules.md); take a `get_screenshot` of the target. Note manual edits that differ from the snapshot and keep them.
3. **Choose the right level.**
   - A color, spacing or radius meant everywhere: edit the **variable** (token), so every bound node follows.
   - One component's look: edit the **component** (or the main component of a set), so all instances follow.
   - One place only: edit the **instance** or the node, and say it is a local override.
   - If a request touches shared tokens or components, state which screens it will affect before applying.
4. **Apply with `use_figma`.** Load `figma-use` first. Keep values bound to variables, keep auto layout and text styles. Do not delete or replace content the user did not mention.
5. **Verify.** `get_screenshot` of the changed frames; compare with the request.
6. **Quality check.** For visual changes, run the critique checklist in [quality-bar.md](quality-bar.md) on the changed area; apply fixes in one batch.
7. **Sync.** Update `DESIGN.md` and the snapshot per [sync-rules.md](sync-rules.md) (Figma → local), and report what changed under the Output Contract.

## Examples

- "Change this screen's color to X": if the screen's colors are bound to semantic variables, change the semantic variable or the primitive it maps to and check contrast; if only this screen should change, create or use a screen-level override and say so.
- "Remove the borders of these form fields and rearrange them": edit the `Form/Input` component (borders, fill or underline for separation), then rearrange the fields in the screen frame with auto layout. Check focus and error states still read clearly without borders.
