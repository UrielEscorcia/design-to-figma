# Preflight

Run before any design step. Detect capabilities by inspecting the tool and skill list available in the current session. There is no runtime detection API, so absence from the list means unavailable. If tools are deferred, load their schemas first (for example with a tool search) before concluding they are missing.

## 1. Figma MCP (BLOCK when missing)

Required tools: `use_figma`, `get_metadata`, `get_screenshot`, `create_new_file`. `get_variable_defs` is useful but optional (variables can also be read with a read-only `use_figma` script). `get_design_context` is not required: this skill only reads state, and the Figma MCP requires the `figma-design-to-code` skill before that tool.

- **All present:** continue.
- **Any missing:** STOP. Do not simulate Figma output. Tell the user which tools are missing and how to install:
  - **Claude Code:** `claude plugin install figma@claude-plugins-official`, or add the remote server `https://mcp.figma.com/mcp`.
  - **Claude Desktop (chat and Cowork):** add the Figma connector under Settings / Customize → Connectors, then connect and authorize it.
- **Desktop note:** the Figma connector in Desktop chat lists `use_figma` among its tools (observed 2026-10-16). If the connector is connected but `use_figma` is absent, report that as the blocker rather than working around it.
- **Seat requirement:** the Figma MCP needs a Figma Dev or Full seat. View and Collab seats are limited to 20 MCP calls per month, which is not enough for design work. If calls start failing with a limit error, stop and tell the user.

## 2. Figma official skills (recommended)

`figma-use`, `figma-generate-library`, `figma-generate-design`, `figma-create-new-file` ship with the Figma plugin. If they are not available, continue with the MCP tools but warn that quality rules are reduced.

## 3. impeccable (optional)

- **Present** (an `impeccable` skill is listed): USE it as described in [tool-directory.md](tool-directory.md).
- **Absent:** recommend it once ("install impeccable for deeper discovery, critique and polish"), then continue with [minimal-system-checklist.md](minimal-system-checklist.md).
- **Claude Desktop:** impeccable cannot be uploaded as-is (extra frontmatter keys and a bundled launcher). Expect it to be absent there and use the fallback without treating it as an error.

## 4. Design-capable surface

Claude Design is built into Claude; nothing to install. Confirm one of:

- **Claude Code:** `/design`, or the Artifact tool with the Design type (found through `action: "quickstart"`, `intent: "design"`).
- **Claude Desktop / claude.ai chat:** Output → Design, or the Artifacts Design template.

If none is available, continue: show proposals as quick frames on a `🧪 Explorations` page in Figma ([proposals.md](proposals.md)) and say so in the report. Never route work to claude.ai/design projects (closing 2026-12-14).

## 5. Local write path ladder

Decide where `PRODUCT.md` / `DESIGN.md` are written. Check in order and take the first match:

| Rung | Signal | Target |
|---|---|---|
| 1 | Environment variable `CLAUDECODE=1` (Claude Code) | The project folder (current working directory) |
| 2 | A user-connected folder is mounted (Cowork) | That folder. If several are mounted, ask which one |
| 3 | Anything else, or detection fails or is ambiguous | Downloadable files (no local write) |

Rules:

- Confirm the target path with the user **once**, before the first write. Reuse the answer for the session.
- A failed or uncertain detection falls back to downloads, never to an unconfirmed write.
- Desktop chat cannot write to the user's folder; use downloads there and tell the user where to put the files.
- Detecting `CLAUDECODE` requires running a shell command, which only exists in Claude Code. If no shell tool is available, skip to rung 2 or 3.

## 6. Web research

Style discovery needs current references ([style-discovery.md](style-discovery.md)). Claude Code: `WebSearch` / `WebFetch`. Desktop: web search when enabled. If no web tool exists, continue and mark the references as model knowledge, unverified. This never blocks.

## 7. Project folder contents

The project folder holds `PRODUCT.md`, `DESIGN.md`, optionally `DESIGN.sync.json`, and the `.impeccable/` folder that impeccable creates (its state: surfaces, questions). The whole folder is shareable. Do not edit `.impeccable/` except through impeccable's own flow, and keep absolute paths and machine details out of any file that is shared.

## 8. Preflight report

Before continuing, state in one short block: Figma tools (ok or BLOCKED), seat note, impeccable (used or fallback), design surface, web research (available or unverified), write path (target and whether confirmed).
