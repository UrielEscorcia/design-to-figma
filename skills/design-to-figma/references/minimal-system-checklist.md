# Minimal system checklist (no impeccable)

Use when impeccable is absent (always on Claude Desktop). Keep it small. Ask, wait for answers, do not invent product decisions. Confirm the results before writing to Figma.

## 1. Brief (3 to 4 questions, one round)

1. Who is the primary user and what problem do they have? What are they trying to do on this screen or product?
2. What does the product do, and what should it feel like (three adjectives, plus one thing it must not feel like)?
3. Constraints: platform (web, iOS, Android), brand colors or fonts to keep, accessibility needs.
4. (Project mode only) The essential screens or flows to design, and the product name.

Record answers in [PRODUCT.template.md](../assets/PRODUCT.template.md) form. Mark any inferred fact as inferred.

## 2. Palette with semantic roles

- Primary action, secondary action, background (default and subtle), surface, border, text (primary and muted), and feedback (success, warning, danger).
- Ask whether dark mode is needed; never assume it. Create the semantic variables in a single-mode collection (Light); add a Dark mode only when asked.
- Check text contrast against its background: at least 4.5:1 for body text, 3:1 for large text and UI boundaries.
- Map each role to a primitive scale value (see naming in [figma-structure.md](figma-structure.md)).

## 3. Type scale

- One or two font families (prefer fonts available in Figma).
- Roles: display or heading 1, heading 2, heading 3, body, small, caption, with size, weight and line height each.
- A consistent ratio between steps (for example 1.2 to 1.25).

## 4. Spacing and radius

- Spacing scale on a 4 or 8 base: 4, 8, 12, 16, 24, 32, 48, 64.
- Radius: sm, md, lg, full. Pick one personality (sharp, soft, round) and stay with it.

## 5. Components

Only the components the screen or screens need (common set: button, input, card, list item, navigation, tag). One variant axis at a time: variant, size, state. Every component binds to variables.

## Done criteria

- Brief answered and recorded.
- Palette roles, type scale, spacing and radius exist as Figma variables and styles.
- Every component used by a screen exists in `🧩 Components` with its needed states.
- No hardcoded colors, spacing or radius in screens.
- Text contrast meets the thresholds above.
- `PRODUCT.md` and `DESIGN.md` carry the Figma link and snapshot.
