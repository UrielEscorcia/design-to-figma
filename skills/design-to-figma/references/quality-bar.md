# Quality bar

The goal is an excellent, current design, not a standard one, even for a single screen. Competent but dated work (heavy skeuomorphism, literal metaphors, decorative texture) is a failure of this bar.

## Rules

- Stay inside the confirmed style ([style-discovery.md](style-discovery.md)).
- No skeuomorphism and no literal metaphors (folders, binders, tickets, paper, wood, brass) unless the user asks for them.
- Hierarchy first: one clear focal point per screen, a limited type scale, consistent spacing, restrained color with purposeful accents.
- Real content: realistic labels, states and data; no lorem ipsum.
- States are part of the design: default, hover or focus, error, empty, loading, disabled, as the screen needs.
- Accessibility: text contrast of at least 4.5:1 for body text and 3:1 for large text and UI boundaries; visible focus; touch targets of at least 44 pt on touch platforms.

## With impeccable

Use impeccable for every design step: `shape` (brief), its new-work flow (direction), `critique`, `polish`. The skill's `critique` and `polish` are mandatory before reporting a design as done, and the report lists them ([SKILL.md](../SKILL.md), Output Contract). Do not modify impeccable.

How impeccable behaves, and how to pass the style into it:

- impeccable honors a pinned brief: "the brief wins" and pinned aesthetics, materials and fonts are respected. State the confirmed style as a pinned aesthetic in the request that starts `shape` or the new-work flow: style name, reference products, and the type, color, density, radius, motion and imagery traits.
- Its direction step asks structured questions and deals candidate directions. Put the style in the answers to those questions and in `PRODUCT.md`, and reject any dealt direction that leaves the style. Ask for a re-roll or steer instead of accepting it.
- When the project already has `DESIGN.md` with a recorded style, impeccable inherits that world; extend it rather than starting a new identity exercise.
- Its flows are code-oriented. In this skill use only the design-facing steps (`init`, `shape`, new-work direction, `extract`, `critique`, `polish`) and apply the result in Figma, not in a codebase. Skip its build, live and code-detector steps.
- impeccable keeps its own state in `.impeccable/` in the project folder (surfaces, questions). Leave it to impeccable; this skill does not edit it except through impeccable's own flow.

Apply `critique` findings and `polish` to the chosen direction, then to the Figma build, in one batch. Bounded: outside the screen loop (for example the chosen-direction critique and the final cross-screen review) a run is one critique, one fix batch, one polish pass. Screens use the budget in [screen-loop.md](screen-loop.md).

## Quality gate

A design is done only when all three hold:

1. **No P0 or P1 issues** remain in the critique findings.
2. **The design-specificity verdict reads as authored**, not interchangeable within its category (impeccable's critique Design Specificity Verdict). This is the visual-quality signal.
3. **The heuristics score is at least 28/40.** When some heuristics are n/a, keep the same 70% of the applicable maximum (for example at least 23/32 when two heuristics are n/a). This score measures usability (Nielsen), not visual quality; do not read it as one.

How to run the critique so the gate means something:

- Critique runs on rendered screenshots, never on source alone: render the comp artifact, and take Figma frames with `get_screenshot`.
- The detector (Assessment B) runs on the HTML comp. A Figma-only critique has no Assessment B; report it as degraded and say so in the report.
- Below the gate: report the gap (which condition failed, the open P0/P1 items, the score) and offer another fix round. Do not call the design done silently. The extra round runs only after the user accepts it, and it starts a new bounded run (one critique, one fix batch, one polish pass) with the user's consent.

Builders are held to the same standard: see the builder guidance in [tool-directory.md](tool-directory.md).

## Without impeccable: built-in critique checklist

Run it on the chosen direction and again on the Figma build. Record each answer as pass, fix applied, or accepted risk.

1. **Style fit:** does it match the confirmed style and its traits, without copying a reference?
2. **Currency:** does it look like current products in the category, or like a dated template? Any skeuomorphic or literal metaphor?
3. **Hierarchy:** is the focal point obvious within two seconds? Are there at most three type sizes competing on the screen?
4. **Spacing and alignment:** one spacing scale, consistent alignment, consistent padding in repeated elements.
5. **Color:** roles are applied consistently; accents are purposeful; contrast thresholds above are met.
6. **Type:** one or two families, consistent weights, readable line lengths and line heights.
7. **Components and states:** consistent radius, borders and shadows; every interactive element has its states.
8. **Content:** realistic copy, clear labels, helpful error and empty states.
9. **Accessibility:** contrast, focus visibility, target sizes, no information carried by color alone.
10. **Polish pass:** alignment to the grid, consistent corner radii, no stray one-off values, every value bound to a variable.

Fix everything that failed in one batch, then check the gate. Without impeccable the gate maps onto this checklist: no item left failed (the P0/P1 condition), items 1 and 2 pass (the specificity condition: the design reads as authored for this product, not as a category template), and there is no heuristics score, so condition 3 does not apply. Report the checklist run as the fallback gate, and report any unfixed failure as the gap and offer another round.
