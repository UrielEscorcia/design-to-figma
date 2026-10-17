# Style discovery

Run before any direction work, in both modes, for every new design (a new project, or a new screen without a recorded style). Skip only when `DESIGN.md` or the Brief page already records a confirmed style, and say so in one line.

## 1. Ask which style

One question, waiting for the answer. If the user is unsure, offer named styles in the same message:

- **Minimal:** generous space, restrained palette, type does the work.
- **Editorial:** strong typographic hierarchy, grid-led layouts, considered imagery.
- **Bold / expressive:** saturated color, large type, confident shapes.
- **Soft / friendly:** rounded forms, warm neutrals, gentle depth.
- **Dense / data-first:** compact, tabular, high information density, neutral chrome.
- **Glass / depth:** translucent layers, blur, light and shadow used with restraint.

Accept a style the user names that is not on the list. A style is never a literal metaphor for the product (no pressboard folders for a document tool, no paper textures for a notes app) unless the user asks for that.

## 2. Research current references

Research the chosen style for this product and screen type (for example "minimal sign-in screen", "dense analytics dashboard").

| Surface | Tool |
|---|---|
| Claude Code | `WebSearch`, then `WebFetch` on the best sources |
| Claude Desktop (chat, Cowork) | Web search, when it is enabled |
| No web tool | Say that the references come from model knowledge and are unverified. Do not invent source links |

Prefer products shipped in the last two years, official design-system pages and the products' own marketing and app pages. Keep it bounded: one research round, a handful of sources.

## 3. Present the style

Present, in one short block:

- the style, and in one line what it means for this product;
- 3 to 5 popular products that use it (for example "this style is used by Stripe and Mercury");
- concrete traits: **type** (families or classes, scale, weight), **color use**, **density**, **radius**, **motion**, **imagery**;
- source links when the research produced them, otherwise the unverified note from step 2.

Ask the user to confirm or adjust. Wait for the answer.

## 4. Record and pass on

The confirmed style, references and traits are constraints from now on:

- **Proposals:** every direction stays inside the style ([proposals.md](proposals.md)).
- **impeccable (when present):** pass them as pinned aesthetics ([quality-bar.md](quality-bar.md)).
- **Local files:** record them in `PRODUCT.md` (Brand Commitments and Product Principles) and `DESIGN.md` (Overview, under a "Style and references" line).
- **Brief page:** add a "Style and references" block with the style name, the reference product names and the traits ([brief-page.template.md](../assets/brief-page.template.md)).

Record product names and traits only. Never copy assets, screenshots, logos or copy from reference products.
