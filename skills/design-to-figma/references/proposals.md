# Proposals

Before building in Figma, show two or three distinct directions inside the confirmed style ([style-discovery.md](style-discovery.md)) so the user can compare, pick one, or ask for more. The proposal is only a base. Only the chosen direction is built in Figma, and from then on Figma is the source of truth.

## What a direction is

A direction differs from the others in structure and character (layout, hierarchy, density, type pairing, color balance), not only in accent color. All directions use the confirmed style and its traits, real content, and no skeuomorphism or literal metaphors. Name each direction in two or three words and describe it in one line.

When impeccable is present, its direction step supplies the candidates (with the style passed as in [quality-bar.md](quality-bar.md)); otherwise derive them yourself.

## Where to show them

Never target claude.ai/design projects and never call the `DesignSync` tool. Claude Design now lives in Claude as artifacts.

| Surface | How |
|---|---|
| Claude Code | Artifact tool with `action: "quickstart"` and `intent: "design"`. The result lists the Design type available to the account. Never hardcode a type URL; it is account-scoped. Publish with that `type_url`, a title (for example `<Product> — <Scope> directions`) and `auto_open: "after_first_write"`, then follow the type's own instructions: artboards on a canvas, one artboard per direction. Artifacts are private by default. |
| Claude Desktop chat or Cowork | The chat's Design output (Output → Design), or the Artifacts Design template. One artboard or section per direction. |
| No design surface | Build quick direction frames on a `🧪 Explorations` page in Figma, one frame per direction at low fidelity. Delete the page after the choice, and say so in the report. |

## After they are shown

1. Ask which direction to build, or whether to adjust or generate more. Wait for the answer.
2. If the user asks for changes or more options, regenerate within the same style and show them again. At most two extra rounds, then ask the user to pick.
3. Record the chosen direction (name, one-line rationale) in `DESIGN.md` Overview and, in project mode, in the Brief page.
4. Run impeccable `critique` (or the built-in checklist) on the chosen direction before the Figma build ([quality-bar.md](quality-bar.md)).
