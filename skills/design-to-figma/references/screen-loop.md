# Screen loop

Every screen runs this loop: each screen of a project, and the single screen in screen mode. Problems are caught on the first screen, not after the whole project. Each loop is its own bounded run ([quality-bar.md](quality-bar.md)). Read Figma first ([sync-rules.md](sync-rules.md)).

Cost: each loop spends Figma MCP calls (about 200 per day on Dev and Full seats). Batch screenshots and take one render per verify.

## 1. Define the screen

- Ask how the screen should work when that adds value: purpose, primary action, content, states, edge cases. One question at a time; wait for each answer.
- Do not accept every request as-is. Contrast it with the confirmed style research ([style-discovery.md](style-discovery.md)) and with real screens of the same type from the reference source ([tool-directory.md](tool-directory.md)). Propose concrete suggestions: "in products X and Y this is solved by...; here it would look like...". Mark references as unverified when no research tool exists.
- Agree with the user what will be built. Record the agreed definition in `DESIGN-PLAN.md` under that screen ([DESIGN-PLAN.template.md](../assets/DESIGN-PLAN.template.md)). Skip the questions only when the user already gave a complete definition.

## 2. Build

Build the screen in Light (or the single mode) with the builder guidance in [tool-directory.md](tool-directory.md). Reuse existing components and variables; add a component only when the screen needs one. State becomes `built`.

## 3. Agent verify

- A fresh, isolated reviewer (a subagent when available) runs impeccable's `critique` Assessment A on `get_screenshot` renders of this screen. It judges against the quality gate in [quality-bar.md](quality-bar.md): no P0 or P1, an authored specificity verdict, heuristics at 70% or more. Declare the run degraded (no Assessment B on Figma).
- Without impeccable, the reviewer applies the built-in checklist in [quality-bar.md](quality-bar.md).
- State becomes `agent-verified` when the gate passes.

## 4. Self-fix

If the gate fails, apply one fix batch in Figma ([iteration.md](iteration.md)) and verify again. At most 2 self-fix rounds. If the screen is still below the gate, do not loop: carry the open gap to the user review.

## 5. User review

Always ask for human review. Show the screenshot or Figma link, the verdict, the score and any open gap. The user approves or requests changes; apply each change in Figma per [iteration.md](iteration.md) and show it again until the user approves. State becomes `user-approved`. Do not start the next screen before approval unless the user explicitly says to batch.

## 6. Final verify

After the user's iterations, run one more agent verify against the same gate and the standards fixed at the start (style, brief, `DESIGN.md`). Report the result. If it fails, say what failed and offer a fix; the user decides. State becomes `final-verified` when it passes.

## 7. Dark mode (only if requested)

Only when the user asked for dark mode ([figma-structure.md](figma-structure.md)). After the Light screen is `user-approved`, add a Dark mode to the `Semantic` collection if it has only one mode, then switch a copy of the frame to it (or build the Dark frame), agent-verify it, and show it to the user. Record it on the screen's Dark line in the plan.

## 8. Check off

Update the screen's state in `DESIGN-PLAN.md` and sync the local files ([sync-rules.md](sync-rules.md)). Then move to the next unfinished item.
