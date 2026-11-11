#!/usr/bin/env bash
# Test runner: fixture self-tests, real skills, then the official plugin validator.
set -uo pipefail
cd "$(dirname "$0")/.."
status=0

expect() { # expect <pass|fail> <skill-dir> [reason-pattern]
  local out got
  if out="$(tests/validate-skill.sh "$2" 2>&1)"; then got=pass; else got=fail; fi
  if [[ "$got" != "$1" ]]; then
    echo "FAIL fixture $(basename "$2"): expected $1, got $got"; status=1
  elif [[ -n "${3:-}" ]] && ! grep -q -- "$3" <<<"$out"; then
    echo "FAIL fixture $(basename "$2"): failed for the wrong reason (wanted '$3')"; echo "$out"; status=1
  else
    echo "ok   fixture $(basename "$2") -> $1${3:+ ($3)}"
  fi
}

expect pass tests/fixtures/valid
expect fail tests/fixtures/extra-key "key not allowed"
expect fail tests/fixtures/long-description "exceeds 200"
expect fail tests/fixtures/broken-link "broken link"
expect fail tests/fixtures/unclosed-frontmatter "or that line is not YAML"
expect fail tests/fixtures/no-closing-line "no second '---' line"
expect fail tests/fixtures/duplicate-key "duplicate frontmatter key: description"
expect fail tests/fixtures/dotted-key "key not allowed outside Claude Code: x2.mode"
expect fail tests/fixtures/quoted-key "key not allowed outside Claude Code: user-invocable"
expect fail tests/fixtures/quoted-duplicate "duplicate frontmatter key: license"
# Oversized fixture is generated at runtime to keep 500 filler lines out of the repo.
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/too-long" && touch "$tmp/too-long/reference.md"
sed 's/^name: valid$/name: too-long/' tests/fixtures/valid/SKILL.md > "$tmp/too-long/SKILL.md"
seq 1 500 >> "$tmp/too-long/SKILL.md"
expect fail "$tmp/too-long" "max 500"

