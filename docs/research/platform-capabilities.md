# Platform capabilities research

- **Date:** 2026-10-15
- **Task:** T1 of `odd/tasks/design-to-figma.md`
- **Labels:** **VERIFIED** means an official doc states it. **INFERRED** means a reasonable conclusion the docs don't state. **UNKNOWN** means no source found.

## 1. Claude Design

| Claim | Label | Source |
|---|---|---|
| The standalone claude.ai/design closes on **December 14, 2026**. Existing projects stay until then; migrate design systems before that date. | VERIFIED | [Get started with Claude Design](https://support.claude.com/en/articles/14604416-get-started-with-claude-design) |
| Migrated design systems "can move over, so Claude can use them in any chat, including in Claude Code." | VERIFIED | same |
| Design now runs inside conversations (**Output → Design**, built beside the chat), from the Artifacts tab (Design template), on mobile, and in Claude Code through `/design`. | VERIFIED | same |
| `/design-sync` (Claude Code) imported a design system into the standalone product. Superseded 2026-10-18 (section 7); the skill no longer mentions it. | VERIFIED (historical) | same |
| Designs automatically use the design system's colors, type and components, and Claude checks its output against it. | VERIFIED | same |
| Cowork is not mentioned. | VERIFIED (absent) | same |
| No public API or MCP exists for reading a design-system project. | UNKNOWN | — |

**Design System Artifact type (checked 2026-10-18).** Design systems are artifacts made from a published "Design System" type, found with the Artifact tool (never a hardcoded URL; two links for it were seen on the same day). The type ships `SKILL.md` and `reference/from-design-tool.md`, a procedure to import from a design tool through its connector (first sync and re-sync). That procedure reads tokens with the connector's variables call, which yields one theme; the script-based variable read returns every mode and maps Light/Dark to `color.themes`. A re-sync proceeds only if `tokens.json` `meta.file` matches the user's file link. Content lives under `project/` (`design-system.json` index written last, `tokens.json`, `README.md`, components).

**Implication:** never target claude.ai/design projects. The skill works with Claude's built-in design capability (chat, Artifacts, `/design`) and with the design system Claude uses. (Superseded by section 7: design systems are now artifacts in Claude.)

## 2. Writing local files from Desktop

| Claim | Label | Source |
|---|---|---|
| Cowork reads and writes local files only in folders the user has connected. | VERIFIED | [Getting started with Cowork](https://support.claude.com/en/articles/13345190-getting-started-with-cowork) |
| Chat "code execution and file creation" produces files in a sandbox. It is not documented as writing to a local folder. | VERIFIED / INFERRED | [support article 12111783](https://support.claude.com/en/articles/12111783) |
| MCPB desktop extensions run locally over stdio. That page lists availability as Team and Enterprise; whether individual plans can install them is not confirmed. | VERIFIED (doc wording) / UNKNOWN (individual plans) | [MCPB](https://claude.com/docs/connectors/building/mcpb) |

**Implication:** writing `PRODUCT.md` / `DESIGN.md` directly works in Claude Code and in Cowork with a connected folder. Desktop chat needs another delivery path (pending decision).

## 3. Plugins per surface

| Component | Chat | Cowork | Claude Code |
|---|---|---|---|
| Skills | loads | loads | loads |
| Commands | loads as a skill | loads | loads |
| Agents / hooks | ignored | loads | loads |
| Remote MCP (http/sse, fixed URL) | shown on the plugin's Connectors tab; usable after the user connects | loads | loads |
| Local MCP | ignored | loads | loads |
| Top-level `bin/` executables | blocks install | blocks install | loads |

- **Limits:** 5,000 files and 200 MB per plugin. Source: [platform support](https://claude.com/docs/plugins/platform-support) (VERIFIED).
- **Dependencies:** `plugin.json` `dependencies` can name other plugins with semver ranges. A skill cannot declare a dependency on a skill or a connector. Source: [plugin dependencies](https://code.claude.com/docs/en/plugins/dependencies.md) (VERIFIED).
- **Runtime detection:** there is no documented way to detect another skill or connector at runtime (UNKNOWN). The practical approach is to check the available tool list for known tool names and degrade gracefully (INFERRED).

## 4. Skill upload restrictions

- **Allowed keys:** outside Claude Code, only `name`, `description`, `license`, `compatibility`, `metadata` and `allowed-tools`. Any other key is a hard error. Source: [Skills](https://code.claude.com/docs/en/skills.md) (VERIFIED).
- **Field limits:** `name` max 64 characters, `description` max 200 characters on claude.ai. The zip root must be the skill folder. Source: [Use custom skills](https://support.claude.com/en/articles/12512198-use-custom-skills) (VERIFIED).
- **impeccable:** v4.3.1 uses `version`, `user-invocable` and `argument-hint`. It cannot be uploaded to Desktop as-is and depends on a bundled launcher binary.
  - In practice: available in Claude Code; Desktop runs the built-in fallback (INFERRED).
- **Our skill:** keep the six keys only, and put `version` under `metadata`.

## 5. Figma MCP

- **Endpoint:** `https://mcp.figma.com/mcp`. Source: [remote server installation](https://developers.figma.com/docs/figma-mcp-server/remote-server-installation/) (VERIFIED).
- **Tools:** source is [tools and prompts](https://developers.figma.com/docs/figma-mcp-server/tools-and-prompts/) (VERIFIED).
  - Read: `get_design_context`, `get_variable_defs`, `get_metadata`, `get_screenshot`, `get_libraries`, `search_design_system`, `whoami`, `download_assets`.
  - Write: `use_figma`, `create_new_file`, `generate_figma_design`, `upload_assets`.
- **Rate limits:** source is [rate limits and access](https://developers.figma.com/docs/figma-mcp-server/rate-limits-access/) (VERIFIED).
  - View and Collab seats: **20 calls per month**.
  - Dev and Full seats: 200 per day (Starter and Professional) or 600 per day (Enterprise).
  - Some write tools are exempt; `use_figma` is not confirmed as exempt.
  - **Prerequisite:** a Dev or Full seat.
- **Desktop status:**
  - Users do connect the Figma cloud connector in Claude Desktop, but forum reports show connection bugs ("Server not found", duplicate local and remote entries). Sources: [Figma forum 54700](https://forum.figma.com/report-a-problem-6/figma-mcp-connector-in-claude-desktop-server-not-found-on-connect-can-t-disconnect-54700), [Figma forum 56867](https://forum.figma.com/report-a-problem-6/local-figma-mcp-server-doesn-t-integrate-with-claude-desktop-even-though-everything-is-connected-on-claude-s-side-56867) (INFERRED).
  - `use_figma` **is exposed in Desktop chat** (VERIFIED by user observation, 2026-10-16). Asked which Figma tools it had, Desktop chat listed about 42 connector tools, including `use_figma`, `create_new_file`, `upload_assets`, `get_design_context`, `get_screenshot`, `get_metadata`, `get_variable_defs`, `get_libraries`, `search_design_system`, `download_assets` and `whoami`. An actual `use_figma` call from Desktop is still untested (T6).
  - The same listing shows tools not in the official tools page used above: `generate_diagram`, `generate_image`, `get_figjam`, `get_motion_context`, `send_code_to_figma`, `export_video`, Code Connect mapping tools, shader and generative-plugin tools, and Weave tools. They are out of scope for v1.

## 6. Validation tooling

- `claude plugin validate <path> [--strict] [--json]` checks `plugin.json`, `marketplace.json`, and the skills, agents and commands in a plugin. Exit codes are 0, 1 and 2. Source: [plugin CLI reference](https://code.claude.com/docs/en/plugins/cli-reference.md) (VERIFIED).
- It ignores a `SKILL.md` at the plugin root; skills must live in `skills/<name>/`.
- `claude plugin eval` also exists, for behavioral eval suites.

## Impact on decisions

| Decision | Change |
|---|---|
| D2 Preflight | Claude Design is built in, not installed. Preflight checks (a) that the Figma MCP tools are present (`use_figma`, `get_design_context`, `get_variable_defs`); (b) impeccable (optional); (c) a design-capable surface. Missing Figma tools block. |
| D5 Context storage | Direct writes only where a folder is writable: Claude Code, or a connected local folder (Cowork, or the unified Claude experience on desktop). Chosen by capability, not surface name (D22); downloads are the fallback. Revised 2026-10-18. |
| D6 Sync | Targets: local `.md` and a Claude Design System artifact (one-way, write-only, from Figma), not claude.ai/design projects, which close 2026-12-14. Claude Design now lives in Claude as artifacts, including design systems, so `/design-sync` is dropped. Revised 2026-10-18. |
| D8 Bootstrap | impeccable is effectively Code-only, so the fallback checklist is mandatory on Desktop. |
| New prerequisite | A Figma Dev or Full seat. |
| T2 runner | `claude plugin validate --strict`, plus a frontmatter check script (allowed keys, `name` ≤ 64, `description` ≤ 200). |

## 7. Unified Claude experience and Claude Design migration (2026-10-18)

| Claim | Label | Source |
|---|---|---|
| "Claude Cowork is now just Claude": chat and Cowork merge. Rolling out to Pro and Max; Team in beta on web and mobile; Enterprise in beta. | VERIFIED | [support article 15520349](https://support.claude.com/en/articles/15520349) |
| Connected local folders are readable and writable from the desktop app, which must be open. | VERIFIED | same |
| Skills, plugins and connectors work on desktop, web and mobile. Local MCP servers are desktop only. | VERIFIED | same |
| Enterprise public beta is off by default; work moves into an isolated cloud sandbox. Design is not mentioned. | VERIFIED | [support article 17444462](https://support.claude.com/en/articles/17444462) |
| "Claude Design now lives in Claude": new designs, design systems and decks are created as artifacts. | VERIFIED | [support article 17440474](https://support.claude.com/en/articles/17440474) |
| Migrated design systems appear in the design system menu and cannot be edited on their page yet. The standalone product closes 2026-12-14. | VERIFIED | same |
| Design output and a connected folder can be used together in one conversation. | INFERRED (needs the T6 trial) | — |

**Implication:** choose the write path by capability (a project or connected folder is writable), not by surface name; "Desktop chat" no longer implies downloads only. Design systems are artifacts, so `/design-sync` is not a route.
