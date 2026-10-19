---
name: design-to-figma
description: "Design a full project or one screen in Figma, or iterate on an existing Figma design. Orchestrates Claude Design, impeccable (optional) and the Figma MCP; Figma stays the source of truth."
license: MIT
metadata:
  version: "0.2.0"
  author: "Uriel Escorcia"
---

# design-to-figma

Orchestrator for design work that must end up in Figma. It decides which tool runs when, keeps Figma and the local context files consistent, and never builds code (design only).

## Activation Contract

Load this skill when the user wants to:

- design a full project (brief, design system, screens) and have it live in Figma;
- design a single screen or view that must live in Figma;
- iterate on, extend or review an existing Figma design, including after someone edited it by hand.

Do not load it for code generation from Figma (a future companion skill), for FigJam diagrams, or for design work that has no Figma destination.

## Hard Rules

1. **Figma is the source of truth.** Local `PRODUCT.md` / `DESIGN.md` mirror Figma; they never outrank it for design data.
2. **Read Figma before every design step.** Fetch the current state first so manual edits are understood and iterated on (see [sync-rules.md](references/sync-rules.md)).
3. **Never silently overwrite.** Local changes absent from Figma are shown as a diff and the user chooses "push to Figma" or "discard". Never delete or replace Figma content the user did not ask to change.
4. **Load `figma-use` before every `use_figma` call.** Also load `figma-generate-design` for screens and `figma-generate-library` for variables, styles and components. Load `figma-create-new-file` before `create_new_file`. Reference these skills; do not restate their content.
5. **Run preflight first.** If the Figma MCP tools are missing, stop and give install guidance. Do not simulate Figma output.
6. **Never target claude.ai/design projects.** They close on 2026-12-14. Claude Design now lives in Claude as artifacts (designs, design systems, decks); use that. Never call the `DesignSync` tool.
7. **Ask before the first local write.** Confirm the target path once; fall back to downloadable files when unsure.
8. **Design only.** Produce no application code.
9. **Do not copy or bundle impeccable or the Figma MCP.** Only call them.
10. **Aim for excellent, current design.** Confirm a style first ([style-discovery.md](references/style-discovery.md)), show proposals before building, and verify every screen against the quality gate ([quality-bar.md](references/quality-bar.md)). No skeuomorphism or literal metaphors unless the user asks.
11. **Never write absolute local paths, usernames or machine details into Figma.**
12. **Enumerate Figma pages with a read-only `use_figma` script.** An unscoped `get_metadata` lists only the first page.
13. **Reply in the user's language.** Prose, questions and reports alike, never mixed. Generated files (`PRODUCT.md`, `DESIGN.md`, Figma content labels, specs) stay in English unless the user asks otherwise.
14. **Builders follow the craft guides.** Every Figma builder, including delegated subagents, receives impeccable's craft guidance or the fallback checklist ([tool-directory.md](references/tool-directory.md)).
15. **Track the plan.** In project mode create `DESIGN-PLAN.md` ([DESIGN-PLAN.template.md](assets/DESIGN-PLAN.template.md)) once the screen list is agreed, update it after every state change, and read it first on resume to continue with the next unfinished item. Every screen runs [screen-loop.md](references/screen-loop.md); never start the next screen before the user approves the current one, unless the user says to batch.

## Decision Gates

