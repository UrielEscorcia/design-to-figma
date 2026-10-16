# Feature: design-to-figma plugin

- **Engram mirror:** `odd/design-to-figma/tasks`
- **Branch:** `feat/design-to-figma-plugin`
- **Status:** T3/T4 done; T5 (Claude Code trial) next, T6a pending from the user

## Objective

Build a Claude plugin with one orchestrator skill, `design-to-figma`. It must work the same way in Claude Code and Claude Desktop. The skill drives Claude Design, the impeccable skill (optional) and the official Figma MCP. Every design decision lands in a Figma file, and Figma is the source of truth.

## Problem

Designing with Claude Design and impeccable leaves the result scattered across artifacts, local files and chat history. The team needs one durable, shareable design record (Figma) and a repeatable flow that:

- defines the design system;
- designs a full project or a single screen;
- keeps iterating after people edit Figma by hand.

## Why a skill (not a connector)

Figma already ships an official remote MCP server (`mcp.figma.com/mcp`) and a Claude plugin with skills. A new connector would duplicate them. The missing piece is the rules: which tool to use when, in what order, and how to keep Figma, Claude Design and local files consistent.

## Decisions (accepted 2026-10-14/15)

| # | Topic | Decision |
|---|---|---|
| D1 | Nature | Orchestrator skill with a tool directory: when to use Claude Design, impeccable or the Figma MCP. |
| D2 | Preflight | Before running, check which tools are available. Figma MCP tools missing (`use_figma`, `get_design_context`, `get_variable_defs`): stop and explain how to install. Claude Design is built into Claude (chat Output → Design, Artifacts, `/design` in Code), so check for a design-capable surface, not an install. impeccable missing: recommend it and continue with the built-in fallback. impeccable present: use it. *(Revised after T1.)* |
| D3 | Source of truth | Figma. Read the current Figma state before every design step so manual edits are understood and iterated on. |
| D4 | v1 scope | Design only. The flow ends at a complete Figma file. Design-to-code is a future companion skill in the same plugin. |
| D5 | Context storage | Two places: (a) a `📋 Brief & Rules` page in Figma; (b) local `PRODUCT.md` / `DESIGN.md` in the folder where the flow starts, carrying the Figma link. The folder is shareable. **Write path (capability ladder, revised 2026-10-16):** (1) `CLAUDECODE=1` → write to the project folder; (2) a user-connected folder is mounted (Cowork) → write there, asking which one if there are several; (3) otherwise → deliver as downloadable files. Confirm the target path once before the first write. A failed detection falls back to downloads, never to an unconfirmed write. |
| D6 | Sync rule | Figma → local `.md` is automatic. Figma → the design system Claude uses is automatic (`/design-sync` in Code; never claude.ai/design projects, which close on 2026-12-14). Local `.md` → Figma: show the diff and ask the user to push or discard; never overwrite silently. Each `.md` has a header with the Figma URL and the last-sync timestamp. |
| D7 | Modes | Full project, or single screen. Single screen with no existing project bootstraps a minimal system: short brief, base tokens, only the components that screen needs. It can grow into a full project later. |
| D8 | Minimal bootstrap | Delegate to impeccable (`init` → PRODUCT.md, `new-work`, `extract`) when present; otherwise use the skill's own short checklist. Local file names match impeccable (`PRODUCT.md`, `DESIGN.md`). impeccable cannot be uploaded to Desktop as-is, so the fallback is mandatory there. |
| D9 | Packaging | Claude plugin: `.claude-plugin/plugin.json` plus `skills/design-to-figma/`, GitHub marketplace for Code, zip upload for Desktop. Does NOT bundle the Figma MCP. |
| D10 | Portability | SKILL.md frontmatter is limited to keys accepted by claude.ai upload: `name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools`, with `name` ≤ 64 characters, `description` ≤ 200 characters and `version` under `metadata`. SKILL.md stays under 500 lines; details go in `references/`. |
| D11 | Prerequisite | A Figma Dev or Full seat. View and Collab seats are limited to 20 MCP calls per month. |

Proposed default Figma structure (adjustable): `📋 Brief & Rules` · `🎨 Foundations` (variables, styles) · `🧩 Components` · `📱 Screens`.

## Scope

- **In:** plugin manifest, marketplace manifest, orchestrator SKILL.md, reference files (sync rules, Figma structure, minimal-system checklist, `.md` templates), structural validation tests, install/usage docs.
- **Out (v1):** code generation, a custom MCP server, bundling or redistributing impeccable or the Figma MCP.

## Constraints

- Generated artifacts are in English.
- The same SKILL.md must work in Claude Code and Claude Desktop.
- No overlap with the official Figma plugin skills; reference them instead.

## Open questions

T1 answered the questions below; see `docs/research/platform-capabilities.md`. Still open:

- **Is `use_figma` exposed in Desktop chat?** UNKNOWN; needs a manual smoke test (T6a).

Original questions:

