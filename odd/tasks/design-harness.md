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
| T1 | S1–S8 | Base: routing reference, SKILL.md wiring, plan template, report, README, guards, v0.4.0 | inline | done (tests pass; review approved and acknowledged, lineage review-38e6fe8ff763b2a1) | `5a91d75` |
| T1a | S6, S7 | Review advisories (non-blocking; only the locations were returned): R3-001 `SKILL.md:95` (step 0 Route), R3-002 `routing.md:57` (Requests log; older plans without a Requests section), R3-003 `routing.md:42` (measured high-risk wording), R3-004/R3-005 `tests/run.sh:279,283` (file-wide guards) | inline | done (inferred from the locations; see Log) | this commit |
| T2 | — | Critique lenses with node ID + screenshot evidence and a refuter | — | pending (next phase) | — |
| T3 | — | Split the skill into trigger-first skills plus a registry | — | pending (next phase) | — |

## Log

- **L1** (2026-10-30) "aqui vamos a quitar lo de Judgment Day de diseño y los tests ya que no tenemos test en diseño, ahora la idea es implementar harness en este plugin pero sin perder lo que ya tenemos y lo que hacemos bien, se podria implementar eso? para definir bien la base antes de implementar la lista de ideas"
- **L2** (2026-10-30) "si suna bien ese plan, un cambio de riesgo que pida confirmacion para validar lo que puede pasar"
- (2026-10-30) T1 RED: 25 new guards failed before the content existed and no earlier guard failed. GREEN: `tests/run.sh` exit 0, and both `claude plugin validate --strict` runs pass. Native review used the readability and reliability lenses: approved with 5 advisories (T1a).
- (2026-10-30) L3 "si corrige las observaciones". T1a fixes, each inferred from its location:
  - R3-001: SKILL.md step 0 now has read-only requests read Figma and has the small route end with the report.
  - R3-003: an unclear high-risk item is measured before the route is chosen.
  - R3-002: small requests are logged too, and older plans get a Requests section without reconstructing earlier requests.
  - R3-004/005: the guards are scoped to their sections; mutation probes fail as expected.
- Context: the direction and gap mapping are in Engram obs 6224; the scope decision is in obs 6235. The idea list (handoff/Code Connect, brownfield, prototypes/FigJam, a11y audit, variants, responsive, motion, Figma quota, fonts in screenshots, direct commands, plugin evals) comes after the base.
