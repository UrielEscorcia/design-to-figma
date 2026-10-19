# Feature: design-to-figma plugin

- **Engram mirror:** `odd/design-to-figma/tasks`
- **Branch:** `feat/d2f-04-quality-loop` (from `main` after PRs #1–#3 merged)
- **Status:** T5c done (full-project trial); T9 (trial fixes and quality gate) next, then T10 (per-screen loop) and T11 (Design System artifact sync)

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
- **Round 2 (2026-10-18):** same `stacked-to-main` strategy. Forecast about 800 authored lines. Slices: (4) `feat/d2f-04-quality-loop`: T9 trial fixes and quality gate; (5) `feat/d2f-05-screen-loop`: T10 per-screen loop, tracker, screen definition, optional dark mode; (6) `feat/d2f-06-ds-artifact`: T11 Figma → Design System artifact sync. Push and PRs remain the user's decision.

## Tasks

| ID | Task | Route | Status | Evidence |
|---|---|---|---|---|
| T1 | Research the open questions; write `docs/research/platform-capabilities.md` | delegated (broad web research) + inline verification of the key claims | done | research doc |
| T2 | Plugin scaffold: `plugin.json`, `marketplace.json`, validation test harness (RED first) | inline | done | RED: no manifest / no skills → GREEN `tests/run.sh` exit 0; commits `6c43e6e`, `083e224`; native review approved (4 lenses, lineage `review-ae3fc37288c0f62c`, acknowledged) |
| T2b | Validator hardening from review advisories R3-003…006 (frontmatter parsing edge cases) | inline | pending | — |
| T3 | `SKILL.md`: preflight, tool directory, both mode flows | delegated writer (writer trigger: 2+ non-trivial files) | done | RED: required-file check failed for all 10 missing files (the writer's pasted RED excerpt was partly reconstructed) → GREEN `tests/run.sh` exit 0, verified by the parent |
| T4 | References: sync rules, Figma structure, minimal-system checklist, `.md` templates | delegated writer (with T3) | done | 7 references plus 3 assets; SKILL.md is 84 lines with a 187-character description |
| T5 | Claude Code trial: local marketplace, both modes, a manual Figma edit round-trip. Also verify that `/design-sync` accepts `DESIGN.md` and what it targets after the claude.ai/design closure | inline + user | in progress | Single-screen mode passed (build, Figma → local, local → Figma); findings below. Full-project mode is retested after T5a/T5b |
| T5a | Trial fixes: enumerate pages through a `use_figma` read; Brief Links without absolute paths; drop the Brief last-sync line; offer usage-rule prose for the Brief; document `.impeccable/`; D12 file naming | delegated writer (writer trigger: 2+ non-trivial files) | done | RED: 10 failures (4 missing references plus 6 structural assertions) → GREEN `tests/run.sh` exit 0, rerun by the parent |
| T5b | Design-quality flow: D13 style discovery and references, D14 quality bar, D15 Claude Design proposals, D16 iteration in Figma | delegated writer (with T5a; preparation trigger: reading impeccable's commands) | done | New `style-discovery.md`, `proposals.md`, `quality-bar.md`, `iteration.md`; SKILL.md 105 lines. Parent verified: Artifact `quickstart` (`intent: design`) returns a Design type on this account; `figma.getLocalTextStylesAsync` / `getLocalEffectStylesAsync` ran in a read script. Unverified until T5c/T6: Desktop Output → Design, impeccable with a pinned style, web search on Desktop |
| T5c | Retest in Claude Code with the reinstalled plugin: full-project mode end to end, including proposals and an iteration request in Figma | user-assisted | done | Full project "Tino" (iOS finance app) built in about 58 minutes: 100 variables, 41 components, 10 screens Light and Dark; critique 25/40 → 27/40; iteration applied in Figma and synced. Findings in the progress log (2026-10-18) |
| T9 | Trial fixes and quality gate: reply in the user's language; brief before style; visual palette by default; file name as its own question; iOS font check; iteration inspects ancestors and prefers local fixes; D21 quality gate; impeccable craft guidance to builders; D22 capability-based write path; D6 revision (`/design-sync` outdated) | delegated writer (writer trigger: 2+ non-trivial files) | done | RED: 16 FAIL lines, exit 1 (writer report) → GREEN `tests/run.sh` exit 0, rerun by the parent. Parent fix: scaled threshold wording (23/32 when two heuristics are n/a). SKILL.md 110 lines, description 191 characters |
| T10 | Per-screen loop (D17), `DESIGN-PLAN.md` tracker (D18), screen definition with research contrast and a reference-source slot (D19), optional dark mode (D20) | delegated writer | pending | — |
| T11 | One-way sync from Figma foundations to a Claude Design System artifact, so later proposals use the project's system | delegated writer | pending | — |
| T6a | Desktop smoke test: Figma connector in chat exposes `use_figma` | user-assisted | done | User screenshot (2026-10-16): Desktop chat lists about 42 Figma tools, `use_figma` included; invocation is tested in T6 |
| T6 | Claude Desktop trial: zip upload, same cases | user-assisted | pending | — |
| T7 | README: install and usage for Code and Desktop | inline | pending | — |
| T8 | Publish the marketplace on GitHub (push is the user's decision) | user decision | in progress | Repo https://github.com/UrielEscorcia/design-to-figma (public, MIT); PRs #1–#3 open; merge pending |

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

## Next step

T10 with a delegated writer (RED first), then T11.
