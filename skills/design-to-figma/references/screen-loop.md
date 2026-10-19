# Screen loop

Every screen runs this loop: each screen of a project, and the single screen in screen mode. Problems are caught on the first screen, not after the whole project. Read Figma first ([sync-rules.md](sync-rules.md)).

**Budget.** The loop has its own explicit budget, stated here once and replacing the per-run limit in [quality-bar.md](quality-bar.md) for screens: one build; one agent verify plus at most 2 re-verifies after self-fix; at most 2 self-fix batches; one polish pass; the user-requested iterations; one final verify; one Dark verify when requested. An extra round after a failed gate runs only with the user's consent, as a new bounded run.

Cost: each loop spends Figma MCP calls (per Figma's rate-limit documentation, checked 2026-10-15: 200 per day on Dev and Full seats on Starter and Professional plans, 600 on Enterprise). Batch screenshots and take one render per verify. If calls run low or a rate-limit error occurs, stop at a clean point (finish or revert the current write), record the state and the next step in the plan, tell the user and resume later. Never leave a half-built screen unrecorded.

## 1. Define the screen

- Ask how the screen should work when that adds value: purpose, primary action, content, states, edge cases. One question at a time; wait for each answer.
- Do not accept every request as-is. Contrast it with the confirmed style research ([style-discovery.md](style-discovery.md)) and with real screens of the same type from the reference source ([tool-directory.md](tool-directory.md)). Propose concrete suggestions: "in products X and Y this is solved by...; here it would look like...". Mark references as unverified when no research tool exists.
- Agree with the user what will be built. Record the agreed definition in `DESIGN-PLAN.md` under that screen when a plan exists ([DESIGN-PLAN.template.md](../assets/DESIGN-PLAN.template.md)); otherwise record it in the screen section of `DESIGN.md` and in the report. Skip the questions only when the user already gave a complete definition.

## 2. Build

Build the screen in Light (or the single mode) with the builder guidance in [tool-directory.md](tool-directory.md). Reuse existing components and variables; add a component only when the screen needs one. State becomes `built`.

## 3. Agent verify

- A fresh, isolated reviewer (a subagent when available) runs impeccable's `critique` Assessment A on `get_screenshot` renders of this screen. It judges against the quality gate in [quality-bar.md](quality-bar.md): its P0/P1, specificity and heuristics conditions. Declare the run degraded (no Assessment B on Figma).
- Without impeccable, the reviewer applies the built-in checklist in [quality-bar.md](quality-bar.md).
- State becomes `agent-verified` when the gate passes.

## 4. Self-fix

If the gate fails, apply one fix batch in Figma ([iteration.md](iteration.md)) and verify again. At most 2 self-fix rounds. If the screen is still below the gate, do not loop: carry the open gap to the user review.

Then run one mandatory `polish` pass on the screen (impeccable's `polish`, or item 10 of the built-in checklist in [quality-bar.md](quality-bar.md)) before the user review. Critique (step 3) and polish are both required for every screen; never skip either.

## 5. User review

Always ask for human review. Show the screenshot or Figma link, the verdict, the score and any open gap. The user approves or requests changes; apply each change in Figma per [iteration.md](iteration.md) and show it again until the user approves. State becomes `user-approved`. Do not start the next screen before approval unless the user explicitly says to batch.

## 6. Final verify

After the user's iterations, run one more agent verify against the same gate and the standards fixed at the start (style, brief, `DESIGN.md`). Report the result. If it fails, say what failed and offer a fix; the user decides. State becomes `final-verified` when it passes.

## 7. Dark mode (only if requested)

Only when the user asked for dark mode ([figma-structure.md](figma-structure.md)). When dark mode was requested up front, `Semantic` already has Light and Dark modes from foundations. When it is requested later and `Semantic` has only one mode, first add a Dark mode to it and set its values (ask the user to confirm the dark palette), then continue. Build the Dark frame only after the Light screen is `user-approved`: switch a copy of the frame to Dark (or build the Dark frame), agent-verify it, and show it to the user. Record it on the screen's Dark line in the plan, or in the report when there is no plan.

## 8. Check off

Update the screen's state in `DESIGN-PLAN.md` when a plan exists (otherwise record the final state in `DESIGN.md` and the report) and sync the local files ([sync-rules.md](sync-rules.md)). Then move to the next unfinished item.
