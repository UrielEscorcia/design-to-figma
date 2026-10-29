# Feature: design-to-figma plugin

- **Engram mirror:** `odd/design-to-figma/tasks`
- **Branch:** `fix/d2f-10-desktop-trial` (from `main` after PR #9 merged, `984e1c2`)
- **Status:** T9–T11 merged (PRs #4–#6); T13 merged (PR #7, v0.2.0); T5d done on v0.2.0; T14 merged (PR #8, v0.3.0); T12 merged (PR #9, v0.3.1); T6 done; T15 merged (PR #10, v0.3.2); T16 done; T17 merged (PR #11, v0.3.3); T7 done (v0.3.4, PR pending); next: close T8

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
| D12 | File naming (2026-10-16) | Before `create_new_file`, suggest a name (for example `<Product> — <Scope>`) and ask the user to confirm or change it. Never create an unnamed or self-named file silently. |
| D13 | Style discovery (2026-10-16) | Before any direction work, ask which style the user wants; if they are unsure, offer named styles (minimal, editorial, bold, and so on). Then research current references for that style and screen type on the web, and present the style with popular products that use it (for example "this style is used by Stripe and Mercury") plus its concrete traits. The confirmed style and references become constraints for impeccable and for the proposals. |
| D14 | Quality bar (2026-10-16) | Aim for an excellent, current design, not a standard one, even for a single screen. Use impeccable for every design step when it is present (shape, direction, critique, polish), with critique and polish mandatory before calling a design done. Use Claude Design tools for the proposals. No skeuomorphism or literal metaphors unless the user asks for them. Without impeccable, run the built-in critique checklist. |
| D15 | Proposals (2026-10-16) | Show two or three directions as Claude Design artifacts for the user to compare. In Claude Code use the Artifact tool's Design type (found through `quickstart`, never a hardcoded type URL); in Desktop use the chat's Design output or the Artifacts Design template. The user picks one or asks for more. Only the chosen direction is built in Figma. |
| D16 | Iteration in Figma (2026-10-16) | After the Figma build, natural-language change requests ("change this color", "remove the field borders and rearrange the fields") are applied directly in Figma with `use_figma` after reading the current state, then synced to the local files. |
| D17 | Per-screen loop (2026-10-18) | In project mode each screen runs its own loop: define (questions plus research contrast) → build → agent verify (impeccable critique on screenshots plus the quality gate) → at most 2 self-fix rounds → human review → user-requested iterations → final agent verify → check off. Problems are caught on screen 1, not after the whole project. |
| D18 | Design plan tracker (2026-10-18) | `DESIGN-PLAN.md` in the project folder lists the sections to design (brief, style, foundations, components, each screen) with states `pending → built → agent-verified → user-approved → final-verified`. Resume reads it first. Without a writable folder it is delivered as a download. |
| D19 | Screen definition (2026-10-18) | Before building a screen, ask how it should work when that adds value. Do not accept every request as-is: contrast it with the research and with real screens of the same type, and suggest how it would look, so both sides agree on what is built. A reference-source slot in the tool directory is reserved for a future references MCP (for example Mobbin). |
| D20 | Dark mode optional (2026-10-18) | Ask whether dark mode is needed when a project or screen is created; never assume it. Semantic color variables are created anyway in a single-mode collection, so adding Dark later is one new mode. When requested, Dark is built after the user approves the Light screen. |
| D21 | Quality gate (2026-10-18) | A design is done only when: no P0/P1 issues, the impeccable design-specificity verdict reads as authored (not category-interchangeable), and the heuristic score is at least 28/40 (70% of the applicable maximum when heuristics are n/a). Builders receive impeccable's craft guidance (`craft-floor`, `layout`, `typeset`, the platform reference) plus `PRODUCT.md`/`DESIGN.md`. Critique runs on rendered screenshots; detector Assessment B runs on the HTML comp, and Figma-only critique is declared degraded. Below the gate, offer another round. |
| D22 | Unified Claude experience (2026-10-18) | Chat and Cowork are merging ("Claude Cowork is now just Claude"); connected local folders are readable and writable from the desktop app. The write path is chosen by capability (a connected or project folder is writable), not by surface name. Downloads stay as the fallback. Claude Design now lives in Claude as artifacts, including design systems. |
| D23 | Versioning (2026-10-19) | Every change to the plugin bumps its version (semver) in `plugin.json` and the SKILL.md `metadata.version`, which must match. `claude plugin update` skips a plugin whose version did not change: after PRs #4–#6 merged, the marketplace clone was current but the installed plugin stayed at the old commit. `tests/run.sh` enforces both rules against the local `origin/main` (fetch first; a downgrade or an unreadable base version fails). |
| D24 | Category research gate (2026-10-19) | Before style work, research real products in the same category (for example barbershop booking apps) with sources, list them to the user and wait before continuing, so the user knows where the references come from. A references connector (for example Mobbin) is preferred when connected; without web tools, say the list is unverified and ask the user for references. |
| D25 | Palette gate (2026-10-19) | The palette is defined and confirmed by the user (as a swatch artifact) before any direction is generated. Directions share the confirmed palette and differ in structure. |
| D26 | Product locale (2026-10-19) | The brief asks the language and locale of the product's UI. All UI copy in proposals and Figma uses it. The English rule covers documentation and generated files, not product UI copy. |

Proposed default Figma structure (adjustable): `📋 Brief & Rules` · `🎨 Foundations` (variables, styles) · `🧩 Components` · `📱 Screens`.

## Scope

- **In:** plugin manifest, marketplace manifest, orchestrator SKILL.md, reference files (sync rules, Figma structure, minimal-system checklist, `.md` templates), structural validation tests, install/usage docs.
- **Out (v1):** code generation, a custom MCP server, bundling or redistributing impeccable or the Figma MCP.

## Constraints

- Generated artifacts are in English.
- The same SKILL.md must work in Claude Code and Claude Desktop.
- No overlap with the official Figma plugin skills; reference them instead.

## Open questions

T1 answered the questions below; see `docs/research/platform-capabilities.md`. T6a answered the last one: `use_figma` is exposed in Desktop chat (2026-10-16).

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
- **Chain strategy (2026-10-16):** `stacked-to-main`. Each PR targets the previous one; the first targets `main`. Proposed slices (to confirm when PRs are created; push and PR creation remain the user's decision):
  1. scaffold and validation tests (`6c43e6e`, `083e224`, `4993807`, plus the planning docs);
  2. orchestrator skill and references (`ccc32bc`, `c546283`, `15628c5`);
  3. trial fixes, design-quality flow and license (T5a/T5b; this branch).
  Branches: `feat/d2f-01-scaffold` (`4797997`..`4993807`), `feat/d2f-02-skill` (`ccc32bc`..`15628c5`), `feat/design-to-figma-plugin` (`59b0317`..HEAD).
- **Round 2 (2026-10-18):** same `stacked-to-main` strategy. Forecast about 800 authored lines. Slices: (4) `feat/d2f-04-quality-loop`: T9 trial fixes and quality gate; (5) `feat/d2f-05-screen-loop`: T10 per-screen loop, tracker, screen definition, optional dark mode; (6) `feat/d2f-06-ds-artifact`: T11 Figma → Design System artifact sync. Push and PRs remain the user's decision. Actual slices (2026-10-18): (4) `main..34c943b` `6be37f7`, `34c943b`: 15 files, +166/−64 (230); (5) `34c943b..c708f60` `2d97a7b`, `45c7817`, `4d24924`, `c708f60`: 14 files, +160/−45 (205); (6) `c708f60..343aab8` `b9165ec`, `343aab8` plus this record: 14 files, +88/−20 (108). All within the 400-line budget.

## Tasks

| ID | Task | Route | Status | Evidence |
|---|---|---|---|---|
| T1 | Research the open questions; write `docs/research/platform-capabilities.md` | delegated (broad web research) + inline verification of the key claims | done | research doc |
| T2 | Plugin scaffold: `plugin.json`, `marketplace.json`, validation test harness (RED first) | inline | done | RED: no manifest / no skills → GREEN `tests/run.sh` exit 0; commits `6c43e6e`, `083e224`; native review approved (4 lenses, lineage `review-ae3fc37288c0f62c`, acknowledged) |
| T2b | Validator hardening from review advisories R3-003…006 (frontmatter parsing edge cases) | inline | folded into T12 (S12.22) | — |
| T3 | `SKILL.md`: preflight, tool directory, both mode flows | delegated writer (writer trigger: 2+ non-trivial files) | done | RED: required-file check failed for all 10 missing files (the writer's pasted RED excerpt was partly reconstructed) → GREEN `tests/run.sh` exit 0, verified by the parent |
| T4 | References: sync rules, Figma structure, minimal-system checklist, `.md` templates | delegated writer (with T3) | done | 7 references plus 3 assets; SKILL.md is 84 lines with a 187-character description |
| T5 | Claude Code trial: local marketplace, both modes, a manual Figma edit round-trip. Also verify that `/design-sync` accepts `DESIGN.md` and what it targets after the claude.ai/design closure | inline + user | in progress | Single-screen mode passed (build, Figma → local, local → Figma); findings below. Full-project mode is retested after T5a/T5b |
| T5a | Trial fixes: enumerate pages through a `use_figma` read; Brief Links without absolute paths; drop the Brief last-sync line; offer usage-rule prose for the Brief; document `.impeccable/`; D12 file naming | delegated writer (writer trigger: 2+ non-trivial files) | done | RED: 10 failures (4 missing references plus 6 structural assertions) → GREEN `tests/run.sh` exit 0, rerun by the parent |
| T5b | Design-quality flow: D13 style discovery and references, D14 quality bar, D15 Claude Design proposals, D16 iteration in Figma | delegated writer (with T5a; preparation trigger: reading impeccable's commands) | done | New `style-discovery.md`, `proposals.md`, `quality-bar.md`, `iteration.md`; SKILL.md 105 lines. Parent verified: Artifact `quickstart` (`intent: design`) returns a Design type on this account; `figma.getLocalTextStylesAsync` / `getLocalEffectStylesAsync` ran in a read script. Unverified until T5c/T6: Desktop Output → Design, impeccable with a pinned style, web search on Desktop |
| T5c | Retest in Claude Code with the reinstalled plugin: full-project mode end to end, including proposals and an iteration request in Figma | user-assisted | done | Full project "Tino" (iOS finance app) built in about 58 minutes: 100 variables, 41 components, 10 screens Light and Dark; critique 25/40 → 27/40; iteration applied in Figma and synced. Findings in the progress log (2026-10-18) |
| T9 | Trial fixes and quality gate: reply in the user's language; brief before style; visual palette by default; file name as its own question; iOS font check; iteration inspects ancestors and prefers local fixes; D21 quality gate; impeccable craft guidance to builders; D22 capability-based write path; D6 revision (`/design-sync` outdated) | delegated writer (writer trigger: 2+ non-trivial files) | done | RED: 16 FAIL lines, exit 1 (writer report) → GREEN `tests/run.sh` exit 0, rerun by the parent. Parent fix: scaled threshold wording (23/32 when two heuristics are n/a). SKILL.md 110 lines, description 191 characters |
| T10 | Per-screen loop (D17), `DESIGN-PLAN.md` tracker (D18), screen definition with research contrast and a reference-source slot (D19), optional dark mode (D20) | delegated writer (writer trigger: 2+ non-trivial files) | done | RED: 16 FAIL lines, exit 1 (writer report) → GREEN `tests/run.sh` exit 0, rerun by the parent. New `screen-loop.md` and `DESIGN-PLAN.template.md`; SKILL.md 114 lines. Parent fixes: screen mode defines the screen before the proposals; Dark adds a mode to a single-mode `Semantic` collection first |
| T12 | Review advisories from rounds 2 and 3 and PR #8, with T2b folded in; items S12.1–S12.24 below | inline (small independent edits; no writer trigger) | done | `dadf4a3`, `623b84f`, `a01ccd1`, `caca2af`. RED: validator 2 fixture failures, content 23 FAIL lines, follow-ups 4 FAIL lines → GREEN `tests/run.sh` exit 0 each time. Version 0.3.1 |
| T13 | Version bump to 0.2.0 and the D23 checks in `tests/run.sh` | inline (3 files, mechanical) | done | RED: version mismatch and an unbumped skill change each failed → GREEN `tests/run.sh` exit 0 |
| T14 | D24 category research gate, D25 palette gate, D26 product locale; bump to 0.3.0 | delegated writer (writer trigger: 2+ non-trivial files) | done (PR #8 merged, `d242c81`) | RED: 8 FAIL lines, exit 1 (writer report) → GREEN `tests/run.sh` exit 0, rerun by the parent. Parent addition: the Brief template lists category and style references separately. SKILL.md 120 lines |
| T5d | Clean full-project retest in Claude Code with v0.2.0: screen loop, user review per screen, dark-mode question, Design System artifact | user-assisted | done | Navaja (barbershop booking, Editorial): 7 screens final-verified (26/36 to 35/40), cross-screen review 31/40, Design System artifact v12. Fixes shipped in PR #8. v0.3.0 gates are verified in T6 |
| T11 | One-way sync from Figma foundations to a Claude Design System artifact, so later proposals use the project's system | delegated writer (writer trigger: 2+ non-trivial files) | done | RED: 9 FAIL lines, exit 1 (writer report) → GREEN `tests/run.sh` exit 0, rerun by the parent. New `design-system-artifact.md` defers file shapes and re-sync rules to the type's own `SKILL.md` and `from-design-tool.md` (read by the parent from the account's Design System type); adds all-mode tokens via the script read, `design_system_url`, opt-in, sync points and non-blocking failure. SKILL.md 118 lines |
| T6a | Desktop smoke test: Figma connector in chat exposes `use_figma` | user-assisted | done | User screenshot (2026-10-16): Desktop chat lists about 42 Figma tools, `use_figma` included; invocation is tested in T6 |
| T6 | Claude Desktop trial: zip upload, same cases | user-assisted | done | Zip v0.3.1 uploaded without errors; Sattva (yoga studio booking): 3 screens final-verified (cross-screen 37/34/36 of 40). Findings F1–F11 go to T15. Font question answered (see T12 items) |
| T15 | Desktop trial fixes F1–F11; bump to 0.3.2; items S15.1–S15.7 below | inline (one understood change, no writer trigger) | done | `f2d6b34`, `6332c34` + this commit. RED: 21 FAIL lines → GREEN `tests/run.sh` exit 0. Mutation probe: dropping "alone" from gate step 6 fails the run. Version 0.3.2 |
| T16 | Desktop-compatible impeccable repack (outside the plugin) and a short second Desktop trial | inline + user-assisted | done | Repack built locally, not committed (D-out: no redistribution): `~/Downloads/impeccable-desktop-4.3.1.zip` (660 KB) passes `tests/validate-skill.sh`; frontmatter keys stripped, description 172 characters, body identical, `scripts/bin` and live scripts dropped, `NOTICE.md` lists the changes. Plugin zip `~/Downloads/design-to-figma-0.3.2.zip`. Trial done 2026-10-29 (Molienda checkout, screen mode, Figma `wJmtPNcMLorbLoyG8jDoK1`): impeccable loaded at the directions step with the documented launcher fallback; findings G1–G7 → T17 |
| T17 | Second Desktop trial fixes (S17.1–S17.5) | inline | done | RED: 11 FAIL lines → GREEN `tests/run.sh` exit 0; v0.3.3. G4–G6 need no rule change (the gate sequence, Hard Rule 13 and screen-loop step 5 already state them) |
| T7 | README: install and usage for Code and Desktop, plus the T17 review advisories R3-001–R3-003 | inline | done | RED: 3 FAIL lines without `README.md`, 1 FAIL line for the preflight install fallback → GREEN `tests/run.sh` exit 0; v0.3.4. R3-001: after an install, check the skill list again and fall back to a new session or chat. R3-002: the negative preflight checks require the file and §3 must say "never assume". R3-003: the Brief scope check is scoped to the Close step |
| T8 | Publish the marketplace on GitHub (push is the user's decision) | user decision | in progress | Repo https://github.com/UrielEscorcia/design-to-figma (public, MIT); PRs #1–#8 merged. Close after T7 |

### T12 items

Sources: review `review-706145da1b2cb93f` (round 2), the PR #8 reviews, and the T5d font-swap reviews. Each item is a fix to existing text or tests; none adds a product feature.

Flow and gates:
- S12.1 Screen mode defines the screen before the proposals at the SKILL.md level too (R2-skill-step-order-drift).
- S12.2 Project mode asks the user to approve the foundations and components before the first Design System artifact sync and the screen plan (R3-foundations-approval-trigger).
- S12.3 Each style-discovery confirmation is recorded where its gate reads it: the category list (or the user's choice to continue with fewer than 3), the style and the palette with its confirmation date (palette record target, category fallback).
- S12.4 Direction comps with no writable folder are delivered as downloads, and the plan records the artifact URL (proposals.md:30).
- S12.5 Figma structure names (pages, frames, layers, variables, styles, components) and the Brief page follow the documentation language rule; only product UI text uses the UI locale (SKILL.md:38).
- S12.6 Decision Gates rows keep related rows together (the recorded-style row sits with the style rows); the feature doc's decision table runs D22 before D23.

Screen loop and quality:
- S12.7 After a rate-limit error no Figma call can revert: record the partial state (what was written, any duplicate frame) in the plan and restore at resume; stop at a clean point only while calls remain (R4-rate-limit-revert, screen-loop.md:35).
- S12.8 The elevate pass maps each opportunity to its impeccable command and is skipped when the remaining calls cannot cover it; the keep/restore rule does not compare scores between reviewers.
- S12.9 Each screen records the Figma calls it used; the first screen's count is the estimate for the next ones (per-screen call budget).
- S12.10 The blind-critique rule is stated once (quality-bar.md); the screen loop points to it.
- S12.11 The user-review step is split into short bullets (overloaded step 6).
- S12.12 An app-wide rule applied to already approved screens sends them back for verification and user review instead of leaving stale states.
- S12.13 The builder guidance list lives only in tool-directory.md; workflow-screen.md points to it (R2-builder-guidance-restated).
- S12.14 Platform font swap: an unstyled text node binds to the text style with the same size, weight and line height; with no match or several, list it and ask (R3-unstyled-target-ambiguous, R2-001/R2-002 on figma-structure.md:42).

Design System artifact:
- S12.15 With no writable folder, tell the user `design_system_url` and include it in the downloaded `DESIGN.md` (R4-ds-artifact-url-no-writable-folder).
- S12.16 Files that failed to save are listed as pending and retried at the next sync point even when their source did not change (R4-ds-artifact-retry-scope).
- S12.17 Availability is decided by capability (tool, type, a publish that succeeds), not by surface name (R2-dsa-surface-name-gate).
- S12.18 The opt-in is recorded in `PRODUCT.md`, and in the plan only when one exists (R3-plan-optin-screen-mode).
- S12.19 Each sync reads the artifact back (file list and previews) and reports unchecked previews.

Tests and validator:
- S12.20 `tests/run.sh` uses one path alias per directory.
- S12.21 Phrase assertions that guard an ordered or step-specific rule are scoped to the section that owns it; the runner states that phrase checks are regression guards, not proof of meaning (R3-keyword-only-assertions).
- S12.22 The validator fails an unclosed frontmatter and a duplicate top-level key with a clear reason (T2b).
- S12.23 The version check accepts only `X.Y.Z` versions and falls back to the local `main` when `origin/main` is missing.
- S12.24 Version bump (D23).

Verified in T6 (2026-10-29): editing a text style's font family in Figma desktop re-lays out every node that uses it. `text/label` changed from Manrope to Roboto Mono; each auto-width node's stored width matched a fresh Roboto Mono measurement (152, 85, 59, 101). A first try with `text/body` → Inter was inconclusive: the wrapped texts break into the same lines in both fonts.

### T15 items

Source: the T6 Desktop trial (Sattva, v0.3.1, 2026-10-28/29). User words: "no hace eso de mejorar cada pantalla cuando la termina de una me la manda review mio"; "revisando el figma no hizo nada den el brief"; "al inicio no me pregunto si mantener el artifact de design".

- S15.1 (F1, F2) Each style-discovery gate is its own turn: the category list, then the style question, then the palette. Never batch gates into one multi-question form, never propose a style in place of asking it, never show palettes before the style is confirmed. The file name question comes at the Figma step, alone, without the team.
- S15.2 (F3) The chosen direction gets its critique before any Figma write, with impeccable or with the fallback checklist, and the result is shown to the user.
- S15.3 (F4, F5) The step-6 user review uses a fixed message with mandatory fields: verdict, score, polish result, elevate (kept or discarded, and what changed), open gaps. The agent does not ask for approval while a field is missing. One screen per review unless the user asked to batch.
- S15.4 (F6, F8, F10, F11) Records come from Figma reads: `DESIGN.md` with the `Foundations: approved` line is written when the user approves; the sync snapshot is built only from the read-only enumeration output, with variable names and values; before the final report, every required page is checked non-empty, the Brief page included.
- S15.5 (F9) Ask before any generation that spends the user's credits (for example Figma AI images); otherwise use placeholders.
- S15.6 (F7) The Design System artifact opt-in is asked at project start, as its own question.
- S15.7 Version bump to 0.3.2 (D23).

### T17 items

From the second Desktop trial (2026-10-29, v0.3.2 plus a personal impeccable repack). User: "tal vez deberiamos ser mas rigurosos con impecable, detectarlo y si no lo tenemos que nos mande un aviso tipo pregunta de que no se encontro y si deseamos proceder sin eso y sino que nos diga como instalarlo asi aseguramso que lo use".

- S17.1 (G1) The preflight report is its own first message, never skipped; it ends by confirming the write path, so `PRODUCT.md` is written right after the brief.
- S17.2 (G2, user request) impeccable is checked at the start on every surface. Present: load it and report "used". Missing: one question, "Install impeccable first" (steps per surface, the Desktop repack steps included) or "Continue without impeccable". The "expect it absent on Desktop" note is removed.
- S17.3 (G3) Screen mode asks the Design System artifact opt-in as its own question after the brief, like project mode.
- S17.4 (G7) The close step checks that the Brief page text matches the current scope (screens and states added later).
- S17.5 Version 0.3.3.
- Not changed: G4 (two questions in one message), G5 (an English interim line) and G6 (Elevate reported while the gate still failed) are agent deviations from rules already stated.

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
- 2026-10-16: third native review (lineage `review-5ebd980b04082bf0`, range `4993807..ccc32bc`) approved and acknowledged, with 11 non-blocking advisories. Applied in a follow-up commit:
  - local-vs-Figma change detection is now a three-way comparison with the snapshot as the base;
  - snapshot sidecar threshold set at 150 lines;
  - variable snapshot format fixed;
  - unreadable-snapshot and inaccessible-Figma handling made explicit.
  Remaining advisories (R2-004, R2-005, R3-004, R3-005) are minor wording and test items, left for T5 feedback.
- 2026-10-16: T6a done. Desktop chat lists `use_figma` among about 42 Figma connector tools. The preflight caveat became a note; the research doc records the extra tools seen (out of scope for v1).
- 2026-10-16: T5 setup. Plugin installed from the local marketplace; Figma MCP authenticated in Claude Code. `whoami`: Full seat on two teams (Starter and Pro), so 200 calls per day. Findings to address in T5:
  - the Figma MCP declares `/figma-design-to-code` mandatory before `get_design_context`, but the skill uses `get_design_context` to read frame state; switch that read to `get_metadata` + `get_screenshot`, or load that skill;
  - ~~a user with several Figma teams must be asked which team owns a new file~~: not a gap. In the trial the skill asked which team before `create_new_file` and loaded `figma-create-new-file`.
  - trial observations so far: the skill auto-activated; preflight blocked until Figma auth; the write path was confirmed before the first write; impeccable ran the brief and direction picker and created a `.impeccable/` folder that the skill does not mention; approval was asked before writing to Figma; the build was delegated to a subagent (check that it loads `figma-use` before `use_figma`).
  - subagent check passed: it loaded `figma-use`, `figma-generate-library` and `figma-generate-design` before any `use_figma` call; its prompt carried the four pages, Primitives + Semantic collections with aliases, the brief content, a bounded screenshot validation and a normalized snapshot for `DESIGN.md`.
  - single-screen run finished (a private test file on a Pro team). Verified from the parent session with a read-only `use_figma` script: 4 pages, collections Primitives 20 / Semantic 20 / Spacing 8 / Radius 4, 8 text styles plus `effect/sheet`; the `DESIGN.md` snapshot matches. Four screen frames = email, SSO and wrong-password states on desktop plus email on mobile. The final report met the output contract. impeccable critique/polish was not run (reported as pending).
  - gap (high): `get_metadata` without `nodeId` lists only the first page (`📋 Brief & Rules`), because pages load incrementally. `sync-rules.md` reads pages with `get_metadata`, so change detection would see three pages as deleted. Enumerate pages with a read-only `use_figma` script (`figma.root.children`), then read each page by id.
  - manual-edit round-trip passed: `color/cobalt/600` changed in Figma (`#2F5AA8` → `#1E4FD8`); the next run detected exactly that change, updated the `DESIGN.md` frontmatter and snapshot, `PRODUCT.md` `last_sync` and `.impeccable/surfaces/sign-in.md`, and reported no conflicts and no false page deletions (verified locally). It also flagged that the hover token is now lighter than the base color and checked AA contrast.
  - gap: the Brief page carries a "last sync" line, but Figma → local sync never writes to Figma, so that line goes stale after every sync. Proposed fix: drop the timestamp from the Brief page; sync state lives in the local files.
  - limit stated by the run: its read did not compare text inside component instances; it relied on screenshots.
  - local-edit round-trip passed the detection step: with `feedback-danger` changed locally (`#B3261E` → `#C62828`) and a prose line added, the run read Figma (unchanged since the snapshot), classified the token as a local-only edit, showed the diff with its contrast impact and asked push or discard. It compared the snapshot semantically and ignored a YAML reformat.
  - local → Figma push passed (user chose push): verified from the parent session that `color/red/600` is `#C62828` in Figma, `color/cobalt/600` keeps the manual `#1E4FD8`, and the local snapshot and both `last_sync` fields read `2026-10-17T03:15:09Z`. The push also rewrote the Brief page's sync line, while the earlier Figma → local sync left it stale; this confirms the Brief timestamp gap. The Brief page's Links line still holds the absolute local path.
  - open: a prose rule added to `DESIGN.md` ("Success green is never used for buttons.") was left local only. Decide whether usage-rule prose should be offered for the Brief page's usage rules.
  - resolved 2026-10-16: the `DesignSync` tool only reads and writes claude.ai/design design-system projects, only inside the user-started `/design-sync` skill, and must not be used to make designs. The skill cannot call it. An Artifact type "Design System" exists as the newer target; whether Figma should sync to it is an open question for the user.
  - superseded: the skill handed `/design-sync` to the user as a manual step; Claude Code also exposes a `DesignSync` tool. Check whether the skill can call it directly.
  - gap: `brief-page.template.md` asks for the `PRODUCT.md` / `DESIGN.md` "path", so the trial wrote an absolute local path (with the OS username) into the shared Figma file. Use file names relative to the project folder instead.
- 2026-10-16: T5a/T5b committed (`59b0317`). Fourth native review (lineage `review-0169275a953af021`, risk high because of `tests/run.sh`) approved and acknowledged, with 12 non-blocking advisories. Applied: `sync-rules.md` three-way detection now points to the script-based read instead of `get_variable_defs` + `get_metadata` (flagged by three lenses). Remaining advisories (R2-002/R2-003/R3-002…R3-006, R1-001, R2-004) are left for T5c feedback.
- 2026-10-16: license MIT (`e13b331`: `LICENSE`, `plugin.json`, SKILL.md frontmatter). Public repo created at https://github.com/UrielEscorcia/design-to-figma (empty; remote `origin` added; nothing pushed). Privacy scan before publishing: the test Figma file key was scrubbed from this document, and the unpushed local history was rewritten (`git filter-branch`) so no pushed commit contains it; a local `backup/pre-scrub` branch keeps the original.
- 2026-10-16: pushed `main` and the three slice branches as UrielEscorcia; stacked PRs opened: #1 scaffold (357 lines, base `main`), #2 skill (612 lines, base #1, `size:exception` requested: SKILL.md and its linked references cannot split without failing the validator), #3 trial fixes and design-quality flow (455 lines, base #2). Merging is the user's decision; after each merge, retarget the next PR to `main`.

- 2026-10-17: PRs #1–#3 merged into `main` (`7d09fff`), identical to the slice-3 tip.
- 2026-10-18: T5c done in Claude Code (full project, iOS finance app "Tino"). Worked: preflight; style question with web research and sourced references; seed-color OKLCH palette with AA checks; one-question-at-a-time brief; three structurally different directions on a Design artifact canvas plus a mix; critique before and after the build; Pro team chosen because Starter limits pages and variable modes; iteration applied in Figma in all theme variants and synced. Findings:
  - prose in English while questions were in Spanish (no language rule);
  - style discovery ran before the product brief (SKILL.md step 2 is ambiguous);
  - the palette was shown as a visual artifact only when the user asked;
  - the file name was suggested inside the team question, never confirmed on its own (D12 half met);
  - `quality-bar.md` has no minimum, so the design was declared done at 27/40; that score is Nielsen usability, not visual quality;
  - SF Pro rendered blank in Figma screenshots and was replaced by Inter/Nunito;
  - impeccable acted as a judge, not a generator: the foundations and screen builders never read its craft guidance; the pre-build critique read HTML, not a render; the Figma critique ran Assessment A only, without declaring it degraded;
  - the iteration agent blamed the card shadow for gray corner squares and offered to soften every card's shadow; a read-only inspection found the real cause: parents `Body` and `Suggestions` clip content with square corners at the card's bottom edge. It also hid a card to make the content fit;
  - not plugin issues: the stop-hook error (the parent folder is itself a git repo), a codegraph hook timeout, and an `odd/tasks` file written by the user's global instructions.
- 2026-10-18: user decisions D17–D22 accepted. Research: unified chat and Cowork (support articles 15520349 and 17444462), Claude Design migration (17440474). T11 (Design System artifact sync) is split into its own slice after T9 and T10.
- 2026-10-18: T9 committed (`6be37f7`). Fifth native review (lineage `review-a0c15fa96fef63f8`, risk high because of `tests/run.sh`) approved and acknowledged with 9 non-blocking advisories. Applied in a follow-up commit: stale status line; below-gate extra round runs only after the user accepts it and starts a new bounded run; the gate maps onto the built-in checklist without impeccable; the tool-directory file-name row now asks the name as its own question. Left as later work: R1-001 (spell out folder confirmation when several are possible), R2-builder-guidance-dup, R3-tests-skill-only-ordering (order checks only cover SKILL.md headings).
- 2026-10-18: T10 committed (`2d97a7b`). Sixth native review (lineage `review-e8e2e3f41600c9d8`, range `6be37f7..2d97a7b`, risk high) opened one CRITICAL finding: the per-screen loop dropped the mandatory polish pass. One bounded correction `45c7817` (RED: the new polish assertion failed without the fix → GREEN); targeted validation approved; acknowledged. Advisories fixed in a follow-up (writer RED: 6 FAIL lines → GREEN): the screen loop owns its budget and quality-bar's bounded rule applies outside it; one dark-mode rule everywhere (single-mode unless requested; Light and Dark modes from foundations when requested up front; Dark frames after Light approval); no-plan case in screen mode; no duplicated threshold; resume after a downloaded plan; stop at a clean point on rate limits; explicit plan state models; stronger template assertion.
- 2026-10-18: advisories commit `4d24924` reviewed (lineage `review-d1ec832b493ff62c`, risk high) and approved; acknowledged. Follow-up: dark mode requested after foundations adds a Dark mode to a single-mode `Semantic` first (RED: new assertion failed → GREEN); redundant consent clause removed. Accepted as designed: Components use `pending → user-approved` because they are foundations work; screens carry the five-state loop.
- 2026-10-18: T11 committed (`b9165ec`). Native review of the branch range `7d09fff..b9165ec` (lineage `review-484e963ada47ad29`, risk high) approved and acknowledged. Advisories fixed in a follow-up: the artifact URL is recorded right after creation (no duplicate artifact after a failed save) and kept out of the Figma snapshot; `PRODUCT.template.md` dark-mode text matches the rule and gains a Design System artifact field; the plan records the opt-in; screen mode asks the opt-in at bootstrap; component syncs follow a screen's `user-approved` state; the scaled threshold rounds up. Left as later work: keyword-only test assertions (R3), duplicated builder-guidance list in `workflow-screen.md` (R2), mixed path aliases in `tests/run.sh` (R2).

- 2026-10-19: PRs #4–#6 opened (stacked) and merged by the user; `main` = `0b928ba`, identical to the slice-6 tip. `claude plugin update` left the installed plugin at `7d09fff` because the version stayed 0.1.0 → D23 and T13.

- 2026-10-19: T5d (barbershop booking app, Editorial) findings so far: brief, dark-mode and artifact opt-in questions all worked in Spanish; but the research was two generic searches (template and font sites), no real barbershop apps, reference brands from model knowledge, disclosed only after the proposals; each direction carried its own palette that the user never confirmed and disliked; UI copy came out in English for a Spanish-speaking user. User decisions D24–D26.

- 2026-10-19: T14 committed (`1e22994`, `ef13fc1`); reviews `review-7af672a41e7bba98` and `review-79d26cdc8eefc678` approved and acknowledged. Follow-up: each style-discovery gate is skipped only by its own recorded confirmation (a recorded style no longer skips the category and palette gates for projects created on v0.2.0); an existing `PRODUCT.md` without a locale gets the locale question; the Category row states the no-tool fallback.

- 2026-10-19: trial evidence: every screen reviewer received the gate in its prompt (a report said "Good, just over the 70% bar"), all scores landed at the threshold, the re-verify read the earlier report, and nothing improved once the gate passed. Added to T14: blind scoring (no gate, no earlier report; the parent applies the gate), an elevate pass after polish with one impeccable refinement command (`bolder`, `delight`, `typeset`, `colorize`, `layout`, `distill`, `quieter`) and a duplicate-and-restore fallback, app-wide requests become `DESIGN.md` and Brief rules applied to built and later screens, and user-review research of category apps. Writer RED: 6 FAIL lines → GREEN.

- 2026-10-19: `df0f2b0` reviewed (`review-826935da4d9dc2c7`) and approved. Follow-up: keep the elevated version when it still passes the gate with no new P0/P1 (score differences between two reviewers are noise), skip elevate when the gate still fails, restore the duplicate before a rate-limit stop, and a `PRODUCT.md` slot for user needs from reviews. Left for T12: keyword-only assertions, command-to-opportunity mapping for elevate.

- 2026-10-19: T5d resumed after the Figma quota reset (not a rolling 24h window) from `DESIGN-PLAN.md`. Services was final-verified (26/36) and the Design System artifact re-synced (v4); Choose barber went through define, build, critique 29/40, polish and user review. Two gaps fixed in PR #8 (inline, 4 small edits): progress lines between subagent results drifted to English, so rule 13 now names progress updates; the chosen direction comps lived only in the session scratchpad, so `proposals.md` persists them in `directions/` and `DESIGN-PLAN.md` records the folder and artifact URL. RED: 3 FAIL lines → GREEN. Review `review-20b7123ca15db8db` (commit) and the stop-hook full-range review `review-0b0f8014ae2265dc` approved and acknowledged; warnings left for T12 (no-writable-folder case for comps, keyword-only assertions, palette gate on existing projects, elevate quota and rate-limit restore).

- 2026-10-19: T5d Choose barber approved and final-verified (30/40); Date & time built and presented (32/40 after one P1 fix). Gaps fixed in PR #8 (inline, 4 small edits): Date & time was built from a definition the agent derived from the direction critique, never agreed with the user, enabled by "ask ... when that adds value" in the define step; it also chose 75-minute slot spacing (category apps such as theCut make the interval a shop setting, 10–60 min). The define step now always asks, treats a self-derived definition as a proposal that needs the user's yes, and the plan records the agreement date. The agent also added unrequested features ("Ya te atendió" badge, "Ver calendario"); new product features now need the user's agreement. English progress lines also followed subagent dispatches; rule 13 names both. RED: 5 FAIL lines → GREEN. Review `review-b956b24cc22d894f` (full range) approved and acknowledged.

- 2026-10-20: T5d Date & time approved after the user moved slots to 15-minute starts (recorded in `DESIGN.md` as an app-wide rule); Review & confirm defined with the user ("agreed 2026-10-20") and built with its Confirmed state (32/40). Gap: the Date & time definition in `DESIGN-PLAN.md` still described 75-minute spacing and "from the direction critique" after the user's change, contradicting `DESIGN.md`. The user-review step now updates the screen's definition and agreement date whenever a change alters behavior. RED: 1 FAIL line → GREEN.

- 2026-10-22: T5d My appointments and Appointment detail. With explicit instructions the agent proposed first, researched the category (Fresha, Booksy) and wrote in Spanish. Gap: the Appointment detail self-fix changed agreed behavior (undo banner 5 s to 8 s, "Agregar al calendario" from a labeled button to an icon-only nav button) and reported it, but the definition kept the old values; the update rule only named user-review changes. It now covers self-fix, polish and elevate changes too and asks to name them in the review. RED: 1 FAIL line → GREEN. Left for T12: the Design System artifact sync has no readback, previews were published unchecked.

- 2026-10-23: T5d closed: seven screens final-verified (26/36 to 35/40), cross-screen review 31/40, local files synced, Design System artifact v12. Gap: the Inter stand-in was swapped back to SF Pro after the final renders, because SF Pro renders blank in MCP screenshots, so the delivered file was never checked and line breaks were left to the user. `figma-structure.md` now compares each text node's line count before and after the swap, fixes changes and overflows, and reports those screens as structurally verified. RED: 1 FAIL line → GREEN. Still open for T12: Design System previews published unchecked (v9 to v12).

- 2026-10-26: tested a visual check for the platform font. `get_screenshot` renders SF Pro blank, but `exportAsync` inside `use_figma` runs in the user's Figma desktop app and rendered SF Pro text ("Perfil" from the Navaja detail screen). A whole screen is about 69 KB of PNG, over the 48 KB return limit (3 calls per screen), so the rule exports only the parent blocks of the nodes the line-count comparison flags. RED: 1 FAIL line → GREEN.
- 2026-10-26: the 841c23e review flagged that a line count from height divided by line height breaks with AUTO line height, the Figma default. The font swap check now compares each text node's height before and after the swap; a changed height means a line was gained or lost. User: "si de una metelo en el pr abierto".
- 2026-10-27: tested in Navaja: the `use_figma` runtime lacks SF Pro (`hasMissingFont: true` although `listAvailableFontsAsync()` lists it). Script changes leave SF Pro text with its old size and breaks, and `exportAsync` shows the last drawn layout (an 80 px test text exported as one 264 px line). After the user re-set the font in Figma desktop, the script read the new layout (443 x 40, two lines) and the export matched; a later script change froze it again. The rule now leaves the swap to the user in Figma desktop, through the text styles, and requires pixel line heights. User: "si corrije eso".

- 2026-10-28: PR #8 merged (`d242c81`); the user updated the installed plugin to 0.3.0 (verified: the installed skill files match `main`). T12 started on `fix/d2f-09-review-advisories` with T2b folded in. L: user "arranca".
- 2026-10-28: T12 done. Reviews: `review-4bc75b6579080abd` (range to `dadf4a3`, reliability) approved and acknowledged; its advisory on a horizontal rule after an unclosed frontmatter fixed in `623b84f` (RED: wrong failure reason → GREEN). `review-47934528333a001e` (`dadf4a3..a01ccd1`, readability and reliability) approved and acknowledged; follow-ups fixed in `caca2af` (RED: 4 FAIL lines → GREEN): foundations approval kept in `DESIGN.md` until the plan exists, artifact skipped only when creating it fails, call estimate before the first screen, one wording for the leftover elevate duplicate, digits in frontmatter keys, a level-aware `section()` helper. Accepted as advisories: the version guard has only a manual scratch probe (prerelease rejected; local `main` fallback caught a missing bump), and `section()` does not handle code fences. Decision: Figma structure names and the Brief page follow the English documentation rule; only product UI text uses the UI locale.

- 2026-10-28: the stop hook required a four-lens review of the combined range `dadf4a3..23d2ca0` (`review-24213262b2e9533a`), approved and acknowledged. Its two warnings fixed before the PR (user: "Corrige y ya subes el PR"): plan items use the template names (`Brief`, `Style and references`, `Palette and foundations`, `Components`), and a closed frontmatter with a dotted or quoted key no longer fails as unclosed (new `dotted-key` fixture). Also: the style-discovery section is named, not numbered, and the elevate pass points to Cost for rate-limit recovery. RED: 4 FAIL lines → GREEN.

- 2026-10-28: `e0a99a3` reviewed (reliability) and approved; its warning R3-001 was a regression from that commit: a quoted key skipped the allowed-key and duplicate checks. Fixed: key extraction strips quotes (new `quoted-key` fixture, RED: expected fail, got pass → GREEN), and the scoped negative checks on the elevate section first assert that the section exists.

- 2026-10-28: `02eceaa` reviewed and approved; last correction batch for its warnings: one key-extraction substitution (a quoted key with a colon was emitted twice) and a `quoted-duplicate` fixture (single quotes plus a bare/quoted duplicate). Left as advisory: `value_of` reads only bare keys (pre-existing). Correction bound reached; remaining suggestions go to later work.

- 2026-10-28: PR #9 opened (https://github.com/UrielEscorcia/design-to-figma/pull/9). Four-lens review of `dadf4a3..608323e` (`review-6e85cdc9d1897142`) approved and acknowledged; its advisories fixed in the same PR (user: "En el mismo PR"): a `no-closing-line` fixture for the end-of-file branch, the plan records whether the elevated version was kept so a rate-limit resume does not discard it (RED → GREEN), `workflow-screen.md` lists the elevate pass (RED → GREEN), and one key grammar (`key_re`) for the stray-line check and the key extraction.

- 2026-10-28: PR #9 merged (`984e1c2`); installed plugin 0.3.1 matches `main`.

- 2026-10-29: T6 done in Claude Desktop (zip v0.3.1, Sattva). Verified: automatic trigger from a plain prompt, proposals as a Claude Design artifact, `use_figma` invoked with `resource:figma-use`, foundations approval gate, local write folder. Findings F1–F11 (S15.1–S15.6). The user asked to install impeccable on Desktop; it cannot be uploaded as shipped (rejected frontmatter keys, 800-character description; its launcher has a documented fallback), so a separate repack is T16 (user: "si eso haremos termino esto y metemos impecable adaptados despues").
- 2026-10-29: T15. Root cause of F3, F6, F7 and F10: the Desktop run never read `workflow-project.md`, so the rules there never applied. The gate sequence now lives in SKILL.md, which is always loaded, and each step names its reference. Reviews: `f2d6b34` (`review-96a5ee0ba685d8ce`, readability + reliability) approved and acknowledged; its warnings fixed in `6332c34` (batch exception, screen mode, critique before building rather than before any Figma write), also approved and acknowledged. Its follow-up warning (the file-name step pointed at the gate row, so the test checked the row instead) fixed in the closing commit. Left as advisories: phrase guards only check wording (item 6).

## Next step

- 2026-10-29: PR #10 merged (ddbd273); plugin 0.3.2 installed. T16 repack built (see the T16 row).

- 2026-10-29: T16 trial done; the user approved the screen. User: "lsito ya lo aprobe podemos ahora rrancar con lo que sigue". T17 implemented (S17.1–S17.5).

- 2026-10-29: PR #11 merged (47993eb). User: "empieza de una con la tarea y agrega los 3 avisos de una ahi". T7 implemented with R3-001–R3-003.

The user reviews and merges the T7 PR (v0.3.4); then close T8.
