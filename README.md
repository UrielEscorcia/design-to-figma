# design-to-figma

A Claude skill for design work that must end up in Figma. It runs the whole flow, from the product brief through the style, the directions and the screens, and builds the result in Figma, which stays the source of truth. It coordinates three tools: Claude Design for the proposals, [impeccable](https://impeccable.style) (optional) for discovery, critique and polish, and the Figma MCP for every write.

It designs; it does not write product code.

## What it does

- **Full project:** brief, style discovery, 2 or 3 directions, foundations and components in Figma, then each screen through a review loop (build, verify, polish, your review).
- **Single screen:** the same quality bar for one screen, reusing an existing project's system or bootstrapping a minimal one.
- **Iteration:** change requests on an existing design, including after someone edited the Figma file by hand. Figma is read first, and manual edits are kept.

It asks one question at a time and waits for your answer before it writes anything to Figma. It keeps `PRODUCT.md`, `DESIGN.md` and `DESIGN-PLAN.md` in your project folder in sync with Figma.

## Requirements

| Requirement | Needed | Notes |
|---|---|---|
| Figma MCP | Yes | The skill stops when it is missing. Needs a Figma Dev or Full seat; View and Collab seats get 20 MCP calls a month, which is not enough. |
| Figma plugin skills (`figma-use`, `figma-generate-design`, `figma-generate-library`, `figma-create-new-file`) | Recommended | Installed with the Figma plugin in Claude Code. Without them the skill continues with reduced quality rules. |
| impeccable | Optional | Deeper discovery, critique and polish. When it is missing, the skill asks whether to install it or continue with its built-in checklist. |
| Claude Design | Built in | Proposals render as Design artifacts. Without it they go to an `🧪 Explorations` page in Figma. |

## Install in Claude Code

1. Install the Figma plugin, which brings the Figma MCP and its skills:

   ```sh
   claude plugin install figma@claude-plugins-official
   ```

2. Add this marketplace and install the plugin:

   ```sh
   claude plugin marketplace add UrielEscorcia/design-to-figma
   claude plugin install design-to-figma@design-to-figma
   ```

3. Optional: install impeccable from https://impeccable.style.
4. Start a new session.

To update later:

```sh
claude plugin marketplace update design-to-figma
claude plugin update design-to-figma@design-to-figma
```

## Install in Claude Desktop

1. Add the Figma connector under Settings → Connectors, then connect and authorize it.
2. Build the skill zip from a clone of this repository. The zip must contain the `design-to-figma` folder itself:

   ```sh
   cd skills && zip -r ../design-to-figma.zip design-to-figma
   ```

3. Upload `design-to-figma.zip` under Settings → Capabilities → Skills.
4. Optional: add impeccable (next section).
5. Start a new chat.

To update, build a new zip from the updated clone and upload it again.

### impeccable in Claude Desktop

The upstream impeccable folder cannot be uploaded as is: Desktop rejects some of its frontmatter keys and descriptions over 200 characters. Build a personal copy from an installed impeccable (for example `~/.claude/skills/impeccable`):

1. Copy the `impeccable` folder somewhere else.
2. In its `SKILL.md` frontmatter, remove the `version`, `user-invocable` and `argument-hint` keys. Keep `license`.
3. Shorten `description` to 200 characters or less.
4. Remove `scripts/bin/` (native binaries that cannot run in the Desktop sandbox).
5. Zip the `impeccable` folder and upload it under Settings → Capabilities → Skills.

impeccable is licensed under Apache 2.0. Keep its license notice in the copy and list the changes you made. The copy is for your own use: do not share or redistribute it. This repository does not include it.

On Desktop, impeccable's launcher cannot run. It says "Context loading did not run" and reads `PRODUCT.md` and `DESIGN.md` directly. That is expected.

## Usage

Ask in plain words. The skill loads when the request has a Figma destination:

- "Design a booking app for a barbershop in Figma: login, service list and checkout."
- "Design one screen in Figma: the pickup checkout for a coffee shop."
- "In my Figma file, make the cards denser and change the primary color."

The first message is a preflight report: which tools are available, whether impeccable is used, and where the local files will be written. Confirm the folder there. Then the skill asks the brief, one question at a time.

### Files in your project folder

| File | Content |
|---|---|
| `PRODUCT.md` | The brief: users, problem, screens, language and locale, dark mode. |
| `DESIGN.md` | The chosen style, tokens and components, with the Figma file header and a sync snapshot. |
| `DESIGN-PLAN.md` | Project mode: the screen list and the status of each step, so work can resume later. |
| `.impeccable/` | impeccable's own state, when impeccable is used. |

Without a writable folder (web, mobile, or older chats), the files are delivered as downloads.

## Development

```sh
tests/run.sh
```

It validates the skill frontmatter and structure, checks the rules the trials depend on, and requires a version bump in `.claude-plugin/plugin.json` and the `SKILL.md` metadata for any change to the skill.

## License

MIT. See [LICENSE](LICENSE).
