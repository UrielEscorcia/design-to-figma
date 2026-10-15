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
| `/design-sync` (Claude Code) imports a design system from a GitHub repo, design files, raw uploads or a local codebase. | VERIFIED | same |
| Designs automatically use the design system's colors, type and components, and Claude checks its output against it. | VERIFIED | same |
| Cowork is not mentioned. | VERIFIED (absent) | same |
| No public API or MCP exists for reading a design-system project. | UNKNOWN | — |

**Implication:** never target claude.ai/design projects. The skill works with Claude's built-in design capability (chat, Artifacts, `/design`) and with the design system Claude uses. In Claude Code, `/design-sync` is the route for loading the Figma-derived system.

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
  - Whether `use_figma` is exposed in Desktop chat is **UNKNOWN**. Smoke-test it before relying on it.

## 6. Validation tooling

- `claude plugin validate <path> [--strict] [--json]` checks `plugin.json`, `marketplace.json`, and the skills, agents and commands in a plugin. Exit codes are 0, 1 and 2. Source: [plugin CLI reference](https://code.claude.com/docs/en/plugins/cli-reference.md) (VERIFIED).
- It ignores a `SKILL.md` at the plugin root; skills must live in `skills/<name>/`.
- `claude plugin eval` also exists, for behavioral eval suites.

## Impact on decisions

| Decision | Change |
|---|---|
| D2 Preflight | Claude Design is built in, not installed. Preflight checks (a) that the Figma MCP tools are present (`use_figma`, `get_design_context`, `get_variable_defs`); (b) impeccable (optional); (c) a design-capable surface. Missing Figma tools block. |
| D5 Context storage | Direct writes only in Claude Code and in Cowork with a connected folder. Desktop chat needs a decided fallback. |
| D6 Sync | Target "the design system Claude uses" (`/design-sync` in Code), not claude.ai/design projects, which close 2026-12-14. |
| D8 Bootstrap | impeccable is effectively Code-only, so the fallback checklist is mandatory on Desktop. |
| New prerequisite | A Figma Dev or Full seat. |
| T2 runner | `claude plugin validate --strict`, plus a frontmatter check script (allowed keys, `name` ≤ 64, `description` ≤ 200). |
