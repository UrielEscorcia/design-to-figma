# Figma structure and naming

## Pages

| Page | Contents |
|---|---|
| `📋 Brief & Rules` | Product summary, design principles, usage rules, links. Text content: [brief-page.template.md](../assets/brief-page.template.md). |
| `🎨 Foundations` | Variable collections (documented with swatches and scales) and text and effect styles. |
| `🧩 Components` | The component library: component sets with variants, one section per family. |
| `📱 Screens` | Screens as top-level frames, grouped by flow. |

The page set is a default. Adjust only on user request, and record changes in the Brief page and `DESIGN.md`.

## Naming

**Variable collections:** `Primitives` (raw values), `Semantic` (roles mapped to primitives), `Spacing`, `Radius`, `Typography` when numeric. When dark mode is not requested, `Semantic` is a single-mode collection (mode `Light`, or the single mode); Dark can be added later as one new mode. When dark mode is requested up front, `Semantic` gets Light and Dark modes during foundations; build Dark frames only after each Light screen is user-approved.

**Variables:** slash-separated, lowercase, role-based.
- Primitives: `color/blue/500`, `space/4`.
- Semantic: `color/bg/default`, `color/bg/subtle`, `color/text/primary`, `color/text/muted`, `color/border/default`, `color/action/primary`, `color/feedback/danger`.
- Spacing and radius: `space/1…n` (scale index), `radius/sm|md|lg|full`.

**Styles:** `text/<role>` (for example `text/body`, `text/heading-1`), `effect/<name>`.

**Components:** `Family/Name`, title case (for example `Button`, `Form/Input`). Slash adds grouping in the assets panel.

**Variants:** properties in title case, values lowercase: `Size=md`, `Variant=primary`, `State=default|hover|focus|disabled`. Boolean properties: `Icon left`. Order: Variant, Size, State.

**Frames (screens):** `<Flow> / <Screen> / <Breakpoint>` (for example `Onboarding / Welcome / Mobile`). Layers inside: descriptive names, not `Frame 123`.

## Brief page content

Short and scannable. Sections: product in one paragraph, audience, principles (3 to 5), design system summary (palette roles, type, spacing, radius), style and references (style name, reference product names, traits), usage rules (do and don't), links (`PRODUCT.md` and `DESIGN.md` by file name relative to the project folder, repo if any).

The Brief page carries no sync timestamp: sync state lives in the local files. Never write absolute local paths, usernames or machine details into Figma.

## Fonts

Before writing text styles, check availability with `figma.listAvailableFontsAsync()` and load only fonts that exist. Platform fonts can be missing or render blank in MCP screenshots (iOS: SF Pro, SF Pro Rounded). When one is not usable, tell the user and ask before substituting (for example Inter); never swap silently. Record an approved substitution in `DESIGN.md` as a known deviation.

## Rules

- Every color, spacing and radius in components and screens binds to a variable. No hardcoded values when a token exists.
- Text uses text styles. Components use auto layout.
- Keep screens in `📱 Screens` only; scratch work goes in a clearly named section that is removed before the report. Direction frames built when no design surface exists go on a `🧪 Explorations` page that is deleted after the choice ([proposals.md](proposals.md)).
- File names follow `<Product> — <Scope>` (for example `Tessera — Sign-in`).
