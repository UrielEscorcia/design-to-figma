# Style discovery

Run after the product brief (`PRODUCT.md`: who, problem, essential screens, name, UI locale) and before any direction work, in both modes, for every new design (a new project, or a new screen without a recorded style). Each gate is skipped only when its own confirmation is recorded: the category references (section 1), the style (sections 2–4) and the palette (section 5). A recorded style does not skip the category or palette gates; a project created before these gates (no category references or confirmed palette recorded) runs them before the next direction work. Say in one line which gates were skipped and why.

## 1. Research the category first

Mandatory, before asking or presenting any style. Research real products in the same category as the brief (for example "barbershop booking app", "salon appointment app"): shipped apps, found through their App Store / Play Store listings or official pages. Template galleries, font sites and stock-UI sites are not category references.

| Order | Tool |
|---|---|
| 1 | A references connector when connected (the "Reference source" slot in [tool-directory.md](tool-directory.md), for example Mobbin) |
| 2 | Web search, then fetch on the best pages (Claude Code: `WebSearch` / `WebFetch`; Desktop: web search when enabled) |
| 3 | No tool: say the list comes from model knowledge and is unverified, and ask the user for references. Never invent links |

Present the list before continuing: at least 3 real products, each with its name, one line on what is relevant (flow, layout, tone) and the source link. Then ask the user to confirm, add or remove references, and wait.

If the research finds fewer than 3 real category products, say so plainly now, never after the proposals, and ask how to proceed: more searches, references from the user, or continue with style references only. The style research below builds on the confirmed category references.

## 2. Ask which style

One question, waiting for the answer. If the user is unsure, offer named styles in the same message:

- **Minimal:** generous space, restrained palette, type does the work.
- **Editorial:** strong typographic hierarchy, grid-led layouts, considered imagery.
- **Bold / expressive:** saturated color, large type, confident shapes.
- **Soft / friendly:** rounded forms, warm neutrals, gentle depth.
- **Dense / data-first:** compact, tabular, high information density, neutral chrome.
- **Glass / depth:** translucent layers, blur, light and shadow used with restraint.

Accept a style the user names that is not on the list. A style is never a literal metaphor for the product (no pressboard folders for a document tool, no paper textures for a notes app) unless the user asks for that.

## 3. Research current style references

Use the brief. Research the chosen style for this product and screen type (for example "minimal sign-in screen", "dense analytics dashboard").

| Surface | Tool |
|---|---|
| Claude Code | `WebSearch`, then `WebFetch` on the best sources |
| Claude Desktop (chat, Cowork) | Web search, when it is enabled |
| No web tool | Say that the references come from model knowledge and are unverified. Do not invent source links |

Prefer products shipped in the last two years, official design-system pages and the products' own marketing and app pages. Keep it bounded: one research round, a handful of sources.

## 4. Present the style

Present, in one short block:

- the style, and in one line what it means for this product;
- 3 to 5 popular products that use it (the confirmed category references may count) (for example "this style is used by Stripe and Mercury");
- concrete traits: **type** (families or classes, scale, weight), **color use**, **density**, **radius**, **motion**, **imagery**;
- source links when the research produced them, otherwise the unverified note from step 3.

Ask the user to confirm or adjust. Wait for the answer.

## 5. Confirm the palette

The palette is defined and confirmed by the user before any direction is generated ([proposals.md](proposals.md)). Show it as a visual swatch artifact without waiting to be asked; a hex table alone is not enough. Claude Code: the Artifact tool; Desktop: Design output or an artifact. Each swatch shows its role, hex and the contrast ratio against its pair (AA: 4.5:1 text, 3:1 large text and UI).

Offer the seed-color option: the user picks one seed color and the palette is generated from it with tonal ramps (OKLCH), tinted neutrals, and semantic colors (success, warning, danger) shifted toward the seed hue, every pairing AA-checked. When the user is unsure, show 2 or 3 palette options as swatches. Wait for an explicit confirmation.

## 6. Record and pass on

The confirmed category references, style, palette and traits are constraints from now on:

- **Proposals:** every direction stays inside the style ([proposals.md](proposals.md)).
- **impeccable (when present):** pass them as pinned aesthetics ([quality-bar.md](quality-bar.md)).
- **Local files:** record them in `PRODUCT.md` (Brand Commitments and Product Principles) and `DESIGN.md` (Overview, under a "Style and references" line).
- **Brief page:** add a "Style and references" block with the style name, both reference lists (category and style) and the traits ([brief-page.template.md](../assets/brief-page.template.md)).

Record both lists (category references and style references) as names and traits only. Never copy assets, screenshots, logos or copy from reference products.
