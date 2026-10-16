---
name: design-to-figma
description: "Design a full project or one screen in Figma, or iterate on an existing Figma design. Orchestrates Claude Design, impeccable (optional) and the Figma MCP; Figma stays the source of truth."
metadata:
  version: "0.1.0"
  author: "Uriel Escorcia"
---

# design-to-figma

Orchestrator for design work that must end up in Figma. It decides which tool runs when, keeps Figma, the local context files and Claude's design-system context consistent, and never builds code (design only).

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
6. **Never target claude.ai/design projects.** They close on 2026-12-14. Use Claude's built-in design capability and the design system Claude uses.
7. **Ask before the first local write.** Confirm the target path once; fall back to downloadable files when unsure.
8. **Design only.** Produce no application code.
9. **Do not copy or bundle impeccable or the Figma MCP.** Only call them.

## Decision Gates

| Question | Condition | Action |
|---|---|---|
| Mode | Many screens, or a design system is needed | Project mode: [workflow-project.md](references/workflow-project.md) |
| Mode | One screen or view | Screen mode: [workflow-screen.md](references/workflow-screen.md) |
| Mode | Unclear | Ask one question: full project or one screen? |
| Existing project | Figma file URL or `PRODUCT.md`/`DESIGN.md` with a Figma header found | Read it; reuse the system; this is an iteration |
| Existing project | None found (screen mode) | Minimal bootstrap inside the screen flow |
| impeccable | Its skill is available | Use it for context, discovery, direction, extraction, critique, polish |
| impeccable | Not available | Recommend it once, continue with [minimal-system-checklist.md](references/minimal-system-checklist.md) |
| Surface | Claude Code | Local write to the project folder; `/design` and `/design-sync` available |
| Surface | Claude Desktop with a connected folder (Cowork) | Local write to that folder |
| Surface | Claude Desktop chat, or detection fails | Deliver files as downloads; describe design-system sync steps in text |
| Both sides changed | Figma and local files differ | Figma wins for design data; ask before dropping local prose |

Per-surface details and the write-path ladder: [preflight.md](references/preflight.md).

## Execution Steps

1. **Preflight.** Follow [preflight.md](references/preflight.md): Figma MCP tools, seat requirement, impeccable, design-capable surface, local write path. BLOCK on missing Figma tools.
2. **Load or create the project context.**
   - Look for `PRODUCT.md` / `DESIGN.md` in the confirmed folder, and for a Figma URL in the user's message.
   - If a Figma file exists, read it (`get_metadata`, `get_variable_defs`; `get_design_context` for specific frames) and compare it with the sync header and snapshot ([sync-rules.md](references/sync-rules.md)).
   - If none exists, create it in the mode flow below. Templates: [PRODUCT.template.md](assets/PRODUCT.template.md), [DESIGN.template.md](assets/DESIGN.template.md).
3. **Run the mode flow.** Project: [workflow-project.md](references/workflow-project.md). Screen: [workflow-screen.md](references/workflow-screen.md). Tool choice at each step: [tool-directory.md](references/tool-directory.md).
4. **Write to Figma.** Follow the page structure in [figma-structure.md](references/figma-structure.md); place the Brief page from [brief-page.template.md](assets/brief-page.template.md). Use `figma-create-new-file` for a new file, then `figma-use` with `figma-generate-library` / `figma-generate-design`. Validate with `get_screenshot` and structural reads.
5. **Sync the local files.** Update `PRODUCT.md` / `DESIGN.md` from Figma, refresh the header and snapshot, then update Claude's design-system context (`/design-sync` in Claude Code; instructions on other surfaces). Handle local-only edits per [sync-rules.md](references/sync-rules.md).
6. **Report** using the Output Contract.

## Output Contract

End every run with a short report containing:

- **Figma link:** the file URL (and frame links for screens touched).
- **What changed:** pages, variables, styles, components and screens created, updated or left untouched; manual Figma edits that were detected and kept.
- **Sync status:** local files written (path, or "delivered as downloads"), last-sync timestamp, whether Claude's design-system context was updated or what the user must do.
- **Pending conflicts:** each local-only change awaiting "push to Figma" or "discard", and any item where both sides changed. Write "none" when clear.
- **Warnings:** impeccable absent (fallback used), seat limit risk, skipped steps.

## References

- [preflight.md](references/preflight.md): capability checks, install guidance, write-path ladder
- [tool-directory.md](references/tool-directory.md): when to use each tool, handoff order
- [workflow-project.md](references/workflow-project.md): full-project flow
- [workflow-screen.md](references/workflow-screen.md): single-screen flow and minimal bootstrap
- [sync-rules.md](references/sync-rules.md): source of truth, diffs, conflicts, snapshot
- [figma-structure.md](references/figma-structure.md): pages, naming, Brief page content
- [minimal-system-checklist.md](references/minimal-system-checklist.md): fallback without impeccable
- [PRODUCT.template.md](assets/PRODUCT.template.md), [DESIGN.template.md](assets/DESIGN.template.md), [brief-page.template.md](assets/brief-page.template.md): file templates