| Question | Condition | Action |
|---|---|---|
| Mode | Many screens, or a design system is needed | Project mode: [workflow-project.md](references/workflow-project.md) |
| Mode | One screen or view | Screen mode: [workflow-screen.md](references/workflow-screen.md) |
| Mode | Unclear | Ask one question: full project or one screen? |
| Existing project | Figma file URL or `PRODUCT.md`/`DESIGN.md` with a Figma header found | Read it; reuse the system; this is an iteration |
| Existing project | None found (screen mode) | Minimal bootstrap inside the screen flow |
| Brief | No `PRODUCT.md` brief yet | Interview first (who, problem, essential screens, name), before style discovery |
| Style | No confirmed style recorded | Run style discovery after the brief, using it: [style-discovery.md](references/style-discovery.md) |
| Style | Style recorded in `DESIGN.md` / Brief page | Reuse it as a constraint; say so in one line |
| Web research | Web tool available (Code: WebSearch/WebFetch; Desktop: web search) | Research current references; otherwise label them unverified |
| Proposals | Design surface available | Show 2 or 3 directions as Claude Design artifacts: [proposals.md](references/proposals.md) |
| Proposals | No design surface | Quick frames on a `🧪 Explorations` page in Figma |
| File name | New Figma file | Ask the file name as its own question (suggest `<Product> — <Scope>`), never folded into another question; only then ask which team or plan when there are several |
| Dark mode | A project or screen is created | Ask whether dark mode is needed; never assume it. If not requested, `Semantic` is a single-mode collection (Dark can be added later as a new mode); if requested up front, `Semantic` gets Light and Dark modes in foundations and Dark frames are built only after each Light screen is user-approved ([figma-structure.md](references/figma-structure.md)). Record the answer in `PRODUCT.md` and the plan |
| Change request | User asks to change a built design | Apply in Figma, then sync: [iteration.md](references/iteration.md) |
| impeccable | Its skill is available | Use it for every design step (context, shape, direction, extraction); `critique` and `polish` are mandatory, and builders get its craft guides |
| impeccable | Not available | Recommend it once, continue with [minimal-system-checklist.md](references/minimal-system-checklist.md) and the critique checklist in [quality-bar.md](references/quality-bar.md) |
| Write path | Claude Code project folder, or any connected local folder (Cowork, or the unified Claude experience on desktop) | Write there after confirming the path |
| Write path | No writable folder (web, mobile, desktop app closed, older chat) or detection fails | Deliver files as downloads |
| Design surface | Claude Code, or desktop/web Claude | Artifact Design type (`/design` in Code), or Output → Design |
| Design System artifact | Artifact tool and the "Design System" type available, and the user agreed | Keep it synced one-way from Figma: [design-system-artifact.md](references/design-system-artifact.md) |
| Design System artifact | Tool, type or publishing surface unavailable | Skip it and say so once; the Figma file and local files stay complete |
| Both sides changed | Figma and local files differ | Figma wins for design data; ask before dropping local prose |

Per-surface details and the capability-based write path: [preflight.md](references/preflight.md).

## Execution Steps

1. **Preflight.** Follow [preflight.md](references/preflight.md): Figma MCP tools, seat requirement, impeccable, design-capable surface, local write path. BLOCK on missing Figma tools.
2. **Load or create the project context.**
   - Look for `PRODUCT.md` / `DESIGN.md` / `DESIGN-PLAN.md` in the confirmed folder, and for a Figma URL in the user's message.
   - If a Figma file exists, read it: enumerate pages with a read-only `use_figma` script, read each page with `get_metadata(nodeId=pageId)`, read variables and styles by script or `get_variable_defs`, take `get_screenshot` of key frames. Then compare with the sync frontmatter and snapshot ([sync-rules.md](references/sync-rules.md)). If `DESIGN-PLAN.md` exists, read it first and resume at the next unfinished item.
   - If none exists, continue with step 3. Templates: [PRODUCT.template.md](assets/PRODUCT.template.md), [DESIGN.template.md](assets/DESIGN.template.md), [DESIGN-PLAN.template.md](assets/DESIGN-PLAN.template.md).
