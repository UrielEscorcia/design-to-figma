# Brownfield: adopting a Figma file this skill did not create

Use when the user brings a Figma file that has no local context from this skill: no `DESIGN.md` whose `figma_file_key` matches the file. Typical cases: a product designed by hand, a file from another team, or a file built before this skill was used. Adoption comes before the request's own route ([routing.md](routing.md)); after it, the request continues on its route with the adopted context.

The file already is the design. Adoption learns it and records it locally; it never reshapes the file to this skill's defaults.

## 1. Read the file (read-only)

Adoption writes nothing to Figma. Load `figma-use` first, then:

1. Run [snapshot.js](../assets/scripts/snapshot.js) as the `use_figma` code, one call. It returns the pages with their top-level frames, components, text and effect styles, and the variables with their values per mode.
2. Pick the representative frames: the screens the request concerns, plus up to 10 more that cover the main flows (ask for links when the file is large and the request names no area). Run [measure.js](../assets/scripts/measure.js) on them in one call. It reports contrast, the text-size floor, touch targets, values not bound to a variable or style, and detached-component candidates.
3. Take `get_screenshot` of 2 or 3 of those frames to read the look.

When the file is not accessible, stop as in [sync-rules.md](sync-rules.md) (Missing or stale header).

## 2. Derive the context

- **Page map:** the role of each existing page, using this skill's roles (Brief, Foundations, Components, Screens) where a page fits one, for example `Screens → "App v2"`, `Components → "Library"`, `Brief → none`. Pages with no role (archive, playground) stay out of the map and are never touched. Ask when the screens page is unclear.
- **System inventory:** the variables, styles and components found, with counts, or "none" for each that is missing. A file with no variables is recorded as using hardcoded values, with the most frequent ones read from the measured frames.
- **Look:** the style, palette, type, radius, elevation and density as the file shows them. This is a look provided by the user ([style-discovery.md](style-discovery.md) section 0; [proposals.md](proposals.md), Provided look): style discovery is not asked, and the palette and type are recorded, not proposed.
- **Brief:** inferred from the screens (product, main flows, UI language and locale from the copy). Only what the file cannot show is asked: users, problem, dark mode when there is no Dark mode or frames.
- **Health:** the measure.js counts (unbound values, contrast and text-floor failures, detached candidates). It is information for the user, never a fix list applied during adoption.

## 3. Confirm and record

Send one adoption summary: the page map, the system inventory, the look in one line, the inferred brief and the health counts.

**A read-only request** (review, critique, compare, explain) runs steps 1 and 2 and records nothing, as [routing.md](routing.md) requires. Put the adoption summary at the top of the answer, use the step 1 reads as the review's evidence, and ask no brief questions. Offer recording the adoption (`PRODUCT.md`, `DESIGN.md`, the snapshot) as a next step; it happens with the first change request, never during the read-only run.

**A change request** (the first one, or the first after a read-only run) asks the brief questions the file could not answer in the same gate as the summary (Hard Rule 18). After the user confirms or corrects it:

- Write `PRODUCT.md` and `DESIGN.md` to the confirmed write path ([preflight.md](preflight.md)). `DESIGN.md` carries the Figma header with `scope: adopted`, the page map, the tokens as the file has them (variables, or the observed hardcoded values marked as such) and the existing components.
- Store the snapshot from step 1 as the sync baseline ([sync-rules.md](sync-rules.md)), with `lastSync`.

Then continue the user's request on its route.

## 4. Working in an adopted file

- **Keep the file's structure.** New screens go to the page the map names as Screens, next to the related flow, following the file's frame naming. New components go to the mapped Components page; when there is none, ask where. Never rename, move, restyle or rebind existing nodes the request did not name.
- **Reuse before creating.** Use the file's components, variables and styles. In a file without variables, new work uses the observed values recorded in `DESIGN.md`; no token system is invented without the user's yes.
- **Opt-ins, each high risk.** Adding a `📋 Brief & Rules` page, creating variables or styles for hardcoded values and rebinding nodes to them, adding the other default pages, or fixing the health findings across the file are offered as next steps, never done during adoption. Each is applied only after the confirmation in step 4 of [routing.md](routing.md) (item 6).
- **No Brief page.** Until the user opts in to one, the rules that write to the Brief page write to `DESIGN.md` only, and the report says the Brief page is not present. The close check covers the mapped pages only.
- **Quality bar.** New and changed work meets the quality gate and runs the lenses as usual ([quality-bar.md](quality-bar.md), [critique-lenses.md](critique-lenses.md)). Existing screens outside the request keep their findings in the health record until the user asks to fix them.

## 5. Report

The Output Contract adds the adoption: the page map, `scope: adopted`, the health counts and the opt-ins offered. The Route and risk line names the request's route, for example `Route: adopted, then small`, or `Route: adopted (not recorded), then read-only` when the run was read-only.
