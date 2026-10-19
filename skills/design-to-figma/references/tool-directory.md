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
| Create the Figma file | `figma-create-new-file` → `create_new_file` | Ask the file name as its own question first, suggesting `<Product> — <Scope>`, before the team or plan question; resolve the plan with `whoami` and ask which team or plan when there are several |
| Brief the Figma builders (including delegated subagents) | Prompt contents below | Always include the builder guidance below |
| Variables, styles, components (foundations) | `figma-generate-library` + `figma-use` → `use_figma` | Build in the order that skill defines |
| Screens and composed views | `figma-generate-design` + `figma-use` → `use_figma` | Reuse library components and variables |
| Change requests after the build | `use_figma` with `figma-use` | [iteration.md](iteration.md) |
| Enumerate pages, variables, styles | Read-only `use_figma` script (`figma.root.children`, `figma.variables.*`, `getLocalTextStylesAsync`, `getLocalEffectStylesAsync`) | `get_metadata` without a `nodeId` lists only the first page; see [sync-rules.md](sync-rules.md) |
| Read one page or frame | `get_metadata(nodeId=...)`, `get_screenshot`; `get_variable_defs` for a node; `search_design_system` for components | Read-only. Do not use `get_design_context` here |

## Handoff order

1. Preflight ([preflight.md](preflight.md)).
2. Read Figma (if a file exists).
3. Product brief: impeccable `init` or brief questions (who, problem, essential screens, name).
4. Style discovery using the brief, and confirmation ([style-discovery.md](style-discovery.md)).
5. Discovery and direction within the style: impeccable `shape` and new-work, or the checklist.
6. Proposals as Claude Design artifacts; the user picks ([proposals.md](proposals.md)).
7. `critique` on the chosen direction (or the built-in checklist).
8. Figma: file name asked on its own and confirmed → file → foundations → components → screens.
9. `critique` fixes and `polish` (mandatory), applied in Figma.
10. Sync local files ([sync-rules.md](sync-rules.md)). Later change requests: [iteration.md](iteration.md).

## Builder guidance

Every Figma builder, including delegated subagents, receives in its prompt:

- **impeccable present:** impeccable's `reference/craft-floor.md`, `reference/layout.md`, `reference/typeset.md` and the platform reference (for example `reference/ios.md`), plus `PRODUCT.md`, `DESIGN.md` and the chosen direction. Pass the content or tell the builder to read them; do not copy impeccable files into this skill.
- **impeccable absent:** [minimal-system-checklist.md](minimal-system-checklist.md) and [quality-bar.md](quality-bar.md), plus `PRODUCT.md`, `DESIGN.md` and the chosen direction.
- Before writing text styles, the builder checks font availability ([figma-structure.md](figma-structure.md)).

## Do not use X for Y

- Do not use Claude Design output as the record of decisions. Figma is the record.
- Do not use claude.ai/design projects for anything (closing 2026-12-14). Claude Design now lives in Claude as artifacts. Never call the `DesignSync` tool.
- Do not call `use_figma` without loading `figma-use`. Do not build components without `figma-generate-library`, or screens without `figma-generate-design`.
- Do not use impeccable for Figma writes; it has no Figma access. Do not use the Figma tools for product discovery.
- Do not use `figma-generate-diagram` or FigJam skills for UI design.
- Do not generate application code, and do not call `get_design_context` (design-to-code belongs to a future companion skill; it requires `figma-design-to-code`).
- Do not use impeccable's `live` or code-oriented commands; there is no frontend codebase here.
