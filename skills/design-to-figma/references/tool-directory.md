# Tool directory

Which tool to use for which job. Reference the named skills and tools; do not copy their instructions.

## When to use what

| Job | Tool | Notes |
|---|---|---|
| Explore, compose and preview screens quickly | Claude Design (Claude Code `/design`; chat Output → Design) | Uses the design system Claude has loaded; good for options and previews before committing to Figma |
| Use the design system in future design chats | Claude's design-system context (`/design-sync` in Claude Code) | Sync from Figma-derived `DESIGN.md`; other surfaces: describe the steps |
| Product context (users, purpose, principles) | impeccable `init` → `PRODUCT.md` | Fallback: brief questions in [minimal-system-checklist.md](minimal-system-checklist.md) |
| Discovery of a feature or screen | impeccable `shape` | Produces a design brief before visuals |
| Visual direction for a new surface or a replacement look | impeccable new-work flow (an ordinary design request when PRODUCT.md exists; `craft` is a deprecated alias) | Not a separate sub-command |
| Record an existing look as `DESIGN.md` | impeccable `document` | When a visual system already exists in code |
| Pull tokens and components into a system | impeccable `extract` | Use before building the Figma library |
| Review a result | impeccable `critique` (UX) and `audit` (accessibility, responsive) | Findings feed the next Figma edit |
| Final refinement pass | impeccable `polish` | Run on the design direction, then apply to Figma |
| Create the Figma file | `figma-create-new-file` → `create_new_file` | Resolve plan first (`whoami`) |
| Variables, styles, components (foundations) | `figma-generate-library` + `figma-use` → `use_figma` | Build in the order that skill defines |
| Screens and composed views | `figma-generate-design` + `figma-use` → `use_figma` | Reuse library components and variables |
| Read current Figma state | `get_metadata`, `get_variable_defs`, `get_design_context`, `get_screenshot`; `search_design_system` for components | Read-only; do this before every design step |

## Handoff order

1. Preflight ([preflight.md](preflight.md)).
2. Read Figma (if a file exists).
3. Context: impeccable `init` or brief questions.
4. Discovery and direction: impeccable `shape` and new-work, or the checklist.
5. Optional preview in Claude Design.
6. Figma: file → foundations → components → screens.
7. Optional: impeccable `critique` / `audit` / `polish`, then apply fixes in Figma.
8. Sync local files and Claude's design-system context ([sync-rules.md](sync-rules.md)).

## Do not use X for Y

- Do not use Claude Design output as the record of decisions. Figma is the record.
- Do not use claude.ai/design projects for anything (closing 2026-12-14).
- Do not call `use_figma` without loading `figma-use`. Do not build components without `figma-generate-library`, or screens without `figma-generate-design`.
- Do not use impeccable for Figma writes; it has no Figma access. Do not use the Figma tools for product discovery.
- Do not use `figma-generate-diagram` or FigJam skills for UI design.
- Do not generate application code, and do not use `get_design_context` to produce code in this skill (design-to-code belongs to a future companion skill).
- Do not use impeccable's `live` or code-oriented commands; there is no frontend codebase here.
