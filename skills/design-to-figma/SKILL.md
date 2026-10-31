---
name: design-to-figma
description: "MANDATORY first step to design or change any app, module, flow or screen in Figma, in any language. Load BEFORE reading attachments, figma-use, figma-generate-design or any Figma tool."
license: MIT
metadata:
  version: "0.4.1"
  author: "Uriel Escorcia"
---

# design-to-figma

Orchestrator for design work that must end up in Figma. It decides which tool runs when, keeps Figma and the local context files consistent, and never builds code (design only).

## Activation Contract

Load this skill first: before reading attachments, and before `figma-use`, `figma-generate-design`, `figma-generate-library` or any Figma tool, whenever the user wants to:

- design a full project (brief, design system, screens) and have it live in Figma, including a product built module by module or flow by flow;
- design a single screen or view that must live in Figma;
- iterate on, extend or review an existing Figma design, including after someone edited it by hand.

The request may be in any language and may come with attachments (product PDFs, a brief, a reference image) or with decisions already made (palette, typography). Those do not replace this skill; they feed its brief and style gates. Example: "Vamos a crear el diseño en figma de un sistema de facturación mexicano… módulo tras módulo… ya elegimos la paleta y la tipografía".

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
10. **Aim for excellent, current design.** Research real category products and confirm them with the user, then confirm a style and a palette ([style-discovery.md](references/style-discovery.md)), show proposals before building, and verify every screen against the quality gate ([quality-bar.md](references/quality-bar.md)). No skeuomorphism or literal metaphors unless the user asks.
11. **Never write absolute local paths, usernames or machine details into Figma.**
12. **Enumerate Figma pages with a read-only `use_figma` script.** An unscoped `get_metadata` lists only the first page.
13. **Reply in the user's language.** Prose, questions, reports and progress updates alike (including the lines written right after you dispatch a subagent or receive its result; subagent prompts and results are often English), never mixed. Generated documentation (`PRODUCT.md`, `DESIGN.md`, the plan, specs) stays in English unless the user asks otherwise. Figma page, frame, layer, variable, style and component names and the Brief page follow that documentation rule. It never covers the product's UI copy: text shown in the product (proposals, Figma screens, component text) uses the UI language and locale from the brief.
14. **Builders follow the craft guides.** Every Figma builder, including delegated subagents, receives impeccable's craft guidance or the fallback checklist ([tool-directory.md](references/tool-directory.md)).
15. **Track the plan.** In project mode create `DESIGN-PLAN.md` ([DESIGN-PLAN.template.md](assets/DESIGN-PLAN.template.md)) once the screen list is agreed, update it after every state change, and read it first on resume to continue with the next unfinished item. Every screen runs [screen-loop.md](references/screen-loop.md); never start the next screen before the user approves the current one, unless the user says to batch.
16. **Ask before spending the user's credits.** Before any generation that uses the user's plan credits (for example Figma AI images), say what it costs and ask; without a yes, use placeholders.
17. **Route every request first** ([routing.md](references/routing.md)). A read-only request writes nothing. A small change to existing work runs inline through [iteration.md](references/iteration.md). New screens and projects take the full flow unchanged. A high-risk change (shared tokens, shared components, deletion, brand foundations, app-wide rules) is applied only after the user confirms its measured reach.

## Decision Gates