3. **Product brief.** Interview the user before any style work: who the users are, the problem, the essential screens, the product name and whether dark mode is needed (ask; never assume) (impeccable `init`, or the questions in [minimal-system-checklist.md](references/minimal-system-checklist.md)). Wait for the answers; write `PRODUCT.md`.
4. **Style discovery.** Using the brief, ask the style, research current references, present them with traits, get confirmation ([style-discovery.md](references/style-discovery.md)).
5. **Direction and proposals.** Direction within the style (impeccable, or the checklist), then 2 or 3 directions as Claude Design artifacts; the user picks ([proposals.md](references/proposals.md)). Critique the chosen direction ([quality-bar.md](references/quality-bar.md)).
6. **Run the mode flow.** Project: [workflow-project.md](references/workflow-project.md). Screen: [workflow-screen.md](references/workflow-screen.md). Tool choice at each step: [tool-directory.md](references/tool-directory.md).
7. **Write to Figma.** Ask the file name as its own question first (before the team or plan question), then check fonts ([figma-structure.md](references/figma-structure.md)). Follow the page structure in [figma-structure.md](references/figma-structure.md); place the Brief page from [brief-page.template.md](assets/brief-page.template.md). Use `figma-create-new-file` for a new file, then `figma-use` with `figma-generate-library` / `figma-generate-design`. Validate with `get_screenshot` and structural reads. Build only the chosen direction, with the builder guidance from [tool-directory.md](references/tool-directory.md).
8. **Screen loop.** Every screen (project: each one in turn; screen mode: the single screen) runs define, build, agent verify (`critique`), self-fix, `polish`, user review, final verify ([screen-loop.md](references/screen-loop.md)); critique and polish are mandatory for every screen. Done only when the quality gate passes, otherwise report the gap and offer another round ([quality-bar.md](references/quality-bar.md)). Project mode ends with a cross-screen critique.
9. **Sync the local files.** Update `PRODUCT.md` / `DESIGN.md` from Figma, refresh the frontmatter and snapshot, and re-sync the Design System artifact when kept ([design-system-artifact.md](references/design-system-artifact.md)). Handle local-only edits per [sync-rules.md](references/sync-rules.md).
10. **Iterate on request.** Natural-language changes are applied in Figma, then synced ([iteration.md](references/iteration.md)).
11. **Report** using the Output Contract.

## Output Contract

End every run with a short report containing:

- **Figma link:** the file URL (and frame links for screens touched) and the file name used.
- **Style and references:** the confirmed style, reference products and whether the references were researched or unverified.
- **Proposals:** the directions shown, where, and which one was chosen.
- **Plan and screen states:** the `DESIGN-PLAN.md` location (or "delivered as downloads") and each screen's state (`pending`, `built`, `agent-verified`, `user-approved`, `final-verified`), plus whether dark mode was requested and built.
- **Quality passes:** `critique` and `polish` done (impeccable, or the built-in checklist), with the fixes applied, the heuristics score, the specificity verdict and whether the critique was degraded. Never report a design as done without them or below the gate.
- **What changed:** pages, variables, styles, components and screens created, updated or left untouched; manual Figma edits that were detected and kept.
- **Sync status:** local files written (path, or "delivered as downloads"), the `.impeccable/` folder when impeccable created it (part of the shareable project folder), last-sync timestamp (local files only), and that the updated `DESIGN.md` is available as design-system context.
- **Design System artifact:** its link and last sync, or "skipped: reason".
- **Pending conflicts:** each local-only change awaiting "push to Figma" or "discard", and any item where both sides changed. Write "none" when clear.
- **Warnings:** impeccable absent (fallback used), seat limit risk, skipped steps.

## References

- [preflight.md](references/preflight.md): capability checks, install guidance, write-path ladder
- [tool-directory.md](references/tool-directory.md): when to use each tool, handoff order
- [workflow-project.md](references/workflow-project.md): full-project flow
- [workflow-screen.md](references/workflow-screen.md): single-screen flow and minimal bootstrap
- [screen-loop.md](references/screen-loop.md): per-screen define, build, verify, review loop
- [style-discovery.md](references/style-discovery.md): ask the style, research references, confirm traits
- [proposals.md](references/proposals.md): 2 or 3 directions as Claude Design artifacts
- [quality-bar.md](references/quality-bar.md): quality rules, impeccable wiring, built-in critique checklist
- [iteration.md](references/iteration.md): natural-language change requests applied in Figma
- [sync-rules.md](references/sync-rules.md): source of truth, diffs, conflicts, snapshot
- [design-system-artifact.md](references/design-system-artifact.md): one-way sync to a Claude Design System artifact
- [figma-structure.md](references/figma-structure.md): pages, naming, Brief page content
- [minimal-system-checklist.md](references/minimal-system-checklist.md): fallback without impeccable
- [PRODUCT.template.md](assets/PRODUCT.template.md), [DESIGN.template.md](assets/DESIGN.template.md), [brief-page.template.md](assets/brief-page.template.md), [DESIGN-PLAN.template.md](assets/DESIGN-PLAN.template.md): file templates
