# Screen loop

Every screen runs this loop: each screen of a project, and the single screen in screen mode. Problems are caught on the first screen, not after the whole project. Read Figma first ([sync-rules.md](sync-rules.md)).

**Budget.** The loop has its own explicit budget, stated here once and replacing the per-run limit in [quality-bar.md](quality-bar.md) for screens: one build; one agent verify plus at most 2 re-verifies after self-fix; at most 2 self-fix batches; one polish pass; one elevate pass with one extra verify (step 5); the user-requested iterations; one final verify; one Dark verify when requested. An extra round after a failed gate runs only with the user's consent, as a new bounded run.

Cost: each loop spends Figma MCP calls (per Figma's rate-limit documentation, checked 2026-10-15: 200 per day on Dev and Full seats on Starter and Professional plans, 600 on Enterprise). Batch screenshots and take one render per verify.

- Record the calls each screen used on its `Figma calls used` line in the plan (or in the report when there is no plan). The first screen's count is the estimate for the next ones.
- Before a screen or a pass, check that the calls made today, as far as you can count them, plus the estimate stay under the daily limit. When they would not, stop at a clean point while calls remain (finish or revert the current write), record the state and the next step in the plan, tell the user and resume later.
- After a rate-limit error, no Figma call can revert anything. Record the partial state in the plan instead: what was written, what is missing, and any duplicate frame left by the elevate pass. Clean it up first on resume.
- Never leave a half-built screen unrecorded.

## 1. Define the screen

- Ask how the screen should work: purpose, primary action, content, states, edge cases. One question at a time; wait for each answer.
- A definition you derived yourself (from the chosen direction, a critique or an earlier screen) is only a proposal. Show it in a few lines with the choices that change behavior (for example time-slot spacing, defaults, what is hidden), contrast those choices with the category references, and wait for the user's yes before building.
- Do not accept every request as-is. Contrast it with the confirmed style research ([style-discovery.md](style-discovery.md)) and with real screens of the same type from the reference source ([tool-directory.md](tool-directory.md)). Propose concrete suggestions: "in products X and Y this is solved by...; here it would look like...". Mark references as unverified when no research tool exists.
- Use the user-review findings for the category (PRODUCT.md, [style-discovery.md](style-discovery.md)): what users ask for and what frustrates them in this type of screen. Agree with the user what will be built. Record the agreed definition, with the date the user agreed it, in `DESIGN-PLAN.md` under that screen when a plan exists ([DESIGN-PLAN.template.md](../assets/DESIGN-PLAN.template.md)); otherwise record it in the screen section of `DESIGN.md` and in the report. Skip the questions only when the user already gave a complete definition.

## 2. Build

Build the screen in Light (or the single mode) with the builder guidance in [tool-directory.md](tool-directory.md). Reuse existing components and variables; add a component only when the screen needs one. State becomes `built`.

## 3. Agent verify

- A fresh, isolated reviewer (a subagent when available) runs impeccable's `critique` Assessment A on `get_screenshot` renders of this screen. Scoring is blind, with the inputs and outputs set in [quality-bar.md](quality-bar.md) (Quality gate), including the single biggest opportunity to move the screen from correct to excellent. The parent applies the quality gate in [quality-bar.md](quality-bar.md) to that report: P0/P1, specificity and heuristics conditions. Declare the run degraded (no Assessment B on Figma).
- Without impeccable, the reviewer applies the built-in checklist in [quality-bar.md](quality-bar.md).
- A re-verify is a fresh blind reviewer that does not see the earlier report; the parent checks separately whether the earlier P0/P1 items are resolved.
- State becomes `agent-verified` when the gate passes.

## 4. Self-fix

If the gate fails, apply one fix batch in Figma ([iteration.md](iteration.md)) and verify again. At most 2 self-fix rounds. If the screen is still below the gate, do not loop: carry the open gap to the user review.

Then run one mandatory `polish` pass on the screen (impeccable's `polish`, or item 10 of the built-in checklist in [quality-bar.md](quality-bar.md)) before the user review. Critique (step 3) and polish are both required for every screen; never skip either.

## 5. Elevate pass

After the gate passes and polish is done, and before the user review, move the screen from correct to excellent. If the gate still fails after the self-fix rounds, skip this pass and carry the gap to the user review. Skip it too when the remaining calls cannot cover it (Cost, above), and say so.

Take the reviewer's named biggest opportunity and apply one pass with the matching impeccable command:

| Opportunity | Command |
|---|---|
| Character: the screen reads generic or safe | `bolder`, or `delight` for small moments |
| Hierarchy or layout | `layout` |
| Too many elements competing | `distill` |
| Too loud or busy | `quieter` |
| Typography | `typeset` |
| Color | `colorize` |

- Duplicate the frame first so the previous version can be restored. Stay within the confirmed style, palette and rules. Without impeccable, apply the opportunity directly.
- Verify again with a fresh blind reviewer. Keep the elevated version when it still passes the gate, adds no P0 or P1 finding and breaks no rule. Scores are not compared between the two reviewers: their differences are noise. Otherwise restore the duplicate and report it. Delete the unused duplicate.
- A rate-limit error mid-pass follows the rule in Cost, above: record the duplicate in the plan and restore it on resume.
- One elevate pass and one extra verify per screen.

## 6. User review

- Always ask for human review. Show the screenshot or Figma link, the verdict, the score, what the elevate pass changed and any open gap.
- The user approves or requests changes. Apply each change in Figma per [iteration.md](iteration.md) and show it again until the user approves. A change for the whole app rather than this screen is an app-wide rule ([iteration.md](iteration.md), step 9).
- When a change alters the agreed behavior, whether it came from a self-fix, the polish or elevate pass or a user-review change, name it in the review as a change to what was agreed. Update the screen's definition in `DESIGN-PLAN.md` in the same step (with the new agreement date once the user approves), so the plan never contradicts `DESIGN.md` or Figma.
- Never add a new product feature (an action, a label, content or a behavior the agreed definition does not have) on your own, whether it comes up in a fix, the polish or elevate pass or a user-review change. Recommend it, say why, and add it only after the user agrees.
- State becomes `user-approved`. Do not start the next screen before approval unless the user explicitly says to batch.

## 7. Final verify

After the user's iterations, run one more blind agent verify against the same gate and the standards fixed at the start (style, brief, `DESIGN.md`). Report the result. If it fails, say what failed and offer a fix; the user decides. State becomes `final-verified` when it passes.

## 8. Dark mode (only if requested)

Only when the user asked for dark mode ([figma-structure.md](figma-structure.md)). When dark mode was requested up front, `Semantic` already has Light and Dark modes from foundations. When it is requested later and `Semantic` has only one mode, first add a Dark mode to it and set its values (ask the user to confirm the dark palette), then continue. If adding the mode fails because the Figma plan has a mode limit (plans limit modes per collection), stop, tell the user the plan limit and offer a separate Dark collection or a plan upgrade; never half-apply. Build the Dark frame only after the Light screen is `user-approved`: switch a copy of the frame to Dark (or build the Dark frame), agent-verify it, and show it to the user. Record it on the screen's Dark line in the plan, or in the report when there is no plan.

## 9. Check off

Update the screen's state in `DESIGN-PLAN.md` when a plan exists (otherwise record the final state in `DESIGN.md` and the report) and sync the local files ([sync-rules.md](sync-rules.md)). When the screen's components are `user-approved` and a Design System artifact is kept, re-sync it ([design-system-artifact.md](design-system-artifact.md)). Then move to the next unfinished item.