| Question | Condition | Action |
|---|---|---|
| Route | Every request | Route it first: read-only, small or large, plus the high-risk check ([routing.md](references/routing.md)). The rows below serve the large route |
| Mode | Many screens, or a design system is needed | Project mode: [workflow-project.md](references/workflow-project.md) |
| Mode | One screen or view | Screen mode: [workflow-screen.md](references/workflow-screen.md) |
| Mode | Unclear | Ask one question: full project or one screen? |
| Existing project | Figma file URL or `PRODUCT.md`/`DESIGN.md` with a Figma header found | Read it; reuse the system; this is an iteration |
| Existing project | None found (screen mode) | Minimal bootstrap inside the screen flow |
| Brief | No `PRODUCT.md` brief yet | Interview first (who, problem, essential screens, name, UI language and locale), before style discovery |
| Locale | `PRODUCT.md` exists without a UI locale | Ask the UI language and locale once and record it before any UI copy is written |
| Category | No confirmed category references recorded | Research real products of the brief's category first (at least 3, with sources; with no research tool, an unverified list plus a request for the user's references), list them and wait for the user: [style-discovery.md](references/style-discovery.md) |
| Style | No confirmed style recorded | Run style discovery after the category references, building on them: [style-discovery.md](references/style-discovery.md) |
| Style | Style recorded in `DESIGN.md` / Brief page | Reuse it as a constraint; say so in one line |
| Palette | No confirmed palette | Show it as swatches and get explicit confirmation before any direction is generated |
| Web research | Web tool available (Code: WebSearch/WebFetch; Desktop: web search) | Research current references; otherwise label them unverified |
| Proposals | Design surface available | Show 2 or 3 directions as Claude Design artifacts: [proposals.md](references/proposals.md) |
| Proposals | No design surface | Quick frames on a `🧪 Explorations` page in Figma |
| File name | New Figma file | Ask the file name as its own question, right before the file is created (suggest `<Product> — <Scope>`), never folded into another question; only then ask which team or plan when there are several |
| Dark mode | A project or screen is created | Ask whether dark mode is needed; never assume it. If not requested, `Semantic` is a single-mode collection (Dark can be added later as a new mode); if requested up front, `Semantic` gets Light and Dark modes in foundations and Dark frames are built only after each Light screen is user-approved ([figma-structure.md](references/figma-structure.md)). Record the answer in `PRODUCT.md` and the plan |
| Change request | User asks to change a built design | Apply in Figma, then sync: [iteration.md](references/iteration.md) |
| impeccable | Its skill is available | Use it for every design step (context, shape, direction, extraction); `critique` and `polish` are mandatory, and builders get its craft guides |
| impeccable | Not available | Ask as its own question: install it first (steps per surface) or continue with [minimal-system-checklist.md](references/minimal-system-checklist.md) and the critique checklist in [quality-bar.md](references/quality-bar.md) ([preflight.md](references/preflight.md)) |
| Write path | Claude Code project folder, or any connected local folder (Cowork, or the unified Claude experience on desktop) | Write there after confirming the path |
| Write path | No writable folder (web, mobile, desktop app closed, older chat) or detection fails | Deliver files as downloads |
| Design surface | Claude Code, or desktop/web Claude | Artifact Design type (`/design` in Code), or Output → Design |
| Design System artifact | Artifact tool and the "Design System" type available, and the user agreed | Keep it synced one-way from Figma: [design-system-artifact.md](references/design-system-artifact.md) |
| Design System artifact | No Artifact tool, no "Design System" type, or creating the artifact fails | Skip it and say so once; the Figma file and local files stay complete |
| Both sides changed | Figma and local files differ | Figma wins for design data; ask before dropping local prose |

Per-surface details and the capability-based write path: [preflight.md](references/preflight.md).

## Gate sequence

This sequence is the large route ([routing.md](references/routing.md)); the small route follows [iteration.md](references/iteration.md) and keeps the Hard Rules. One gate per turn: ask it, wait for the answer, record it, then move to the next. Never bundle two gates into one message or one multi-question form, even when the surface offers a form tool; the brief's own questions are one gate. Before each step, read the reference it names; this list is a checkpoint, not a replacement for the reference. Steps 7 and 8 are project mode; screen mode follows [workflow-screen.md](references/workflow-screen.md) and keeps the other steps.

0. **Preflight report** ([preflight.md](references/preflight.md)) as its own message: confirm the write path. Then, only when impeccable is missing, ask install or continue as its own question.
1. **Brief** ([workflow-project.md](references/workflow-project.md) or [workflow-screen.md](references/workflow-screen.md)): users, problem, essential screens, name, UI locale, dark mode → `PRODUCT.md`. Then, in both modes, the Design System artifact opt-in as its own question → `PRODUCT.md`.
2. **Category references**: list them with sources and wait ([style-discovery.md](references/style-discovery.md)).
3. **Style**: ask it; never propose one in place of asking. Wait.
4. **Palette**: swatches only after the style is confirmed. Wait.
5. **Direction**: 2 or 3 proposals; the user picks. Run the critique and show the critique and its fixes before building in Figma (an `🧪 Explorations` fallback page is not a build).
6. **File name**: ask it alone, right before the file is created; only then the team or plan, when there are several.
7. **Foundations and components**, with the Brief page filled; the user approves; write `DESIGN.md` now with the `Foundations: approved` line.
8. **Screen list** → `DESIGN-PLAN.md`.
9. **Each screen**: the user review message has every field in [screen-loop.md](references/screen-loop.md) step 6; one screen per review unless the user said to batch.
10. **Close**: build the snapshot from the read-only enumeration output ([sync-rules.md](references/sync-rules.md)) and check that every required page is not empty, the Brief page included, and that the Brief page text matches the current scope (screens and states added since it was written), before the report.

## Execution Steps

0. **Route** the request ([routing.md](references/routing.md)). Read-only requests run preflight and read Figma (step 2), then answer and stop without writing. Small changes run preflight and step 2, then [iteration.md](references/iteration.md), which applies, syncs and ends with the report. Large work continues below.
1. **Preflight.** Follow [preflight.md](references/preflight.md): Figma MCP tools, seat requirement, impeccable, design-capable surface, local write path. BLOCK on missing Figma tools.
2. **Load or create the project context.**
   - Look for `PRODUCT.md` / `DESIGN.md` / `DESIGN-PLAN.md` in the confirmed folder, and for a Figma URL in the user's message.
   - If a Figma file exists, read it: enumerate pages with a read-only `use_figma` script, read each page with `get_metadata(nodeId=pageId)`, read variables and styles by script or `get_variable_defs`, take `get_screenshot` of key frames. Then compare with the sync frontmatter and snapshot ([sync-rules.md](references/sync-rules.md)). If `DESIGN-PLAN.md` exists, read it first and resume at the next unfinished item.
   - If none exists, continue with step 3. Templates: [PRODUCT.template.md](assets/PRODUCT.template.md), [DESIGN.template.md](assets/DESIGN.template.md), [DESIGN-PLAN.template.md](assets/DESIGN-PLAN.template.md).
