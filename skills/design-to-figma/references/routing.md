# Request routing

Every request is routed here first, before the Decision Gates. Routing decides how much of the flow a request needs; it never removes a Hard Rule. When the route is clear, take it and do not ask about it. Ask one question only when the route itself is unclear.

## 1. Authorize

- **Read-only:** the user asks to review, critique, compare, explain or audit, or asks how something looks. A read-only request writes nothing: no Figma writes, no local file writes, no plan change. Read Figma as in [sync-rules.md](sync-rules.md), answer, and offer the change as a next step. Apply it only when the user asks.
- **Change:** the user asks to create or modify. Continue with step 2.
- **Unclear** (for example "this card feels off"): ask once whether to change it or only review it, then wait.

## 2. Size

A change is **small** when all three hold:

1. It modifies something that already exists in Figma: a node, a frame, an instance, a text, or one screen's spacing or color.
2. The target and the outcome are clear, with no new product, style, palette or direction decision.
3. No high-risk item (step 3) applies, or the user confirmed it (step 4).

Anything else is **large**. The number of nodes or frames alone never decides the size.

| Route | When | Flow |
|---|---|---|
| Small (inline) | Small change | [iteration.md](iteration.md) |
| Screen mode | One new screen or view | [workflow-screen.md](workflow-screen.md), unchanged |
| Project mode | A new project, many screens, or a design system | [workflow-project.md](workflow-project.md), unchanged |
| Ask | New work but the mode is unclear | The mode question in the Decision Gates |

The small route skips the gates that are already settled: brief, category references, style, palette, proposals, file name and foundations. It reuses the existing system. It keeps all the Hard Rules, including preflight, reading Figma first, `figma-use`, never silently overwriting, the user's language and asking before spending credits. It also keeps the critique checklist on the changed area, the sync and the report. When the user approved the write path in an earlier run and the local files are there, the preflight report is one line.

A small change that turns out to need a new decision (a new component, a new screen state, a style change) becomes large. Say so in one line and switch route.

## 3. Design high-risk items

A change is high risk when a mistake reaches beyond its target or is hard to undo:

1. **Shared tokens.** Editing, renaming or deleting a variable, a variable mode or a style that other nodes use.
2. **Shared components.** Editing a main component or a component set whose instances live on other screens, or detaching instances.
3. **Deletion.** Deleting or replacing pages, frames, components or variables, or anything the user did not name.
4. **Brand foundations.** The palette, type families, logo, or the confirmed style or direction.
5. **App-wide rules.** A change that applies to every built screen and sends approved screens back to `built` ([iteration.md](iteration.md) step 9).

The size check counts a high-risk item only after it is measured. A local override of one instance is not a shared component change.

## 4. Confirm a high-risk change

Before applying a high-risk change, measure its reach with a read-only `use_figma` script (load `figma-use` first). For example, find the nodes bound to the variable through `boundVariables`, the instances of the component through `getInstancesAsync`, or the pages that hold the frames. Then send one message:

- **Change:** what will change, in one line.
- **Reach:** the screens, frames and components that follow it, with counts and node links.
- **Undo:** how the change is reverted (an edit back, a rebind, Figma version history), or "not cleanly" when it breaks bindings or instances. Name the plan states that go back to `built`.
- **Smaller option:** the local alternative when one exists (an instance override, a screen-level change), or "none".

Ask the user to apply it, take the smaller option or cancel, and wait. Without a yes, apply nothing. When a plan exists, record the answer in its Requests log. After a yes, a small change stays on the inline route.

## 5. Record requests verbatim

When `DESIGN-PLAN.md` exists or is created, its `## Requests` section holds the user's original request as **L1**, verbatim. Later corrections, decisions and high-risk confirmations are appended as L2, L3 and so on, with the date. Never paraphrase them. A screen definition names the L# it comes from. Builders and reviewers, including delegated subagents, get the plan path and the section to read by reference, never a summary ([tool-directory.md](tool-directory.md)). With no plan, the report quotes the request.

## 6. Close with the route and risk

The report adds the **Route and risk** line to the Output Contract: the route taken (read-only, small, screen or project), then `Risk: none` or `Risk: item N (reason), confirmed by the user`.
