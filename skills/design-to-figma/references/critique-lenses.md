# Critique lenses

Four focused lenses check a Figma build after the holistic critique ([quality-bar.md](quality-bar.md)). They add evidence; they never replace impeccable's critique, its score or the quality gate. Each lens looks at one concern, measures what can be measured, and reports only findings it can prove. A refuter then tries to disprove the serious ones before anything is fixed.

## Which lenses run

Proportional, like [routing.md](routing.md): run the lenses that cover what changed.

| What changed | Lenses |
|---|---|
| A new screen or state, the screen loop's agent verify, the final cross-screen review | all four |
| Color, a token or a variable value | Accessibility, System consistency |
| Spacing, layout or sizes | Hierarchy and readability, System consistency (and Accessibility when text size or touch targets change) |
| Copy, labels or the UI locale | Copy and UX (and Hierarchy and readability when the length changes the layout) |
| A component or variant | System consistency, Accessibility |
| A behavior or a flow | Copy and UX, Hierarchy and readability |

When it is unclear which lenses cover a change, run all four. A re-verify after a self-fix batch runs the lenses whose findings the batch fixed, plus the lenses that cover what the fixes changed. Say in one line which lenses ran and why.

All lenses share the same `get_screenshot` renders of the frames under review. Take one render per frame per verify; the measurements come from new screenshots never.

Measure with [measure.js](../assets/scripts/measure.js), a tested read-only `use_figma` script (load `figma-use` first). Read the file, replace the two parameter lines (`NODE_IDS` with the frame IDs under review, all of them in one call; `OPTIONS` with `textFloor` from `DESIGN.md` and `touch: false` for desktop-only frames), and send the whole file as the `use_figma` code. One call returns, for every frame:

| Output | Feeds |
|---|---|
| `contrast.failures` (fg and bg hex and variable names, ratio, required), `contrast.unmeasured` | Accessibility |
| `textFloor.failures`, `targets.failures` | Accessibility |
| `unbound` (fills, strokes, spacing, radius, text), `detachedCandidates` | System consistency |

Every example carries its `frameId`. `counts` holds the exact totals. The example lists are capped per frame and per list (`maxExamples`, 25 by default), and every cut list is named in `truncated` with its shown and total size. Never read a truncated list as complete: re-run measure.js on that frame alone with a higher `maxExamples` before judging it.

Its measurements are the evidence for those findings. Hierarchy and Copy and UX findings are judgments: they cite the node and the screenshot, and stay unverifiable for the refuter. `contrast.unmeasured` and the script's `limits` (backgrounds come from ancestor fills only) are judged on the screenshot, never counted as a pass.

## 1. Hierarchy and readability

- One focal point per screen, found within two seconds; the primary action is the most prominent control.
- At most three type sizes compete in one view; headings, body and metadata follow the type scale in `DESIGN.md`.
- Related items sit closer than unrelated ones; sections read as groups, not a flat list.
- Density fits the user in the brief (for example compact tables for accountants, larger targets on mobile).
- Repeated information (the same amount or status shown several times) has a reason in each place.

## 2. Accessibility

- Text contrast: at least 4.5:1 for body text, 3:1 for large text, UI boundaries and focus indicators. Compute it from the resolved variable colors in the current mode, opacity included, never from the screenshot.
- Text size: no functional text below the floor in `DESIGN.md` (11 px when none is set).
- Touch targets: at least 44 × 44 pt on touch platforms, from the node bounds.
- Focus states exist for every interactive component; color is never the only carrier of meaning (badges have text or an icon).

## 3. System consistency

- Every fill, stroke, spacing, radius and text value is bound to a variable or style; list the unbound ones.
- Components are instances of the library, not detached copies or one-off frames that look like a component.
- States and variants are real component variants, never faked (painted backgrounds, overlays) ([quality-bar.md](quality-bar.md)).
- Values sit on the scales in `DESIGN.md` (spacing, radius, type); a value off the scale is a finding.
- With a provided look, the reference's radius, elevation and color use are kept ([proposals.md](proposals.md)).

## 4. Copy and UX

- All copy is in the UI language and locale from the brief: dates, currency, number formats, tone.
- Labels say what happens; buttons start with a verb; no placeholder text or lorem ipsum.
- Empty, loading and error states exist where the screen needs them, and an error says how to fix it.
- The screen follows the app-wide rules in `DESIGN.md` and the agreed definition in `DESIGN-PLAN.md` (its L# requests).
- A missing action, label or behavior is a product addition: recommend it, never add it ([quality-bar.md](quality-bar.md)).

## Evidence

Every finding carries all of these, or it is not reported:

- **Severity:** P0 to P3, as in impeccable's critique.
- **Node ID:** the node, with its Figma link.
- **Screenshot:** the frame render where it shows.
- **Rule:** the lens rule it breaks, quoted short.
- **Measured:** the value found against the value required (for example "contrast 3.2:1, required 4.5:1: `text/tertiary` #8F959B on `bg/canvas` #F4F6F9"), or, for a rule without a number, the exact text or element. A value read from a screenshot (text over an image or a gradient, which measure.js reports as unmeasured) is estimated, never called measured: write "estimated 3.8:1 from the screenshot".

A finding without evidence is dropped, not softened. Example:

`[P1] Accessibility · node 123:456 (link) · frame Inicio · 390 · rule: body text ≥ 4.5:1 · measured: 3.2:1 (text/tertiary on bg/canvas) · fix: text/secondary`

## Refuter

Before any P0 or P1 finding drives a fix or the gate, try to disprove it with a fresh measurement: re-run the read-only [measure.js](../assets/scripts/measure.js) with `NODE_IDS` set to the finding's node only. It resolves the bound variables in the node's mode, reads font sizes and bounds, and checks instance state. The refuter receives only the finding (node ID, rule, measured value claimed), never the lens's reasoning, and does not look at the screenshot again; its independence comes from measuring the file.

Each finding ends as confirmed, refuted or unverifiable:

- **Confirmed:** the measurement reproduces it. It counts for the gate and goes into the fix batch.
- **Refuted:** the measurement contradicts it (for example the text is 14 px, not 10 px, or the variable resolves to a passing color). Drop it and say why in one line.
- **Unverifiable:** no script can measure it (a judgment about hierarchy or tone). Keep it at P2 at most and list it in Open gaps; it never blocks the gate on its own.

P2 and P3 findings skip the refuter and go to the polish pass or Open gaps.

Where the surface has subagents (Claude Code), run each lens as a fresh, isolated reviewer given the renders, `PRODUCT.md`, `DESIGN.md`, the plan section and this file, never the gate thresholds or earlier reports; run the refuter as another subagent given only the findings to check. Without subagents (Claude Desktop), run them in sequence in one context, keep the refuter to the finding and the script, and declare the run degraded (single-context), as [quality-bar.md](quality-bar.md) says for the critique.

## Report

The user review gets a **Lenses** field ([screen-loop.md](screen-loop.md) step 6): which lenses ran, and the confirmed findings per lens with their fix or Open gaps entry. Refuted findings are counted, not listed. For example: "Ran all four. Accessibility: 1 confirmed, fixed (P1 contrast on node 123:456); System consistency: 2 unbound values, bound; 1 refuted."