3. **Product brief.** Interview the user before any style work: who the users are, the problem, the essential screens, the product name, the UI language and locale (for example Spanish, Mexico: dates, currency, number formats) and whether dark mode is needed (ask; never assume) (impeccable `init`, or the questions in [minimal-system-checklist.md](references/minimal-system-checklist.md)). Wait for the answers; write `PRODUCT.md`.
4. **Style discovery.** Using the brief, first research real products of the same category and get the user's confirmation of that list (category gate); then ask the style, research current references, present them with traits, get confirmation, and get the palette confirmed as swatches ([style-discovery.md](references/style-discovery.md)).
5. **Direction and proposals.** In screen mode, define the screen first (step 1 of [screen-loop.md](references/screen-loop.md)), so the proposals show the agreed screen. Direction within the style (impeccable, or the checklist), then 2 or 3 directions that share the confirmed palette as Claude Design artifacts; the user picks ([proposals.md](references/proposals.md)). Critique the chosen direction ([quality-bar.md](references/quality-bar.md)).
6. **Run the mode flow.** Project: [workflow-project.md](references/workflow-project.md). Screen: [workflow-screen.md](references/workflow-screen.md). Tool choice at each step: [tool-directory.md](references/tool-directory.md).
7. **Write to Figma.** Ask the file name as its own question first (before the team or plan question), then check fonts ([figma-structure.md](references/figma-structure.md)). Follow the page structure in [figma-structure.md](references/figma-structure.md); place the Brief page from [brief-page.template.md](assets/brief-page.template.md). Use `figma-create-new-file` for a new file, then `figma-use` with `figma-generate-library` / `figma-generate-design`. Validate with `get_screenshot` and structural reads. Build only the chosen direction, with the builder guidance from [tool-directory.md](references/tool-directory.md).
8. **Screen loop.** Every screen (project: each one in turn; screen mode: the single screen, already defined in step 5) runs define, build, agent verify (`critique`), self-fix, `polish`, elevate, user review, final verify ([screen-loop.md](references/screen-loop.md)); critique and polish are mandatory for every screen. Done only when the quality gate passes, otherwise report the gap and offer another round ([quality-bar.md](references/quality-bar.md)). Project mode ends with a cross-screen critique.
9. **Sync the local files.** Update `PRODUCT.md` / `DESIGN.md` from Figma, refresh the frontmatter and snapshot, and re-sync the Design System artifact when kept ([design-system-artifact.md](references/design-system-artifact.md)). Handle local-only edits per [sync-rules.md](references/sync-rules.md).
10. **Iterate on request.** Natural-language changes are applied in Figma, then synced ([iteration.md](references/iteration.md)).
11. **Report** using the Output Contract.

## Output Contract

End every run with a short report containing:

- **Route and risk:** the route taken (read-only, small, screen or project) and `Risk: none` or `Risk: item N (reason), confirmed by the user` ([routing.md](references/routing.md)). A read-only or small run reports only the fields it touched.
- **Figma link:** the file URL (and frame links for screens touched) and the file name used.
- **Style and references:** the confirmed category references, style, reference products, palette and whether the references were researched or unverified.
- **Proposals:** the directions shown, where, and which one was chosen.
- **Plan and screen states:** the `DESIGN-PLAN.md` location (or "delivered as downloads") and each screen's state (`pending`, `built`, `agent-verified`, `user-approved`, `final-verified`), plus whether dark mode was requested and built.
- **Quality passes:** `critique` and `polish` done (impeccable, or the built-in checklist), with the fixes applied, the heuristics score, the specificity verdict and whether the critique was degraded. Never report a design as done without them or below the gate.
- **What changed:** pages, variables, styles, components and screens created, updated or left untouched; manual Figma edits that were detected and kept.
- **Sync status:** local files written (path, or "delivered as downloads"), the `.impeccable/` folder when impeccable created it (part of the shareable project folder), last-sync timestamp (local files only), and that the updated `DESIGN.md` is available as design-system context.
- **Design System artifact:** its link and last sync, or "skipped: reason".
- **Pending conflicts:** each local-only change awaiting "push to Figma" or "discard", and any item where both sides changed. Write "none" when clear.
- **Warnings:** impeccable absent (fallback used), seat limit risk, skipped steps.

## References

- [routing.md](references/routing.md): authorize, size and route every request; design high-risk items and their confirmation
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