1. Is Claude Design available from Desktop chat or Cowork, and how does a skill drive it on each surface?
2. Can Desktop write `PRODUCT.md` / `DESIGN.md` into the user's local folder (chat sandbox vs Cowork vs a filesystem extension)?
3. Can impeccable be uploaded and run on Desktop, given its frontmatter (`version`, `user-invocable`, `argument-hint`) and its bundled binary?
4. Which Figma MCP tools write to Figma, and are there plan or seat limits?
5. Runtime detection of available skills and connectors.
6. Is there a plugin validation command?

## TDD

- **Mode:** enabled. Source: user global config ("Strict TDD Mode: enabled").
- **Runner:** `tests/run.sh`. It runs the validator fixture self-tests (each negative fixture must fail for its expected reason), `tests/validate-skill.sh` on every `skills/*/`, and `claude plugin validate --strict` on `plugin.json` and `marketplace.json`.
- **What gets tested:** manifests are valid JSON with the required fields; frontmatter uses only allowed keys; SKILL.md is under 500 lines; every referenced file exists.

## Delivery

- **Strategy:** `ask-on-risk` (default).
- **Forecast:** about 900–1,300 authored lines, mostly Markdown. This exceeds the 400-line budget, so the chain strategy will be asked before the commit that crosses it.

## Tasks

| ID | Task | Route | Status | Evidence |
|---|---|---|---|---|
| T1 | Research the open questions; write `docs/research/platform-capabilities.md` | delegated (broad web research) + inline verification of the key claims | done | research doc |
| T2 | Plugin scaffold: `plugin.json`, `marketplace.json`, validation test harness (RED first) | inline | done | RED: no manifest / no skills → GREEN `tests/run.sh` exit 0; commits `6c43e6e`, `083e224`; native review approved (4 lenses, lineage `review-ae3fc37288c0f62c`, acknowledged) |
| T2b | Validator hardening from review advisories R3-003…006 (frontmatter parsing edge cases) | inline | pending | — |
| T3 | `SKILL.md`: preflight, tool directory, both mode flows | delegated writer (writer trigger: 2+ non-trivial files) | done | RED: required-file check failed for all 10 missing files (the writer's pasted RED excerpt was partly reconstructed) → GREEN `tests/run.sh` exit 0, verified by the parent |
| T4 | References: sync rules, Figma structure, minimal-system checklist, `.md` templates | delegated writer (with T3) | done | 7 references plus 3 assets; SKILL.md is 84 lines with a 187-character description |
| T5 | Claude Code trial: local marketplace, both modes, a manual Figma edit round-trip. Also verify that `/design-sync` accepts `DESIGN.md` and what it targets after the claude.ai/design closure | inline + user | pending | — |
| T6a | Desktop smoke test: Figma connector in chat exposes `use_figma` | user-assisted | pending | — |
| T6 | Claude Desktop trial: zip upload, same cases | user-assisted | pending | — |
| T7 | README: install and usage for Code and Desktop | inline | pending | — |
| T8 | Publish the marketplace on GitHub (push is the user's decision) | user decision | pending | — |

## Acceptance criteria

- The plugin installs in Claude Code from a marketplace and in Desktop via zip upload, with no frontmatter errors.
- Preflight blocks when the Figma MCP tools are missing, reports when no design-capable surface is available, and warns but continues when impeccable is missing.
- Full-project mode produces a Figma file with the four pages, plus `PRODUCT.md` / `DESIGN.md` carrying the Figma link, written to the folder or delivered as downloads according to the D5 ladder.
- Single-screen mode with no project bootstraps a minimal system, then designs the screen.
- A manual edit in Figma is picked up on the next run. A local `.md` edit triggers the diff-and-ask prompt.

## Progress log

- 2026-10-15: decisions D1–D10 accepted in the planning round. Repository initialized (`84d1e7a`), branch created. T1 started.
- 2026-10-15: T1 done. Revised D2, D6, D8 and D10; added D11. Key verified facts: claude.ai/design closes on 2026-12-14; Desktop chat cannot write local files; `claude plugin validate` exists.
- 2026-10-16: D5 write-path ladder accepted (verified signal: `CLAUDECODE=1`; Cowork mounts connected folders, with no official detection API).
- 2026-10-16: T2 done. Native review (risk: high, shell scripts) approved with only non-blocking advisories. Applied: negative fixtures now assert the failure reason; the stale plan text was fixed. Remaining advisories (R3-003…006: validator parsing edge cases) are tracked as T2b.

- 2026-10-16: delivery decision. Skill content (T3/T4) may exceed the 400-line budget in one slice; code or multi-file work later uses chained PRs (strategy asked when it first applies). Second native review (lineage `review-ed29e1cc09e34678`) approved and acknowledged.
- 2026-10-16: T3/T4 done. Writer choices to confirm in T5:
  - sync metadata lives in YAML frontmatter of `PRODUCT.md`/`DESIGN.md`;
  - the snapshot goes in a `DESIGN.md` section with an optional `DESIGN.sync.json` sidecar (no size threshold defined yet);
  - `scope: minimal` marks a bootstrapped single-screen project.
  impeccable `new-work` is a flow, not a sub-command.

## Next step

T5: install from the local marketplace in Claude Code and run both modes against a test Figma file. Before T8, decide the license (omitted for now).
