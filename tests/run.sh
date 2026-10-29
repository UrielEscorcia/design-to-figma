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

if [[ -f "$d/SKILL.md" ]]; then
  for f in "$d"/references/*.md "$d"/assets/*; do
    [[ -e "$f" ]] || continue
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
