# Changelog

All notable changes to the design-to-figma plugin. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses [Semantic Versioning](https://semver.org/). Every version has a tag (`vX.Y.Z`) and a GitHub release with the Desktop zip attached.

## [0.7.0] - 2026-11-04

### Added
- Brownfield adoption (`references/brownfield.md`). A Figma file the plugin did not create is adopted read-only before the request runs. It is read with `snapshot.js` and `measure.js` and a few screenshots. The user confirms a summary: the page map, the system inventory, the look, an inferred brief and health counts. Then `PRODUCT.md` and `DESIGN.md` are written with `scope: adopted`, and the snapshot becomes the sync baseline.
- Work in an adopted file keeps the file's own pages and reuses its components and values. Its look counts as provided, so style discovery is not asked. Without a Brief page, app-wide rules go to `DESIGN.md` only.
- High-risk item 6 (adopted file structure): adding pages, tokenizing hardcoded values or reshaping content the request did not name in an adopted file needs the measured-reach confirmation.

## [0.6.0] - 2026-11-04

### Added
- `assets/scripts/measure.js` is a read-only `use_figma` script that measures several frames in one call. It reports text contrast from resolved variables (mode, opacity and translucent text composited over its background), the text-size floor, touch targets, values not bound to a variable or style, and frames that look like detached components. The critique lenses and the refuter use it as their evidence.
- `assets/scripts/snapshot.js` is a read-only `use_figma` script that returns the sync snapshot (pages, frames, components, styles and variable values per mode, sorted) in one call.
- `tests/figma-scripts.test.mjs` runs both scripts against a fake Figma API, so they are tested without a Figma file or any MCP call. `tests/run.sh` runs it when Node is available.

## [0.5.0] - 2026-11-04

### Added
- Four critique lenses (`references/critique-lenses.md`): hierarchy and readability, accessibility, system consistency, and copy and UX. Each finding needs evidence (node ID, screenshot, rule, measured value, severity) or it is dropped.
- A refuter re-measures every P0/P1 lens finding with a read-only Figma script. Only confirmed findings count for the quality gate and the fix batch; unverifiable ones stay at P2.
- Lenses run in proportion to the change: all four on new screens and the final cross-screen review, and only the covering lenses on small changes. The screen review gets a **Lenses** field.

## [0.4.7] - 2026-11-03

### Fixed
- Every report carries the full Output Contract, small and read-only runs included. No field is dropped, Route and risk comes first, and Pending conflicts is always present. ([#24](https://github.com/UrielEscorcia/design-to-figma/pull/24))
- App-wide rules are written to `DESIGN.md` and the Brief page without asking. (#24)
- Component states and variants are never faked (painted backgrounds, overlays, detaching). The agent adds the variant or reports the gap. (#24)
- Every question form marks a recommended option, high-risk decisions included. A question that depends on another answer waits for a later turn. (#24)

## [0.4.6] - 2026-11-03

### Fixed
- Critique fixes are split into design fixes, which are applied, and product additions, which are asked in one multi-select form and built only when accepted. This covers every critique, the chosen-direction critique included. ([#23](https://github.com/UrielEscorcia/design-to-figma/pull/23))

## [0.4.5] - 2026-11-03

### Added
- Hard Rule 18: questions with defined options go through the surface's question form (`AskUserQuestion` in Claude Code, the options form in Desktop), with the recommended option first. Each form holds one gate. ([#22](https://github.com/UrielEscorcia/design-to-figma/pull/22))

## [0.4.4] - 2026-11-02

### Fixed
- Every screen in `📱 Screens`, system test screens included, runs the full screen loop before approval. ([#21](https://github.com/UrielEscorcia/design-to-figma/pull/21))
- No backup or temporary files (`.bak`, `.orig`, `.tmp`) are left in the user's folder. (#21)

## [0.4.3] - 2026-11-02

### Fixed
- Directions stay inside a UI reference the user provided. Only structure, hierarchy and density vary; radius, elevation, color use, type and imagery are kept. ([#20](https://github.com/UrielEscorcia/design-to-figma/pull/20))

## [0.4.2] - 2026-11-02

### Added
- A palette, typography or look already given in the request or its attachments is recorded as provided by the user and never asked again. Category references still run, to learn how real products are built. ([#19](https://github.com/UrielEscorcia/design-to-figma/pull/19))

### Fixed
- A provided palette gates the directions until its pairs that fail AA are resolved. (#19)
- `evals/setup.sh` explains a missing Figma plugin instead of exiting silently. (#19)

## [0.4.1] - 2026-10-31

### Fixed
- The skill loads before the official Figma skills: its description is now a MANDATORY first step, in any language, before attachments or any Figma tool. ([#18](https://github.com/UrielEscorcia/design-to-figma/pull/18))

### Added
- Trigger evals (`claude plugin eval`) with a real Desktop prompt that must load the skill and a design-to-code prompt that must not. (#18)

## [0.4.0] - 2026-10-30

### Added
- Request routing (`references/routing.md`). Read-only requests write nothing, small changes run inline, and new screens and projects keep the full flow. High-risk changes (shared tokens, shared components, deletion, brand foundations, app-wide rules) are applied only after the user confirms their measured reach. ([#17](https://github.com/UrielEscorcia/design-to-figma/pull/17))
- `DESIGN-PLAN.md` keeps the user's requests verbatim (L1, L2…), and builders read them by reference. (#17)
- The report starts with a Route and risk line. (#17)

### Changed
- README redesign with a contents menu, diagrams and the Desktop marketplace install. ([#16](https://github.com/UrielEscorcia/design-to-figma/pull/16))

## [0.3.4] - 2026-10-29

### Added
- README with install and usage for Claude Code and Claude Desktop, including the impeccable repack for Desktop. ([#12](https://github.com/UrielEscorcia/design-to-figma/pull/12))

## [0.3.3] - 2026-10-29

### Fixed
- The preflight report is its own message and confirms the write path. A missing impeccable is asked as its own question. ([#11](https://github.com/UrielEscorcia/design-to-figma/pull/11))

## [0.3.2] - 2026-10-28

### Fixed
- One gate per turn, and a complete screen review message (verdict, score, polish, elevate, open gaps). ([#10](https://github.com/UrielEscorcia/design-to-figma/pull/10))

## [0.3.1] - 2026-10-28

### Added
- Blind screen scoring and an elevate pass in the screen loop. ([#9](https://github.com/UrielEscorcia/design-to-figma/pull/9))

### Fixed
- Platform font swap handled structurally and left to the user's Figma desktop app. (#9)
- An agreed definition is required for each screen, and the agent asks before adding product features. (#9)

## [0.3.0] - 2026-10-27

### Added
- Category research and palette confirmation gates before any direction. ([#8](https://github.com/UrielEscorcia/design-to-figma/pull/8))

## [0.2.0] - 2026-10-18

### Added
- Quality gate, per-screen loop, `DESIGN-PLAN.md` tracker and optional dark mode. ([#4](https://github.com/UrielEscorcia/design-to-figma/pull/4), [#5](https://github.com/UrielEscorcia/design-to-figma/pull/5))
- One-way sync from Figma foundations to a Claude Design System artifact. ([#6](https://github.com/UrielEscorcia/design-to-figma/pull/6))
- Version bump enforcement in `tests/run.sh`. ([#7](https://github.com/UrielEscorcia/design-to-figma/pull/7))

## [0.1.0] - 2026-10-16

### Added
- First release: plugin manifests, the `design-to-figma` orchestrator skill (Claude Design, impeccable and the Figma MCP, with Figma as the source of truth) and skill validation tests. ([#1](https://github.com/UrielEscorcia/design-to-figma/pull/1), [#2](https://github.com/UrielEscorcia/design-to-figma/pull/2), [#3](https://github.com/UrielEscorcia/design-to-figma/pull/3))