shopt -s nullglob
skills=(skills/*/)
(( ${#skills[@]} )) || { echo "FAIL no skills found under skills/"; status=1; }
for s in ${skills[@]+"${skills[@]}"}; do tests/validate-skill.sh "${s%/}" || status=1; done

# design-to-figma content: required files exist and SKILL.md links every supporting file.
# Content checks are phrase guards against regressions found in trials and reviews; they do not prove
# what the prose means. Rules that belong to one step are checked inside that step's section.
# section <file> <heading-regex>: from the matching heading to the next heading of the same or a higher level.
# The regex goes through ENVIRON because awk -v would process its escapes. Code fences are not handled.
section() { H="$2" awk 'f && /^#+ / {match($0, /^#+/); if (RLENGTH <= lvl) exit}
  !f && $0 ~ ENVIRON["H"] {f=1; match($0, /^#+/); lvl=RLENGTH} f' "$1"; }
d=skills/design-to-figma
r="$d/references"; sl="$r/screen-loop.md"; sd="$r/style-discovery.md"; das="$r/design-system-artifact.md"
required=(
  SKILL.md
  references/preflight.md references/tool-directory.md references/workflow-project.md
  references/workflow-screen.md references/sync-rules.md references/figma-structure.md
  references/minimal-system-checklist.md
  references/style-discovery.md references/proposals.md references/quality-bar.md
  references/iteration.md references/screen-loop.md references/design-system-artifact.md
  references/routing.md references/critique-lenses.md references/brownfield.md
  assets/PRODUCT.template.md assets/DESIGN.template.md assets/brief-page.template.md
  assets/DESIGN-PLAN.template.md
)
for f in "${required[@]}"; do
  [[ -f "$d/$f" ]] || { echo "FAIL missing required file: $d/$f"; status=1; }
done
# Content rules from the Claude Code trial (T5a): no sync timestamp or absolute paths in the Brief page,
# no get_design_context in the required preflight tools, no routine /design-sync step.
b="$d/assets/brief-page.template.md"
if [[ -f "$b" ]]; then
  grep -qiE 'last[ -]?sync' "$b" && { echo "FAIL $b must not contain a last-sync line"; status=1; }
  grep -qE '(/Users/|/home/|[A-Za-z]:\\|<absolute|<path)' "$b" && { echo "FAIL $b must not contain an absolute-path placeholder"; status=1; }
fi
grep -qiE 'last[ -]?sync' "$r/figma-structure.md" && { echo "FAIL figma-structure.md must not mention a Brief last-sync line"; status=1; }
grep -qE 'Required tools:[^.]*get_design_context' "$r/preflight.md" && { echo "FAIL preflight.md must not require get_design_context"; status=1; }
grep -rq '/design-sync' "$d" && { echo "FAIL /design-sync is outdated (Claude Design lives in Claude as artifacts); remove every mention"; status=1; }
grep -qE 'figma\.root\.children' "$r/sync-rules.md" || { echo "FAIL sync-rules.md must enumerate pages with figma.root.children"; status=1; }

# Content rules from the trial fixes and quality gate (T9).
grep -qiE "user's language" "$d/SKILL.md" || { echo "FAIL SKILL.md must state the reply-in-the-user's-language rule"; status=1; }
brief_line="$(grep -nE '\*\*Product brief' "$d/SKILL.md" | head -1 | cut -d: -f1)"
style_line="$(grep -nE '\*\*Style discovery' "$d/SKILL.md" | head -1 | cut -d: -f1)"
{ [[ -n "$brief_line" && -n "$style_line" ]] && (( brief_line < style_line )); } || { echo "FAIL SKILL.md must run the product brief step before style discovery (brief line '${brief_line:-none}', style line '${style_line:-none}')"; status=1; }
grep -qiE 'swatch' "$sd" || { echo "FAIL style-discovery.md must show palettes as a visual swatch artifact"; status=1; }
grep -qiE 'seed' "$sd" || { echo "FAIL style-discovery.md must mention the seed-color option"; status=1; }
grep -qiE 'file name[^.]*(own|separate) question' "$d/SKILL.md" || { echo "FAIL SKILL.md must ask the file name as its own question before the team"; status=1; }
grep -rqE 'listAvailableFontsAsync' "$d" || { echo "FAIL no file mentions the listAvailableFontsAsync font check"; status=1; }
grep -qE 'clipsContent' "$r/iteration.md" || { echo "FAIL iteration.md must tell to inspect ancestors (clipsContent)"; status=1; }
grep -qiE 'local fix' "$r/iteration.md" || { echo "FAIL iteration.md must prefer the smallest local fix"; status=1; }
grep -qE '28/40' "$r/quality-bar.md" || { echo "FAIL quality-bar.md must state the 28/40 heuristics threshold"; status=1; }
grep -qE 'P0' "$r/quality-bar.md" || { echo "FAIL quality-bar.md must gate on P0/P1 issues"; status=1; }
grep -qiE 'specificity' "$r/quality-bar.md" || { echo "FAIL quality-bar.md must gate on the design-specificity verdict"; status=1; }
grep -qiE 'degraded' "$r/quality-bar.md" || { echo "FAIL quality-bar.md must declare Figma-only critique degraded"; status=1; }
grep -rqE 'craft-floor' "$r" || { echo "FAIL builder guidance must reference impeccable craft-floor"; status=1; }
grep -rqE 'typeset' "$r" || { echo "FAIL builder guidance must reference impeccable typeset"; status=1; }
grep -qiE 'connected (local )?folder' "$r/preflight.md" || { echo "FAIL preflight.md write path must be capability-based (connected folder)"; status=1; }
grep -qiE 'unified' "$r/preflight.md" || { echo "FAIL preflight.md must mention the unified Claude experience"; status=1; }

# Content rules from the per-screen loop, plan tracker and optional dark mode (T10).
grep -q 'screen-loop.md' "$d/SKILL.md" || { echo "FAIL SKILL.md must link screen-loop.md"; status=1; }
grep -q 'DESIGN-PLAN' "$d/SKILL.md" || { echo "FAIL SKILL.md must mention DESIGN-PLAN"; status=1; }
for st in pending built agent-verified user-approved final-verified; do
  grep -q -- "$st" "$d/assets/DESIGN-PLAN.template.md" 2>/dev/null || { echo "FAIL DESIGN-PLAN.template.md must carry the state '$st'"; status=1; }
done
grep -qF 'pending → built → agent-verified → user-approved → final-verified' "$d/assets/DESIGN-PLAN.template.md" || { echo "FAIL DESIGN-PLAN.template.md must state the full screen sequence on one line"; status=1; }
grep -qiE 'budget' "$sl" || { echo "FAIL screen-loop.md must state its own budget"; status=1; }
grep -q 'screen-loop.md' "$r/quality-bar.md" || { echo "FAIL quality-bar.md must point screens to screen-loop.md"; status=1; }
grep -qE '70%|28/40' "$sl" && { echo "FAIL screen-loop.md must not hardcode the gate threshold"; status=1; }
grep -qiE 'when a plan exists|otherwise record' "$sl" || { echo "FAIL screen-loop.md must handle the no-plan case"; status=1; }
grep -qiE 'rate[- ]limit' "$sl" || { echo "FAIL screen-loop.md must handle rate limits"; status=1; }
grep -qiE 'only one mode' "$sl" || { echo "FAIL screen-loop.md must add a Dark mode when dark mode is requested after foundations"; status=1; }
grep -q 'polish' "$r/workflow-project.md" || { echo "FAIL workflow-project.md must reach the polish pass"; status=1; }
grep -qiE 'user review' "$sl" 2>/dev/null || { echo "FAIL screen-loop.md must include the user review step"; status=1; }
grep -qiE 'at most 2' "$sl" 2>/dev/null || { echo "FAIL screen-loop.md must cap self-fix at most 2 rounds"; status=1; }
grep -qiE 'final verify' "$sl" 2>/dev/null || { echo "FAIL screen-loop.md must include the final verify step"; status=1; }
grep -qiE 'contrast' "$sl" 2>/dev/null || { echo "FAIL screen-loop.md must contrast the request with research and real screens"; status=1; }
grep -qiE 'dark mode[^.]*ask|ask[^.]*dark mode' "$d/SKILL.md" || { echo "FAIL SKILL.md must ask about dark mode, never assume it"; status=1; }
grep -rqiE 'single[- ]mode' "$r" || { echo "FAIL references must document the single-mode semantic collection"; status=1; }
grep -rqiE '(in|both) light and dark' "$d" && { echo "FAIL wording implies Light and Dark are always built"; status=1; }
grep -qiE 'reference source' "$r/tool-directory.md" || { echo "FAIL tool-directory.md must declare a reference source slot"; status=1; }
grep -qE '`polish`' "$sl" || { echo "FAIL screen-loop.md must keep the mandatory polish pass"; status=1; }

# Content rules from the Design System artifact sync (T11).
grep -qiE 'one-way' "$das" 2>/dev/null || { echo "FAIL design-system-artifact.md must state the sync is one-way"; status=1; }
grep -q 'from-design-tool.md' "$das" 2>/dev/null || { echo "FAIL design-system-artifact.md must name the type's from-design-tool.md procedure"; status=1; }
grep -qiE 'never hardcode' "$das" 2>/dev/null || { echo "FAIL design-system-artifact.md must forbid hardcoding the type URL"; status=1; }
grep -q 'color.themes' "$das" 2>/dev/null || { echo "FAIL design-system-artifact.md must map modes to color.themes"; status=1; }
grep -q 'design_system_url' "$d/assets/DESIGN.template.md" || { echo "FAIL DESIGN.template.md must carry design_system_url"; status=1; }
grep -q 'design-system-artifact.md' "$r/sync-rules.md" || { echo "FAIL sync-rules.md must link design-system-artifact.md"; status=1; }
grep -qiE 'design system' "$r/proposals.md" || { echo "FAIL proposals.md must use the project's design system"; status=1; }
grep -rqE 'claude\.ai/(code/)?artifact/' "$d" && { echo "FAIL no artifact URL may be hardcoded in the skill"; status=1; }
grep -qiE 'mode limit|limits modes' "$sl" || { echo "FAIL screen-loop.md must handle the Figma mode limit when adding Dark"; status=1; }

# Content rules from the trial T5d: category research gate (D24), palette gate (D25), product locale (D26).
grep -qiE 'category' "$sd" || { echo "FAIL style-discovery.md must research the product category before style"; status=1; }
grep -qiE 'at least 3' "$sd" || { echo "FAIL style-discovery.md must require at least 3 real category products"; status=1; }
grep -qiE 'before (continuing|any style|asking)' "$sd" || { echo "FAIL style-discovery.md must show the category references before continuing"; status=1; }
grep -qiE 'confirm(ed)? .*palette|palette .*confirm' "$r/proposals.md" || { echo "FAIL proposals.md must gate on a confirmed palette"; status=1; }
grep -qiE 'share the confirmed palette' "$r/proposals.md" || { echo "FAIL proposals.md must make directions share the confirmed palette"; status=1; }
grep -qiE 'locale' "$d/SKILL.md" || { echo "FAIL SKILL.md must ask the UI language and locale in the brief"; status=1; }
grep -qiE 'locale' "$d/assets/PRODUCT.template.md" || { echo "FAIL PRODUCT.template.md must carry a Locale field"; status=1; }
grep -qiE 'UI copy' "$d/SKILL.md" || { echo "FAIL SKILL.md must say the English rule does not cover UI copy"; status=1; }

# Content rules from the live trial (v0.2.0): blind scoring, elevate pass, app-wide rules, user-review research.
grep -qiE 'never includes the gate|without the gate|blind' "$sl" || { echo "FAIL screen-loop.md must score blind (reviewer never sees the gate)"; status=1; }
grep -qiE 'blind' "$r/quality-bar.md" || { echo "FAIL quality-bar.md must run the critique blind"; status=1; }
grep -qiE 'elevate' "$sl" || { echo "FAIL screen-loop.md must include the elevate pass"; status=1; }
grep -qE '`(bolder|delight|typeset)`' "$sl" || { echo "FAIL screen-loop.md must name the impeccable elevate commands"; status=1; }
grep -qiE 'app-wide' "$r/iteration.md" || { echo "FAIL iteration.md must turn app-wide requests into rules"; status=1; }
grep -qiE 'user reviews' "$sd" || { echo "FAIL style-discovery.md must research user reviews of category apps"; status=1; }

# Content rules from the T5d resume: progress updates in the user's language, persisted direction comps.
grep -qiE 'progress updates' "$d/SKILL.md" || { echo "FAIL SKILL.md must keep progress updates in the user's language"; status=1; }
grep -qE 'directions/' "$r/proposals.md" || { echo "FAIL proposals.md must persist the chosen direction in the project folder"; status=1; }
grep -qiE 'direction' "$d/assets/DESIGN-PLAN.template.md" || { echo "FAIL DESIGN-PLAN.template.md must record where the chosen direction lives"; status=1; }

# Content rules from the T5d Date & time screen: agreed definitions, no unrequested features.
! grep -qiE 'when that adds value' "$sl" || { echo "FAIL screen-loop.md must not let the define step skip the user"; status=1; }
grep -qiE 'only a proposal' "$sl" || { echo "FAIL screen-loop.md must treat a self-derived definition as a proposal"; status=1; }
grep -qiE 'new product feature' "$sl" || { echo "FAIL screen-loop.md must ask before adding a new product feature"; status=1; }
grep -qiE 'agreed with the user' "$d/assets/DESIGN-PLAN.template.md" || { echo "FAIL DESIGN-PLAN.template.md must mark the definition as agreed with the user"; status=1; }
grep -qiE 'update the (screen.s )?definition' "$sl" || { echo "FAIL screen-loop.md must keep the plan definition current after user changes"; status=1; }
grep -qiE 'self-fix, the polish or elevate pass' "$sl" || { echo "FAIL screen-loop.md must keep the plan definition current after agent-made changes too"; status=1; }

# Content rule from the T5d closing: the stand-in font swap was never verified because screenshots render the platform font blank.
grep -qiE "each text node's height" "$r/figma-structure.md" || { echo "FAIL figma-structure.md must verify the platform font swap structurally"; status=1; }
grep -qE 'hasMissingFont' "$r/figma-structure.md" || { echo "FAIL figma-structure.md must say the use_figma runtime cannot lay out a platform font"; status=1; }
grep -qiE 'never apply the platform font by script' "$r/figma-structure.md" || { echo "FAIL figma-structure.md must leave the platform font swap to the user's Figma desktop app"; status=1; }
grep -qiE 'pixel line heights' "$r/figma-structure.md" || { echo "FAIL figma-structure.md must require pixel line heights so height gives the line count"; status=1; }
grep -qiE 'no text style' "$r/figma-structure.md" || { echo "FAIL figma-structure.md must bind unstyled text before the style-based font swap"; status=1; }
grep -qE 'exportAsync' "$r/figma-structure.md" || { echo "FAIL figma-structure.md must check flagged text visually with an export"; status=1; }
grep -qiE 'dispatch' "$d/SKILL.md" || { echo "FAIL SKILL.md must keep the line after dispatching a subagent in the user's language"; status=1; }

# Content rules from the review advisories of rounds 2-3 and PR #8 (T12 items in odd/tasks/design-to-figma.md).
# Rules that belong to one step are checked inside that step's section; checks that fail when a phrase is
# present guard against an old wording coming back.
grep -E '\*\*Direction and proposals' "$d/SKILL.md" | grep -qiE 'screen mode[^.]*defin' || { echo "FAIL SKILL.md step 5 must define the screen before the proposals in screen mode"; status=1; }
section "$r/workflow-project.md" '^## 4\.' | grep -qiE 'ask the user to approve the foundations' || { echo "FAIL workflow-project.md step 4 must ask the user to approve the foundations"; status=1; }
section "$sd" '^## 1\.' | grep -qiE "record the user's choice" || { echo "FAIL style-discovery.md must record the choice to continue with fewer than 3 category products"; status=1; }
grep -qiE 'Palette: confirmed' "$d/assets/PRODUCT.template.md" || { echo "FAIL PRODUCT.template.md must record the palette confirmation"; status=1; }
grep -qF 'Record it in `PRODUCT.md`' "$r/workflow-project.md" && { echo "FAIL workflow-project.md step 2 must name where each confirmation is recorded"; status=1; }
section "$r/proposals.md" '^## After' | grep -qiE 'no writable folder' || { echo "FAIL proposals.md must persist the comps when there is no writable folder"; status=1; }
grep -qiE 'and the Brief page follow' "$d/SKILL.md" || { echo "FAIL SKILL.md must say which language Figma structure names and the Brief page use"; status=1; }
style_new="$(grep -nE '^\| Style \| No confirmed style' "$d/SKILL.md" | cut -d: -f1)"
style_rec="$(grep -nE '^\| Style \| Style recorded' "$d/SKILL.md" | cut -d: -f1)"
[[ -n "$style_new" && "$style_rec" == "$((style_new + 1))" ]] || { echo "FAIL SKILL.md Decision Gates must keep the style rows together"; status=1; }
grep -qiE 'no Figma call can' "$sl" || { echo "FAIL screen-loop.md must not revert by Figma call after a rate-limit error"; status=1; }
grep -qiE 'restore the duplicate first' "$sl" && { echo "FAIL screen-loop.md must not restore the elevate duplicate after a rate-limit error"; status=1; }
section "$sl" '^## 5\.' | grep -qF '| Typography | `typeset` |' || { echo "FAIL screen-loop.md elevate pass must map each opportunity to its command"; status=1; }
section "$sl" '^## 5\.' | grep -qiE 'scores are not compared' || { echo "FAIL screen-loop.md elevate pass must not compare scores between reviewers"; status=1; }
grep -qiE 'Figma calls used' "$d/assets/DESIGN-PLAN.template.md" || { echo "FAIL DESIGN-PLAN.template.md must record the Figma calls each screen used"; status=1; }
grep -qiE 'never includes the gate thresholds' "$sl" && { echo "FAIL screen-loop.md must point to quality-bar.md for the blind rule instead of restating it"; status=1; }
(( $(section "$sl" '^## 6\.' | grep -cE '^- ') >= 4 )) || { echo "FAIL screen-loop.md user review must be split into bullets"; status=1; }
grep -qiE 'go back to `built`' "$r/iteration.md" || { echo "FAIL iteration.md must send screens changed by an app-wide rule back for verification"; status=1; }
grep -q 'craft-floor' "$r/workflow-screen.md" && { echo "FAIL workflow-screen.md must point to tool-directory.md instead of restating the builder guidance"; status=1; }
grep -qiE 'same font size, weight and line height' "$r/figma-structure.md" || { echo "FAIL figma-structure.md must say which style an unstyled text node binds to"; status=1; }
grep -qiE 'no writable folder' "$das" || { echo "FAIL design-system-artifact.md must handle design_system_url with no writable folder"; status=1; }
grep -qiE 'even when (its|their) source did not change' "$das" || { echo "FAIL design-system-artifact.md must retry failed files"; status=1; }
grep -qiE 'Claude Code or a Cowork' "$das" && { echo "FAIL design-system-artifact.md must decide availability by capability, not surface name"; status=1; }
grep -qiE 'plan when one exists' "$das" || { echo "FAIL design-system-artifact.md must record the opt-in in the plan only when one exists"; status=1; }
grep -qiE 'read (it|the artifact) back' "$das" || { echo "FAIL design-system-artifact.md must read the artifact back after a sync"; status=1; }
grep -qiE 'Foundations: approved' "$d/assets/DESIGN.template.md" || { echo "FAIL DESIGN.template.md must keep the foundations approval until the plan exists"; status=1; }
grep -qiE 'creating it fails' "$das" || { echo "FAIL design-system-artifact.md must skip only when creating the artifact fails, and retry later saves"; status=1; }
grep -qiE 'foundations build used' "$sl" || { echo "FAIL screen-loop.md must define the call estimate before the first screen"; status=1; }
grep -qiE 'clean it up first' "$sl" && { echo "FAIL screen-loop.md must use one wording for the leftover elevate duplicate"; status=1; }
grep -qiE 'if it was kept, delete the duplicate' "$sl" || { echo "FAIL screen-loop.md must keep an accepted elevate after a rate-limit stop"; status=1; }
grep -E 'Continue the screen loop from step 3' "$r/workflow-screen.md" | grep -qi 'elevate' || { echo "FAIL workflow-screen.md must list the elevate pass among the remaining loop steps"; status=1; }
grep -rqE 'Palette/foundations|and Palette in' "$d" && { echo "FAIL plan items must use the template names (Brief, Style and references, Palette and foundations, Components)"; status=1; }
for item in 'Brief' 'Style and references' 'Palette and foundations' 'Components'; do
  grep -qF -- "- [ ] $item: \`pending\`" "$d/assets/DESIGN-PLAN.template.md" || { echo "FAIL DESIGN-PLAN.template.md must list the plan item '$item'"; status=1; }
done
grep -qE 'section [0-9]+ of \[style-discovery' "$r/workflow-project.md" && { echo "FAIL workflow-project.md must name the style-discovery section, not its number"; status=1; }
[[ -n "$(section "$sl" '^## 5\.')" ]] || { echo "FAIL screen-loop.md has no section 5 (the elevate pass); the scoped checks would test nothing"; status=1; }
section "$sl" '^## 5\.' | grep -qiE 'restore the version from before' && { echo "FAIL screen-loop.md elevate pass must point to Cost for rate-limit recovery instead of restating it"; status=1; }

# T15: Desktop trial findings F1-F11 (listed under "T15 items" in odd/tasks/design-to-figma.md). The gate sequence lives in SKILL.md because Desktop runs may skip reading a reference.
wp="$r/workflow-project.md"
gs="$(section "$d/SKILL.md" '^## Gate sequence')"
[[ -n "$gs" ]] || { echo "FAIL SKILL.md must have a Gate sequence section"; status=1; }
grep -qiE 'one gate per turn' <<<"$gs" || { echo "FAIL SKILL.md gate sequence must require one gate per turn"; status=1; }
grep -qiE 'multi-question form' <<<"$gs" || { echo "FAIL SKILL.md gate sequence must forbid bundling gates into a multi-question form"; status=1; }
grep -qiE 'read the reference' <<<"$gs" || { echo "FAIL SKILL.md gate sequence must require reading each step's reference"; status=1; }
grep -qiE 'File name.*alone, right before the file is created' <<<"$gs" || { echo "FAIL SKILL.md gate sequence must ask the file name alone, right before creating the file"; status=1; }
grep -qiE 'show the critique' <<<"$gs" || { echo "FAIL SKILL.md gate sequence must show the direction critique before any Figma write"; status=1; }
grep -qiE 'Design System artifact.*own question' <<<"$gs" || { echo "FAIL SKILL.md gate sequence must ask the Design System artifact opt-in as its own question"; status=1; }
grep -qiE 'write `DESIGN.md` now' <<<"$gs" || { echo "FAIL SKILL.md gate sequence must write DESIGN.md when the foundations are approved"; status=1; }
grep -qiE 'not empty' <<<"$gs" || { echo "FAIL SKILL.md gate sequence must check the required pages are not empty before the report"; status=1; }
section "$d/SKILL.md" '^## Hard Rules' | grep -qiE 'before spending the user.s credits' || { echo "FAIL SKILL.md must ask before spending the user's credits"; status=1; }
rv="$(section "$sl" '^## 6\.')"
for field in 'Verdict' 'Score' 'Polish' 'Elevate' 'Open gaps'; do
  grep -qE -- "^  - \*\*$field:\*\*" <<<"$rv" || { echo "FAIL screen-loop.md user review message must have the field '$field'"; status=1; }
done
grep -qiE 'do not ask for approval while' <<<"$rv" || { echo "FAIL screen-loop.md must not ask for approval with a review field missing"; status=1; }
grep -qiE 'one screen per review' <<<"$rv" || { echo "FAIL screen-loop.md must review one screen at a time"; status=1; }
snap="$(section "$r/sync-rules.md" '^## Snapshot')"
grep -qiE 'never by hand' <<<"$snap" || { echo "FAIL sync-rules.md snapshot must come from the enumeration script, never by hand"; status=1; }
grep -qiE 'not counts' <<<"$snap" || { echo "FAIL sync-rules.md snapshot must record variable values, not counts"; status=1; }
section "$wp" '^## 4\.' | grep -qiE 'Brief & Rules. included, is not empty' || { echo "FAIL workflow-project.md must check the Brief page is not empty"; status=1; }
section "$wp" '^## 1\.' | grep -qiE 'own question' || { echo "FAIL workflow-project.md must ask the Design System artifact opt-in as its own question"; status=1; }

# T17: second Desktop trial findings (listed under "T17 items" in odd/tasks/design-to-figma.md).
pf="$r/preflight.md"
grep -qiE '^0\. \*\*Preflight report' <<<"$gs" || { echo "FAIL SKILL.md gate sequence must start with the preflight report as step 0"; status=1; }
grep -qiE 'confirm the write path' <<<"$gs" || { echo "FAIL SKILL.md gate sequence step 0 must confirm the write path"; status=1; }
grep -qiE 'impeccable.*own question' <<<"$gs" || { echo "FAIL SKILL.md gate sequence must ask about a missing impeccable as its own question"; status=1; }
# The negative checks below pass on a missing file, so require the file first.
[[ -f "$pf" ]] || { echo "FAIL missing $pf"; status=1; }
grep -qiE 'Expect it to be absent' "$pf" && { echo "FAIL preflight.md must not assume impeccable is absent on Desktop"; status=1; }
grep -qiE 'recommend it once' "$pf" "$d/SKILL.md" && { echo "FAIL a missing impeccable must be a question, not a one-time recommendation"; status=1; }
ip="$(section "$pf" '^## 3\.')"
grep -qiE 'never assume it is present or absent' <<<"$ip" || { echo "FAIL preflight.md must check for impeccable on every surface, never assume"; status=1; }
grep -qiE 'new session or chat' <<<"$ip" || { echo "FAIL preflight.md must fall back to a new session or chat when a new install is not listed yet"; status=1; }
grep -qiE 'Install impeccable first' <<<"$ip" || { echo "FAIL preflight.md must offer 'Install impeccable first' when it is missing"; status=1; }
grep -qiE 'Continue without impeccable' <<<"$ip" || { echo "FAIL preflight.md must offer 'Continue without impeccable' when it is missing"; status=1; }
grep -qiE 'version.*user-invocable.*argument-hint' <<<"$ip" || { echo "FAIL preflight.md must give the Desktop repack steps for impeccable"; status=1; }
section "$pf" '^## 8\.' | grep -qiE 'own message' || { echo "FAIL preflight.md report must be its own message, never skipped"; status=1; }
section "$r/workflow-screen.md" '^## B\.' | grep -qiE 'Design System artifact.*own question' || { echo "FAIL workflow-screen.md must ask the Design System artifact opt-in as its own question"; status=1; }
grep -E '^[0-9]+\. \*\*Close\*\*' <<<"$gs" | grep -qiE 'Brief page text matches the current scope' || { echo "FAIL SKILL.md close step must check the Brief page matches the current scope"; status=1; }

# Harness base (T1 in odd/tasks/design-harness.md): route every request before the gates; S# refer to that file.
rt="$r/routing.md"
[[ -f "$rt" ]] || { echo "FAIL missing $rt"; status=1; }
section "$rt" '^## 1\.' | grep -qiE 'read-only[^.]*(writes|changes) nothing' || { echo "FAIL routing.md must keep read-only requests from writing (S3)"; status=1; }
sz="$(section "$rt" '^## 2\.')"
grep -qF 'iteration.md' <<<"$sz" || { echo "FAIL routing.md small route must run through iteration.md (S4)"; status=1; }
grep -qiE 'unchanged' <<<"$sz" || { echo "FAIL routing.md large route must keep the current flow unchanged (S1, S4)"; status=1; }
grep -qiE 'Hard Rules' <<<"$sz" || { echo "FAIL routing.md small route must keep the Hard Rules (S1)"; status=1; }
hr="$(section "$rt" '^## 3\.')"
for item in 'Shared tokens' 'Shared components' 'Deletion' 'Brand foundations'; do
  grep -qF -- "**$item.**" <<<"$hr" || { echo "FAIL routing.md high-risk items must name '$item' (S5)"; status=1; }
done
cf="$(section "$rt" '^## 4\.')"
for field in 'Change' 'Reach' 'Undo' 'Smaller option'; do
  grep -qE -- "^- \*\*$field:\*\*" <<<"$cf" || { echo "FAIL routing.md confirmation must show the field '$field' (S6)"; status=1; }
done
grep -qiE 'read-only .use_figma.' <<<"$cf" || { echo "FAIL routing.md must measure the reach with a read-only use_figma script (S6)"; status=1; }
grep -qiE 'without a yes, apply nothing' <<<"$cf" || { echo "FAIL routing.md must apply nothing without a yes (S6)"; status=1; }
section "$rt" '^## 5\.' | grep -qiE 'verbatim' || { echo "FAIL routing.md must record requests verbatim (S7)"; status=1; }
grep -qE '^## Requests' "$d/assets/DESIGN-PLAN.template.md" || { echo "FAIL DESIGN-PLAN.template.md must have a Requests section (S7)"; status=1; }
grep -qE -- '- \*\*L1\*\*' "$d/assets/DESIGN-PLAN.template.md" || { echo "FAIL DESIGN-PLAN.template.md must hold the original request as L1 (S7)"; status=1; }
section "$r/tool-directory.md" '^## Builder guidance' | grep -qiE 'by reference' || { echo "FAIL tool-directory.md builder guidance must pass the plan by reference (S7)"; status=1; }
section "$d/SKILL.md" '^## Output Contract' | grep -qE '\*\*Route and risk:\*\*' || { echo "FAIL SKILL.md Output Contract must report the route and risk (S8)"; status=1; }
section "$d/SKILL.md" '^## Hard Rules' | grep -qF 'routing.md' || { echo "FAIL SKILL.md Hard Rules must route every request first"; status=1; }
grep -qiE 'large route' <<<"$gs" || { echo "FAIL SKILL.md gate sequence must say it is the large route (S4)"; status=1; }
section "$r/iteration.md" '^## Steps' | grep -E '^4\. ' -A6 | grep -iE 'high risk' | grep -qF 'routing.md' || { echo "FAIL iteration.md step 4 must confirm high-risk changes through routing.md (S6)"; status=1; }
section "$rt" '^## 5\.' | grep -qiE 'no `## Requests` section' || { echo "FAIL routing.md must handle an older plan without a Requests section (S7)"; status=1; }
section "$rt" '^## 3\.' | grep -qiE 'unclear[^.]*measure' || { echo "FAIL routing.md must measure an unclear high-risk item before choosing the route (S5)"; status=1; }
section "$d/SKILL.md" '^## Execution Steps' | grep -E '^0\. ' | grep -qiE 'read-only[^.]*read Figma' || { echo "FAIL SKILL.md step 0 must read Figma before a read-only answer (S3)"; status=1; }
section "$d/SKILL.md" '^## Execution Steps' | grep -E '^0\. ' | grep -qiE 'small changes.*the report' || { echo "FAIL SKILL.md step 0 must end the small route with the report (S8)"; status=1; }
grep -qiE 'Request routing' README.md || { echo "FAIL README.md must document request routing"; status=1; }

# T4 in odd/tasks/design-harness.md: the skill must win over the official Figma skills (Desktop trial, S9).
# Real triggering is measured by `claude plugin eval` (evals/); these guards keep the wording that won.
desc="$(grep -m1 '^description:' "$d/SKILL.md")"
grep -qE '^description: "MANDATORY first step' <<<"$desc" || { echo "FAIL SKILL.md description must start with the MANDATORY directive (S9)"; status=1; }
grep -qF 'BEFORE reading attachments, figma-use, figma-generate-design' <<<"$desc" || { echo "FAIL SKILL.md description must load before attachments and the Figma skills (S9)"; status=1; }
grep -qiE 'any language' <<<"$desc" || { echo "FAIL SKILL.md description must trigger in any language (S9)"; status=1; }
section "$d/SKILL.md" '^## Activation Contract' | grep -qiE 'module by module' || { echo "FAIL SKILL.md activation contract must cover a product built module by module (S9)"; status=1; }
for f in evals/spanish-module-prompt/case.yaml evals/design-to-code-no-fire/case.yaml evals/setup.sh; do
  [[ -f "$f" ]] || { echo "FAIL missing trigger eval file: $f (S9)"; status=1; }
done
grep -q 'facturación mexicano' evals/spanish-module-prompt/case.yaml 2>/dev/null || { echo "FAIL the trigger eval must keep the real Desktop prompt verbatim (S9)"; status=1; }

# T5 in odd/tasks/design-harness.md: decisions the user already made are taken, not asked again (S10).
pd="$(section "$sd" '^## 0\.')"
[[ -n "$pd" ]] || { echo "FAIL style-discovery.md must have section 0 for decisions the user already made (S10)"; status=1; }
grep -qiE 'provided by the user' <<<"$pd" || { echo "FAIL style-discovery.md section 0 must record provided decisions as provided by the user (S10)"; status=1; }
for item in 'Palette' 'Typography' 'Look'; do
  grep -qE -- "^- \*\*$item" <<<"$pd" || { echo "FAIL style-discovery.md section 0 must cover '$item' (S10)"; status=1; }
done
grep -qiE 'never ask (it|them) again|do not ask (it|them) again' <<<"$pd" || { echo "FAIL style-discovery.md section 0 must not ask provided decisions again (S10)"; status=1; }
grep -qiE 'category references[^.]*(always|still) run' <<<"$pd" || { echo "FAIL style-discovery.md section 0 must still run the category references (S10)"; status=1; }
grep -qiE 'how (real|the) products? (are|is) built' <<<"$pd" || { echo "FAIL style-discovery.md section 0 must use category references to learn how the product is built (S10)"; status=1; }
grep -qE '^\| Provided \|' "$d/SKILL.md" || { echo "FAIL SKILL.md Decision Gates must have a Provided row (S10)"; status=1; }
grep -E '^[34]\. \*\*(Style|Palette)' <<<"$gs" | grep -qiE 'provided' || { echo "FAIL SKILL.md gate sequence must skip provided style or palette (S10)"; status=1; }
grep -qiE 'provided by the user' "$r/proposals.md" || { echo "FAIL proposals.md palette gate must accept a palette provided by the user (S10)"; status=1; }
grep -qiE 'provided by the user' "$d/assets/PRODUCT.template.md" || { echo "FAIL PRODUCT.template.md must record decisions provided by the user (S10)"; status=1; }
grep -qE '^Typography:' "$d/assets/PRODUCT.template.md" || { echo "FAIL PRODUCT.template.md must have a Typography line (S10)"; status=1; }

# evals/setup.sh must explain a missing Figma plugin instead of exiting silently (review advisory on PR #19).
mkdir -p "$tmp/no-figma-home"
setup_out="$(HOME="$tmp/no-figma-home" evals/setup.sh 2>&1)"
grep -qF 'Install the Figma plugin first' <<<"$setup_out" || { echo "FAIL evals/setup.sh must print the install hint when the Figma plugin is missing"; status=1; }
grep -qiE 'pairs that failed AA were resolved|failing pairs (are|were) resolved' "$r/proposals.md" || { echo "FAIL proposals.md must wait until a provided palette's failing AA pairs are resolved (S10)"; status=1; }

# T6 in odd/tasks/design-harness.md: directions never leave a look the user provided (S11).
lk="$(section "$r/proposals.md" "^## Provided look")"
[[ -n "$lk" ]] || { echo "FAIL proposals.md must have a Provided look section (S11)"; status=1; }
for trait in 'radius' 'elevation' 'color use' 'type'; do
  grep -qiE "$trait" <<<"$lk" || { echo "FAIL proposals.md provided look must keep '$trait' (S11)"; status=1; }
done
grep -qiE 'structure, hierarchy and density' <<<"$lk" || { echo "FAIL proposals.md provided look must vary only structure, hierarchy and density (S11)"; status=1; }
grep -qiE 'density variant' <<<"$lk" || { echo "FAIL proposals.md must keep the look in a density variant the brief asks for (S11)"; status=1; }
grep -qiE 'only when the user asks' <<<"$lk" || { echo "FAIL proposals.md must explore another look only when the user asks (S11)"; status=1; }
section "$sd" '^## 0\.' | grep -E '^- \*\*Look' | grep -qiE 'proposals\.md' || { echo "FAIL style-discovery.md section 0 Look must point to the provided look rule in proposals.md (S11)"; status=1; }

# T7b in odd/tasks/design-harness.md: every screen in Screens runs the full loop; no backup files (S12).
sed -n '1,4p' "$sl" | grep -qiE 'system test' || { echo "FAIL screen-loop.md must run the loop for system test screens too (S12)"; status=1; }
grep -E '^9\. \*\*Each screen' <<<"$gs" | grep -qiE 'system test' || { echo "FAIL SKILL.md gate step 9 must cover system test screens (S12)"; status=1; }
grep -E '^9\. \*\*Each screen' <<<"$gs" | grep -qiE 'before asking (for )?approval' || { echo "FAIL SKILL.md gate step 9 must run polish and elevate before asking approval (S12)"; status=1; }
section "$r/sync-rules.md" '^## Write path' | grep -qiE 'never (leave|create) (backup|\.bak)' || { echo "FAIL sync-rules.md write path must forbid backup files in the user's folder (S12)"; status=1; }

# T8 in odd/tasks/design-harness.md: questions with defined options go through the surface's question form (S13).
hr18="$(section "$d/SKILL.md" '^## Hard Rules' | grep -E '^18\. ')"
grep -qiE 'defined options' <<<"$hr18" || { echo "FAIL SKILL.md Hard Rule 18 must route questions with defined options to the form (S13)"; status=1; }
grep -qF 'AskUserQuestion' <<<"$hr18" || { echo "FAIL SKILL.md Hard Rule 18 must name the Claude Code question tool (S13)"; status=1; }
grep -qiE 'recommended option first' <<<"$hr18" || { echo "FAIL SKILL.md Hard Rule 18 must list the recommended option first (S13)"; status=1; }
grep -qiE 'numbered' <<<"$hr18" || { echo "FAIL SKILL.md Hard Rule 18 must fall back to numbered options without a form tool (S13)"; status=1; }
grep -qiE 'open questions' <<<"$hr18" || { echo "FAIL SKILL.md Hard Rule 18 must keep open questions in the chat (S13)"; status=1; }
grep -qiE 'one form per gate|never two gates' <<<"$gs" || { echo "FAIL SKILL.md gate sequence must allow one form per gate, never two gates (S13)"; status=1; }

# T9 in odd/tasks/design-harness.md: critique fixes never add product features without the user's yes (S14).
qr="$(section "$r/quality-bar.md" '^## Rules')"
grep -qiE 'design fixes' <<<"$qr" || { echo "FAIL quality-bar.md rules must name design fixes (S14)"; status=1; }
grep -qiE 'product additions' <<<"$qr" || { echo "FAIL quality-bar.md rules must name product additions (S14)"; status=1; }
grep -qiE 'every critique' <<<"$qr" || { echo "FAIL quality-bar.md rule must apply to every critique, the direction critique included (S14)"; status=1; }
grep -qiE 'multi-select' <<<"$qr" || { echo "FAIL quality-bar.md must ask product additions in a multi-select form (S14)"; status=1; }
grep -qiE 'only the accepted' <<<"$qr" || { echo "FAIL quality-bar.md must apply only the accepted additions (S14)"; status=1; }
grep -E '^5\. \*\*Direction' <<<"$gs" | grep -qiE 'product additions' || { echo "FAIL SKILL.md gate step 5 must ask product additions before building (S14)"; status=1; }

# T10 in odd/tasks/design-harness.md: point 3 trial findings (S15).
oc="$(section "$d/SKILL.md" '^## Output Contract')"
grep -qiE 'never drop a field' <<<"$oc" || { echo "FAIL SKILL.md Output Contract must never drop a field (S15)"; status=1; }
grep -qiE 'reports only the fields it touched' <<<"$oc" && { echo "FAIL SKILL.md Output Contract must not let small runs drop fields (S15)"; status=1; }
grep -E '^10\. \*\*Close' <<<"$gs" | grep -qiE 'Route and risk' || { echo "FAIL SKILL.md close step must end with the Route and risk line (S15)"; status=1; }
grep -E '^9\. \*\*App-wide' "$r/iteration.md" | grep -qiE 'both, without asking' || { echo "FAIL iteration.md must write app-wide rules to DESIGN.md and the Brief page without asking (S15)"; status=1; }
section "$r/quality-bar.md" '^## Rules' | grep -qiE 'never fake a component state' || { echo "FAIL quality-bar.md must forbid faking component states (S15)"; status=1; }
grep -qiE 'high-risk decisions included' <<<"$hr18" || { echo "FAIL Hard Rule 18 must recommend an option in high-risk decisions too (S15)"; status=1; }
grep -qiE 'depend on another answer' <<<"$hr18" || { echo "FAIL Hard Rule 18 must ask dependent questions in a later turn (S15)"; status=1; }

# Releases (T11 in odd/tasks/design-harness.md): every version has a CHANGELOG entry, and the release script builds
# the tag, notes and Desktop zip that the release workflow publishes.
pv_now="$(grep -oE '"version": *"[^"]+"' .claude-plugin/plugin.json | grep -oE '[0-9][^"]*')"
grep -qF "## [$pv_now]" CHANGELOG.md 2>/dev/null || { echo "FAIL CHANGELOG.md must have a '## [$pv_now]' entry for the plugin version"; status=1; }
for f in scripts/release.sh scripts/changelog-section.sh; do
  [[ -x "$f" ]] || { echo "FAIL $f must exist and be executable"; status=1; }
done
if [[ -x scripts/changelog-section.sh ]]; then
  [[ -n "$(scripts/changelog-section.sh "$pv_now")" ]] || { echo "FAIL scripts/changelog-section.sh returned no notes for $pv_now"; status=1; }
  [[ -z "$(scripts/changelog-section.sh 9.9.9)" ]] || { echo "FAIL scripts/changelog-section.sh must print nothing for an unknown version"; status=1; }
fi
if [[ -x scripts/changelog-section.sh ]]; then
  second="$(grep -m2 -oE '^## \[[0-9]+\.[0-9]+\.[0-9]+\]' CHANGELOG.md | tail -1 | tr -d '#[] ')"
  grep -q '^## \[' <<<"$(scripts/changelog-section.sh "$pv_now")" && { echo "FAIL scripts/changelog-section.sh must stop before the next entry"; status=1; }
  [[ -n "$second" && -n "$(scripts/changelog-section.sh "$second")" ]] || { echo "FAIL scripts/changelog-section.sh must read entries below the first one"; status=1; }
fi
head_v="$(git show HEAD:.claude-plugin/plugin.json 2>/dev/null | grep -oE '"version": *"[^"]+"' | grep -oE '[0-9][^"]*')"
if [[ -x scripts/release.sh && "$head_v" != "$pv_now" ]]; then
  echo "SKIP release dry-run (version $pv_now is not committed yet; HEAD has $head_v)"
elif [[ -x scripts/release.sh ]]; then
  dry="$(scripts/release.sh --dry-run "$pv_now" HEAD 2>&1)"
  grep -qF "tag v$pv_now" <<<"$dry" || { echo "FAIL release.sh --dry-run must name the tag v$pv_now"; status=1; }
  grep -qE 'zip design-to-figma-[0-9.]+\.zip: [1-9][0-9]* files, SKILL\.md at design-to-figma/SKILL\.md' <<<"$dry" || { echo "FAIL release.sh --dry-run must build a zip with design-to-figma/SKILL.md at its root"; echo "$dry"; status=1; }
fi
wf=.github/workflows/release.yml
grep -qF "github.ref == 'refs/heads/main'" "$wf" 2>/dev/null || { echo "FAIL $wf must only publish from main, manual runs included"; status=1; }
grep -qE 'uses: actions/checkout@[0-9a-f]{40}' "$wf" 2>/dev/null || { echo "FAIL $wf must pin actions/checkout to a commit SHA"; status=1; }
grep -qE 'uses: actions/checkout@[0-9a-f]{40} # v[5-9]' "$wf" 2>/dev/null || { echo "FAIL $wf must use a Node 24 actions/checkout (v5 or later)"; status=1; }
grep -qE 'persist-credentials: false' "$wf" 2>/dev/null || { echo "FAIL $wf must not persist the checkout credentials"; status=1; }
grep -qF 'cancel-in-progress' "$wf" 2>/dev/null && ! grep -qF 'github.sha' "$wf" && { echo "FAIL $wf must not share one concurrency group that drops pending version releases"; status=1; }
grep -qiE 'tag exists without a release' scripts/release.sh 2>/dev/null || { echo "FAIL scripts/release.sh must finish a release whose tag already exists"; status=1; }
grep -qF 'scripts/release.sh' "$wf" 2>/dev/null || { echo "FAIL $wf must publish through scripts/release.sh"; status=1; }
grep -qF 'tests/run.sh' "$wf" 2>/dev/null || { echo "FAIL $wf must run tests/run.sh before releasing"; status=1; }
grep -qiE 'Versions and changelog' README.md || { echo "FAIL README.md must have a Versions and changelog section"; status=1; }

# T2 in odd/tasks/design-harness.md: critique lenses with evidence and a refuter (S17).
cl="$r/critique-lenses.md"
for lens in 'Hierarchy and readability' 'Accessibility' 'System consistency' 'Copy and UX'; do
  grep -qE "^## [0-9]\. $lens" "$cl" 2>/dev/null || { echo "FAIL critique-lenses.md must define the lens '$lens' (S17)"; status=1; }
done
ev="$(section "$cl" '^## Evidence')"
for field in 'node ID' 'screenshot' 'rule' 'measured' 'severity'; do
  grep -qiF -- "$field" <<<"$ev" || { echo "FAIL critique-lenses.md evidence must require '$field' (S17)"; status=1; }
done
grep -qiE 'without evidence is dropped' <<<"$ev" || { echo "FAIL critique-lenses.md must drop findings without evidence (S17)"; status=1; }
rf="$(section "$cl" '^## Refuter')"
grep -qiE 'read-only' <<<"$rf" || { echo "FAIL critique-lenses.md refuter must re-measure with a read-only read (S17)"; status=1; }
grep -qiE 'confirmed, refuted or unverifiable' <<<"$rf" || { echo "FAIL critique-lenses.md refuter must classify findings (S17)"; status=1; }
sel="$(section "$cl" '^## Which lenses run')"
grep -E '^\| A new screen' <<<"$sel" | grep -qiE 'cross-screen review \| all four \|' || { echo "FAIL critique-lenses.md must run all four lenses on new screens and the final review (S17)"; status=1; }
grep -qiE 'only the finding' <<<"$rf" || { echo "FAIL critique-lenses.md refuter must receive only the finding, never the lens reasoning (S17)"; status=1; }
grep -qiE 're-verify[^.]*lenses' "$cl" || { echo "FAIL critique-lenses.md must say which lenses a re-verify runs (S17)"; status=1; }
section "$r/workflow-project.md" '^## 7\.' | grep -qF 'critique-lenses.md' || { echo "FAIL workflow-project.md final cross-screen critique must run the lenses (S17)"; status=1; }
section "$d/SKILL.md" '^## Output Contract' | grep -qF 'critique-lenses.md' || { echo "FAIL SKILL.md Output Contract must report the lenses (S17)"; status=1; }
grep -qiE 'unclear[^.]*all four' <<<"$sel" || { echo "FAIL critique-lenses.md must run all four when the change is unclear (S17)"; status=1; }
section "$sl" '^## 3\.' | grep -qF 'critique-lenses.md' || { echo "FAIL screen-loop.md step 3 must run the critique lenses (S17)"; status=1; }
grep -qE -- "^  - \*\*Lenses:\*\*" <<<"$rv" || { echo "FAIL screen-loop.md user review must have the field 'Lenses' (S17)"; status=1; }
section "$r/quality-bar.md" '^## Quality gate' | grep -qiE 'confirmed lens findings' || { echo "FAIL quality-bar.md gate must count confirmed lens findings (S17)"; status=1; }
grep -E '^7\. \*\*' "$r/iteration.md" | grep -qF 'critique-lenses.md' || { echo "FAIL iteration.md step 7 must run the lenses that cover the change (S17)"; status=1; }

# T12 in odd/tasks/design-harness.md: tested read-only measurement scripts (S18).
if command -v node >/dev/null; then
  node tests/figma-scripts.test.mjs || { echo "FAIL tests/figma-scripts.test.mjs (the use_figma measurement scripts)"; status=1; }
else
  echo "SKIP tests/figma-scripts.test.mjs (node not found)"
fi
grep -qF 'assets/scripts/measure.js' "$cl" || { echo "FAIL critique-lenses.md must measure with assets/scripts/measure.js (S18)"; status=1; }
grep -qF 'measure.js' <<<"$rf" || { echo "FAIL critique-lenses.md refuter must re-run measure.js on the finding's node (S18)"; status=1; }
grep -qF 'assets/scripts/snapshot.js' <<<"$snap" || { echo "FAIL sync-rules.md snapshot must come from assets/scripts/snapshot.js (S18)"; status=1; }
grep -qiE 'replace the (two )?parameter lines' "$cl" || { echo "FAIL critique-lenses.md must say how to pass parameters to measure.js (S18)"; status=1; }

# T13 in odd/tasks/design-harness.md: brownfield adoption of a Figma file the plugin did not create (S19).
bf="$r/brownfield.md"
if [[ -f "$bf" ]]; then
  adopt="$(section "$bf" '^## 1\.')"
  grep -qiE 'writes nothing to Figma' <<<"$adopt" || { echo "FAIL brownfield.md adoption must write nothing to Figma (S19)"; status=1; }
  for s in snapshot.js measure.js; do
    grep -qF "assets/scripts/$s" <<<"$adopt" || { echo "FAIL brownfield.md adoption must read the file with $s (S19)"; status=1; }
  done
  grep -qiE 'page map' "$bf" || { echo "FAIL brownfield.md must map the file's own pages to roles (S19)"; status=1; }
  grep -qF 'scope: adopted' "$bf" || { echo "FAIL brownfield.md must record scope: adopted (S19)"; status=1; }
  grep -qiE 'never (run|ask) style discovery|style discovery is not (run|asked)' "$bf" || { echo "FAIL brownfield.md must take the look from the file instead of style discovery (S19)"; status=1; }
  opt="$(section "$bf" '^## 4\.')"
  for item in 'Brief page' 'variables'; do
    grep -qiF "$item" <<<"$opt" || { echo "FAIL brownfield.md must offer '$item' as an opt-in (S19)"; status=1; }
  done
  grep -qiF 'routing.md' <<<"$opt" || { echo "FAIL brownfield.md opt-ins must go through the high-risk confirmation (S19)"; status=1; }
fi
section "$d/SKILL.md" '^## Decision Gates' | grep -qF 'brownfield.md' || { echo "FAIL SKILL.md Decision Gates must route a file the skill did not create to brownfield.md (S19)"; status=1; }
section "$d/SKILL.md" '^## Activation Contract' | grep -qiE 'did not create' || { echo "FAIL SKILL.md activation must cover files the skill did not create (S19)"; status=1; }
section "$r/routing.md" '^## 3\.' | grep -qE '^6\. \*\*Adopted file' || { echo "FAIL routing.md must list adopted-file structure as high-risk item 6 (S19)"; status=1; }
section "$r/workflow-screen.md" '^## A\.' | grep -qF 'brownfield.md' || { echo "FAIL workflow-screen.md part A must take an adopted file's look from brownfield.md (S19)"; status=1; }
section "$r/figma-structure.md" '^## Pages' | grep -qF 'brownfield.md' || { echo "FAIL figma-structure.md must keep an adopted file's own pages (S19)"; status=1; }
grep -E '^9\. \*\*' "$r/iteration.md" | grep -qF 'brownfield.md' || { echo "FAIL iteration.md step 9 must handle an adopted file without a Brief page (S19)"; status=1; }
grep -qE '^scope: <full \| minimal \| adopted>' "$d/assets/DESIGN.template.md" || { echo "FAIL DESIGN.template.md scope must allow adopted (S19)"; status=1; }
grep -qiE 'did not create' README.md || { echo "FAIL README.md must explain adopting a file the plugin did not create (S19)"; status=1; }

# T14 in odd/tasks/design-harness.md: review prompts must load the skill (S20); the description is all
# Claude reads before deciding, so it must name review next to design and change.
desc="$(grep -m1 '^description:' "$d/SKILL.md")"
grep -qiE 'design, change or review' <<<"$desc" || { echo "FAIL SKILL.md description must name review (S20)"; status=1; }
[[ -f evals/spanish-review-prompt/case.yaml ]] || { echo "FAIL missing trigger eval evals/spanish-review-prompt (S20)"; status=1; }

# T15 in odd/tasks/design-harness.md: a read-only first request on an adopted file shows the adoption
# summary and records nothing; the files are written with the first change request (S21).
if [[ -f "$bf" ]]; then
  ro="$(section "$bf" '^## 3\.')"
  grep -qiE 'read-only request' <<<"$ro" && grep -qiE 'records nothing' <<<"$ro" || { echo "FAIL brownfield.md must show the summary and record nothing on a read-only request (S21)"; status=1; }
  grep -qiE 'first change request' <<<"$ro" || { echo "FAIL brownfield.md must record the adoption with the first change request (S21)"; status=1; }
fi
section "$r/routing.md" '^## 1\.' | grep -E '^- \*\*Read-only' | grep -qF 'brownfield.md' || { echo "FAIL routing.md read-only must run the brownfield.md reads for a file the skill did not create (S21)"; status=1; }
section "$d/SKILL.md" '^## Output Contract' | grep -E 'Quality passes' | grep -qiE 'counts of confirmed, refuted and unverifiable' || { echo "FAIL SKILL.md Output Contract must report lens finding counts (S21)"; status=1; }

# T16 in odd/tasks/design-harness.md: v0.7.2 Desktop trial gaps, steps A and B (S22).
hr18="$(grep -E '^18\. ' "$d/SKILL.md")"
grep -qiE 'questions from different steps' <<<"$hr18" || { echo "FAIL SKILL.md Hard Rule 18 must keep questions from different steps in separate forms (S22 #1, #6)"; status=1; }
grep -qiE 'preflight[^.]*adoption[^.]*change[^.]*next step' <<<"$hr18" || { echo "FAIL SKILL.md Hard Rule 18 must give the step order preflight, adoption, change, next step (S22 #6)"; status=1; }
if [[ -f "$bf" ]]; then
  ro="$(section "$bf" '^## 3\.')"
  grep -qiE 'one next-step question' <<<"$ro" && grep -qiE 'record the adoption' <<<"$ro" || { echo "FAIL brownfield.md read-only must end with one next-step question that offers to record the adoption (S22 #1, #2)"; status=1; }
  grep -qiE 'never write inferred' <<<"$ro" || { echo "FAIL brownfield.md must ask the brief before writing, never write inferred answers instead (S22 #7)"; status=1; }
  grep -qiE 'unchanged' <<<"$(section "$bf" '^## 1\.')" || { echo "FAIL brownfield.md must run snapshot.js unchanged (S22 #4, #11)"; status=1; }
  grep -qiE 'marked high risk' <<<"$(section "$bf" '^## 4\.')" || { echo "FAIL brownfield.md opt-ins must be marked high risk when offered (S22 #3, #9)"; status=1; }
fi
grep -qiE 'unchanged' <<<"$(section "$r/sync-rules.md" '^## Snapshot')" || { echo "FAIL sync-rules.md must run snapshot.js unchanged (S22 #4)"; status=1; }
grep -qiE 'estimated[^.]*never[^.]*measured' <<<"$(section "$cl" '^## Evidence')" || { echo "FAIL critique-lenses.md must call screenshot values estimated, never measured (S22 #5)"; status=1; }
grep -E '^7\. \*\*' "$r/iteration.md" | grep -qiE 'position' || { echo "FAIL iteration.md step 7 must count position and spacing changes as visual (S22 #8)"; status=1; }
grep -E '^9\. \*\*' "$r/iteration.md" | grep -qiE 'one change is not a rule' || { echo "FAIL iteration.md step 9 must not turn a one-change choice into a rule (S22 #10)"; status=1; }

# T17 in odd/tasks/design-harness.md: v0.7.3 Desktop retrial gaps (S23).
if [[ -f "$bf" ]]; then
  grep -qiE 'change run[^.]*ends with one next-step question[^.]*opt-ins' <<<"$(section "$bf" '^## 5\.')" || { echo "FAIL brownfield.md report: a change run on an adopted file must end with one next-step question form offering the opt-ins (S23 #1)"; status=1; }
  grep -qiE 'never left as warnings' <<<"$(section "$bf" '^## 5\.')" || { echo "FAIL brownfield.md report: opt-ins are never left as warnings or prose (S23 #1)"; status=1; }
  look="$(grep -E '^- \*\*Look:' "$bf")"
  grep -qiE 'observed in the (adopted )?file' <<<"$look" || { echo "FAIL brownfield.md look must be recorded as observed in the file (S23 #4)"; status=1; }
  if grep -qiE 'provided by the user' <<<"$look" && ! grep -qiE 'never[^.]*provided by the user' <<<"$look"; then
    echo "FAIL brownfield.md look must not call the observed look provided by the user (S23 #4)"; status=1
  fi
fi
grep -E '^Palette:' "$d/assets/PRODUCT.template.md" | grep -qiE 'observed in the adopted Figma file' || { echo "FAIL PRODUCT.template.md Palette must allow 'observed in the adopted Figma file' (S23 #4)"; status=1; }
grep -E '^Typography:' "$d/assets/PRODUCT.template.md" | grep -qiE 'observed in the adopted Figma file' || { echo "FAIL PRODUCT.template.md Typography must allow 'observed in the adopted Figma file' (S23 #4)"; status=1; }
section "$d/SKILL.md" '^## Output Contract' | grep -E 'Quality passes' | grep -qiE 'as numbers, zeros included' || { echo "FAIL SKILL.md Output Contract must give lens counts as numbers, zeros included (S23 #2)"; status=1; }
section "$d/SKILL.md" '^## Output Contract' | grep -E 'Warnings' | grep -qiE 'opt-ins' || { echo "FAIL SKILL.md Output Contract Warnings must send adopted-file opt-ins to the next-step form (S23 #1)"; status=1; }
grep -E '^When it is unclear' "$cl" | grep -qiE 'tappable[^.]*touch target' || { echo "FAIL critique-lenses.md must say resizing a tappable element changes its touch target and runs Accessibility (S23 #3)"; status=1; }

# T7: README with install and usage for Claude Code and Claude Desktop.
readme="README.md"  # relative to the repository root; the script cds there at the top
if [[ -f "$readme" ]]; then
  for pat in 'claude plugin marketplace add UrielEscorcia/design-to-figma' 'claude plugin install design-to-figma@design-to-figma' 'claude plugin update design-to-figma@design-to-figma' 'zip -r \.\./design-to-figma\.zip design-to-figma' 'Capabilities → Skills' 'version.*user-invocable.*argument-hint' 'do not share or redistribute' 'Dev or Full seat' 'Add → Add marketplace' 'docs/assets/banner\.svg'; do
    grep -qE -- "$pat" "$readme" || { echo "FAIL README.md must include: $pat"; status=1; }
  done
  # Every local image the README references must exist; the banner and both Desktop screenshots stay referenced.
  imgs="$(grep -oE 'src="docs/assets/[^"]+"' "$readme" | sed -E 's/^src="//; s/"$//')"
  for img in docs/assets/banner.svg docs/assets/desktop-plugins-list.png docs/assets/desktop-plugin-page.png; do
    grep -qxF "$img" <<<"$imgs" || { echo "FAIL README.md must reference $img"; status=1; }
  done
  while IFS= read -r img; do
    [[ -z "$img" || -f "$img" ]] || { echo "FAIL README image missing: $img"; status=1; }
  done <<<"$imgs"
else
  echo "FAIL missing README.md"; status=1
fi

if [[ -f "$d/SKILL.md" ]]; then
  for f in "$d"/references/*.md "$d"/assets/* "$d"/assets/scripts/*; do
    [[ -f "$f" ]] || continue
    rel="${f#"$d"/}"
    grep -qF "]($rel)" "$d/SKILL.md" || { echo "FAIL SKILL.md does not link $rel"; status=1; }
  done
fi

# Versioning: `claude plugin update` skips a plugin whose version did not change, so the plugin and
# skill versions must match, and any change to the plugin since main must bump the version.
# The base is origin/main, or the local main when there is no remote.
version_of_plugin() { grep -oE '"version": *"[^"]+"' | grep -oE '[0-9][^"]*'; }
pv="$(version_of_plugin < .claude-plugin/plugin.json)"
# Plain X.Y.Z only: `sort -V` ranks 0.3.0-rc.1 above 0.3.0, so a prerelease would pass as a bump.
[[ "$pv" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "FAIL plugin.json version '$pv' must be X.Y.Z"; status=1; }
sv="$(grep -oE '^ +version: *"[^"]+"' "$d/SKILL.md" | head -1 | grep -oE '[0-9][^"]*')"
[[ -n "$pv" && "$pv" == "$sv" ]] || { echo "FAIL plugin.json version ($pv) and SKILL.md metadata version ($sv) must match"; status=1; }
base_ref=origin/main; git rev-parse -q --verify origin/main >/dev/null || base_ref=main
if base="$(git merge-base HEAD "$base_ref" 2>/dev/null)"; then
  if ! git diff --quiet "$base" -- skills .claude-plugin; then
    bv="$(git show "$base:.claude-plugin/plugin.json" 2>/dev/null | version_of_plugin)"
    newest="$(printf '%s\n%s\n' "$bv" "$pv" | sort -V | tail -1)"
    if [[ -z "$bv" ]]; then
      echo "FAIL cannot read the plugin version on $base_ref; fetch origin and rerun"; status=1
    elif [[ "$pv" == "$bv" || "$newest" != "$pv" ]]; then
      echo "FAIL the plugin changed since $base_ref but its version $pv is not higher than $bv; bump it"; status=1
    fi
  fi
else
  echo "SKIP version bump check (no origin/main or main)"
fi

if command -v claude >/dev/null; then
  claude plugin validate --strict .claude-plugin/plugin.json || status=1
  claude plugin validate --strict .claude-plugin/marketplace.json || status=1
else
  echo "SKIP claude plugin validate (claude CLI not found)"
fi

exit $status
