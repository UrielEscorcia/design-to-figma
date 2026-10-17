# Tool directory

Which tool to use for which job. Reference the named skills and tools; do not copy their instructions.

## When to use what

| Job | Tool | Notes |
|---|---|---|
| Find the style's current references | Web research (Claude Code `WebSearch` / `WebFetch`; Desktop web search when enabled) | Before any direction work: [style-discovery.md](style-discovery.md). No web tool: say references are unverified model knowledge |
| Show 2 or 3 directions to compare | Claude Design artifacts (Claude Code: Artifact tool, `quickstart` with `intent: "design"`; chat: Output → Design) | Never hardcode the type URL. Fallback: `🧪 Explorations` page in Figma. See [proposals.md](proposals.md) |
| Product context (users, purpose, principles) | impeccable `init` → `PRODUCT.md` | Fallback: brief questions in [minimal-system-checklist.md](minimal-system-checklist.md) |
| Discovery of a feature or screen | impeccable `shape` | Pass the confirmed style as a pinned aesthetic ([quality-bar.md](quality-bar.md)) |
| Visual direction for a new surface or a replacement look | impeccable new-work flow (an ordinary design request when PRODUCT.md exists; `craft` is a deprecated alias) | Not a separate sub-command. Reject dealt directions that leave the style |
| Record an existing look as `DESIGN.md` | impeccable `document` | When a visual system already exists |
| Pull tokens and components into a system | impeccable `extract` | Use before building the Figma library |
| Review a result | impeccable `critique` (mandatory) and `audit` (accessibility, responsive, optional) | Findings feed the next Figma edit. Without impeccable: critique checklist in [quality-bar.md](quality-bar.md) |
| Final refinement pass | impeccable `polish` (mandatory) | Run on the chosen direction, then apply to Figma |
| Create the Figma file | `figma-create-new-file` → `create_new_file` | Suggest a name (`<Product> — <Scope>`) and get the user's confirmation first; resolve the plan with `whoami` and ask which team or plan when there are several |
| Variables, styles, components (foundations) | `figma-generate-library` + `figma-use` → `use_figma` | Build in the order that skill defines |
| Screens and composed views | `figma-generate-design` + `figma-use` → `use_figma` | Reuse library components and variables |
| Change requests after the build | `use_figma` with `figma-use` | [iteration.md](iteration.md) |
| Enumerate pages, variables, styles | Read-only `use_figma` script (`figma.root.children`, `figma.variables.*`, `getLocalTextStylesAsync`, `getLocalEffectStylesAsync`) | `get_metadata` without a `nodeId` lists only the first page; see [sync-rules.md](sync-rules.md) |
| Read one page or frame | `get_metadata(nodeId=...)`, `get_screenshot`; `get_variable_defs` for a node; `search_design_system` for components | Read-only. Do not use `get_design_context` here |

## Handoff order

1. Preflight ([preflight.md](preflight.md)).
2. Read Figma (if a file exists).
3. Context: impeccable `init` or brief questions.
4. Style discovery and confirmation ([style-discovery.md](style-discovery.md)).
5. Discovery and direction within the style: impeccable `shape` and new-work, or the checklist.
6. Proposals as Claude Design artifacts; the user picks ([proposals.md](proposals.md)).
7. `critique` on the chosen direction (or the built-in checklist).
8. Figma: file name confirmed → file → foundations → components → screens.
9. `critique` fixes and `polish` (mandatory), applied in Figma.
10. Sync local files ([sync-rules.md](sync-rules.md)). Later change requests: [iteration.md](iteration.md).

## Do not use X for Y

- Do not use Claude Design output as the record of decisions. Figma is the record.
- Do not use claude.ai/design projects for anything (closing 2026-12-14). Never call the `DesignSync` tool; it only serves the user-started `/design-sync` skill for claude.ai/design design-system projects and must not be used to make designs. `/design-sync` is optional and only for users who already keep such a project.
- Do not call `use_figma` without loading `figma-use`. Do not build components without `figma-generate-library`, or screens without `figma-generate-design`.
- Do not use impeccable for Figma writes; it has no Figma access. Do not use the Figma tools for product discovery.
- Do not use `figma-generate-diagram` or FigJam skills for UI design.
- Do not generate application code, and do not call `get_design_context` (design-to-code belongs to a future companion skill; it requires `figma-design-to-code`).
- Do not use impeccable's `live` or code-oriented commands; there is no frontend codebase here.
