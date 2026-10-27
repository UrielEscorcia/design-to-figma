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

Before writing text styles, check availability with `figma.listAvailableFontsAsync()` and load only fonts that exist; a listed platform font can still be unusable by script (see below). Platform fonts can be missing or render blank in MCP screenshots (iOS: SF Pro, SF Pro Rounded). When one is not usable, tell the user and ask before substituting (for example Inter); never swap silently. Record an approved substitution in `DESIGN.md` as a known deviation. Text styles use pixel line heights (platform type ramps define them), so a text node's line count is its height divided by its line height.

Never apply the platform font by script. The Figma that `use_figma` runs in lacks local platform fonts even when `listAvailableFontsAsync()` lists them: their text nodes report `hasMissingFont`, keep their previous size and line breaks after any script change, and export as last drawn. Only the user's Figma desktop app, which has the font, lays them out again. So keep the stand-in through every verify, and swap at the end:
1. With a script, bind every text node with no text style (or with overridden font or line height) to its style, since step 2 does not reach it; then record each text node's height and line count.
2. Ask the user to change the font family to the platform font in each text style, in Figma desktop. Editing the styles, not the nodes, lays out every text that uses them.
3. Read the heights again. Flag every node whose line count changed or that now overflows its container, plus every fixed-height text node (`textAutoResize` `NONE` or `TRUNCATE`), whose height cannot show a new line.
4. Check the flagged nodes visually: in `use_figma`, export each one's parent block with `exportAsync` as PNG and return it as base64. Right after the desktop layout, the export shows the real font and breaks. Export blocks, never whole screens, because a call's return value is limited (about 48 KB).
5. Fix flagged nodes in Figma desktop with the user: a script change to a platform-font text node or its width leaves it stale again.

Report the screens as structurally verified, plus the blocks checked visually.

## Rules

- Every color, spacing and radius in components and screens binds to a variable. No hardcoded values when a token exists.
- Text uses text styles. Components use auto layout.
- Keep screens in `📱 Screens` only; scratch work goes in a clearly named section that is removed before the report. Direction frames built when no design surface exists go on a `🧪 Explorations` page that is deleted after the choice ([proposals.md](proposals.md)).
- File names follow `<Product> — <Scope>` (for example `Tessera — Sign-in`).
