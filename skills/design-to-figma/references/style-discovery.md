# Style discovery

Run after the product brief (`PRODUCT.md`: who, problem, essential screens, name, UI locale) and before any direction work, in both modes, for every new design (a new project, or a new screen without a recorded style). Each gate is skipped only when its own confirmation is recorded, or when the user already provided that decision (section 0): the category references (section 1), the style (sections 2–4) and the palette (section 5). A recorded style does not skip the category or palette gates; a project created before these gates (no category references or confirmed palette recorded) runs them before the next direction work. Say in one line which gates were skipped and why.

## 0. Decisions the user already made

Read the request and its attachments (brief, PDFs, screenshots, a reference image of the app, a brand guide) before asking any style question. Take what the user already decided as confirmed, recorded as provided by the user with the date, and never ask it again:

- **Palette:** colors given as values, a named seed or visible in a reference image or brand guide. Record the values and their roles; mark values read from an image as "(from image)". Show the swatch artifact once as the record without waiting for an answer. Check contrast (section 5) and ask only about the pairs that fail AA, with a fix for each.
- **Typography:** the families the user named (for example Geist and Geist Mono). Use them for every text style; check availability in Figma ([figma-structure.md](figma-structure.md)) and ask only when a family is missing.
- **Look:** a reference image, screenshots of the app or an existing design the user wants to follow. Derive the style and its traits from it (sections 2 to 4 are not asked), state them in one line and continue. The user can correct them at any time.

The category references always run (section 1), even when everything above was provided. They show how real products are built in this category: their flows, screens, patterns and what their users ask for. They feed the screen list and each screen's definition, not the look. Present them and wait, as section 1 says.

Anything the user did not provide runs its own gate. Say in one line what was taken from the request, for example: "Taken from your request: palette (from the reference image), Geist and Geist Mono, the look of the reference image. Next: category references."

## 1. Research the category first

Mandatory, before asking or presenting any style. Research real products in the same category as the brief (for example "barbershop booking app", "salon appointment app"): shipped apps, found through their App Store / Play Store listings or official pages. Template galleries, font sites and stock-UI sites are not category references.

| Order | Tool |
|---|---|
| 1 | A references connector when connected (the "Reference source" slot in [tool-directory.md](tool-directory.md), for example Mobbin) |
| 2 | Web search, then fetch on the best pages (Claude Code: `WebSearch` / `WebFetch`; Desktop: web search when enabled) |
| 3 | No tool: say the list comes from model knowledge and is unverified, and ask the user for references. Never invent links |

Also look at user reviews of the category apps (App Store / Play Store reviews, review sites) and summarize what users ask for and what frustrates them, with sources. Record the findings in `PRODUCT.md` and use them in each screen's definition ([screen-loop.md](screen-loop.md)).

Present the list before continuing: at least 3 real products, each with its name, one line on what is relevant (flow, layout, tone) and the source link. Then ask the user to confirm, add or remove references, and wait.

If the research finds fewer than 3 real category products, say so plainly now, never after the proposals, and ask how to proceed: more searches, references from the user, or continue with style references only. Record the user's choice in `PRODUCT.md` (Category references), so the gate counts as confirmed on the next run. The style research below builds on the confirmed category references.

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

The confirmed or provided category references, style, palette, typography and traits are constraints from now on:

- **Proposals:** every direction stays inside the style ([proposals.md](proposals.md)).
- **impeccable (when present):** pass them as pinned aesthetics ([quality-bar.md](quality-bar.md)).
- **Local files:** each gate reads its own record, so write all three, with the date of the user's confirmation: in `PRODUCT.md` (Brand Commitments) the `Category references` line, the `Style and references` line, the `Palette` line and the `Typography` line, each marked confirmed or provided by the user ([PRODUCT.template.md](../assets/PRODUCT.template.md)); in `DESIGN.md` the style under Overview and the palette values and roles. When `DESIGN-PLAN.md` exists, mark its `Brief` and `Style and references` items; `Palette and foundations` is marked once the user approves the foundations.
- **Brief page:** add a "Style and references" block with the style name, both reference lists (category and style) and the traits ([brief-page.template.md](../assets/brief-page.template.md)).

Record both lists (category references and style references) as names and traits only. Never copy assets, screenshots, logos or copy from reference products.
