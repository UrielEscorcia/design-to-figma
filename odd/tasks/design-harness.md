# Feature: design harness for design-to-figma

- **Engram mirror:** `odd/design-harness/tasks`
- **Branch:** `feat/d2f-17-harness-base` (from `main` at `186500b`)
- **Goal:** make design-to-figma for designers what gentle-ai is for developers, keeping the current flow intact. Define the base before the idea list.

## Specs

- **S1** Add the harness without losing the current flow: "implementar harness en este plugin pero sin perder lo que ya tenemos y lo que hacemos bien". The Hard Rules, gate sequence, screen loop, quality gate, sync rules, Design System artifact and `DESIGN-PLAN.md` stay as they are for large work.
- **S2** Out of scope: "quitar lo de Judgment Day de diseño y los tests ya que no tenemos test en diseño". `tests/run.sh` keeps checking the plugin's own structure.
- **S3** Authorize: a read-only request (review, compare, explain) writes nothing to Figma or to the local files.
- **S4** Size: a small change (a clear tweak to something that already exists, with no new product or style decision and no high-risk item) runs inline through `iteration.md` and skips the brief, style, palette, proposal and file gates. A large change (a new project or a new screen) follows the current flow unchanged.
- **S5** Design high-risk items: shared tokens or variables, components used by several screens, deleting frames, and brand foundations.
- **S6** High-risk changes ask for confirmation. User's words: "un cambio de riesgo que pida confirmacion para validar lo que puede pasar". Before applying, show the measured reach, whether the change can be undone and a smaller alternative; apply nothing without a yes.
- **S7** Verbatim requests: the user's original request is stored verbatim in `DESIGN-PLAN.md` and passed to builders by reference, never paraphrased.
- **S8** The final report states the route taken and a risk line.

## Tasks

| ID | Specs | Task | Route | Status | Commit |
|---|---|---|---|---|---|
| T1 | S1–S8 | Base: routing reference, SKILL.md wiring, plan template, report, README, guards, v0.4.0 | inline | in progress | — |
| T2 | — | Critique lenses with node ID + screenshot evidence and a refuter | — | pending (next phase) | — |
| T3 | — | Split the skill into trigger-first skills plus a registry | — | pending (next phase) | — |

## Log

- **L1** (2026-10-30) "aqui vamos a quitar lo de Judgment Day de diseño y los tests ya que no tenemos test en diseño, ahora la idea es implementar harness en este plugin pero sin perder lo que ya tenemos y lo que hacemos bien, se podria implementar eso? para definir bien la base antes de implementar la lista de ideas"
- **L2** (2026-10-30) "si suna bien ese plan, un cambio de riesgo que pida confirmacion para validar lo que puede pasar"
- Context: the direction and gap mapping are in Engram obs 6224; the scope decision is in obs 6235. The idea list (handoff/Code Connect, brownfield, prototypes/FigJam, a11y audit, variants, responsive, motion, Figma quota, fonts in screenshots, direct commands, plugin evals) comes after the base.
