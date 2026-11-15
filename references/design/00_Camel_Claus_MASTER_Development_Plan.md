# CLAUS FOR ALARM — MASTER GAME DEVELOPMENT PLAN
### Winter Sports Tower Defense · Godot 4.7.2 · Opus 5.5 · Blender · Browser delivery

**Plan ID:** `CC-MASTER-2026-11-13`  
**Revision:** `v1.0 — initial master plan`  
**Created:** 2026-11-13  
**Execution status:** `NOT STARTED — planning artifact only`  
**Owner / creative director:** You. **Implementation model:** Opus 5.5 at various effort levels. **Art production agent:** Blender-capable AI workflow, supervised by the owner.
**Project folder:** `C:\Users\qdruc\Projects\Godot\Camel Claus\Claus for Alarm` (Godot project root).  
**Studio/team:** Camel Claus. **Game title:** **Claus for Alarm**.  
**Event:** festive / Christmas-at-Connecticut-College with secret **Winter Sports** sub-theme.  
**Primary deliverable:** playable, self-contained, attractive **3D desktop-browser Godot game**. **Secondary deliverable:** separate studio / submission website if the hackathon actually requires it; check its specific submission rules.

> **MISSION:** First build a correct, demonstrably playable tower-defense simulation with disposable interface and art placeholders. Then, without changing the validated gameplay contracts, replace those placeholders in deliberate passes with cohesive original 3D models, terrain, VFX, interface, original music/SFX and a release-quality website/build. This master plan orchestrates work; the three hybrid design documents define what the game *is*. The three BTD6 research documents are references, not the implementation source of truth.

> **No automatic kickoff:** Giving an agent this file authorizes **inspection/planning**, not unrestricted execution. The owner must explicitly request the first phase or grant a bounded set of tasks. Never run all phases in one pass, replace approved files, or start modeling simply because this plan exists.

## Table of contents

1. [How to run and maintain this plan](#1-how-to-run-and-maintain-this-plan)
2. [Authoritative design documents and research references](#2-authoritative-design-documents-and-research-references)
3. [Locked concept, scope and deliberately excluded features](#3-locked-concept-scope-and-deliberately-excluded-features)
4. [Milestone dashboard and release definitions](#4-milestone-dashboard-and-release-definitions)
5. [Pending creative decisions, data gaps and decision gates](#5-pending-creative-decisions-data-gaps-and-decision-gates)
6. [Cross-document implementation contracts](#6-cross-document-implementation-contracts)
7. [Project architecture, file conventions and source control](#7-project-architecture-file-conventions-and-source-control)
8. [Step-by-step phased development checklist](#8-step-by-step-phased-development-checklist)
9. [Testing, golden cases, balance fidelity and acceptance matrix](#9-testing-golden-cases-balance-fidelity-and-acceptance-matrix)
10. [Fast submission route, scope cuts and priorities](#10-fast-submission-route-scope-cuts-and-priorities)
11. [AI coding-agent protocol and ready-to-use handoff prompts](#11-ai-coding-agent-protocol-and-ready-to-use-handoff-prompts)
12. [Progress log, decisions, risks, regressions and change control](#12-progress-log-decisions-risks-regressions-and-change-control)
13. [Definition of done and final submission checklist](#13-definition-of-done-and-final-submission-checklist)
14. [External technical references and provenance](#14-external-technical-references-and-provenance)

---

## 1. How to run and maintain this plan

### 1.1 Use it as a *living execution contract*

- An item is complete **only** if its listed behavior is implemented, reproducibly tested, evidenced and committed. A code file merely existing does not count as finished. Agent claims of success are provisional until demonstrated in Godot/browser and/or supported by tests.
- For each work session: read the relevant hybrid MD sections and latest progress entries → select a *small task batch with a measurable exit criterion* → make a branch/checkpoint → implement → run tests → inspect game visually → fix failures → update checkboxes and evidence → record changes → stop at the requested boundary.
- **Checkbox legend:** `- [ ]` pending; `- [x]` verified and accepted. Use separate `BLOCKED`, `PARTIAL`, `DEFERRED`, and `CANCELLED` labels in the task notes. Do **not** tick partial tasks; record partial progress in the session log.
- Keep task IDs stable even if a requirement moves between phases. Append new tasks with suffixes, such as `P08-T04a`, rather than renumbering older completed records. Record revised scope, not just a silent edit to the checkbox.
- Include an evidence pointer for every checked milestone: test file, screenshot, browser URL, short screen capture, run log, commit hash, and/or Blender inspection renders. Evidence file paths are preferred over prose assertions.
- Reopen upstream tests when map geometry, economy, round schedules, enemy descendants, tower footprints, targeting or upgrade stats change. Art-only changes must not alter these values without explicit authorization.
- This plan is not a replacement for issue tracking if the project later grows, but one Markdown file is easier to audit during a short hackathon than a new Kanban platform.

### 1.2 Document hierarchy, when conflicts occur

1. **Explicit new owner decision** (written in this plan's Decision Log and, if necessary, reflected in the appropriate hybrid design doc).
2. **Three Camel Claus hybrid documents in `references/design/`**: gameplay mechanics (`01`), art/UX (`02`), models/Blender (`03`). Use section-specific authority (see §2).
3. **This MASTER plan**: task order, evidence, progress state, dependencies, and operational rules. It may propose a default but does **not** silently override gameplay specs.
4. **BTD6 research in `references/research/`**: comparative mechanics, numerical baselines, reference observations and sources, clearly versioned.
5. **External patch notes/wiki/tool docs** when validating a missing or conflicting reference. Version and cite the result in the project data manifest.
6. **Agent assumptions**: lowest priority; must be labeled `ASSUMPTION` or `PROPOSED`, never smuggled into `LOCKED` specs.

If the three hybrids contradict one another: report the conflict, use the domain owner (`01` for mechanics, `02` for UX/audio, `03` for art-asset construction) and open a decision entry if cross-domain effects remain. Never guess a BTD6 number because a deadline feels close.

### 1.3 Agent response format per session

At **start**: task IDs, precise source sections read, proposed files touched, the current test baseline and a short concrete plan.  
At **end**: completed IDs, changed files, tests actually run and their outcomes, runtime/editor/browser verification, screenshots or evidence paths, remaining problems, required owner decisions, next bounded tasks.  
Always distinguish: `implemented` / `automated tests passing` / `visually reviewed` / `Web build verified` / `owner approved` — these are not synonymous.

### 1.4 What *not* to let the AI do

- Do not accept a single gigantic unchecked rewrite of the whole Godot project, or auto-create all six towers' entire 5-tier paths in one untestable patch.
- Do not copy or import BTD6 source meshes, extracted art, sounds or music; the published reference is design research only. Original costumes, names, map route, HUD graphics and sounds are required.
- Do not let presentation-layer nodes decide damage, income, enemy state or attack range. VFX may *observe* game events, never author them.
- Do not mark version-56 upgrade costs or patch snippets as an exact tested version-57.4 simulation of all crosspaths.
- Do not silently refactor both architecture and visual assets in the same step; isolate mechanical regressions from visual imports.
- Do not change the existing Godot version/renderer, Godot MCP setup, `.mcp.json`, `AGENTS.md` or `CLAUDE.md` without first inspecting and justifying the change.
- Do not use actual gameplay art as a blocker for the first technical alpha. Use intentionally ugly disposable proxies and clear text labels.

---

## 2. Authoritative design documents and research references

### 2.1 Primary files — **MUST read before corresponding tasks**

Assumed home for this master: `Claus for Alarm/references/design/00_Camel_Claus_MASTER_Development_Plan.md`. Links below are relative from that location.

| Shorthand | Project document | Domain authority | Must-read chapters before work |
|---|---|---|---|
| `HYB-M` | [01_Camel_Claus_Hybrid_Gameplay_and_Balance.md](./01_Camel_Claus_Hybrid_Gameplay_and_Balance.md) | Economy, enemies, rounds, six towers, four later towers, Quincy/Camel hero, targeting, upgrade architecture | **M-00–M-06** all simulation work; **M-07** initial upgrade identity and pricing; **M-08** later roster only; **M-09** hero; **M-10** base stats; **M-11** patch changes; **M-12** data/API/test contracts; **M-13** decisions |
| `HYB-A` | [02_Camel_Claus_Hybrid_Art_UI_Audio.md](./02_Camel_Claus_Hybrid_Art_UI_Audio.md) | Snow palette, world/camera, tower silhouettes, UI, audio, SFX, VFX, feedback | **A-01** identity; **A-02** map; **A-03/A-04** visual tower/hero identity; **A-05** layers; **A-06/A-07** UI states; **A-08/A-09** VFX/motion; **A-10** audio; **A-11/A-12** implementation and QA |
| `HYB-B` | [03_Camel_Claus_Hybrid_3D_Assets_Blender.md](./03_Camel_Claus_Hybrid_3D_Assets_Blender.md) | Asset production, topology, rigging, variants, `.blend/.glb`, 3D performance and model QA | **B-01** anti-primitive standard; **B-03** shared athlete; **B-04** Camel hero; **B-05** six tower briefs; **B-06** later roster; **B-07/B-08** enemies/map; **B-11/B-12** sockets/manifests; **B-13/B-14** agent workflow / acceptance; **B-15** Web constraints |

**Hard rule:** For each task, the agent must inspect the identified **exact hybrid section** and any dependent chapter before writing code. Simply reading this master is insufficient. Do not use file attachments in chat as the canonical version once the files are present in the project workspace; read the live on-disk copies.

### 2.2 Secondary BTD6 research — comparative sources, not design authority

| Shorthand | File under `../research/` | Suitable uses | Important limitation |
|---|---|---|---|
| `REF-M` | [BTD6_Gameplay_Systems_Mechanics_and_Balance.md](../research/BTD6_Gameplay_Systems_Mechanics_and_Balance.md) | Source tower costs/paths, high-level damage/round/economy and crosspath rules; version reconciliation | Most detailed prices from **v56**; many upgrade behaviors and complete round spawn schedules not verified for v57.4 |
| `REF-A` | [BTD6_Art_Audio_Visuals_and_UX.md](../research/BTD6_Art_Audio_Visuals_and_UX.md) | UI patterns, visuals, feedback event semantics and winter-map comparisons | Not a full frame-by-frame measured audiovisual capture; do not infer internal renderer pipeline |
| `REF-B` | [BTD6_3D_Asset_Modeling_and_Blender_Production_Reference.md](../research/BTD6_3D_Asset_Modeling_and_Blender_Production_Reference.md) | Art quality, pose/silhouette, mesh refinement, asset taxonomy, Blender QA | Not BTD6 source `.blend`/mesh data; proposed craftsmanship standards for original assets |

**Optional legacy dataset:** `BTD6_reference_balance_data.json` if present. Treat it as an optional version-56 numeric index, not an exact behavior engine. If absent, proceed using the primary design MDs and verified reference URLs; never block the entire game merely because that JSON isn't in the project.

### 2.3 Task → exact reading map

| Implementing... | Required hybrid chapters | BTD6 evidence to consult if ambiguity exists |
|---|---|---|
| Simulation time, match state and rounds | `M-02`, `M-04`, `M-05`, `M-12` | `REF-M` §§2,3,5,8,22–24 |
| Color-tier snowballs, split and immunities | `M-03`, `M-05` + `A-05` + `B-07` | `REF-M` §§4,8 and derived enemy reference |
| Placement/path targeting | `M-05` + `A-02`, `A-06/A-07` | `REF-M` §§3,6; `REF-A` V-06 |
| Six towers' base stats/attacks | `M-06`, `M-07`, `M-10`, `M-11` | Individual tower source links at `M-14` |
| Three paths, crosspath locks and exact tiers | `M-07`, `M-11`, `M-12` + `A-04`, `A-06` | `REF-M` §§6–7,21,23 |
| Ticket Booth economy | `M-04`, `M-07` (Farm), `M-10` + `A-06/A-10` | `REF-M` §§5,9,21 |
| Camel Claus / Quincy hero | `M-09`, `M-11` + `A-03`, `A-06` + `B-04` | Quincy individual hero page, patch notes |
| UI, audio, VFX | `A-01`–`A-12` + `M-02` events | `REF-A` V-06–V-13 |
| Blender towers + shared athlete | `B-01`, `B-03`, `B-05`, `B-11`–`B-15` + `A-04` | `REF-B` A-04–A-17 |
| Blender enemy/terrain/map | `B-07/B-08`, `A-02/A-05` + `M-03` | `REF-B` A-09/A-10 |
| Web/performance QA | `M-12`, `A-12`, `B-14/B-15` | Godot official Web/GLB docs (see §14) |

---

## 3. Locked concept, scope and deliberately excluded features

### 3.1 Creative/technical commitments **already decided**

- Stylized toy-like winter-sports **humanoid defender characters** and **mechanical** winter-game towers (not an all-camel roster; no photoreal humans).
- One featured mascot hero: **Camel Claus** mechanically anchored to **Quincy**. Hero auto-levels; do *not* invent a generic support aura that is absent from Quincy's source abilities.
- Enemy design: rolling, dynamically layer-breaking **colored snowballs**, with approved visual color sequence **Powder → Blue → Mint → Violet → Coral**, and **Gold** visually approved but *not yet assigned an exact mechanical class*; differentiated camo, regrow, lead-like, purple-like, armored and boss flags.
- Initial regular towers **six** with specific BTD6 mechanical anchors (table below); each is designed around **three paths × five tiers**, but all 90 tiers need **not** be available in the first playable jam build.
- Four additional mapped tower families are **planned later**; their presence in references does not grant permission to implement them now.
- Godot **4.7.2** standard / **GDScript** / **Compatibility renderer**, using existing **Godot MCP** connection in the development workspace; a browser build is a first-class target from the beginning.
- Work sequence: **mechanics and correct loops first**, use placeholder map/models/UI; polished meshes, cinematics, animations, audio and UI art follow in separately tested passes.
- BTD6 is a *mechanics and communication reference*. Do not include copied assets, exact map layouts, proprietary sounds, portraits, or branding.

### 3.2 Exact roster and mapping: initial versus later

**Owner scope decision (2026-11-14): Winter Games Lodge (Monkey Village) and Track Gritter (Spike Factory) are DEFERRED beyond the hackathon submission. Do not create, implement, or include these towers in the hackathon build. Existing concepts are retained only for a possible later expansion/extension; future production requires renewed authorization.**

| Status | Camel Claus name | BTD6 mechanical parent | Main role | Must never be confused with... |
|---|---|---|---|---|
| INITIAL | **Snowball Rookie** | Dart Monkey | Cheap early tower; standard piercing projectile; three distinct high-tier modes | Camel Claus hero projectile |
| INITIAL | **Avalanche Cannon** | Bomb Shooter | Explosive splash, group damage, anti-heavy branch | Tack Shooter |
| INITIAL | **Biathlon Ranger** | Sniper Monkey | Whole-map precision, heavy-target specialization, Supply Drop/Ammo mode | Dartling Gunner |
| INITIAL | **Slope Wax Sprayer** | Glue Gunner | Slow/wax debuff; corrosive branch can damage | Ice Monkey |
| INITIAL | **Snow Sorcerer** | Wizard Monkey | Elemental projectile, wall/area and summoning branches | Alchemist |
| INITIAL | **Ski Resort Ticket Booth** | Banana Farm | Income, bank and collection mechanics | Universal passive money generator |
| INITIAL HERO | **Camel Claus** | Quincy | Ricochet damage, auto XP, lvl 3/10 abilities, lvl 4 Focus stance | Team aura hero |
| PLANNED | Hockey Slapper | Boomerang Monkey | Returning/ricocheting projectile, knockback | Initial roster |
| PLANNED | Snowboard Trickster | Ninja Monkey | Intrinsic property detection, fast projectile/status | Initial roster |
| DEFERRED (post-hackathon, optional) | Winter Games Lodge | Monkey Village | Nearby support/aura | Initial roster |
| DEFERRED (post-hackathon, optional) | Track Gritter | Spike Factory | Persistent path hazards | Initial roster |

**Excluded, unless the owner explicitly changes scope later:** Dartling Gunner / Industrial Snowblower; Monkey Ace / Ski Patrol Glider; Engineer Monkey / Rink Engineer; Ice Monkey / Figure Skater; Tack Shooter / Puck Carousel; Alchemist / Hot Cocoa Coach. Do **not** create placeholders, purchase buttons, data resources, modeled assets, icon slots or preemptive tier trees for excluded families.

### 3.3 Source-to-reskin compatibility policy

To facilitate reuse of BTD6 balance, retain for each original mechanic: attack type, projectile count, attack interval, damage, pierce, range, targeting policy, attack tags, enemy-property interactions, special effects, upgrade transformative deltas, ability duration/cooldown, price, hero XP, and round spawn behavior **where sourced**. A visually themed snowball can replace a dart only if the attack behavior is actually equivalent; a magical blizzard cannot replace a straight laser without logging a mechanical deviation.

**Never say “exact BTD6 balance” merely because the visuals changed and the prices were copied.** Even perfect tower stats will play differently if map path-length, line-of-sight, placement sites, starting cash, enemy spawn schedules or hero XP/rate change. For missing reference values, create explicit `UNKNOWN_REFERENCE` entries, pick a labeled temporary placeholder *only for a prototype* if the current requested task requires it, add a reconciliation ticket, and prohibit the `SOURCE_PARITY_VERIFIED` label. A placeholder value is not an authorized final balance decision.

### 3.4 Scope tiers and delivery target

| Scope label | Promise | What it must contain | When |
|---|---|---|---|
| **S0: Minimum survivable Web build** | Demonstrable game that loads reliably | One path/map, basic layered snowballs, one tower, wave loop, place/upgrade, money/lives, win/lose, browser smoke test | Earliest technical vertical slice |
| **S1: Hackathon playable** | Short enjoyable complete game | Four or preferably six initial tower base kits, 1–2 meaningful upgrades per active path, Camel Claus at available hero levels, differentiated enemy properties, usable HUD and pause, all essential end states, themed presentation, working Web URL | Primary event target |
| **S2: Extended reference-faithful build** | Full design-spec depth | All six initial tower families with properly verified 3×5 paths and crosspath exceptions, extensive round patterns, full Quincy 20-level arc, more specialized enemies/economy interactions | Only after S1 stable; can continue after the event |
| **S3: Expansion** | Optional new content | Four planned regular families, extra maps/modes, richer progression, special events | Explicitly out of initial deadline |

**Important conflict resolution:** It is not mathematically coherent to promise a 10–15-round jam game reaching BTD6's expensive T5 builds while using vanilla round income and upgrade prices unchanged. Decide whether the release is (a) a short custom round set with clearly labeled new economic pacing; or (b) a longer reference-style round sequence with those prices. Do not claim exact parity under option (a). Full path architecture and data fields can be built now without shipping all future content.

---

## 4. Milestone dashboard and release definitions

**Manual tracking:** mark [x] only when the stated task/gate scope has supporting evidence. [ ] Partial means work exists but acceptance remains; [ ] Deferred is outside submission scope. Update this dashboard and the task checklists together; they do not auto-sync.

| ID | Milestone | Core phases | Gate / demonstration | Status | Evidence |
|---|---|---|---|---|---|
| G0 | Specifications and decisions recorded | P00 | Hybrid specs and decisions available | [x] Complete | Baseline d1567e1; session log |
| G1 | Editor & Web smoke | P01 | Editor boot and actual browser export | [x] Complete | p01 evidence; later Dev 12 export/browser smoke also passes |
| G2 | Data-driven match skeleton | P02-P04 | Path, placement, towers and match states | [x] Complete | test_data/map/match; Dev 12 regression |
| G3 | Combat/economy vertical slice | P05-P07 | Layers, money, waves, leaks, win/lose | [x] Complete | test_combat/full_run; selected special layers now implemented |
| G4 | Initial six-tower mechanical roster | P08-P09 | Six base kits, three upgrade paths and path locks | [x] Complete for submission scope | 54/90 tiers implemented (all paths through tier 3); remaining 36 deferred; test_towers/upgrades |
| G5 | Hero & selected special-property interactions | P10-P11 | Hero progression/abilities; active immunities, camo, splits, wax and economy | [x] Implemented and regression-tested for current roster | test_hero/combat/upgrades/full_run; P11-T01-T03; DEC-025/031; dev12_tests.txt. Unused enemy classes/branches remain deferred. |
| G6 | Technical alpha with functional UX | P12-P14 | Functional match loop plus complete browser/fresh-player acceptance | [ ] Partial: technical alpha exists | technical-alpha tag; Dev 12 12/12 suites and Web rounds 1-5. Full browser playthrough/restart and fresh-player acceptance remain. |
| G7 | Art asset pipeline established | P15 | Character, snowball and prop QA plus Web import and owner acceptance | [ ] Partial: pipeline working; acceptance open | P15-A01-A16 delivered; P15-T09 review not closed. Old Rookie retained by owner DEC-046; replacement is not a blocker. |
| G8 | Visual/audio beta | P16-P18 | Cohesive accepted models, terrain, UI, VFX, audio | [ ] Partial: integrated; owner requests visual revision | Dev 12 map/VFX/HUD/notices; P18 audio and animated menu exist. Dev 13 lighting/terrain/sidebar/portraits/UI pass pending. |
| G9 | Release candidate | P19 | Final candidate passes browser, performance, input and hosted QA | [ ] Partial: local RC built/tested | claus_for_alarm_rc_web_d098ca5.zip; dev12_rc_smoke.txt; high-end stress p95 6.8 ms. Hosted/late-round browser checks and revised-art candidate pending. |
| G10 | Submission complete | P20 | Public playable URL, completed website/credits and submitted entry | [ ] Pending | Upload/hosted verification, website credit publication, final media and submission confirmation outstanding. |
| G11 | Optional post-jam extension | P21 | Additional towers/tiers/rigging when authorized | [ ] Deferred; outside submission | Includes selected AccuRIG Rookie replacement, extra towers and tiers 4-5. |

**Dashboard reconciled after Dev 12 (2026-11-15).** Checked means evidence supports the stated submission scope; an unchecked partial gate does not mean its implementation is absent. Deferred work is not a submission blocker. No percentage is used because the original task list includes optional and superseded requirements.

**Submission progress at a glance**
- [x] Playable 25-round game, six regular towers plus hero, 54 implemented upgrades.
- [x] Current roster integrated; larger hero approved; functional old Rookie retained (DEC-045/046).
- [x] Animated main menu and original audio/settings integrated.
- [x] Dev 12 map dressing, layer-break feedback and special-wave acknowledgment notices implemented.
- [x] Local RC ZIP exported; extracted ZIP smoke-tested; 12/12 suites pass.
- [ ] Owner-requested terrain/lighting and complete UI overhaul accepted (Dev 13 checklist, section 12.1.7).
- [ ] Seven runtime-model portraits and per-tower pop counters implemented.
- [ ] Revised final Web build tested, including late rounds and restart.
- [ ] Public hosted game verified; website credits/media finished.
- [ ] Fresh-player check recorded and submission confirmed.


### Dependency overview

`G0 → G1 → G2 → G3 → G4 → G5 → G6 → G7 → G8 → G9 → G10`.  
**Allowed overlap:** asset *concept art* can be explored alongside G4–G6, and a small asset-import **pipeline test** belongs in G1/G7, but production modeling of all towers must not obstruct technical alpha. A Web export smoke test belongs in G1 and repeats at every gate, *not* only at G9.

### Non-negotiable milestone demonstrations

- G3 video/screenshot: a visible snowball transitions through layers when hit; on escaping, lives drop exactly once; once fully destroyed it pays the expected cash; a round does not finish with descendants alive.
- G4 evidence: shop icons for six tower categories are actionable where appropriate; four non-combat/combat mechanical categories behave differently; upgrade path locks are visible and tested.
- G5 evidence: Camel Claus levels at the correct event boundary; level 3/10 ability buttons unlock as specified when reached; Focus toggle only from level 4; pause and 2× affect cooldowns correctly.
- G6 evidence: a stranger can finish the playable slice with no development console, warnings or data-editor access.
- G8 evidence: character/asset comparison captures at the **actual gameplay camera** and a first-device browser performance check; the scene must not be a primitive collage.
- G10 evidence: independent opening of the actual hosted URL after publication; working controls and sound unlock, functional replay, accurate instructions and credit/license page.

---

## 5. Pending creative decisions, data gaps and decision gates

**The defaults below are not owner approvals.** Use them for non-destructive planning only; ask before locking a balance-affecting or public-facing choice. If a gameplay task would otherwise halt, implement the interface for both outcomes behind a config flag and temporarily label the active behavior as `PROTOTYPE_ASSUMPTION`.

| ID | Decision / unresolved issue | Default recommendation | Must decide before | Impact |
|---|---|---|---|---|
| D-01 | Public title and logo | **Claus for Alarm** (locked), studio **Camel Claus** | Public menu art / website / submission | Brand strings, visual identity |
| D-02 | **Gold snowball** | Make Gold a distinctive later **special class**, not a 6th linear basic hit point | Locking enemy family, precise rounds, economy | Spawn tree, RBE, currency, tutorial semantics |
| D-03 | Event experience length | Ship a short, labeled **custom demo round set** unless full reference rounds actually playable | Balancing and wave scripting | Ability access, economy/tier reach, demo duration |
| D-04 | Currency/start lives/difficulty | Begin from v56 **Medium** source numbers where verified; make defaults configurable | Economy tuning | All costs and perceived accessibility |
| D-05 | Path and map dimensions | One original ski-course route with 3–5 corners, fixed elevated camera | Placement/target testing | Entire tower effectiveness curve |
| D-06 | Camo/special property nomenclature | Winter equivalents and visible overlays; preserve separate mechanic flags | Enemy waves / tutorial | Damage eligibility, VFX, documentation |
| D-07 | Initial released upgrade depth | Build architecture 3×5; ship only verified and testable tiers by deadline | Upgrade content batch | Art scope, QA matrix, affordability |
| D-08 | How strict to pursue exact v57.4 BTD6 | Mark per-field confidence, patches, canonical scenarios; never invent full parity | Calling a feature “exactly matched” | Data provenance and effort |
| D-09 | Hero pose/weapon/costume | Unique camel anatomy, ski-pole launcher, winter gear, BTD6 Quincy *mechanics* | Premium character modeling | Rig, attack sockets, portraits |
| D-10 | Special boss / giant snowmass | Include only if scripted shell + child rules tested | End-wave content | New animations / performance / win logic |
| D-11 | Studio website and host | Verify event rules; prioritize one stable playable URL; site may be a separate lightweight page | Submission | Hosting/branding/extra work |
| D-12 | College logo / likeness rights | Use original stylized college-inspired look and original palette | Art finalization | Publishing / permission |

### Gap register for the agent to populate

| Gap ID | Domain | Required missing fact | Source to check | Priority | Status |
|---|---|---|---|---|---|
| GAP-001 | Upgrades | Every active tier's exact stats/attacks/secondary-path exceptions | `HYB-M` M-07 + individual BTD6 upgrade pages | P0 for shipped tiers | OPEN |
| GAP-002 | Rounds | Exact spawn groups/start times/intervals for selected reference rounds | `REF-M` round individual pages | P0 if claiming reference rounds | OPEN |
| GAP-003 | Hero | Quincy XP distribution, level modifiers, Focus and abilities in *target* game version | `HYB-M` M-09/M-11 + hero source/patch notes | P0 for shipped levels | OPEN |
| GAP-004 | Enemies | Special-type descendant graph/overkill/leak behavior and valid damage tags | `REF-M` enemies + BTD6 wiki | P0 for shipped enemy types | OPEN |
| GAP-005 | Income | Round completion, time modifiers, collection expiry/caps and farm bank rules | `HYB-M` M-04/M-07; `REF-M` §§5/9 | P0 for shipped economy | OPEN |
| GAP-006 | Rendering | Actual export options, device FPS/memory and audio gesture handling | Official Godot Web docs + real browser build | P0 | OPEN |

On a missing exact number, the agent must annotate its temporary stand-in in the project balance registry with `status = "PROTOTYPE_ASSUMPTION"`, add a GAP row, and not mark fidelity test passed. No silent interpolation.

---

## 6. Cross-document implementation contracts

### 6.1 One contract for simulation and presentation

Every gameplay state transition emits a structured semantic event (defined by `HYB-M` M-02) and is consumed by presentation (`HYB-A` A-05–A-11). **VFX/audio are subscribers**, not sources of truth. Suggested event names: `tower_placed`, `purchase_failed`, `tower_upgraded`, `attack_fired`, `enemy_hit`, `enemy_immune`, `layer_broken`, `enemy_split`, `enemy_leaked`, `status_applied`, `ability_ready`, `ability_used`, `hero_level_up`, `round_started`, `round_complete`, `income_collected`, `match_won`, `match_lost`.

At minimum an event needs `type`, `simulation_tick`, `source_entity_id`, `target_entity_id`, `world_position` (when applicable), `magnitude`, `tags` and `visual_context` (optional). An event never uses a VFX callback to inflict additional damage. A combat hit with no available sound/VFX assets must still resolve perfectly.

### 6.2 Layered snowball state contract (mechanics `M-03/M-05`, look `A-05`, model `B-07`)

Store **current enemy type**, **outer shell health**, **properties** (`camo`, `regrow`, `armored`, `lead_like`, `purple_like`, etc.), **path progress**, **speed**, **child-spawn tree**, **cash and leak values**, and relevant active statuses separately. For normal 1-damage chain, replace visible Powder/Blue/Mint/Violet/Coral shell based on **true descendant type**. Gold remains configurable until D-02 decision. Special effects use additional overlays/shape changes—not merely six colors for all properties.

Damage must process in a reproducible order: target eligibility → immunity → attack bonuses/mitigation → shell damage → layer break → descendants and overspill policy → pop/cash → gameplay event → eventual UI/VFX. Do not only reduce an on-screen colored ball's arbitrary HP and assume BTD6-like splitting was achieved.

### 6.3 Tower and upgrade contract (`M-06/M-07/M-10/M-11`, `A-04`, `B-05`)

A tower definition has stable `tower_id`, BTD6 `mechanical_source`, version tags, base Medium cost, footprint, placement type, range/LOS policy, one or more attack definitions, all three upgrade-tree slots, supported targeting policies, and one presentation profile ID. An upgrade records tier/path, price, prerequisite, new/modified attacks, replacement rules, stat changes, immunity modifiers, ability, non-linear crosspath exceptions and confidence/source fields.

The **visual model** changes based on the upgrade state but must never be trusted for target radius, pierce or damage. Keep each tier-3+ primary-path look dominant (`HYB-A` A-04 / `HYB-B` B-05), while secondary path tiers 1–2 decorate without overriding it. Crosspath states must be legal at runtime, not only disabled in the HUD.

### 6.4 Hero contract (`M-09/M-11`, `A-03/A-06`, `B-04`)

Camel Claus uses a **separate hero progression system** with round-based experience, no manual three-path purchases, level cap 20 in the long-term spec, one hero per match, and named ability cooldowns. **Quincy mechanically**: ricochet shot, level-3 Snowball Frenzy, level-4 Focused Shot, level-5 whiteout/camo detection, level-10 Blizzard Barrage and further per-level modifiers. Hero equipment changes/animations do not determine XP or attacks. **Do not add a team buff as default**; it would be a recorded original deviation.

### 6.5 Economic ledger contract (`M-04/M-07/M-10`, `A-06/A-10`, `B-05.6`)

All cash transactions go through one ledger: initial cash, tower purchases, upgrades, layer/pop income, end-round reward, Ticket Booth pickups/interest/auto collect, hero purchase, ability-produced cash where supported, refunds. Keep transaction reason and source entity, prohibit negative cash, ensure cash never gets credited twice on shell break and descendant resolution. Bank math and collection timing are source-sensitive; do not guess unexplained parameters.

### 6.6 Map/placement contract (`M-05`, `A-02`, `B-08`)

The **track spline, waypoints, path length, placement polygons, buildable/blocked masks and physical footprints** are gameplay data and must survive cosmetic map replacement unchanged. Environment objects can be visually relocated or added without affecting LOS/collisions unless the change has an explicit tech ticket and re-runs balance tests. Art test must include Powder snowball contrast against terrain and visible path edge in a 320×180 thumbnail.

### 6.7 Audio/VFX and browser contract (`A-08`–`A-12`, `B-14/B-15`)

FX budget priority: critical match state/hero abilities > ordinary hits/status > cosmetic snowfall. Pooled/reused effects over per-hit allocations. Sound bus categories and concurrency/pitch handling per `A-10`. Browser autoplay unlock uses first legal user gesture. WebGL 2 / Compatibility and single-thread export initially preferred, subject to verification of Godot 4.7.2 actual settings, host and test device. Performance optimization must not alter deterministic combat outcomes.

---

## 7. Project architecture, file conventions and source control

### 7.1 Proposed source tree (not yet created)

```text
Claus for Alarm/
  project.godot
  CLAUDE.md                       # small persistent agent policy, preserve user setup
  AGENTS.md                       # may coexist with CLAUDE.md; inspect before editing
  .mcp.json                       # already configured Godot MCP; do not overwrite
  .gitignore
  references/
    research/                     # gitignored
      BTD6_Gameplay_Systems_Mechanics_and_Balance.md
      BTD6_Art_Audio_Visuals_and_UX.md
      BTD6_3D_Asset_Modeling_and_Blender_Production_Reference.md
    design/
      00_Camel_Claus_MASTER_Development_Plan.md
      01_Camel_Claus_Hybrid_Gameplay_and_Balance.md
      02_Camel_Claus_Hybrid_Art_UI_Audio.md
      03_Camel_Claus_Hybrid_3D_Assets_Blender.md
  docs/
    logs/
      # QA and batch handoff notes generated later
    decisions/
      # optional machine-queryable spec changes; master §12 is canonical
  scenes/
    boot/Boot.tscn
    match/MainMatch.tscn
    match/TowerPlaceholder.tscn
    match/SnowballEnemy.tscn
    match/Projectile.tscn
    hero/CamelClaus.tscn
    ui/MatchHUD.tscn
    ui/TowerShop.tscn
    ui/UpgradePanel.tscn
    ui/HeroPanel.tscn
    ui/Settings.tscn
  scripts/
    core/SimulationClock.gd
    core/MatchState.gd
    core/PathService.gd
    core/PlacementValidator.gd
    core/TargetingService.gd
    core/CombatResolver.gd
    core/StatusManager.gd
    core/RoundDirector.gd
    core/EconomyLedger.gd
    core/UpgradeValidator.gd
    core/HeroXPService.gd
    core/GameplayEventBus.gd
    data/TowerDefinition.gd
    data/AttackDefinition.gd
    data/EnemyDefinition.gd
    data/UpgradeDefinition.gd
    data/RoundDefinition.gd
    data/HeroDefinition.gd
    data/BalanceRegistry.gd
    presentation/PresentationRouter.gd
  data/
    towers/                        # one definition per tower and upgrades
    enemies/                       # layered family and special flags
    rounds/                        # reference or labeled custom schedules
    heroes/                        # Quincy-mapped Camel Claus config
    balance/                        # version/provenance/overrides
    presentation/                   # cosmetic mappings only
  tests/
    unit/ integration/ scenarios/ performance/ fixtures/
  tools/
    # content validators, source reconciliation and export scripts
  assets/
    placeholders/                 # clearly temporary; disposable
    blender_source/                # source meshes, if kept in repo
    exports/                       # GLBs ready for Godot import
    portraits/ materials/ vfx/ audio/ qa_renders/
  build/
    web/                           # generated export artifacts; avoid source-controlled bloat
  release/
    # manifest, credits, screenshots, instructions, release notes
```

**Architecture is a proposal; align with existing files before moving anything.** Never create duplicate competing `MatchState`/`EventBus` implementations or break installed Godot MCP. Use small, explicit APIs and Godot `Resource` types for authorable game definitions if practical; JSON is also viable if versioned and validated. No battle math should be hardcoded in menu or model scene.

### 7.2 Responsibility boundaries

| Module | Owns | Does NOT own |
|---|---|---|
| `SimulationClock` | fixed simulation ticks, speed and pause | game art animation elapsed time |
| `MatchState` | PREPARE, SPAWNING, CLEANUP, REWARD, WIN, LOSE | tower ability formula |
| `PathService` | track interpolation and progress | snowball VFX rolling rotation |
| `PlacementValidator` | footprint/buildability, blocking/terrain | whether an asset's boots look good |
| `TargetingService` | priority, eligibility, LOS and selection | projectile collision resolution |
| `CombatResolver` | applied damage, pierce, immunity, children, rewards triggers | sound volume and particle counts |
| `StatusManager` | wax slow, regrow, armor debuff, timing/stacking | overlay appearance |
| `EconomyLedger` | ALL money mutations, priced purchase validation | ticket animation visuals |
| `RoundDirector` | scripted enemy group schedules and completion | cinematic intermission |
| `UpgradeValidator` | legal paths, tier mutation and discounts | icon coloring |
| `HeroXPService` | round XP and levels, abilities availability | hero costume mesh |
| `GameplayEventBus` | semantic one-way notifications | source of truth for combat |
| `PresentationRouter` | event-to-VFX/UI/audio/model mapping | modifying simulation damage |

### 7.3 Data files: required schema and provenance

Every stat used by the released game should be inspectable in data or code with: `source_game`, `source_entity`, `source_version`, `source_url`, `reference_value`, `game_value`, `unit`, `difficulty`, `crosspath_context`, `status` (`VERIFIED_SOURCE`, `PATCHED_SOURCE`, `PROTOTYPE_ASSUMPTION`, `ORIGINAL_DEVIATION`, `NOT_APPLICABLE`), `verified_date`, and `notes`. For values where no source is known, `reference_value=null` and **do not fake provenance**.

A useful audit command/table should show: `(unit/path/tier/field) — reference — implementation — delta — status — source`. Use patch overlays rather than overwriting original v56 rows. `original_design_diff.md` or a deviations log is a useful generated artifact, but §12 owns approval of gameplay changes.

### 7.4 Version control and safe agent work

- Make a **Git baseline commit** before code changes, then one small coherent commit per phase or tested task batch; store commit IDs in session log.
- Inspect `.gitignore`; exclude `.godot/`, bulky generated exports and machine-specific caches. Keep the authoritative MD specs, scripts, scenes, resources and code tests tracked. Plan large `.blend` assets and source provenance deliberately; consider Git LFS where available and needed.
- Use a new branch/checkpoint before risky schema migrations or broad refactors. Never execute unreviewed bulk deletions, automated asset replacements or blanket project setting changes.
- Capture Godot editor/import errors and runtime logs; do not declare `godot_status` connection equivalent to running a valid scene. A missing main scene is expected for the currently empty project but **not** after G2.
- Protect `.mcp.json` local executable settings; if moving the Godot exe out of OneDrive later, modify the path deliberately and verify MCP/editor still connect.
- Avoid making a separate app framework or Web frontend unless the jam specifically needs a studio website; core game lives in Godot.

---

## 8. Step-by-step phased development checklist

**Ordering principle:** Finish the technical vertical slice first. Every phase has a **must-read source list**, concrete tasks, evidence and a gate. Many tasks are content/data-heavy; the agent should work in small batches (preferably 1–4 task IDs per iteration) rather than attempt the whole phase in one prompt. Phase numbers remain stable across updates.

### P00 — Transfer documents, audit setup and freeze the current baseline
**Goal:** Establish one live project source of truth, avoid accidental rework.  
**Read:** all three hybrid files (especially M-00/M-01/M-13, A-00, B-00/B-17), this plan §§1–7.  
**Gate:** G0. **No gameplay implementation yet.**

- [x] **P00-T01** — Copy all three hybrid docs into `references/design/` with **exact expected filenames**, and place this master alongside them; confirm no `.md.md` extensions or renamed `(1)` duplicates.
- [x] **P00-T02** — Confirm the three original BTD6 MD references are in `references/research/` and clarify any missing optional JSON without blocking work.
- [x] **P00-T03** — Read `CLAUDE.md`, `AGENTS.md`, `.mcp.json`, `project.godot`, Git status and existing project content; report actual current game implementation rather than assuming project is blank.
- [x] **P00-T04** — Verify engine executable, version, Compatibility renderer, Godot MCP editor connection, and that the AI-assisted workflow is using the correct project workspace. — exe/version 4.7.2/Compatibility verified (P00). 2026-11-13: `godot_addon_install` installed `addons/godot_mcp` 0.1.2 + enabled plugin; `godot_editor_launch` → `godot_status` `editor_connected: true`, `scene_backend: editor (undoable, live)`; `godot_project_info` reads main scene/renderer; session runs in project root.
- [x] **P00-T05** — Create initial Git commit/checkpoint of current working configuration; protect existing work and configuration.
- [x] **P00-T06** — Record every user-approved roster entry, its source counterpart, and every explicit exclusion in the game-facing design registry (not yet content scenes).
- [x] **P00-T07** — Confirm owner decisions D-01–D-12 as LOCKED, PROPOSED or DEFERRED; do not unilaterally resolve high-impact ambiguities.
- [x] **P00-T08** — Write an `implementation_assumptions.md` (or log entry) listing exact short-demo constraints, target browser(s), play time goal and minimum acceptance definition.
- [x] **P00-T09** — Add a one-paragraph reference-loading rule to existing `CLAUDE.md` *without replacing existing text*; verify it explicitly prioritizes these design docs and this plan.
- [x] **P00-T10** — Set up persistent `docs/logs/` and test-evidence directories; add a reproducible command list for running Godot and future Web export.
- [x] **P00-T11** — Mark G0 only after on-disk paths, version control and the decision register have been checked in the actual project.

**P00 completion proof:** directory tree, actual Godot version, output from editor MCP connectivity, current Git hash, and decisions copied into §12. No edit to simulation code required.

### P01 — Godot/Web infrastructure smoke test (before complex gameplay)
**Goal:** Prove that the engine, renderer and hosting environment can launch the smallest possible game.  
**Read:** HYB-M M-01/M-12; HYB-A A-12; HYB-B B-15; official Godot Web docs.  
**Gate:** G1.

- [x] **P01-T01** — Create a tiny main scene with camera, fixed test geometry and `PLAY TEST` text; set project main scene only after verifying existing project contents. — `scenes/main/smoke_test.tscn/.gd` (engine-generated via headless builder, MCP unavailable); `run/main_scene` set; project had no scenes before.
- [x] **P01-T02** — Run scene in Godot editor; check Output/Debugger for parse errors, script warnings and missing resources. — windowed debug run with the editor binary (`--path . --quit-after 600`, exit 0, GL Compatibility on RTX 5080): 0 errors/warnings, `docs/logs/evidence/p01_editor_run.log`. In-editor F5 not driven (no MCP).
- [x] **P01-T03** — Install/check matching Godot Web export templates for actual installed engine version; do not assume templates installed because editor works. — `export_templates/4.7.2.stable/web_*` present and used by a successful export.
- [x] **P01-T04** — Configure an export preset for Web with Compatibility/WebGL 2; start with single-threaded mode unless actual host/browser testing requires otherwise. — `export_presets.cfg` preset `Web`, `thread_support=false`; browser log confirms `single-threaded`, WebGL 2.0.
- [x] **P01-T05** — Export a minimal `index.html` plus required sibling files to local build directory; serve via HTTP(s), not unsupported `file://` assumptions. — headless `--export-release` exit 0, 0 warnings (`docs/logs/evidence/p01_web_export.log`); served by `python -m http.server`.
- [x] **P01-T06** — Open in target desktop browser, check console, click/keyboard input, resize and fullscreen; document any restrictions. — Chrome 157 (Playwright, ANGLE/D3D11 GPU): console 0 errors/0 warnings, L/R click + keys logged, canvas tracks 1280×720/1366×768/900×700, `F` enters/leaves fullscreen. `docs/logs/evidence/p01_web_*.png`, `p01_web_console.log`. Not yet tested: Firefox/Edge, real-user zoom 90%.
- [x] **P01-T07** — Test audio gesture unlock with a tiny licensed/original sound stub so late-phase sound design does not surprise the release. — original synthesized `assets/audio/sfx_smoke_blip.wav`; AudioContext `suspended` before gesture → `running` after first click, blip played on each input. Audibility not confirmed by ear (automated browser).
- [x] **P01-T08** — Measure initial baseline FPS/frametime/loading size; note device, browser and resolution for future comparisons. — RTX 5080 laptop, Chrome 157 headless, 1920×1080 DPR 1: 1200 frames/5 s, avg 4.17 ms, p99 4.40, max 4.90 (rAF-capped); load event 34 ms local; build 39 MB raw / 10.2 MB gzip (wasm 38.6 MB).
- [x] **P01-T09** — Add a tiny script/shell note describing repeatable export, local serve and smoke test, including expected output paths. — `docs/COMMANDS.md` §Web smoke test.
- [x] **P01-T10** — Checkpoint the smoke-test state and keep an immediately restorable minimal Web build. — git tag `p01-web-smoke`; local archive `build/archive/p01_smoke_web.zip` (gitignored, 10 MB).

**P01 exit proof:** archived `build/web` smoke test, browser screenshot, console-clean log or enumerated known warning, and export command. **Do not** wait until completion of final art to attempt the first browser build.

### P02 — Data contracts, automated reference validation and simulation core
**Goal:** Make content data-driven rather than embedding every BTD6-ish number in GDScript conditionals.  
**Read:** HYB-M M-00/M-02/M-05/M-06/M-07/M-09/M-10/M-11/M-12; HYB-A A-11; HYB-B B-16.  
**Gate:** supports G2/G4.

- [x] **P02-T01** — Inventory preexisting scripts/data resources; choose Godot `Resource` definitions or versioned JSON in one consistent schema; do not duplicate sources of truth. — Inventory: only the P01 smoke scene existed. Chose Godot `Resource` `.tres` (CONVENTIONS) as the single schema; `scripts/data/*.gd`, values in `resources/`.
- [x] **P02-T02** — Implement `TowerDefinition`, `AttackDefinition`, `UpgradeDefinition`, `EnemyDefinition`, `RoundDefinition`, and `HeroDefinition` (or equivalent) with validation for required fields. — `TowerDefinition`/`AttackDefinition`/`UpgradeDefinition`/`EnemyDefinition`/`RoundDefinition`(+`SpawnGroup`)/`HeroDefinition`/`MatchRules`, all `GameDefinition` with `validate()`. Owner-scoped lean: only fields the six towers, basic snowballs, rounds and hero need now.
- [x] **P02-T03** — Add `BalanceRegistry`/loader with deterministic IDs, missing-field errors, version tags and a development-only source comparison report. — `Content` autoload (`scripts/core/content.gd`): sorted deterministic load, missing-status/negative errors, `status_report()` → `docs/logs/evidence/p02_status_report.txt` (188 lines). Per-value status field instead of report tooling (owner instruction).
- [x] **P02-T04** — Represent three upgrade paths with tiers 1–5, legal prerequisites, abilities, multiple attacks and explicit crosspath transforms; *do not* hardcode max tier 2 just because MVP is smaller. — 15 upgrades per tower (90 rows parsed from M-07: names, v56/v57 prices); prerequisite + duplicate validation; `is_legal_crosspath`/`can_upgrade`; `attacks` is an array. Abilities and crosspath transforms: fields added in P09 when the first verified upgrade needs them (owner: keep P02 lean).
- [x] **P02-T05** — Represent enemy shells/children, properties, status resistances, base speed, leak damage, cash, round-appearance and source references; allow Gold class to be swapped by data. — 5 basic snowballs Powder…Coral with source speeds 25/35/45/80/87.5 u/s, child chain, cash/pop, property flags; RBE/leak = `Content.rbe()`; Gold not defined (D-02 open). Status resistances arrive with P05.
- [x] **P02-T06** — Represent wave groups with enemy ID, count, first spawn time, send duration/spacing, lane ID, round ID and optional custom-round label. — `SpawnGroup` (enemy, count, start, duration, lane) + `RoundDefinition.custom_label`; rounds 1–10 = exact v56 source pages; golden RBE test 20/35/35/71/59/57/75/92/90/204 passes.
- [x] **P02-T07** — Represent hero levels 1–20, experience increments, changes per level, ability unlocks, stance and cooldowns separately from normal upgrades. — `HeroDefinition`: XP table L1–20 (M-09), `level_changes` per level incl. ability unlocks (L3/L10), Focus stance L4 (v57), cooldown notes. Applied in P10.
- [x] **P02-T08** — Implement deterministic simulation clock with fixed-step update, pause, speed multipliers and event order documented in tests. — `SimClock` fixed 60 Hz, speed = time scale, pause, long-frame cap; tested 60/120 ticks, paused 0, cap (`tests/test_data.gd`). Event order documented in `docs/ARCHITECTURE.md`.
- [x] **P02-T09** — Implement typed semantic game events, with event subscriber stub that may log text before art assets exist. — `GameEvent` + `Events` autoload (`send`/`emitted`, allowed `TYPES`), print subscriber via `-- --log-events`.
- [x] **P02-T10** — Add content validators: duplicate IDs, missing references, negative stats, invalid upgrade prerequisite cycle, undefined child types and unreachable round exit. — Validators: duplicate ids, missing refs (child, round enemy), negative stats, missing/unknown status, upgrade prerequisite gaps/duplicates, child-chain loops (round could never end), empty rounds/zero counts, hero XP order. Each proven by a broken fixture in `tests/test_data.gd`.
- [x] **P02-T11** — Create v56 baseline + v57 patch overlay record structure and distinguish `PROTOTYPE_ASSUMPTION` from `VERIFIED_SOURCE`. — Per-value status: v56 = `VERIFIED_SOURCE`, v57 overrides = `PATCHED_SOURCE` with old value in `notes` (e.g. Wax Splatter $970→$650), guesses = `PROTOTYPE_ASSUMPTION` (lives 150, footprints).
- [x] **P02-T12** — Write unit tests for content-loader determinism, upgrade-state legality (including 5-2-0 / 0-2-5 / 2-0-5) and wrong-branch rejection. — `tests/test_data.gd`: loader determinism, 5-2-0/0-2-5/2-0-5 legal, 3-3-0/1-1-1/6-0-0/5-0-3 illegal, wrong-branch rejection. `godot --headless --path . -s res://tests/test_data.gd` → PASS, exit 0.
- [x] **P02-T13** — Create one deliberately small **test-only** tower/enemy/round fixture to exercise all schemas without claiming game balance. — Test-only fixture built in code in `tests/test_data.gd` (`fx_*` tower/enemies/round/hero/rules), never shipped.
- [x] **P02-T14** — Document stable public interfaces and immutable combat-vs-presentation boundaries for future agents. — `docs/ARCHITECTURE.md`.

**P02 exit proof:** all data fixture validation tests pass; version/provenance report generated; changing a prototype tower stat requires changing data, not HUD scripts. An incomplete reference row must be visibly marked as a gap.

### P03 — Original map greybox, camera, paths, valid placement geometry
**Goal:** Create a *playable geometric arena*, not finished scenery.  
**Read:** HYB-M M-02/M-05; HYB-A A-02/A-06/A-07; HYB-B B-08/B-16.  
**Gate:** G2.

- [x] **P03-T01** — Block out one **original** Winter Games Ski Circuit with clear entry, finish/exit, 3–5 interesting turns and visible room for land-based towers. — `scenes/world/ski_circuit.tscn`: original route, START upper-left → FINISH right, 5 corners, 66 m; open snow beside entry and at the central bends. Screenshot `docs/logs/evidence/p03_placement_invalid_track.png`.
- [x] **P03-T02** — Choose a fixed, elevated orthographic or mild-perspective camera based on mouse selection accuracy and target unit readability; record the decision. — Fixed orthographic camera, pitch −60°, keep-width 42 m (reasons in `docs/ARCHITECTURE.md` §Map).
- [x] **P03-T03** — Define canonical world units, route length, track width, tower footprints, reference-to-Godot range conversion and map extents. — 1 unit = 0.1 m; map 320×200 units, route 660, track width 22, footprint 6 (`GameDefinition.UNIT_M`, ARCHITECTURE §Map).
- [x] **P03-T04** — Implement deterministic path interpolation/progress and heading; rolling snowball visual can be a simple colored sphere for now. — `position_at(distance)` piecewise-linear over waypoints, clamped; 6 interpolation asserts in `tests/test_map.gd`. Snowball sphere arrives with P04 rounds.
- [x] **P03-T05** — Define buildable vs unbuildable placement masks: track, map borders, props, existing tower overlaps and reserved areas. — `Placement.check` (`scripts/core/placement.gd`): bounds minus footprint, track + footprint clearance, blocker rects, tower overlap.
- [x] **P03-T06** — Implement screen-to-world mouse projection and mouse/keyboard placement controls; ensure no selection offset at different resolutions. — Keys 1–6 pick a shop tower, ghost follows the ground-plane ray, left-click buys, Esc / right-click cancel, click selects a placed tower. Cursor alignment checked in-game at 1152×648 (ghost under cursor); browser resolutions re-checked in the P04 Web smoke.
- [x] **P03-T07** — Create clear green-valid/red-invalid placeholder placement ghost with range circle and reason label; enforce validity in simulation, not only preview. — Ghost = tower scene: translucent green/red body, range ring, reason label (`On the ski track`, …). Purchase calls the same `placement_reason()` before `ledger.spend()`.
- [x] **P03-T08** — Implement basic location ownership: each tower has one stable placed coordinate; no walking towers in this initial scope. — Tower stores one fixed position + `entity_id`; no movement code exists.
- [x] **P03-T09** — Place representative placeholders for lake, lodge, slope, bench and trees **only if** they help validate obstruction and visibility; decorations cannot accidentally block LOS invisibly. — Only Lodge + Pond blockers (validate obstruction); placement-only, no LOS occluders in map_v1.
- [x] **P03-T10** — Test towers near bends, on route intersections, near HUD edge, at border and on colliders; placement rejection must be deterministic. — `tests/test_map.gd`: open snow, on track, inside/just clear of a bend, border, off-map, on/touching/beside lodge, pond, tower overlap, repeated calls identical → PASS. HUD-edge clicks: GUI consumes them (P04).
- [x] **P03-T11** — Freeze a `map_v1_geometry` snapshot and coordinate tests; any later artistic edit to track/footprint requires a balance review. — map_v1 frozen: waypoints, bounds, track width asserted by `tests/test_map.gd`; any change needs a balance review.

**P03 exit proof:** cursor-accurate playable path and tower ghost at desktop browser resolution; map geometry and waypoint coordinates committed.

### P04 — Match state machine, flow controls and placeholder HUD
**Goal:** Provide a controllable game loop before adding complex combat.  
**Read:** HYB-M M-02/M-04; HYB-A A-06/A-07; HYB-B B-16.  
**Gate:** G2.

- [x] **P04-T01** — Implement main match states: BOOT/READY/PREPARE/ROUND_SPAWN/ROUND_CLEANUP/ROUND_REWARD/WON/LOST and PAUSED; define allowed transitions. — `match.gd` `State` + `TRANSITIONS` (BOOT/PREPARE/ROUND_SPAWN/ROUND_CLEANUP/ROUND_REWARD/WON/LOST); READY folded into PREPARE; pause is an orthogonal clock freeze, not a state (`docs/ARCHITECTURE.md` §Match).
- [x] **P04-T02** — Implement `Start round`, pause/resume, normal/fast time and restart; capture which controls are enabled in each state. — Start (Space/button), pause (P/button/overlay), 1×/2× (F/button), restart (overlay → `reload_current_scene`); per-state control table in ARCHITECTURE §Match. Double start ignored (test).
- [x] **P04-T03** — Build crude but usable HUD with lives, money, round number, speed, start, pause, and a six-slot tower list with temporary text labels. — `scenes/ui/match_hud.tscn`: lives/cash/round/state, six price-sorted text shop buttons (disabled when unaffordable), start/pause/speed. Screenshots `docs/logs/evidence/p04_*.png`.
- [x] **P04-T04** — Add simple placeholder info panel for selected defender: range, target mode, price, sell, upgrade slots and blocking status. — Selected-tower card: range (units + m / global), target mode, invested, sell (70 %, works), next tier per path from data with crosspath "locked" flag; purchase of upgrades deferred to P09.
- [x] **P04-T05** — Make inputs safe in a browser: mouse focus, escape-cancel, key conflicts, fullscreen resize and UI-to-3D click-through handling. — Buttons `focus_mode = NONE`; world input via `_unhandled_input` (HUD clicks never reach the world, MCP click report); Esc/right-click cancel only; Chrome resize 1280×720/1366×768/1920×1080/900×700: ghost under cursor each time (`p04_web_*.png`). Fullscreen = browser F11 (P01 `F` key now = speed).
- [x] **P04-T06** — Create a debug overlay (only for development) showing simulation ticks, active snowballs, towers, effects, cash transactions and active state. — F3 dev overlay (debug builds only): tick, speed, paused, state, spawned/scheduled, snowballs, towers, effects, last 5 ledger transactions (`p04_round_running.png`).
- [x] **P04-T07** — Prevent round completion while scheduled spawn events or spawned descendants remain; differentiate SPAWNING and CLEANUP. — ROUND_SPAWN → CLEANUP when schedule exhausted; REWARD only when no snowballs remain; asserted in `tests/test_match.gd` (20 spawned, still rolling in CLEANUP).
- [x] **P04-T08** — Implement minimal win/lose/replay screens with plain typography and actual state changes; no final visual design required. — Overlay with title + Resume/Restart: Paused / Victory / Defeat; WON/LOST state changes proven by `tests/test_match.gd`; paused overlay screenshot `p04_web_paused.png` (win/lose overlay not screenshotted).
- [x] **P04-T09** — Add match reset tests covering towers, cash, XP, ability cooldowns, statuses, children, bank balance and event subscriptions. — `tests/test_match.gd`: new match after a played one has start cash/lives, tick 0, round −1, no towers/snowballs, 1 ledger entry, no leaked `Events` subscriptions. XP, cooldowns, statuses, bank do not exist yet; extend this test when they land.
- [x] **P04-T10** — Record one uninterrupted PREPARE→ROUND→REWARD→PREPARE session without invalid transitions. — `docs/logs/evidence/p04_test_match.log`: PREPARE→ROUND_SPAWN(t0)→ROUND_CLEANUP(t1051)→ROUND_REWARD→PREPARE(t2635), 20 lives lost, +$101, deterministic across runs; same result in Chrome (130 lives, $551).

**P04 exit proof:** all control states work; no overlapping rounds on repeated clicks; pause genuinely freezes simulation; restart restores clean state.

### P05 — Rolling colored snowballs, children, armor and immunity foundation
**Goal:** Establish the game's core intuitive enemy representation and actual layered damage state.  
**Read:** HYB-M M-03/M-05; HYB-A A-05/A-08; HYB-B B-07.  
**Gate:** G3.

- [x] **P05-T01** — Lock the five baseline mechanical layers: Powder→Blue→Mint→Violet→Coral, mapped to source Red→Blue→Green→Yellow→Pink; keep speed-per-layer semantics separate from color. → DEC-017; `test_data` layer RBE 1..5
- [x] **P05-T02** — Implement `EnemyDefinition` for basic five-layer descendants and a runtime `SnowballEnemy` shell/child state that can downgrade on one valid damage. → `EnemyDefinition` + `snowball.gd` `set_layer`
- [x] **P05-T03** — Implement rolling movement along route based on progress/speed; rotation is cosmetic and must not alter gameplay path. → distance/speed per tick in `match.gd`; no rotation yet
- [x] **P05-T04** — Implement deterministic `apply_damage`/`break_shell`/`spawn_children` lifecycle and event IDs; preserve credited kills without double counting. → `match.damage_snowball` (overflow, $1/layer, `layer_broken` events); `test_combat` damage table + chain
- [ ] **P05-T05** — Add data-driven child graphs for branching special types; test one 1→1 downgrade and one 1→multiple split fixture. → **DEFERRED** — multi-child specials (DEC-019); 1→1 tested; validator rejects child_count > 1 until P11
- [x] **P05-T06** — Separate `can_detect`, `can_target`, `can_damage`, and `can_apply_status` per attack; represent immunity tags independently. → detect/target (camo), damage (`immune_<type>`) and status (wax skips `immune_glue`) separate and tested (`test_combat`, `test_towers`)
- [x] **P05-T07** — Implement stop/slow/regen/camo/fortified-like flags at framework level; do not create all 17 BTD6 enemy types in MVP unless required by active rounds. → camo + immunity + slow (wax status) live and tested; regen/fortified DEFERRED with specials (DEC-019)
- [ ] **P05-T08** — Create test versions of protective shell (Ceramic-like), blast-resistant, cold-resistant, magical-immune, and camouflaged snowballs where mechanical source supports them. → **DEFERRED** — special snowballs DEFERRED (DEC-019)
- [x] **P05-T09** — On escape, remove child/parent appropriately and subtract leak damage *once*; never award destruction cash for a leak. → `test_match` "leaks never pay pop cash"; `test_full_run` pop $ = RBE − leaked
- [x] **P05-T10** — On layer break, replace current visible placeholder color; ensure Powder has dark outline so it stands out against snowy terrain. → recolour on break + dark outline on every layer; `p06_editor_combat.png`
- [ ] **P05-T11** — Make Gold a configurable special class placeholder, not hardcoded as six straight HP layers, until D-02 owner approval. → **DEFERRED** — no Gold for now (DEC-018)
- [x] **P05-T12** — Test fast enemy + 2× + pause/resume + exit at exact endpoint; no premature disappearance, false rewards, or status-timing drift. → `test_combat` 1×≡2×, `test_match` pause; leak at exact track length; status timing N/A until P08
- [x] **P05-T13** — Validate RBE/child consistency with known references on a per-type basis; label any unverified exact branch structure. → basic five: RBE 1..5 and rounds 1–16 RBE = source pages (`test_data`); specials DEFERRED

**P05 exit proof:** deterministic damage table for all five basic snowballs; two recorded demos of a color decrement and a special child split; no reward duplication.

### P06 — Targeting, projectiles, collision, damage/pierce and status pipeline
**Goal:** Make defense numerically coherent and deterministic.  
**Read:** HYB-M M-02/M-05/M-07/M-10/M-11; HYB-A A-08/A-11.  
**Gate:** G3.

- [x] **P06-T01** — Implement base target priorities **First**, **Last**, **Close**, **Strong** where the active unit supports them; specify stable tie-breaking to avoid flicker. → `scripts/core/targeting.gd` First/Last/Close/Strong, tie → lower id; `test_combat`
- [x] **P06-T02** — Compute range/detection/LOS eligibility before ranking targets; global-target Sniper is a separate policy, not a giant radius hack. → range (edge contact) + camo before ranking; Biathlon Ranger is a separate whole-map policy with Lodge line of sight (`test_towers._test_ranger`)
- [x] **P06-T03** — Define attack scheduler with cooldown/volley/projectile spawn semantics, fixed-step timing and projectiles remaining after target changes. → per-tower cooldown on sim ticks, shots fly on after retarget; volleys with P09 upgrades
- [x] **P06-T04** — Implement moving projectile collision with attack hit history, pierce consumption, travel time, distinct-target and repeated-hit policies. → swept segment hits, pierce, per-shot hit history by entity id; `test_combat` pierce 1/2 + one-shot-one-layer
- [x] **P06-T05** — Implement area-of-effect explosion with **contact projectile pierce ≠ explosion pierce**, especially for Avalanche Cannon. → Cannon contact projectile (pierce 1, no damage) creates one explosion (pierce 22); `test_towers` blast-pierce cap differs from contact pierce
- [x] **P06-T06** — Implement damage tags and immunity interactions, including magic/energy, sharp, explosive, status-only wax and future typed bonus damage. → `immune_<damage_type>` check in the single damage path; `test_combat`
- [x] **P06-T07** — Implement behavior when attack is immune: no damage, no unintended income, correct event; whether it consumes pierce must be specified/tested. → immune contact uses 1 pierce, no damage/cash, one `enemy_immune` event; `test_combat`
- [x] **P06-T08** — Implement status application, timing, refresh/override and stacking semantics with source/version fields rather than one global slow percentage. → wax status: duration, refresh by equal/stronger, weaker ignored, no stacking, shed on layer break unless Glue Soak; `test_towers._test_wax`
- [ ] **P06-T09** — Implement attack bonus vs large snowballs, before/after armor debuffs, persistent effects and multi-attack order support even if later tiers aren't shipped yet. → **PARTIAL** — camo bonus (`bonus_vs_camo`), multi-attack order (Sorcerer Fireball) and sub-attacks done; bonus vs large / armor debuffs DEFERRED (no MOAB-class or armored snowballs, DEC-019)
- [x] **P06-T10** — Use a single gameplay damage resolver and one event emission path; ensure effects do not recursively cause unbounded chain loops. → `damage_snowball` is the only damage/event path; loop bounded by damage
- [x] **P06-T11** — Test 1x and 2x game speed equivalence in **simulation results**, allowing wall-clock run time to differ. → `test_combat` identical ledgers at 1× and 2×
- [x] **P06-T12** — Build unit test fixtures: one layer, heavy shell, lead-like immunity, camo undetectable, pierce=1 vs pierce>1, overlapping explosion, cross-source status. → one layer, lead-like immunity, camo, pierce 1 vs 2 (`test_combat`); overlapping explosion, blast vs contact pierce, cross-source wax refresh (`test_towers`); heavy shell DEFERRED (DEC-019)
- [ ] **P06-T13** — Profile 100+ proxy snowballs / many projectiles to find obvious O(N²) broadphase issues; optimize when evidenced. → **PARTIAL** — not profiled yet: round 19 (115 snowballs, 23 towers) runs headless without issue; browser FPS check in P14
- [x] **P06-T14** — Expose development logs: attacks fired, hits, immune impacts, pierce used, pop credit and target choice to enable balance analysis. → `-- --log-events` prints attack_fired (with target), enemy_hit, enemy_immune, layer_broken; F3 ledger

**P06 exit proof:** one validated basic projectile, one explosive attack, one status-only attack, and automated correctness cases for immunity, pierce, and target order.

### P07 — Economy, buying/selling, scripted rounds and end conditions
**Goal:** Turn disconnected combat mechanics into an actual tower-defense strategy game.  
**Read:** HYB-M M-04/M-07/M-10/M-11/M-12; HYB-A A-06/A-07.  
**Gate:** G3.

- [x] **P07-T01** — Create one `EconomyLedger` for starting cash, price checks, purchase, upgrade, pop income, round reward, sell, Ticket Booth rewards and hero placement. → `EconomyLedger`: start, purchase, upgrade, pop, round bonus, sale, Ticket Booth `ticket_income` (hero in P10)
- [x] **P07-T02** — Implement round-based income using verified source values; represent income brackets/difficulty modifiers as data rather than UI code. → round bonus 100 + n and $1/pop as data (`rules_medium`, enemy `cash_per_pop`); >R50 brackets N/A
- [x] **P07-T03** — Implement Medium cost baseline and optional Easy/Hard/Impoppable price multipliers/rounding **only after** source rounding checks; use Medium for MVP. → Medium only
- [x] **P07-T04** — Apply 70% default sell-back on invested amount in eligible modes; account for discounts separately when applicable. → 70% of invested (P04, `test_match`)
- [x] **P07-T05** — Implement `RoundDirector` from time-stamped group data; round completes only after all spawned descendants are resolved and scheduled spawns exhausted. → round ends only when schedule exhausted and all snowballs resolved (`test_match`, `test_full_run`)
- [x] **P07-T06** — Create one short playable wave fixture first, then a sequence that introduces layer speed, crowds, statuses and armor deliberately. → round 1 fixture → 19-round sequence (`test_full_run`)
- [x] **P07-T07** — Source and verify exact round compositions for any stage claimed as a BTD6-equivalent round; mark custom rounds as original. → rounds 1–16 exact v56 pages, RBE checked; 17–19 `ORIGINAL_DEVIATION` "Finale" (DEC-020)
- [x] **P07-T08** — Implement legal win/lose conditions and optional freeplay choice later; no extra money/life changes after match ended. → WON after round 19, LOST at 0 lives; frozen after end (`test_match`, `test_full_run`)
- [x] **P07-T09** — Add developer-only cash transaction ledger and projected-income per round report; compare to expected fixtures. → F3 ledger overlay; per-round report `docs/logs/evidence/p07_full_run.txt`
- [x] **P07-T10** — Test sell/rebuy timing, insufficient cash, lost lives and simultaneous pop/leak near round finish. → insufficient cash/sell (`test_match`); leak-before-shoot tick order; ledger identity holds in leaking finale rounds
- [x] **P07-T11** — Implement safe automation for skipping intermissions if desired; double-clicking start never doubles spawn groups. → double start ignored (`test_match`); auto-skip not added
- [x] **P07-T12** — Build a complete two/three-round test run playable with starter tower and placeholder UI; compare logs across reruns. → `test_full_run` WON, rerun identical; browser round 1 = headless ($371)

**P07 exit proof:** a real, repeatable beginning-to-end match exists. **This is the first complete technical vertical slice** and should be deployed to browser immediately, even if the art is crude.

### P08 — Six initial tower families, base attacks and data-backed roles
**Goal:** Have every approved starting defender instantiated, placed and behaviorally distinct.  
**Read:** HYB-M M-06/M-07/M-10/M-11; HYB-A A-04/A-06; HYB-B B-05 only to reserve art/socket/profile names.  
**Gate:** G4.

**Implementation order:** Snowball Rookie → Avalanche Cannon → Biathlon Ranger → Slope Wax Sprayer → Snow Sorcerer → Ski Resort Ticket Booth. Make each unit pass smoke tests before adding the next. The initial six base numeric anchor rows are in `HYB-M M-10`; upgrade prices/path names are in `HYB-M M-07`. Do **not** choose stats from memory.

- [x] **P08-T01** — **Snowball Rookie (Dart Monkey)**: configure price, default projectile interval, range, pierce, sharp damage and legal placement using versioned data; test single-target and line/group cases. → base kit from G3 (`test_combat` pierce/line cases); in the six-tower shop
- [x] **P08-T02** — **Avalanche Cannon (Bomb Shooter)**: explosion area with separate contact and blast parameters, group damage, immunity; test nearby independent snowballs and overlapping child spawns. → `test_towers._test_cannon` (independent snowballs in one blast, explosion-immune, out-of-radius, Coral loses one layer); blast radius 18 PROTOTYPE_ASSUMPTION
- [x] **P08-T03** — **Biathlon Ranger (Sniper Monkey)**: whole-map eligible targeting with LOS, base damage and rate; test prioritized Strong and hidden camo enemy behavior. → instant hit, `global_range` + Lodge line of sight (group `blocks_sight`), Strong across the map, camo skipped; `test_towers._test_ranger`
- [x] **P08-T04** — **Slope Wax Sprayer (Glue Gunner)**: wax status projectile whose base mode does not deal damage; slow duration/refresh and immunity tests; no accidental pop income. → status only, no pop cash, waxed snowballs not re-targeted (PROTOTYPE_ASSUMPTION), duration 11 s PROTOTYPE_ASSUMPTION; `test_towers._test_wax`
- [x] **P08-T05** — **Snow Sorcerer (Wizard Monkey)**: energy/magic attack, multiple enemy pierce and immunity response; reserve interfaces for wall effects and summon branches. → energy damage, pierce 3, energy-immune contact uses pierce; wall/summon branches = later tiers (coming soon); `test_towers._test_sorcerer`
- [x] **P08-T06** — **Ski Resort Ticket Booth (Banana Farm)**: no combat targeting; collectible income event or explicit cash-collection affordance; test per-round production, cash expiry and manual/auto collection where applicable. → 4 x $20 pickups spread over the round (timing PROTOTYPE_ASSUMPTION), click to collect, 15 s expiry (source), sold booth stops; `test_towers._test_booth`
- [x] **P08-T07** — Create one base-tower purchase tile/selection info for each initial unit; temporary icon names are enough while assets absent. → six text tiles + hotkeys 1-6, price, greyed when unaffordable (`p08_editor_shop_round1.png`, `p09_web_boot.png`)
- [x] **P08-T08** — All six towers use a common placement/selection/upgrade interface; special mechanics extend it through data-driven capabilities, not copy-pasted scripts. → one `tower.tscn`/`tower.gd` + data capabilities (attacks/sub-attacks, `global_range`, pickups); no per-tower scripts
- [x] **P08-T09** — Add stable IDs and accurate BTD6 source counterparts to content manifests; no unused excluded roster resources. → id + `source_tower` + `source_url` per tower/attack/upgrade; exactly six towers (`test_towers._test_base_report`)
- [x] **P08-T10** — Run comparative baseline tests of base purchase cost, cooldown, range, damage/pierce, targeting and legal placement for each, with version/citation fields. → `docs/logs/evidence/p08_base_stats.txt` (all six match M-10, provenance per field)
- [x] **P08-T11** — Add mixed-roster automated scenario: Rookie handles low-tier snowballs, Cannon handles clusters, Biathlon heavy target, Wax slows, Sorcerer handles typed enemies, Booth generates income. → mixed-roster bot WON 80 lives ~10.2 min + solo bots per type (`tests/test_full_run.gd`, `p09_full_run.txt`)
- [ ] **P08-T12** — Rebuild and run Web alpha after the sixth tower; record performance and input errors. → **PARTIAL** — Web alpha exported and browser-tested with 0 console errors/warnings and working input (`p09_web_*`); frame-time profiling not recorded (P14)

**P08 exit proof:** six priced units available in shop, all function distinctly, first base-stat comparison report passes, and zero excluded families present.

### P09 — Branching upgrade paths, crosspath legality, ability modifiers
**Goal:** Build *one correct reusable upgrade engine* and phase in content without re-architecting for five tiers later.  
**Read:** HYB-M M-07/M-08 (later only), M-11/M-12; HYB-A A-04/A-06/A-07; HYB-B B-05/B-11.  
**Gate:** G4.

- [x] **P09-T01** — Build upgrade legality engine for 3 paths × 5 tiers and exactly one permitted supporting path to tier 2 after a tier 3+ commitment. → `TowerDefinition.is_legal_crosspath` + `can_upgrade` (also requires a shipped tier)
- [x] **P09-T02** — Test legal edge states (`0-0-0`, `2-2-0`, `2-0-2`, `5-2-0`, `0-2-5`, `2-0-5`) and illegal states (`3-3-0`, `3-2-1`, `5-0-5`). → `test_upgrades._test_legality` (all listed legal/illegal states) + purchase refusals for 3-2-0
- [x] **P09-T03** — Build data-driven stat/attack mutation pipeline: additive/multiplicative stats, attack append/replace, ability attach, property bypass, spawned subattacks and crosspath overrides. → `UpgradeEffect` add/multiply/set/append on the tower or any attack in its tree; attack append (Fireball), sub-attack append (frags, shrapnel, splatter, cluster), property bypass (FMJ Normal); appends applied before stat changes; abilities DEFERRED (no shipped tier has one)
- [ ] **P09-T04** — Build price display and purchase from actual source/patch price, with correct rounding and available cash; serialize/preserve selected path state for restart/replay. → **PARTIAL** — source/v57 prices (Glue Splatter $650), charged once via the ledger, invested + sell value; path state is per tower and restart is a fresh match by design, no replay serialization
- [x] **P09-T05** — Implement **one fully verified low-tier progression** for Snowball Rookie across all 3 paths including crosspath sample, then generalize to Cannon and others. → Rookie T1-T3 on all three paths + crosspaths 2-0-3 and 3-2-0, then Cannon and the other four (`p09_fixtures.txt`)
- [x] **P09-T06** — For each *shipped* upgrade, cross-check actual stat deltas and behavioral exceptions from source page instead of extrapolating description text. → each shipped tier from its teemo.dev upgrade page (v56) + M-11 v57; unverified tiers coming soon (`p09_upgrade_coverage.txt`)
- [x] **P09-T07** — Reconcile v57 changes: Rookie precision path projectile count/attack interval; Cannon fragments; Wax price/duration; Biathlon supply cash/ammo toggle. → applied where the tier ships: Crossbow pierce 5, frag pierce 2, Glue Splatter $650, Stickier 18 s; Rookie xx5, Cannon xx5 cap and Sniper x4x Supply Drop toggle DEFERRED (tiers not shipped)
- [x] **P09-T08** — Implement tier-3 identity transformations mechanically first: a distinct new attack/ability per branch where source verified, not simply +5% damage skins. → Spike-o-pult (Shatter, damage 2, pierce 18), Triple Shot (3 projectiles), Crossbow, Really Big Bombs, Cluster Bombs (exhaust explosions); `test_upgrades._test_behaviour`
- [x] **P09-T09** — Implement tier-4/tier-5 data capability and placeholders even if disabled in short release; do not advertise unavailable upgrades as purchasable. → all 90 tiers in data; tiers 4-5 and unverified tiers show "coming soon" and cannot be bought (tested)
- [x] **P09-T10** — Build in-game upgrade grid and labels with owned/affordable/unaffordable/path-locked/max-tier states; the validator, not the panel, is authoritative. → HUD button per path: owned n/5, price, unaffordable (disabled), locked (other paths), coming soon, max; `match.upgrade_state`, authority stays `can_upgrade` (`p09_editor_upgrade_panel.png`, `p09_web_upgraded.png`)
- [x] **P09-T11** — Test secondary paths that affect projectile child attacks or status applications; non-linear transforms must override, not double-apply multiplicatively. → FMJ reaches Shrapnel, Stickier/Glue Soak reach Splatter, Cluster overrides frag damage; rebuild twice = same stats, shared data untouched
- [x] **P09-T12** — Create scenario fixtures for all newly active tiers with expected DPS, per-shot/projectile count, pierce, attack tags, cooldown, visual state and total invested price. → stat fixtures per shipped tier + crosspaths (`p09_fixtures.txt`); DPS/visual state not part of the fixtures
- [x] **P09-T13** — Update upgrade coverage report showing: verified reference + implemented + tested + deferred counts out of 90 initial tier entries. → 35 / 90 shipped (Rookie 9, Cannon 9, Ranger 6, Booth 4, Wax 4, Sorcerer 3), 55 coming soon (`p09_upgrade_coverage.txt`)
- [x] **P09-T14** — Run full regression on wave, cash, hero scaffolding and pause/2× after first crosspath engine integration. → all 7 suites PASS after the engine (`test_data, map, match, combat, towers, upgrades, full_run`)

**P09 exit proof:** crosspath behavior tested independent of UI, upgrade path progression works for representative branches, and shipped tiers have sourced values. **Do not mark all 90 upgrades completed because names/prices exist in MD.**

### P10 — Camel Claus hero, Quincy source progression, ability controls
**Goal:** Make the game's mascot a genuine mechanically differentiated hero, not another ordinary tower.  
**Read:** HYB-M M-09/M-11/M-12; HYB-A A-03/A-06/A-08; HYB-B B-04/B-11.  
**Gate:** G5.

- [x] **P10-T01** — Implement hero placement as a singleton per match with source Medium price $540 (version labeled), separate from ordinary tower cap/upgrade menu. → `HeroDefinition` extends `TowerDefinition`; 7th shop entry $540 (v56); second hero refused ("Only one Camel Claus per match"); no upgrade buttons (`test_hero._test_placement`)
- [x] **P10-T02** — Configure baseline Quincy-compatible ricochet attack with range, attack interval, damage, pierce and distinct-hit behavior from `HYB-M M-09`. → base 1 dmg, pierce 3 = distinct targets, 0.95 s, range 50; ricochet = `bounce_range_units` (30 u PROTOTYPE_ASSUMPTION): one shot pops 3 parked snowballs (`_test_ricochet`)
- [x] **P10-T03** — Implement hero experience from appropriate round events (not damage-dealt by default) with a 20-level data table and source/patch flags. → XP at each round end, 20r+20 (community formula, PROTOTYPE_ASSUMPTION: not on teemo.dev); 20-level table VERIFIED (teemo.dev Quincy); levels 2/3/4/5 after rounds 3/7/12/18 (`p10_hero_levels.txt`)
- [x] **P10-T04** — Implement stable level-up application so each level's modifiers apply **once**, including multiple projectiles and interval shifts. → `tower._apply_levels` rebuilds from data each time; rebuild twice / level down = same stats, data untouched (`_test_levels`)
- [x] **P10-T05** — Implement level-3 Snowball Frenzy active ability with verified duration/speed multiplier/cooldown and button states. → Q / button: 3× attack speed (VERIFIED), 8 s (historic guide, PROTOTYPE_ASSUMPTION), cooldown 60 s from activation; locked/ready/active/recharging states (`_test_frenzy`, `p10_editor_hero_frenzy.png`)
- [x] **P10-T06** — Implement level-4 **Focused Shot** toggle (v57): slower interval, higher projectile speed/range and precision, with accurate enable/disable and HUD feedback. → E / button from level 4: interval ×1.25, projectile speed ×1.25, range ×1.2, toggles back exactly (`_test_focus`); "initial-shot precision" = the existing lead aim, nothing extra
- [ ] **P10-T07** — Implement level-5 camo/whiteout detection with correct interactions against otherwise immune targets. → **PARTIAL** — level 5 sets camo detection (fixture tested); no camo snowballs exist yet (DEC-019)
- [ ] **P10-T08** — Implement level-6 double shot, level-7 periodic explosive shot, level-10 Blizzard Barrage and later tiers as source-verified data allows. → **PARTIAL** — level 6 two shots, 9/12/19 pierce, 11/16/18/20 interval, 15 Frenzy ×4/45 s apply and are tested; level 7/17 explosions, 8/14 large bonus and 10 Blizzard Barrage are data only (unreachable: max level 5 in 19 rounds)
- [x] **P10-T09** — Implement ability cooldowns and cast state across pause, 2×, restart and win/loss; abilities may not continue affecting a new match. → timers run on sim ticks during rounds only (BTD6: none between rounds): pause freezes, 2× doubles, ticks stop on WON/LOST, restart = fresh scene (`_test_frenzy`)
- [x] **P10-T10** — Implement hero-specific selection panel: level, XP progress, next milestone, ability unlocks, Focus toggle, cooldown and source-derived descriptions. → bottom-left hero panel: level, XP bar + numbers, next milestone, Frenzy (locked/ready/active s/recharging s), Focus on/off; hero card without upgrade paths (`p10_editor_hero_panel.png`, `p10_editor_hero_selected.png`)
- [x] **P10-T11** — Verify that one cannot place a second hero, cannot purchase regular tower upgrade tiers on a hero, and cannot force unavailable ability by hotkey. → second hero refused, `buy_upgrade` false on all paths, Q/E refused below level 3/4 (`_test_placement`, `_test_focus`)
- [x] **P10-T12** — Create hero-specific automated tests for levels 1, 3, 4, 5, 6, 7, 10, 19 and 20, even if later levels aren't reachable during the short jam demo. → fixtures for levels 1, 3, 4, 5, 6, 7, 10, 19, 20 (`_test_levels`)
- [x] **P10-T13** — Expose developer test cheats for jumping hero levels **only in debug builds** to validate unreachable milestone behavior; disable for release. → `match.set_hero_level` (tests) + F4 in debug builds only
- [x] **P10-T14** — Audit user's intended visual identity: hero must be camel anatomy/gear, but temporary scene proxy can be a labeled capsule/arrow, not a Quincy character model. → placeholder = grey labelled cylinder "Claus" (tower greybox); no Quincy likeness. Camel anatomy/gear decided by the owner in P15–P16

**P10 exit proof:** Camel Claus placed once, earns XP, fires, uses at least available active abilities, and correctly enters/exits Focus. Remaining unreachable 20-level advanced behavior is recorded, not claimed complete.

### P11 — Special snowballs, complex tower branches and synergy interactions
**Goal:** Ensure the game is not just a colored DPS race; mechanical vulnerabilities and strategic responses work.  
**Read:** HYB-M M-03/M-05/M-07/M-10/M-11/M-12; HYB-A A-05/A-08; HYB-B B-07.  
**Gate:** G5 / extended G6.

- [x] **P11-T01** — Choose specific special snowball types actually appearing in the release's waves; do not implement the entire late-game enemy catalog prematurely. → BTD6 rounds 17–25 need Black, White, Purple and Camo Green only (DEC-025); `REGISTRY.md` ACTIVE rows; Rainbow/Ceramic/Lead/Zebra stay deferred, Regrow dropped (DEC-031)
- [x] **P11-T02** — Implement property-specific damage restrictions (explosion-resistant, cold/white-resistant, magic-resistant, lead-like armored, camo, regrow, fortified) as appropriate to referenced counterparts. → `camo` (detection required; kept by camo children), `immune_explosion` (Black), `immune_cold` (White), `immune_energy/fire/plasma` (Purple) through the single damage path; regrow DEC-031 not used, lead/fortified deferred (`test_combat` `_test_specials`)
- [x] **P11-T03** — Implement multi-descendant splitting including shell overkill handling and appropriate propagation of status/flags; verify per source type. → 2-child splits: first child keeps the node with a fresh id, siblings trail 0.15 m; overflow damage into every child, stopping at an immune child; lineage hit history (no re-hit by the popping shot); wax copied (`test_combat`, PROTOTYPE_ASSUMPTION logged)
- [ ] **P11-T04** — Implement wax interactions: slowing, priority/overwrite, corrosive damage, application scope and expiry without duplicating cash.
- [ ] **P11-T05** — Implement special attacks and their necessary subsystems when their corresponding tower branch is playable: Wizard fire wall, summon logic; Bomb special stun/fragment; Sniper ammo supply; Farm bank/automation.
- [ ] **P11-T06** — Implement consistent large enemy classes and typed damage bonuses only as selected waves require; create placeholder distinct sizes/shapes for danger visibility.
- [ ] **P11-T07** — Implement ability/supply switches and notification UI for source v57 changed behavior where these tiers are active.
- [ ] **P11-T08** — Test property combinations: camo+armor, explosive immune+split, wax+regen, fast target+global aim, giant mass+stun/slow immunity.
- [ ] **P11-T09** — Test interactions among towers, including knockback/slow vs projectile travel time and re-aiming; do not assume source synergies if an included tower was excluded.
- [ ] **P11-T10** — Add effective damage and cash efficiency report against actual upcoming wave compositions; tune only labeled original deviations.
- [ ] **P11-T11** — Keep Gold enemy in its approved semantic category and document how it rewards cash and transitions on break.
- [ ] **P11-T12** — Stress test late-tier subattacks and chained child creation; cap visual effects, not combat events.

**P11 exit proof:** first selected special-property wave requires an informed player response. Combat behavior is correct even with all visuals/audio disabled.

### P12 — Round-script progression, economy curves and balancing validation
**Goal:** Convert mechanical ingredients into a satisfying difficulty curve without pretending missing BTD6 data is complete.  
**Read:** HYB-M M-03/M-04/M-07/M-09/M-12/M-13; source `REF-M` round and economy index; HYB-A A-02.  
**Gate:** G6.

- [x] **P12-T01** — Choose D-03 final match structure: faithful sourced rounds with exact group data, OR a clearly labeled custom short-round jam progression. → DEC-025/026: exact BTD6 rounds 1–25, win = survive round 25
- [x] **P12-T02** — For reference-style rounds, transcribe/verify every selected group enemy ID, count, spawn interval/start/end and tier; cross-check total RBE/cash. → rounds 17–25 transcribed from teemo.dev v56 round pages (`tests/tools/build_rounds_17_25.gd`); all 25 round RBEs asserted against the pages (`test_data`); DEC-031 regrow rounds 17/19/25 labelled ORIGINAL_DEVIATION
- [ ] **P12-T03** — For jam-custom rounds, define deliberate introductions: basic layer → fast layer → crowd density → branching/resistance → advanced defense test → meaningful finale.
- [ ] **P12-T04** — Build one balance workbook/log from simulation traces: opening cash, per-round reward/pop cash, expected player cash, purchase milestones, lifetime farm/ticket revenue and leaked lives.
- [ ] **P12-T05** — Test canonical builds: starter-only, Rookie+Cannon, Rookie+Wax, Biathlon plus cheap crowd clear, Wizard handling immunity and Booth early investment.
- [ ] **P12-T06** — Test losing scenarios intentionally; player must be able to fail from bad strategy, not from RNG or opaque immunity rules.
- [ ] **P12-T07** — Test winning scenarios without developer cheats and document minimum viable strategy, not one rigid forced solution.
- [ ] **P12-T08** — Check the number of encounters required to make a chosen upgrade affordable; a T5 with source price > entire demo's cash cannot be claimed as accessible.
- [x] **P12-T09** — Check hero XP milestone pacing: if Lv10 cannot be reached in the jam game under Quincy XP rate, do **not** silently accelerate it without labeling the deviation. → Quincy XP unchanged (20r+20, 40r−380 after 20): level 6 only as round 25 is won; 7+ unreachable, data only (`p10_hero_levels.txt`)
- [ ] **P12-T10** — Evaluate geometry sensitivity: move tower placement to bend/straight, compare engagement time and balance; if original map heavily changes roles, log it.
- [ ] **P12-T11** — Resolve D-02 Gold special class within tutorial and actual wave table; do not mix Gold HP semantics in different rounds.
- [ ] **P12-T12** — Provide difficulty and round report with expected enemy totals, properties, initial/total money, normalized speed and win/loss checkpoints.
- [x] **P12-T13** — Run full deterministic replay / fixed-seed logs where random mechanics exist; compare key numbers across two runs and 1×/2× modes. → full matches at 1×/2×/4× give identical event digest, ledger, lives and end tick (bots act on sim ticks; `p12_full_run_25.txt`)
- [ ] **P12-T14** — Freeze `balance_release_candidate.json` or equivalent source data snapshot for art phase; any later changes require an explicit balance ticket and regression run.

**P12 exit proof:** playable content has documented round-by-round intention, tested affordability, hero milestone coverage and at least two distinct winning strategies. Reproducible balance log exists.

### P13 — Placeholder UX usability, tutorial and input correctness
**Goal:** Make the **technical** game usable by someone who has never seen the code or BTD6.  
**Read:** HYB-A A-05/A-06/A-07/A-11/A-12; HYB-M M-02/M-03/M-07/M-09.  
**Gate:** G6.

- [x] **P13-T01** — Implement startup/title, Play, How to Play, Pause, Retry, Results and Settings with clear text-based placeholder controls. → `scenes/ui/title_screen.tscn` (main scene): Play, one-screen How to Play, Settings; in-match Pause, Restart, Main menu and the win/lose result overlay (`p13_title.png`, `p13_how_to_play.png`, `test_ui`)
- [x] **P13-T02** — Make six tower purchase panels with source-based cost, unaffordable state, tooltip and placement workflow; no excluded icons. → seven shop buttons (6 towers + hero) with data cost, "need $X" when unaffordable, tooltip with cost/role/stats, ghost placement with reasons (`p13_shop_reasons.png`)
- [x] **P13-T03** — Make selected tower panel show true legal three-path upgrades, targeting modes, sellback and reason when a button is disabled. → upgrade buttons: price, "need $X", "locked: only two paths per defender" / "locked: only one path past tier 2", coming soon, max; effect tooltip; Target + Sell; Start button says "Round in progress" / "Paused" / "Match over" (`test_ui`)
- [x] **P13-T04** — Implement hero panel with level progress, skills, Focus stance and unambiguous ready/active/cooldown states. → hero panel: level, XP bar, next milestone, Frenzy locked/ready/active/recharging, Focus on/off (P10-T10)
- [x] **P13-T05** — Implement readable layer-color legend with icon/shape explanation for each special-property class used in demo; include Gold warning if relevant. → How to Play: layer chain + B/W/P/C letter legend with immunities, camo detection sources, 11-life leaks (`test_ui`, `p14_web_how_to_play.png`)
- [x] **P13-T06** — Implement clear visual/sound placeholders for damage success vs immunity, wave arrival/finish, income, leak and hero ability; placeholders may be diagnostic text and flashes. → `scenes/ui/feedback_layer.gd`: `*` per hit, IMMUNE, −N lives + red stats flash, +$N income, Frenzy/Focus and round start/complete banners; capped visuals (`test_ui`, `p14_web_round6_banner.png`). No sound yet (owner)
- [ ] **P13-T07** — Handle hover, press, selection, escape, cancel, click elsewhere, keyboard shortcuts and fullscreen without losing pointer synchronization.
- [ ] **P13-T08** — Verify HUD never obscures critical enemy exit; check 16:9 normal desktop and a narrower browser window.
- [ ] **P13-T09** — Implement accessible contrast independent of color: valid/invalid symbol, status pattern, selection ring, text description, readable font scaling.
- [x] **P13-T10** — Implement settings toggles (at minimum music/sfx and pause; FX detail/reduced motion if feasible) so future art and sound have controls ready. → Music and SFX buses (`default_bus_layout.tres`), volume sliders on the title Settings screen, saved in `user://settings.cfg`, 0 = mute (`test_ui`); pause exists; no reduced-motion toggle (no VFX yet). No music or sounds yet
- [ ] **P13-T11** — Do a guided fresh-player test: show the game, ask player to place/upgrade/start/finish; record each confusion as a fix ticket.
- [ ] **P13-T12** — Clean up programmer/debug text before public Web export while keeping dev overlays accessible behind development-only flag.

**P13 exit proof:** a first-time player completes a match without verbal instructions from developer; selected unit and ability UI reflect true state. Visual polish is not yet required.

### P14 — Freeze mechanical alpha and create stable art-swap points
**Goal:** Establish a stable technical baseline *before full-scale visual work*.  
**Read:** all three hybrids; HYB-B B-16; master §§4/6/9.  
**Gate:** G6.

- [x] **P14-T01** — Run full unit/integration/scenario suite with release content; save `alpha_baseline` results and benchmark device/profile. → `p14_alpha_baseline.txt`: 9/9 suites PASS at `e75493f`, Windows 11 / Godot 4.7.2 headless
- [ ] **P14-T02** — Perform browser export, load and complete whole game at least twice; test restart without reload.
- [x] **P14-T03** — Record bug list with blocker/high/medium/low; fix blockers and game-state correctness bugs first. → `docs/BUGS.md` (BUG-001 high fixed; no blockers)
- [x] **P14-T04** — Freeze stable IDs for tower, upgrades, enemy families, hero skills, event names, asset sockets and model placeholder resource paths. → `docs/STABLE_IDS.md` (generated from data)
- [ ] **P14-T05** — Implement `PresentationProfile` / art-binding layer mapping `gameplay_id`→model, animation, portrait, VFX, audio without reading source names in UI. → PARTIAL (P15-A02, 2026-11-14): `scripts/data/presentation_profile.gd` + `resources/presentation/{snowball_rookie,avalanche_cannon}.tres` map id → model, display scale, optional AnimationPlayer, vertex-colour flag, recoil and muzzle puff (`tower.gd` `PROFILES`); Dev 9 adds weapon yaw, tilt and puff colour and the Ranger/Wax profiles; portrait, VFX-family and audio mapping not in the profile yet
- [x] **P14-T06** — Ensure Godot render/animation nodes can be swapped while data-driven combat logic and placements remain identical. → Cannon greybox → GLB swap and Rookie binding through the profile: 10/10 suites PASS and the STATE transcripts (tick/round/lives/cash) of full_run, combat, upgrades, match, hero, ui are byte-identical to the pre-change run (`p15a_tests.txt`); footprint 0.6 m, aim/recoil on a separate visual pivot (`test_towers` `_test_cannon_visual`)
- [ ] **P14-T07** — Save an asset-independent test scene for each type: enemy layer break, bomb explosion, wax slow, global sniper, Wizard magical impact, farm income, hero ability.
- [ ] **P14-T08** — Produce screenshots/video of current greybox at game camera so art decisions can be compared to same composition.
- [x] **P14-T09** — Create release branch/checkpoint named meaningfully (e.g., `technical-alpha`) and store commit hash. → git tag `technical-alpha` (25 exact rounds, specials, 1×/2×/4×; ZIP `claus_for_alarm_alpha_web_619af86.zip`)
- [ ] **P14-T10** — Review whether remaining unverified mechanics are intentionally deferred or should stop release; do not declare exact parity if marked prototype.
- [ ] **P14-T11** — Approve **G6** only when the simulation and full UI loop work without polished assets.

**P14 exit proof:** technically playable Web alpha, regressions passing and stable `presentation_id`/GLB/art swap contracts. This is the transition into the main art phase.

### P15 — Art bible, premium modeling pipeline and single-asset vertical slice
**Current handoff override:** see section 12.1.1 for the selected Tripo/AccuRIG sources and proposed P15-A01–A04 Cannon integration proof. Earlier checked tasks describe the old hand-built asset pipeline; they do not certify the newly selected FBXs or their runtime integration. P15-T09/G7 remain open.

- [x] **P15-A01** — Non-destructive Tripo/AccuRIG preparation: original FBX (read only) → `art_src/tools/prepare_source_model.py` profile → derived `art_src/prepared/<id>.blend` + `assets/models/<id>.glb`. → all nine sources inspected (`p15a_source_inspect.txt`; scale, ground, centre, envelope, tris, open edges, maps, rig/actions), per-model record in `art_src/models/README.md`; only the Cannon prepared (owner scope)
- [x] **P15-A02** — Cannon prepared + static-model-safe binding. → stray 1-face island (the "3 non-manifold edges") deleted, turned 180° to face +Y, ground-contact centre at origin, envelope 0.44 m modelled = 0.66 m displayed (footprint 0.6 m unchanged; 1.5× applied once in the profile), 0.93 m tall displayed, `muzzle_A` in the bore (0.61 m), `effect_center`; 1024² PNG maps, opaque, single-sided (`p15a_prepare_cannon.log`); `PresentationProfile` + visual pivot in `tower.gd` (optional AnimationPlayer, no vertex-colour override on textured models)
- [x] **P15-A03** — Cannon visual integrated: aim on the visual pivot, recoil 0.12 m + 8% squash, kick 0.05 s / recover 0.30 s in simulation time, warm-gold muzzle puff 0.5 m; rapid fire re-enters at the current amount (no snap, no drift); `muzzle_position()` and the `match.gd` shot offset unchanged. Old Rookie runtime model kept as baseline
- [x] **P15-A04** — Verified for owner review (NOT a P15-T09/G7 sign-off): 10/10 suites + identical gameplay transcripts; editor process run 0 errors/warnings; Web export exit 0, Chrome 0 console errors, 240 fps; ghost/select/upgrade/sell, pause, 1x/2x/4x (reaction 350/174/87 ms real); 120-snowball stress; captures + 320×180 thumbnail (`p15a_*`, section 12.1.1 progress)
- [x] **P15-A05** — Cannon proof checks closed: Blender clay/silhouette/close-up views, B-14 self-score 7×2/3×1, reproducible browser stress (8 Cannons + 4 Rookies, 120 snowballs, Chrome p95 5.6 ms display-paced, 978 draws, 0 errors) with method and limitations (`p15c_avalanche_cannon_*`, `p15c_b14_scorecard.md`, `p15c_stress_web.txt`); DEC-040 owner choices recorded, size provisional
- [x] **P15-A06** — Biathlon Ranger prepared + integrated: yaw 180°, height 1.2 m (1.8 m shown), barrel marker, `weapon_yaw_deg` 60 (barrel aims), 4 cm recoil + 4° climb, 0.25 m gold flash; instant-hit timing unchanged (`p15c_prepare_biathlon_ranger.log`, `p15c_biathlon_ranger_*`)
- [x] **P15-A07** — Slope Wax Sprayer prepared + integrated: yaw 180°, height 1.2 m, nozzle marker (shots start there), pump/tilt reaction, spruce nozzle puff; status data untouched (`p15c_prepare_slope_wax_sprayer.log`, `p15c_slope_wax_sprayer_*`)
- [x] **P15-A08** — Combined verification for owner review (NOT a P15-T09/G7 sign-off): 10/10 suites + identical transcripts, roster review (ghost/select/upgrade/sell, clearance, muzzle alignment, pause, 1×/2×/4×, rapid-fire rest), editor run, Web export + Chrome, captures + 320×180 thumbnail (`p15c_*`); Ranger rifle reach reported (DEC-041)
- [x] **P15-A09** — Snow Sorcerer prepared + integrated (visual): yaw 180°, boots-centred and grounded, 1.0 m (1.5 m shown), staff-head marker, cast pulse/lean + icy puff; attack timing/projectiles/damage types unchanged (`p15d_prepare_snow_sorcerer.log`, `p15d_snow_sorcerer_*`)
- [x] **P15-A10** — Ticket Booth prepared + integrated (visual): 1.5 m envelope = footprint, 2.42 m tall, stationary, income bounce + window puff; tickets drawn over the building; income behaviour unchanged (`p15d_prepare_ski_resort_ticket_booth.log`, `p15d_ski_resort_ticket_booth_*`, `p15d_booth_tickets*`); batch A gameplay-identical (`p15d_tests_visual.txt`)
- [x] **P15-A11** — Booth base price $750 (DEC-042, ORIGINAL_DEVIATION); upgrades/income/footprint/lifetime unchanged; sellback from spent (`_test_booth_price`)
- [x] **P15-A12** — Cursor-proximity ticket collection (DEC-043): 1.0 m world XZ, explicit tick-ordered input, once-only via `collect()`, not paused/over UI/outside viewport/after the end; tests, help text, editor + browser checks; economy differences explained (`p15d_tests_gameplay.txt`, `p15d_web_hover.txt`) — NOT a P15-T09/G7 sign-off
- [x] **P15-A13** — Camel Claus prepared (visual): yaw 180°, 1.68 m modelled = 2.52 m shown (ART_STYLE 1.4 × elf; 1.5 m alternative compared: out-scales the elves only by the hat), envelope 0.885 m shown, markers `muzzle_A` (launcher, 0.82 m), `effect_center`, `focus_goggle`, `hat_top` (`p15e_prepare_camel_claus.log`, `p15e_camel_claus_*`)
- [x] **P15-A14** — Camel Claus bound (visual only): launcher aim (0.0° error), cooldown wind-up, recoil + gold puff, Frenzy elastic recoil + red pulse ring, Focus lean + cyan reticle + goggle glow, level-up hat glint + gold XP ring, from existing state in sim time; all reachable shots (and the debug level-6 volley) start at the launcher, sim origin unchanged (`test_hero._test_visual`); transcripts identical (`p15e_tests_visual.txt`)
- [x] **P15-A15** — Snow Sorcerer 1.13 m modelled = 1.70 m shown (DEC-044 approved): uniform rescale, grounded, staff marker 1.508 m, footprint/attack unchanged; 0.094 m past the track edge at the nearest spot (`p15e_review.txt`)
- [x] **P15-A16** — Web costs (bounded): real S3TC/RGTC artifacts for all 18 Tripo maps (98.5 -> 42.5 MB video memory, frame time unchanged, visually identical); first-use stalls reproduced (3 fresh loads + reload), shown not to need audio, warm-up probe costs 2–3x the stalls -> not shipped (`p15e_texture_memory.txt`, `p15e_stutter_web.txt`) — NOT a P19 sign-off

**Goal:** Test how the final art will look/perform in the *real* game before modeling the whole roster.  
**Read:** HYB-A A-01–A-05/A-08–A-12; HYB-B B-01–B-04/B-07–B-15.  
**Gate:** G7.

- [x] **P15-T01** — Lock a compact visual style sheet: silhouette rules, facial proportions, character scale hierarchy, winter palette, material families, lighting and readability thresholds. → `docs/ART_STYLE.md` (PROPOSED; owner directs; skin/dark-timber/stone/special colours are proposals)
- [ ] **P15-T02** — Build original concept sheets/front/side/three-quarter designs for Camel Claus, a generic athlete, a base snowball and a chalet prop.
- [x] **P15-T03** — Create **one** excellent athlete base `.blend`: continuous sculpted anatomy, planned joints, face, hands/boots and cloth contact; not a set of visible primitive intersections. → `art_src/characters/elf_rookie.blend` (continuous metaball sculpt per garment, face/ears/gripping mittens/curled boots); revised per DEC-036, B-14 10×2 (`p15_b14_scorecard.md`); **rebuilt per DEC-039 review 1** (owner sheets: hair, beanie, painted-iris eyeballs + sculpted lids/lashes/brows/nose/mouth, belt, bare hands) — B-14 9×2/1×1, the 1 = rig debt for review 2 (`p15_b14_scorecard.md`, `p15b_*`)
- [x] **P15-T04** — Create a deliberately small test set: one game-ready retopologized athlete, one rolling snowball mesh with color material variants, one environment prop. → Rookie 17.2k tris / 3 materials (vertex-colour atlas + one 256² eye texture, DEC-039), snowball shell 1.4k + marker band 1.5k (Black/White/Aurora/Camo), Lodge 15.6k
- [x] **P15-T05** — Build `.blend`→`.glb` export conventions, naming, root axis, unit scale, sockets (`root_ground`, `aim_pivot`, `muzzle_A/B`, `shadow_anchor`) and animation playback tests. → `cc_art.export_glb` (Y-up, applied, ACTIONS); elf sockets root_ground/shadow_anchor/aim_pivot/effect_center/portrait_focus/weapon_hand_l/r/muzzle_A import as BoneAttachment3D children; `idle_loop` (imports as looping `idle`) + `attack` play in Godot and Web
- [x] **P15-T06** — Render clay orthographic, silhouette, 3/4 closeup and game-camera screenshots for the three test assets; correct all geometry defects at source. → `docs/logs/evidence/p15_*_{clay_turnaround,silhouette,closeup}.png`, `p15_godot_gamecam*.png`, `p15_web_gamecam.png`; 11 defects fixed at source (scorecard)
- [x] **P15-T07** — Import the GLBs into Godot Compatibility mode; check normals/materials, shadow contact, scale, look direction, animation import and shooting muzzle alignment. → Compatibility import, normals, vertex-colour materials, shadows, 1.5× scale, facing, idle/attack all checked; shots start at `muzzle_A` and blend onto the sim line (`match.gd` presentation offset), 0 errors
- [x] **P15-T08** — Open Web build and inspect the same assets in-browser; compare Blender versus Godot output and track texture/memory/frametime impact. → Web 0 ERROR/WARNING, Chrome 1280×720 by mouse/keyboard, 0 console errors, 240 fps / worst 4.6 ms; stress 12 Rookies + ~120 snowballs p95 4.3 ms, ~1,060 draws, 21 MB VRAM (desktop)
- [ ] **P15-T09** — *(self-scored: Rookie 9×2/1×1 after the DEC-039 rebuild (rig debt → review 2), snowball 8×2, Lodge 10×2 — all pass; owner review 1 of the rebuilt Rookie pending)* Accept only models meeting HYB-B B-14 rubric; no zero scores, sufficient 2s, and correct game-camera readability.
- [x] **P15-T10** — Document re-usable material palette, skeleton rig, Blender operation scripts and one reliable automatic export/test loop. → palette tokens `ART_STYLE.md`, rig + reuse check `rig_elf.py`/`check_rig_reuse.py` (`p15r_rig_reuse.md`: reusable for all five elves, arm poses re-baked per build), build/QA/export loop `docs/COMMANDS.md`
- [x] **P15-T11** — Make **no** gameplay stat or round-data edits during this art-pipeline milestone; any discovered footprint mismatch triggers owner approval. → no `resources/` edits; Lodge blocker box kept (hidden) as gameplay data; 10/10 suites PASS (`p15_tests.txt`)

**P15 exit proof:** a premium reusable character, layered snowball, prop and successful Godot Web import with evaluation renders; asset standard proven before mass production.

### P16 — Complete 3D asset production: hero, six towers, snowballs, map
**Current scope override:** section 12.1.1 records supplied source models, deferred additional rigging and upgrade-form variants, and the preparation-first handoff. Source-model availability is partial progress, not completion of the unchecked integration/QA tasks below. The former Dev 8 map/snowball slice remains queued after the Cannon proof.

**Goal:** Replace placeholders with coherent original stylized models at practical in-game resolution.  
**Read:** HYB-B B-01/B-03–B-14; HYB-A A-02–A-05; HYB-M M-03/M-07/M-09.  
**Gate:** G8.

**Production order:** enemy shells & map path → shared athlete base → Camel Claus hero → Snowball Rookie gear → Avalanche Cannon → Biathlon Ranger → Slope Wax Sprayer → Snow Sorcerer → Ticket Booth → environment kit → upgrade visual states. Finish and accept one asset group before commissioning many variants.

- [ ] **P16-T01** — Model original high-res sculpt/master and optimized GLB for **Camel Claus**, preserving camel head/neck/torso cohesion, scarf/goggles/sports launcher contact and meaningful silhouette. → PARTIAL (P15-A13/A14): base form from the owner's Tripo source (scarf, goggles, sack, candy-striped crossbow launcher, not the DEC-033 ski pole), unrigged with procedural cues; owner approved the larger 2.52 m displayed size (DEC-045); remaining quality review open
- [ ] **P16-T02** — Rig Camel Claus face/neck/weapon, create attack, aim, idle, Frenzy, Focus visor and Blizzard Barrage animation anchors; import and QA.
- [ ] **P16-T03** — Create **Snowball Rookie** athlete costume, throw equipment, pellet bag and tier-3 primary-path silhouettes from a shared athlete rig. Owner DEC-046 (2026-11-15): replacement/animation work DEFERRED beyond submission; retain the functional existing runtime Rookie.
- [ ] **P16-T04** — Create **Avalanche Cannon** sled-mounted machine with believable chassis, cannon muzzle, pivot, recoil assembly and identifiable heavy/fragment/missile path variants. → PARTIAL (P15-A02/A03): base form only, from the owner's Tripo source (sled-mounted cannon, bore marker, whole-model recoil on a visual pivot); separate barrel/recoil assembly and path variants deferred (upgrade forms deferred by owner)
- [ ] **P16-T05** — Create **Biathlon Ranger** sports launcher, gear, scope, goggles and recoil alignment; separate top/middle/bottom high-tier equipment silhouettes. → PARTIAL (P15-A06): base form from the owner's Tripo source (rifle, scope, bipod, goggles), recoil along the barrel with the barrel aimed (`weapon_yaw_deg`); tier silhouettes deferred (upgrade forms deferred by owner); owner size review open (rifle reach, DEC-041)
- [ ] **P16-T06** — Create **Slope Wax Sprayer** fitted technician costume, actual hose/tank/nozzle assembly, persistent wax indicator and three branch silhouettes. → PARTIAL (P15-A07): base form from the owner's Tripo source (harness, hose, tank pack, nozzle), nozzle marker + pump reaction; wax indicator (snowball effects) and branch silhouettes not in this batch
- [ ] **P16-T07** — Create **Snow Sorcerer** original winter-festival magical athlete with unique robe/staff/elemental/summon identity; distinguish from visual clone of BTD6 Wizard. → PARTIAL (P15-A09): base form from the owner's Tripo source (robe, cape, snowflake staff), staff-head cast effect; elemental/summon forms deferred (upgrade forms deferred by owner); owner size review open (DEC-044); Dev 11: 1.70 m shown (DEC-044 approved)
- [ ] **P16-T08** — Create **Ski Resort Ticket Booth** income building with cashier window, legible output pickup, bank and vending variants; functional gameplay node remains identical. → PARTIAL (P15-A10): base building from the owner's Tripo source (cashier counter, lamps, snow roof), income reaction at the window, tickets visible around it; bank/vending variants deferred
- [ ] **P16-T09** — Create 5 basic rolling snowball shell materials/variants, mechanical property overlays and distinct child size; test shell-to-child timing and clear Powder/terrain contrast. **Status after Dev 12:** PARTIAL: existing five basic shells, special markers and roll retained; Dev 12 pooled layer-break feedback added. Owner reports washed-out terrain; Powder contrast and final surface finish remain in Dev 13.
- [ ] **P16-T10** — Create source-referenced *special* snowball classes actually used in released rounds: armor plates, stealth motif, regeneration, heavy shell and large threat body where needed. **Status after Dev 12:** PARTIAL: active Black/White/Aurora/camo visuals exist; inactive armor/regrow/heavy classes remain deferred, not extra submission work.
- [ ] **P16-T11** — Produce map kit: ski trail, berms, start/finish gates, evergreen sets, snowdrifts, fencing, skis/pucks/curling kit, chalet, warming hut, lights, background slopes and distant low-detail decorations. **Status after Dev 12:** PARTIAL: Dev 12 delivered trail berms, gates, flags, pine margins, fence, skis, rink/curling props and existing lodge. Owner requests organic terrain/material finish; remaining optional microdetail is lower priority.
- [ ] **P16-T12** — Construct the final snowy environment **on top of locked route and placement coordinates**, not by moving the actual game path to fit concept art. **Status after Dev 12:** PARTIAL: Dev 12 dressing is built from locked route/bounds/blockers and passes test_map. Final visual acceptance reopened by owner; preserve the same gameplay geometry.
- [ ] **P16-T13** — Build modular tier 1/2 accessories, 3 defining tier-3 visual identities and selective t4/t5 signatures **only for tiers currently implemented**.
- [ ] **P16-T14** — For each commissioned asset, preserve `.blend` source, optimized `.glb`, manifest with `gameplay_id`, 4+ QA renders, material/rig/LOD notes and provenance. → PARTIAL: Cannon has source FBX + derived `.blend` + `.glb`, profile with `gameplay_id`, provenance/material notes (`art_src/models/README.md`), Godot captures; Blender clay/silhouette/close-up QA renders now made for Cannon, Ranger and Wax (`p15c_<id>_*`, Dev 9); Ranger and Wax have the same source/derived/profile/provenance set
- [ ] **P16-T15** — Run 360° clay/silhouette/game-camera tests; reject visible default sphere/cylinder collage, floating clothing or unsupported mechanical joins. → PARTIAL (Dev 9): four-side + 3/4 clay, silhouettes and game-camera captures for Cannon, Ranger, Wax; no primitive collage or floating parts found (`p15c_b14_scorecard.md`); other assets pending
- [ ] **P16-T16** — Batch/instance vegetation and repeated shells; verify clustered tower copies and high enemy density in browser before adding microdetail. **Status after Dev 12:** PARTIAL: pines/posts/flags use MultiMesh; stress 432k primitives, p95 6.8 ms on one high-end GPU (dev12_stress_web.txt). Final shell batching/device acceptance not claimed.
- [x] **P16-T17** - Bind the retained submission roster through presentation profiles without changing stats, footprints or shot timing. All seven current profiles/models integrated (P15-A03/A06/A07/A09/A10/A14 and existing Rookie); regression evidence p15a/p15c/p15d/p15e and dev12_tests.txt. Selected Rookie replacement deferred by DEC-046.
- [ ] **P16-T18** — Document any deferred tier models and which cosmetics temporarily share a visual state; never call a tier fully visually implemented when it isn't.

**P16 exit proof:** in-game models for every active roster entry plus map/enemies, integrated and art-reviewed at play camera, without mechanical regressions. **The end of P16 is not enough by itself**: animation and UI/audio polish follow.

### P17 — Character animation, readable combat VFX and complete UI visual pass
**Goal:** Make gameplay feedback expressive while respecting deterministic events and the late-wave visual priority.  
**Read:** HYB-A A-03–A-09/A-11/A-12; HYB-B B-11/B-14; HYB-M M-02.  
**Gate:** G8.

- [ ] **P17-T01** — Connect each `PresentationEvent` to correct animation, VFX and UI reaction; no new simulation effects inside render-event callbacks.
- [ ] **P17-T02** — Animate snowball tumble with speed/radius relation, hit reaction, outer shell change, tiny fragment burst, large shell shatter and leak feedback. **Status after Dev 12:** PARTIAL: existing roll/shell changes plus Dev 12 pooled 32-slot colored break puff/ring, driven by sim time. Full visual acceptance remains open.
- [ ] **P17-T03** — Animate athlete idle, target turn, anticipation, attack, followthrough and modest celebration using shared rig without model deformation defects.
- [ ] **P17-T04** — Animate machines: cannon recoil, wax nozzle pump, ticket slot/collection, mechanical dials, and any active upgrade devices.
- [ ] **P17-T05** — Animate Camel Claus: throw/ricochet, level-up, stance/visor, ability cast and ready/cooldown state; check sockets through all poses.
- [ ] **P17-T06** — Produce VFX for ordinary hit, armor immune, wax slow/coating, magic impact, cannon blast, explosive layers, income pickup, hero ability and critical warnings.
- [ ] **P17-T07** — Add restrained winter ambient motion: gentle snowfall, flag sway, pines, distant skier or lift if performance allows; ambience must not resemble enemies. **Status after Dev 13:** PARTIAL: gentle snowfall (700 shader-animated flakes, one MultiMesh) + a spiral gust ribbon every 6-13 s (DEC-051), `scripts/presentation/ambient_snow.gd`, `tests/test_ambient_snow.gd` PASS, Web 0 console errors (`p17t07_web_snowfall.png`). Flag sway, pines, distant skier/lift not done.
- [ ] **P17-T08** — Create original GUI visual tokens, panels, tower cards, small portraits, upgrade icon rules and hierarchy according to A-06/A-07. **Status after Dev 12:** PARTIAL: Dev 12 winter skin/layout exists. Dedicated portrait sidebar and cohesive textured UI requested for Dev 13; not complete.
- [ ] **P17-T09** — Make button hover/pressed/disabled/owned/path-locked feedback visually distinct and input-accessible; never conceal whether an upgrade is legal.
- [ ] **P17-T10** — Implement selected hero profile with readable Focus toggle, skill ability radial cool-down and actual XP bar; confirm parity with simulation state.
- [ ] **P17-T11** — Build wave-intro, upgrade-achievement, life-loss and victory/defeat animation sequences with brief, non-obstructive timings. **Status after Dev 12:** PARTIAL: acknowledged Black/White/Camo/Aurora notices implemented/tested in Dev 12; complete themed notifications/result animation pass remains.
- [ ] **P17-T12** — Implement VFX detail and reduced motion options; cosmetic particle systems drop first at load, critical UI/events retained.
- [ ] **P17-T13** — Audit 320×180 thumbnail, grayscale/color-vision, low/high VFX, narrow window and 2× game speed.
- [ ] **P17-T14** — Run full technical regression on combat, economy and upgrade paths after replacing every placeholder; compare deterministic logs to alpha snapshot. **Status after Dev 12:** PARTIAL: Dev 12 12/12 suites pass and bot transcripts unchanged. Repeat after the authorized Dev 13 changes; final-placeholder replacement acceptance not claimed.

**P17 exit proof:** animation/effects and UI improve understanding rather than hiding the route, layer color, danger or controls; core simulation logs match technical alpha.

### P18 — Original soundtrack, sound effects, audio mix, settings
**Goal:** Make every important action sound responsive without fatigue; meet browser audio constraints.  
**Read:** HYB-A A-08–A-12 and BTD6 REF-A sound analysis for *design principles only*.  
**Gate:** G8.

- [x] **P18-T01** — Design original music palette: cozy winter festival menu, energetic but non-harsh gameplay loop, wave escalation stinger, victory and defeat sting. — DEC-037/038: licensed Willosuna Christmas Music Pack loops: menu `we_wish_you_menu` (138 BPM); gameplay `god_rest_ye_sleigh_chase` (168 BPM, all rounds — owner wanted BTD6-like drive); escalation = ambience crowd swells from the calm to the sample-aligned intense winter-market bed at round 16; `victory` / `game_over` jingles; seamless loops, −16 LUFS. Web: menu + ambience on first click, crossfade to the chase on Play (`p18_web_audio.txt`).
- [x] **P18-T02** — Compose/generate/license original tracks; record exact authorship/license/attribution and source files; no BTD6 samples, melodies or proprietary tracks. — Licensed, not composed (DEC-037): author, pack, page, license terms, source track per file in `assets/audio/CREDITS.md`; composer's OGGs shipped unchanged; carol melodies public domain.
- [x] **P18-T03** — Create original event SFX for snowball hit/layer crack, armor immune, Wax hit, Rookie throw, cannon, Biathlon shot, Sorcerer spell, ticket payout, hero abilities and UI. — DEC-037 replaced the code-synth set (owner: too retro) with 40 licensed Willosuna files from 6 packs of one author, processed by `scripts/audio/build_sfx.py` (trim, −20 dBFS RMS, −1 dBFS peak, OGG): 12 snow-crunch variants for layers, heavy crunch, ornament-clink immune, cannon launch + blast, sorcerer celesta / fireball, wax splash, elf-poof place, ticket jingle, Frenzy, Focus on/off, level-up, ability-ready, sleigh-bell round start, reward round complete, click/hover/deny. Ledger: `assets/audio/CREDITS.md`.
- [x] **P18-T04** — Map every named sound to a gameplay semantic event and only then to audio-player instance, respecting source unit visual identity. — Autoload `Audio` (`scripts/audio/audio_router.gd`) listens only to `Events.emitted` + Button pressed/hovered; attack sound by attack-id prefix, Cannon blast on hits whose source is a placed Cannon, wax on `status_applied`, crunch pitch by layer; `tests/test_audio.gd` PASS (24 event→slot mappings, Cannon source, layer pitch, gap merge, click, music files); Web sample starts per action in `docs/logs/evidence/p18_web_audio.txt`.
- [x] **P18-T05** — Implement distinct Master, Music, Combat SFX, UI and Ambience buses (or equivalent), adjustable in Settings and stored if persistence is implemented. — DEC-038: buses Master / Music / SFX (UI + feedback) / Towers (tower attacks + snowball hits, feeds SFX) / Ambience; Settings has Music, Sound effects, Tower sound effects (default 50% = 0 dB, 100% = +6 dB) and Ambience sliders, saved in `user://settings.cfg`; `test_ui` checks Towers 0.5 → 0 dB, 1.0 → +6 dB. UI shares the SFX bus (equivalent).
- [ ] **P18-T06** — Test sample concurrency during large waves; cap redundant pops and randomize safe pitch/volume without altering important warning signals. — *partial:* per-slot voice cap + min gap (crunch 30 ms), random variant (no immediate repeat), ±pitch and −0–1.5 dB level jitter; none on leak/immune/deny. Web combat shows rotating crunch variants. Not yet listened to in a late big wave.
- [ ] **P18-T07** — Implement ducking where needed for hero ability/win/lose; prevent harsh repeated high-pitched transients and extreme loudness. — *partial:* Music bus ducks −8 dB for 1.5 s on Snowball Frenzy; win/loss crossfade music to the victory/defeat jingle; all SFX levelled to one loudness with −1 dBFS peaks. Untested by ear.
- [ ] **P18-T08** — Implement browser-safe audio start after first user gesture, and stable pause/resume/mute behavior. — *partial:* Web build (Chrome, playwright): 0 sample starts before the first click; the first click (Play) already sounds; music held until the gesture. Mute = existing Settings sliders; pause/resume by ear not checked.
- [ ] **P18-T09** — Test audio in browser with speakers and earbuds at normal user volumes; ensure music not too oppressive or repetitively loud.
- [x] **P18-T10** — Confirm export includes only licensed/original audio assets and that credits contain any required third-party attribution. — Exported pack holds only `assets/audio/{sfx,music}` Willosuna files + the original P01 blip; every file listed in `CREDITS.md` with a submission credit line (attribution not required by the license, given anyway).
- [ ] **P18-T11** — Run sound-off mode playthrough: all critical mechanical information must remain legible visually.

**P18 exit proof:** music/SFX are pleasant and balanced, assets legally usable, autoplay works on real browser input, critical feedback survives mute.

### P19 — Release engineering, optimization, accessibility and final Web QA
**Goal:** Deliver a reliable Web game, not just a local Godot demo.  
**Read:** HYB-M M-12/M-13; HYB-A A-12; HYB-B B-14/B-15; official Godot Web docs.  
**Gate:** G9.

- [ ] **P19-T01** — Freeze release content and commit; only critical bug fixes or explicitly approved changes after freeze.
- [x] **P19-T02** — Export with correct Web template version, Compatibility/WebGL 2 renderer and host-compatible settings; verify single-thread default rather than relying on SharedArrayBuffer headers. **Status after Dev 12:** DONE for Dev 12 RC: correct Godot Web release export, single-threaded Compatibility build, 0 errors/warnings (dev12_web_export.log). Repeat for the revised final candidate.
- [ ] **P19-T03** — Run browser on target OS/Chromium and, where feasible, Firefox/Safari; test first load, cache refresh, fullscreen, input capture and audio unlock.
- [x] **P19-T04** — Test Web export served over HTTP(s) and investigate browser console/network errors, missing assets, security headers and script parse failures. **Status after Dev 12:** DONE locally for Dev 12 RC: extracted ZIP served over HTTP, Chrome 0 console errors and successful asset loading (dev12_rc_smoke.txt). Hosted site checks remain P20-T04/P19-T14.
- [ ] **P19-T05** — Measure FPS and frametime at opening scene, heaviest wave, largest number of towers and heaviest VFX mode; document device specs and final budgets. **Status after Dev 12:** PARTIAL: bounded high-end stress p95 6.8 ms, 432k primitives, 1007 draws; first-use stalls recorded. Full final-candidate/device coverage remains.
- [ ] **P19-T06** — Optimize mesh LODs, repeated snowball meshes, vegetation instances, transparencies, textures, audio size and UI layout while maintaining quality standards.
- [ ] **P19-T07** — Stress test waves with very many snowballs/child splits, multiple high-pierce attacks, ability spam and sell/rebuild; game outcomes must remain deterministic.
- [ ] **P19-T08** — Verify readability of Powder on snow, colorblind status patterns, range rings, UI text at smaller window and HUD placement at 16:9/16:10. **Status after Dev 12:** PARTIAL: Dev 12 800x600 smoke check exists; owner still rejects terrain/UI readability. Recheck after Dev 13.
- [ ] **P19-T09** — Verify robust fail states: selling last defense, repeated restart, rapid upgrade clicks, pause while ability active, game over during explosion, browser tab hidden/resumed.
- [x] **P19-T10** — Disable developer cheats/console commands/debug overlays in release build; retain logged errors for analysis if enabled safely. **Status after Dev 12:** DONE for Dev 12 release: F3/F4 developer controls debug-only and release hint stripped; recorded in dev12_rc_smoke.txt. Reverify final artifact.
- [ ] **P19-T11** — Test persistent settings and best-score storage if implemented, including no-save/error cases and browser storage restrictions.
- [ ] **P19-T12** — Confirm game startup explains controls and main goal in less than a minute and requires no external installation.
- [ ] **P19-T13** — Record and triage outstanding known issues and test against a release-blocker policy (see §9).
- [ ] **P19-T14** — Create a candidate ZIP of the Web export with files kept together and naming intact; host a release candidate, verify URL independently. **Status after Dev 12:** PARTIAL: build/archive/claus_for_alarm_rc_web_d098ca5.zip (33.7 MB, index.html at root) built and extracted copy tested. Hosting and independent URL verification remain.
- [ ] **P19-T15** — Perform a final full game playthrough **on hosted release candidate**, not only editor or local development server.

**P19 exit proof:** hosted release candidate, documented browser/platform testing, no unresolved critical bugs, acceptable measured performance, input/audio/restart validated.

### P20 — Website, credits, release media, submission and demo prep
**Goal:** Make the project easy to find, play, understand, and present to judges.  
**Read:** HYB-A A-06/A-10; game-jam official rules/announcement; current release facts.  
**Gate:** G10.

- [ ] **P20-T01** — Verify hackathon submission platform, due date/time, required field formats, team credits, playable URL rules and whether a **separate studio website** is actually required.
- [ ] **P20-T02** — Lock the public game title and subtitle and update splash, browser title, website, README and screenshots consistently.
- [ ] **P20-T03** — Create lightweight **Camel Claus studio/team website** only as required (or if time remains), with team name, one-sentence project story, screenshot and a large Play link/embed to tested Web build.
  - **STATUS: DRAFT, NOT DONE (2026-11-14, owner).** A first draft is live at https://quentin-drucker.github.io/Claus-for-Alarm/ (source `website/`, served from the `gh-pages` branch; publish steps in `website/README.md`). The owner will revisit it once the game itself is finished: add baked screenshots/renders of the final in-game models and assets as site visuals, the real itch.io URL (`website/config.js`), team names and asset credits. Do not tick P20-T03 until then.
- [ ] **P20-T04** — Host Godot Web export on supported static site/store page; verify MIME/path/headers, `index.html` companions and no broken static asset routes.
- [ ] **P20-T05** — Write concise instructions: how to place towers, start rounds, click upgrades, understand color layers, use Camel Claus abilities, pause and speed.
- [ ] **P20-T06** — Write accurate game description that emphasizes original winter-sports theme and original assets; do not present as official BTD6 remake or endorsed title.
- [ ] **P20-T07** — Create credits for team, game engine, original artwork, music/SFX licenses and third-party sources; references are informational, not redistributed assets. **Status after Dev 12:** PARTIAL: source/license ledgers and copy-ready lumoize credit exist; website publication and complete public credits not verified.
- [ ] **P20-T08** — Capture 4–6 actual gameplay screenshots and a short trailer/GIF if event expects media; exclude editor-only visuals or unimplemented features.
- [ ] **P20-T09** — Prepare a short judge walkthrough: 15-second premise, one tower placement, a layer break, an upgrade, one Camel ability, win/loss highlight.
- [ ] **P20-T10** — Create final release manifest with Git commit, build date, tested browsers, known issues, artifact URL and contingency local ZIP.
- [ ] **P20-T11** — Submit the correct hosted URL(s), title, media, brief description and credits by verified deadline; save submission confirmation.
- [ ] **P20-T12** — Test the submitted link in a private/incognito window on another machine/network where possible; no sign-in or dev server required.
- [ ] **P20-T13** — Archive a fully reproducible release build alongside docs and changelog; never rely solely on live local development sessions.

**P20 exit proof:** actual submission confirmation, stranger-playable URL, working studio page if required, official demo instructions and final release manifest.

### P21 — Post-jam extension and full-depth fidelity work (OPTIONAL)
**Goal:** Build toward the broader 3×5 upgrade ambition without jeopardizing event delivery.  
**Read:** HYB-M M-07/M-08/M-09/M-11/M-12; HYB-A A-04; HYB-B B-06/B-14.  
**Gate:** G11 only on owner request.

- [ ] **P21-T01** — Reconcile missing numerical effects, every legal crosspath exception, late-tier damage tags, multi-attack/collision behaviors and version-57.4 changes for six initial towers.
- [ ] **P21-T02** — Implement and test all six tower families' 90 nominal tier entries; produce matrix of legal configurations and auto-generated stat snapshots.
- [ ] **P21-T03** — Complete all Camel Claus hero levels/ability variants to 20 with full visual evolution, validated XP and speed interactions.
- [ ] **P21-T04** — Add extended round schedules with verified spawn groups and economic pacing, including large/elite snowball variants and late-game survival.
- [ ] **P21-T05** — Introduce Hockey Slapper ⇔ Boomerang, Snowboard Trickster ⇔ Ninja, Winter Games Lodge ⇔ Village, Track Gritter ⇔ Spike Factory only after explicitly re-authorized.
- [ ] **P21-T06** — Produce corresponding new models, tier-3+ visual identities, UI portraits, sounds, attack feedback and crosspath coverage without reworking core data contracts.
- [ ] **P21-T07** — Consider new original winter-sports mechanics **as a separately versioned design branch** so the source-faithful mechanical baseline remains testable.
- [ ] **P21-T08** — Add additional maps, challenge modes, scores/achievements, accessibility refinements and optional meta progression in independent milestones.
- [ ] **P21-T09** — If adding online co-op, first research networking/data synchronization and define a separate design phase; not included in event MVP.
- [ ] **P21-T10** — Maintain a compatibility migration ledger when patch data, engine version, scene schema or GLB export conventions change.

**P21 exit proof:** optional extended build has separate release notes and a proven no-regressions migration from hackathon version. Not required for the event.

---

## 9. Testing, golden cases, balance fidelity and acceptance matrix

### 9.1 Evidence tiers for all claims

| Claim level | Required evidence |
|---|---|
| `CREATED` | File, scene or resource exists, importable/parsable |
| `IMPLEMENTED` | Feature functions in editor under representative conditions |
| `UNIT_TESTED` | Invariant(s) and known cases assert expected behavior |
| `SCENARIO_TESTED` | Interactions with real towers/enemies/waves work in executable match |
| `BROWSER_VERIFIED` | Feature reproduced in actual Web build, with browser/context recorded |
| `SOURCE_PARITY_VERIFIED` | Exact matching source build/version and mode conditions, measured values, cited proof, relevant crosspath behaviors; **not** assigned merely because an upgrade name/price is present |
| `VISUALLY_APPROVED` | Approved at game camera and model inspection resolutions with QA evidence |
| `RELEASE_ACCEPTED` | Owner approval after successful hosted-browser playthrough |

### 9.2 Golden mechanical scenarios (initial automated suite)

| Test ID | Scenario | Expected invariant | Origin |
|---|---|---|---|
| GT-001 | 1 damage to Coral | Spawns/changes to Violet equivalent; inherited speed and event correct | M-03 |
| GT-002 | 1 damage Violet→Mint→Blue→Powder | Sequential correct shell states; each layer contributes income only once | M-03/M-04 |
| GT-003 | 1 excess damage on child-producing shell | Source-compliant overkill/child distribution; no crash or duplicated child | M-03/M-05 |
| GT-004 | Enemy escapes during last spawn | Lives decrease once; round completion semantics correct | M-02/M-03 |
| GT-005 | Undetectable camo vs Rookie | Tower does not acquire target unless detection granted | M-05/M-07 |
| GT-006 | Bomb vs blast-immune snowball | No illegal damage, clear immune event, expected pierce consumption | M-05/M-07 |
| GT-007 | Magic projectile vs magic-resistant class | Correct damage/miss behavior and feedback | M-05/M-07 |
| GT-008 | Wax base attack | Slow applied without base damage or income | M-07/M-10 |
| GT-009 | Wax plus corrosive tier | Correct stacked/modifier slow+damage and timer ownership | M-07/M-11 |
| GT-010 | Cannon near six grouped targets | Explosion cap/pierce independent of contact projectile | M-10 |
| GT-011 | Biathlon Global and LOS | Eligible target hit without circular range hack; obstruction rules honored | M-10 |
| GT-012 | Sell/rebuy | Correct refund, price and no stale statuses, deterministic ledger | M-04 |
| GT-013 | Ticket Booth payout | Exact configured number/timing; collection once; no cash during wrong state | M-07/M-10 |
| GT-014 | Round end with children alive | No premature PREPARE/REWARD state | M-02/M-03 |
| GT-015 | Start button spam | Exactly one spawn schedule; no double income | M-02/M-04 |
| GT-016 | Crosspath valid `5-2-0` | Accepted if tier content available and fully paid | M-07/M-12 |
| GT-017 | Crosspath invalid `3-3-0` | Blocked in core and UI; no debit | M-07/M-12 |
| GT-018 | Purchase with insufficient cash | No state change; clear reason and UI disabled | M-04/A-07 |
| GT-019 | Hero level 3 skill | Ability exists only at level 3+, proper multiplier/duration/cooldown | M-09 |
| GT-020 | Hero level 4 Focus | Correct 1.25 cooldown ×, 1.25 projectile speed ×, 1.2 range × per v57 | M-09/M-11 |
| GT-021 | Hero level 5 detect | Whiteout/camo eligible only when properly unlocked | M-09 |
| GT-022 | Hero 10 barrage | Ability is unlocked with source-defined target/event behavior | M-09 |
| GT-023 | Pause + 2× + abilities | Identical tick-based outcomes to 1×, cooldown paused | M-02/M-09 |
| GT-024 | Complete match restart | No stale tower, enemy, timer, purchase, ability or UI state | M-02/M-12 |
| GT-025 | Cosmetic GLB swap | Numeric traces unchanged from placeholder after replacing model | B-16 |
| GT-026 | Browser audio unlock | Start with sound after user gesture, no blank/blocked game | A-10/A-12 |
| GT-027 | Game camera readability | Powder distinguishable from snowy map; path/targets visible | A-01/A-05/A-12 |
| GT-028 | Browser performance stress | No major freezes/collapses; record actual FPS/timing/load data | B-14/B-15 |

**Note:** Some expectations need exact source validation before claiming `SOURCE_PARITY_VERIFIED` (especially split-overkill, immunities and nested upgrades). Until then, write unit tests to the *labeled prototype contract* and keep the gap open.

### 9.3 Scenario baseline captures

Store stable test assets under `tests/fixtures/` and evidence under `docs/logs/` or `assets/qa_renders/`. For each scenario, record test name, data snapshot hash, engine build, renderer, simulated seed if any, final cash, lives, round, hero XP, active enemies and elapsed simulation ticks. Re-run baseline comparisons after every release-affecting upgrade, wave, model replacement or engine setting change.

### 9.4 Browser acceptance checklist

- [ ] **WEB-T01** — Hosted `index.html` loads with all sibling `.wasm`, `.pck`, `.js` assets and no missing asset errors.
- [ ] **WEB-T02** — Works over HTTP(s) origin with actual selected threading/security header setup; no local file assumption.
- [ ] **WEB-T03** — Viewport resizing doesn't offset placement pointer or hide HUD.
- [ ] **WEB-T04** — One game start/play/upgrade/win/lose/retry cycle is possible solely with mouse and keyboard.
- [ ] **WEB-T05** — Audio unlocks after gesture, and mute/settings controls function.
- [ ] **WEB-T06** — Load time and build size observed/tested; heavy waves show no unacceptable long freezes.
- [ ] **WEB-T07** — All GUI text is visible and buttons readable on common desktop aspect ratios.
- [ ] **WEB-T08** — Web console inspected for parse errors, asset 404, WebGL errors and input exceptions.
- [ ] **WEB-T09** — Browser refresh/restart and returning from background tab do not corrupt state; pause/background policy documented.
- [ ] **WEB-T10** — Actual hosted URL checked in incognito/different device if available.

### 9.5 Model quality acceptance checklist (read HYB-B B-14)

- [ ] **MODEL-T01** — Neutral clay turnaround displays deliberate organic surfaces instead of obvious intersecting stock primitives.
- [ ] **MODEL-T02** — Back/side/three-quarter and gameplay-camera silhouettes are coherent and recognizable.
- [ ] **MODEL-T03** — Clothes/helmet/goggles/tools are properly seated with physical thickness/contact and no accidental clipping.
- [ ] **MODEL-T04** — Mechanical parts have coherent mounts, pivots, connection details and mass distribution.
- [ ] **MODEL-T05** — GLB import preserves transforms, material appearance, animations and required sockets.
- [ ] **MODEL-T06** — No geometry or rig-driven stat changes occur when replacing placeholder.
- [ ] **MODEL-T07** — Performance measured with several identical models and many rolling enemy copies.
- [ ] **MODEL-T08** — Source `.blend`, optimized `.glb`, QA renders, manifest and original-license provenance are retained.

### 9.6 Release-blocking bug policy

`BLOCKER`: game doesn't boot, hosted Web export broken, purchase/round/hero crash, impossible win due to bug, corrupted core economy, input cannot place, security/attribution violations.  
`HIGH`: reproducible double cash, wrong layer/children, invalid upgrade purchased, hero ability stuck, extreme FPS drops, unreadable UI.  
`MEDIUM`: rare minor VFX/audio sync, cosmetic clipping, secondary tooltip issue or an unobtrusive error.  
`LOW`: optional ambience and presentation refinement.  
**Do not ship with a BLOCKER.** HIGH issues affecting fairness/controls are also release blockers unless consciously cut from released content. Record deferred issues explicitly.

---

## 10. Fast submission route, scope cuts and priorities

### 10.1 Deadline-conscious priority order

The hackathon is a short event; doing the full **six tower families × 15 upgrade tiers**, extensive round schedules, premium modeled character and 20-level hero is likely too much for a weekend even with capable agents. **Keep the full architecture**, but reduce *released content* rather than break mechanics or ship an unplayable Web page.

| Priority | Absolute requirement | If time becomes constrained |
|---|---|---|
| **P0 — protect** | Browser boot, map/path, layered snowballs, round states, placement, one working attack/damage path, income/lives, restart, coherent HUD, one winning game | Never cut these |
| **P0 — strongly prefer** | Two different attacks (Rookie + Cannon), source-defined Wax/status or Biathlon/global aim, Camel Claus basic hero, at least one substantive upgrade path | Cut high-tier complexity before these |
| **P1 — event identity** | Clear winter-sports scene, stylized character/tool silhouettes, festive but original music/SFX, readable snowball spectrum, obvious camel mascot | Simplify geometry/number of props, keep identity |
| **P1 — roster depth** | Additional three/four base tower types, few verified upgrades per tower, special enemy properties, source hero abilities | Disable inaccessible unverified tiers with honest UI |
| **P2 — polish** | Detailed tier-4/5 animations, ambient ski lift, advanced boss cinematic, large OST, photo-quality turntables, savings/persistent scores | Defer without touching the core loop |
| **P3 — post-jam** | 90 upgrade effects + all crosspaths, later four families, multiple maps, freeplay/paragons, online multiplayer | Do not start before release |

### 10.2 Three stage fallback builds

**Fallback A — Minimal valid submission:** single original track, six layered color roles but simple visuals, Snowball Rookie + Avalanche Cannon, a small wave set, basic Camel Claus, place/upgrade/round/replay, clean Web export.  
**Fallback B — Strong short showcase:** add Biathlon Ranger, Wax Sprayer, visible tower synergy, upgrade paths, more distinct enemy classes, audio/UI and selective modeled asset quality.  
**Fallback C — Full targeted jam slice:** all six base towers, hero key abilities if reachable, clear three-path choices for implemented tiers, curated 10–15 or longer rounds by owner decision, complete original ski-festival look and QA.  
**Do not mislabel fallback A/B as completion of all six towers.** Tag them as release scopes; full design continues in S2.

### 10.3 Make deliberate cuts

Prefer **one model with several elegant modular upgrade accessories** over ten unfinished primitive characters. Prefer a tested 15-wave custom demo with source-like tower semantics *and explicitly custom economy*, over asserting exact BTD6 rounds while using invented spawn timings. Prefer high-quality gameplay feel for first 3 minutes over 140 nominal round rows never tested. Prefer a working hostable game with some placeholder props over a flawless trailer for a broken Web export.

---

## 11. AI coding-agent protocol and ready-to-use handoff prompts

### 11.1 The persistent rule for `CLAUDE.md` / `AGENTS.md`

Append a concise excerpt to the active project-instruction file **after reading it first** (avoid duplicate contradictory policies):

> **Camel Claus project hierarchy.** Before any feature implementation, read `references/design/00_Camel_Claus_MASTER_Development_Plan.md` and the exact sections of `references/design/01_Camel_Claus_Hybrid_Gameplay_and_Balance.md`, `references/design/02_Camel_Claus_Hybrid_Art_UI_Audio.md`, and `references/design/03_Camel_Claus_Hybrid_3D_Assets_Blender.md` referenced by that task ID. `references/research/BTD6_*.md` are secondary inspiration/numeric baseline with explicit version gaps; never silently treat them as exact implementation specs. Work in small verified phases, keep game mechanics independent of visual assets, test Godot editor **and** Web, update master checkboxes/logs only after evidence, do not overwrite prior approved files or start later phases without authorization.

**If the agent is only starting with P00**, it must not auto-write the rest of the game's code or begin asset production. Work within the user-approved set of task IDs.

### 11.2 First prompt to Opus 5.5 after placing files in project

```text
You are the primary engineering agent for my Godot 4.7.2/GDScript/Compatibility-renderer browser game, produced by team Camel Claus. All work should happen inside the existing project workspace, not in a newly created unrelated Godot project.

Read, in order:
1) references/design/00_Camel_Claus_MASTER_Development_Plan.md
2) references/design/01_Camel_Claus_Hybrid_Gameplay_and_Balance.md
3) references/design/02_Camel_Claus_Hybrid_Art_UI_Audio.md
4) references/design/03_Camel_Claus_Hybrid_3D_Assets_Blender.md
Then consult BTD6 research docs from references/research/ only for cited gaps relevant to the requested task.

For this session, perform ONLY P00 (project/document setup and audit) and report all findings before any gameplay implementation. Verify actual files, project/engine version, MCP connection and Git state. Do not create game scenes, edit gameplay scripts, start asset modeling, overwrite my existing configs, or progress to P01 until I approve. Report outstanding decisions, discovered conflicts and a proposed P01 task batch.

Use master plan task IDs in your report, cite exact design sections, and do not check off unverified tasks.
```

### 11.3 Repeatable per-phase implementation prompt template

```text
Continue my Camel Claus Godot project using references/design/00_Camel_Claus_MASTER_Development_Plan.md as the live checklist. Execute ONLY these task IDs: [Pxx-Tyy, ...].

Before edits, read the exact HYB-M/HYB-A/HYB-B sections specified for these tasks. State source/patch version and uncertain data. Do not invent exact BTD6 numbers or silently alter approved game designs. Give a brief technical plan and list of files to change. Preserve editor/Web compatibility and the source-vs-presentation contract. Use placeholder assets if this is a technical phase.

Implement incrementally, run relevant unit/integration tests and a Godot runtime check; run browser smoke if Web-facing. Fix failures rather than declaring untested success. Update the checked tasks, evidence, logs and any affected decisions in the MASTER file, but only for tasks demonstrably complete. Commit with clear message if the Git state and permissions permit. Finish by reporting changes, tests, screenshot/log paths, open gaps and the next smallest recommended task batch. STOP at this batch boundary.
```

### 11.4 Blender/3D agent prompt template

```text
Work as the 3D asset artist for the existing Camel Claus Godot project. Tasks: [P15/P16 task IDs]. First read references/design/03_Camel_Claus_Hybrid_3D_Assets_Blender.md (especially B-01, relevant B-03/B-04/B-05/B-07/B-08, B-11–B-15), references/design/02_Camel_Claus_Hybrid_Art_UI_Audio.md (A-01/A-02/A-03/A-04), and mechanics from references/design/01_Camel_Claus_Hybrid_Gameplay_and_Balance.md for the active asset's attack and range role.

The model MUST be an original professionally sculpted, coherent cartoon character/prop with intentional anatomy and attachments. Primitive assemblies are acceptable ONLY as early blockout; a smooth-shaded sphere-plus-cylinder collage is not a final asset. Preserve editable Blender masters, rig/socket definitions, optimized GLBs and evidence: clay turnaround, black silhouette, game-camera capture, 360-degree inspection, Web import/screenshot and QA rubric score. Do not change tower costs, footprints, DPS, map path or gameplay event IDs. Produce/revise only the requested asset family and report defects honestly.
```

### 11.5 Dedicated test/QA agent prompt

```text
Audit the Camel Claus feature(s) [task IDs] against the MASTER plan and referenced hybrid docs. Do not infer success from file existence or prior assistant claims. Identify exact numerical and interaction requirements, separate confirmed reference values from prototype assumptions, run test suite and actual game, compare state snapshots and browser behavior. Give a severity-ranked defect list with reproduction steps, evidence paths, and responsible task IDs. Make no changes outside the explicit authorized QA/fix scope.
```

### 11.6 Agent handoff when context/session limits are reached

At the end of every session append one concise entry to §12 or `docs/logs/SESSION_LOG.md` with current branch/hash, tasks completed, files changed, testing evidence, errors, known gaps, and next suggested IDs. A new AI chat must **read this plan and current live files** rather than trusting the old chat summary. If a session is interrupted, mark task as PARTIAL and preserve failing test/repro details. Never claim autonomous resumption unless an actually configured automation or running agent mechanism verifies it.

---

## 12. Progress log, decisions, risks, regressions and change control

### 12.1 Current project status (edit manually after each session)

| Field | Value |
|---|---|
| Current milestone | G0-G5 implemented for current submission scope. G6/G7 acceptance partial; G8 visual revision pending; G9 local RC exists but hosted/final acceptance open; G10 submission pending. See the reconciled dashboard in section 4. |
| Current phase | Dev 13 visual overhaul implemented and verified locally (ski-lodge sidebar HUD, portraits, Pops, terrain/lighting, themed menus). Owner visual review pending. Dev 12 ZIP kept as fallback. |
| Active task IDs | V13-T01..T10 in 12.1.7 (all implemented; owner visual acceptance and hosted checks open). P19/P20 hosted/submission work open. |
| Latest verified commit | Dev 13 code `c0b246d` (A), `ac1dc6c` (B), `c10e144` (C); final candidate built from `c10e144`; docs commit follows. |
| Latest passing editor test | MCP process runs of match/title (2026-11-15 Dev 13): 1280x720 checkpoint, 800x600, pause, special notice, defeat -> restart, menu How/Settings; 0 script errors (forced lives=0 in the build phase logs a PREPARE->LOST refusal: test artefact) (`dev13_*.png`). |
| Latest passing Web build URL | Local only: `build/archive/claus_for_alarm_dev13_web_c10e144.zip` extracted to `build/rc_c10e144`, served http://localhost:8147/ (Chrome 157, 0 console errors; `dev13_web_smoke.txt`). Fallback `claus_for_alarm_rc_web_d098ca5.zip` on :8143. Hosted page NOT verified. |
| Latest passing test suite | 13/13 incl. new `test_pops` (`dev13_tests.txt`; test_playfeel failed once on the zoom contract, fixed by fitting to size 46, rerun PASS); test_map/match/playfeel rerun after batch C PASS. |
| Current blockers | Owner visual acceptance of Dev 13; hosted upload + private-window check; website credits; submission. Browser ticket-hover not conclusively re-verified this session (logic unchanged, editor check OK). Late-round browser playthrough, low-end/mobile and fresh-player tests not done. First-visit load still ~12 s. |
| Primary next action | Owner: review Dev 13 screenshots/ZIP; upload `claus_for_alarm_dev13_web_c10e144.zip` (or the Dev 12 fallback) per docs/PUBLISHING.md, verify hosted, publish credits, submit before 10:00 ET. |

### 12.1.1 Asset assessment and revised Dev 8 handoff (2026-11-14)

This section supersedes the old next-action text and old Dev 8 map-first prompt. It records the owner's source-model and scope decisions plus a read-only assessment; it does not claim that preparation or integration has been completed.

**Verified progress and history**
- Local development transcripts were available: setup/logistics, Dev 1-7, subsequent "Modeling with Fable 1 - Rookie elf re-rig and face", website, and audio work. Dev 7 is the P15 slice, but the later modeling session and this owner's Tripo/AccuRIG work are also relevant.
- HEAD at assessment: `3efc464`, after `6eaaf5d` face/hat/hair fixes. The existing runtime Rookie is still `assets/models/elf_rookie.glb`, built from the older procedural Blender source. It is NOT the selected Tripo/AccuRIG model.
- Six initial tower base kits, hero progression, 25 rounds and special enemy interactions exist. Later records report 54/90 upgrade tiers (tiers 1-3), superseding the G4 dashboard's historical 35/90 count. Regrow remains deliberately omitted; do not claim unconditional exact BTD6 parity.
- P18 music/SFX/ambience implementation exists; it is not waiting to begin. Latest saved ten-suite evidence is `docs/logs/evidence/p15b_tests.txt`; these tests were not rerun during the assessment.
- `docs/BUGS.md` and the unfilled `docs/FRESH_PLAYER_TEST.md` retain outstanding UX/acceptance work. G6/G7 and release gates must not be auto-closed from source-model availability.
- Source assets and recent documentation edits remain local/uncommitted at assessment. Inspect git status and staging before any commit; do not sweep unrelated work into a batch.

**Selected source assets**
- Current index: `art_src/models/README.md`. There are nine active FBXs: Rookie, Cannon, Ranger, Wax Sprayer, Sorcerer, Ticket Booth, Camel Claus, Hockey Slapper and Snowboard Trickster.
- Rookie authority: `art_src/models/snowball_rookie/snowball_rookie_rigged.fbx`. Superseded Rookie models and historical path manifests are in `art_src/archive/model_collection_before_cleanup/`.
- All nine imported successfully in temporary Blender sessions. One mesh/material and UVs per model; eight have no armature/actions. Approximate triangle counts: Rookie 25,058; Cannon 24,997; Ranger 24,996; Wax 24,988; Sorcerer 12,508; Booth 25,000; Camel 24,994; Hockey 12,500; Snowboarder 13,384. These are source-import measurements, not a Web performance sign-off.
- Raw imported Blender heights: Rookie/Ranger/Wax/Booth/Camel about 1.0; Cannon 0.946; Sorcerer 0.718; Hockey 0.786; Snowboarder 0.801. Different scales must be normalized intentionally, not copied unchanged into the world.
- Sorcerer/Hockey have small below-ground bounds and offsets; Snowboarder has about 10 degrees of object yaw. Cannon has three non-manifold edges requiring inspection, not automatic rejection.
- Rookie has a 71-bone armature and no unweighted vertices in the structural check, but only single-frame T-Pose actions (`Armature|0_T-Pose`, `Key|0_T-Pose`). A rig is present; usable idle/attack clips are NOT supplied. Its embedded diffuse/normal maps import despite stale external AccuRIG temp paths; make exported dependencies portable. Other models resolve their accompanying textures. Imported image maps are generally 2048 squared.
- Facing, artistic quality, deformation quality, actual play-camera readability and browser performance of the NEW models remain unverified.

**Integration hiccups to address**
- `scenes/towers/tower.gd` currently binds only the old Rookie. `_set_model()` unconditionally calls `_anim.play("idle")`; static models need safe optional-animation handling.
- `play_attack()` returns before turning if no AnimationPlayer exists. Separate visual aiming/attack reactions from optional skeletal clips.
- Preserve `muzzle_position()` and the presentation-only projectile offset in `scenes/main/match.gd`; provide per-model markers or offsets rather than changing simulation origins/damage.
- The old binding enables vertex-color albedo for the old painted model. New FBXs have no vertex-color layers; preserve their texture materials and test outline behavior.
- Single-mesh exports do not supply separate barrels/arms/staffs. Initial recoil/tilt/pulse may animate a visual root; independent part movement is optional future mesh separation.
- Preserve map coordinates, blockers, placement masks, costs, ranges, attack cadence and footprints. Booth radius is 1.5 m; others currently default to 0.6 m. Evaluate visual envelope without silently changing balance.
- Do not apply the existing 1.5x presentation multiplier twice. The fixed gameplay camera currently has orthographic size 46.
- Existing scenery `assets/models/lodge.glb` is NOT the deferred Winter Games Lodge support tower.

**Revised sequence (recommended; execute only when the owner invokes the next development prompt)**
1. P15-A01: establish a repeatable non-destructive Tripo/AccuRIG preparation process: original FBX -> derived Blender preparation/profile -> runtime GLB under `assets/models/`. Record per-asset scale, facing, grounding, placement center, materials and markers. Prepared artifacts must be reproducible.
2. P15-A02: prove the process with Avalanche Cannon only, covering P14-T05/T06 and P16-T04/T14/T17 in limited form. Add a small visual binding/profile sufficient for per-model transforms, optional animation, stationary buildings and muzzle markers; avoid an architectural rewrite.
3. P15-A03: integrate Cannon visual only, with a short procedural recoil/recovery and modest muzzle effect. Keep the old Rookie runtime visual as baseline for this slice; inspect its selected rigged replacement but do not require completing Rookie animation first.
4. P15-A04: verify normal camera + placement ghost + nearest legal neighbors + pause/1x/2x/4x, regression suites, Web export/browser, 120-snowball stress frame timing/draws, screenshots and thumbnail. Stop for owner review. Do NOT mark P15-T09/G7 approved automatically: evidence for the selected new character pipeline is still needed.
5. Once accepted, prepare/replace the other INITIAL tower visuals and Camel Claus in small verified batches. Give the rigged Rookie minimal suitable clips or explicitly agreed temporary fallback; do not reuse incompatible old skeleton actions blindly.
6. Resume the former Dev 8 map/snowball slice (P16-T09/T11/T12): locked geometry, track luma snow > stone > track, dressing and pooled layer-break effects. The scope is queued, not cancelled. Hero/tower rollout order can be reviewed after the Cannon proof; avoid combining all work in one unchecked batch.
7. Finish P17 feedback/UI work, remaining G6 acceptance, P19 browser QA and P20 publishing verification. A recorded website/itch URL is not proof of present public accessibility.

**Progress: Dev 8 Cannon proof, P15-A01–A04 (2026-11-14; all results below are new tests unless marked historical)**
- Pipeline: `art_src/tools/prepare_source_model.py` (headless Blender 5.3; `inspect` = all sources, `<id>` = prepare). Source FBX/texture folders are only read; the derived `art_src/prepared/<id>.blend` and `assets/models/<id>.glb` are rebuilt from scratch each run. Per-model record: `art_src/models/README.md`; raw measurements: `p15a_source_inspect.txt`.
- Cannon: the three "non-manifold edges" are one isolated ~1 cm triangle floating by the left trunnion (each vertex has only that face), deleted rather than filled; normals consistent (1 face differs from a recalculation, visually fine); muzzle faced −Y → turned 180°; already grounded and centred (offset 2 mm); 24,996 tris kept (the stress run shows no measurable desktop cost). Maps 2048² JPEG → 1024² PNG in the GLB (Godot 4.7's JPEG loader rejected two Blender-written JPEGs; that first export rendered black). Material opaque, single-sided, metallic ≈ 2% (painted non-metal).
- Size: modelled envelope 0.44 m × 1.5 display = 0.66 m vs footprint 0.6 m; 0.93 m tall displayed (Rookie ~1.8 m, snowball 0.8 m). At the nearest legal spot (centre 1.71 m from the centreline) the sled feet reach at most 4.9 cm (≈1 px at the game camera) past the track edge at the worst of 24 aim angles; neighbours at 1.204 m (touching footprints) do not intersect visibly (`p15a_gamecam_placed.png`). AABB y 0.000–0.934: no float/sink.
- Binding: one `PresentationProfile` resource per id (`resources/presentation/`); `tower.gd` builds Tower → `_pivot` (aim) → GLB (recoil/squash, display scale). An optional AnimationPlayer is now advanced manually from `animate(dt)` (called per simulation tick by `match.gd`), so the old Rookie's idle/attack also pause and follow 1×/2×/4×; the placement ghost is not ticked, so a ghost Rookie no longer idles (static pose). Vertex-colour albedo only for the old Rookie profile.
- Verification: 10/10 suites, STATE transcripts identical (`p15a_tests.txt`); new `test_towers` `_test_cannon_visual` (grounded 0.93 m, bore marker, aim on the pivot not the root, 30 rapid shots bounded, pause freezes, exact return to rest, footprint 0.6). `tests/tools/cannon_review.gd` (windowed): ghost valid/invalid, select + upgrades (tiers 1-0-1, model kept), sell frees the visual, pause holds offset 0.12 for 30 frames, reaction 352/174/87 ms real at 1×/2×/4× (expected 350/175/88). Editor process run 0 errors/warnings. Web export exit 0 with 0 ERROR/WARNING; `--main-pack` shows only the known exit-time "8 resources still in use" line (unchanged since DEC-039); Chrome 1152×648 by mouse/keyboard: Cannon + Rookie placed, round 1 won, pause, 1×/2×/4×, 0 console errors, 240 fps, worst frame 6.3 ms.
- Stress (`cannon_review.gd -- stress [greybox]`, desktop RTX 5080 laptop, Compatibility, vsync off, 1152×648, 8 Cannons + 4 Rookies, 120 moving immune Coral kept topped up): GLB frame p50 1.28 / p95 1.82 / max 4.52 ms, draws p50 968, primitives 417k, 33.5 MB video; same scene with greybox Cannons p50 1.23 / p95 1.83 / max 3.72 ms, draws 942, primitives 311k. Not a low-end or Web performance sign-off (the historical P15 stress with 12 Rookies used a different tower mix and is not comparable).
- Not done here: Blender clay/turnaround QA renders and a B-14 score for the Tripo Cannon; Web stress; Label3D tower names overlap at touching footprints (existing behaviour: labels sit at 2.7 m for every model); at the 320×180 thumbnail the Cannon is a ~6 px blob, readable by colour only.

**Progress: Dev 9 — Cannon proof checks + Biathlon Ranger + Slope Wax Sprayer, P15-A05–A08 (2026-11-14; new tests unless marked historical)**
- Owner direction recorded (DEC-040): animations pause and follow game speed, placement ghosts stay still, the gold Cannon muzzle flash is acceptable; the Cannon keeps its current size provisionally (no further 8% shrink for the ~1 px track overlap); final size/readability approval stays open until a coherent roster is compared at the normal gameplay camera. P15-T09 and G7 are NOT marked.
- Cannon proof checks (P15-A05): Blender clay turnaround (front/right/back/left/3/4), black silhouettes (game camera + front) and an EEVEE close-up from the prepared `.blend` (`p15c_avalanche_cannon_*`; `qa_render.py` extended to prepared models); B-14 self-score 7×2 / 3×1 / 0×0 (`p15c_b14_scorecard.md`: material gloss, cohesion with the old Rookie, readability at 0.93 m). No geometry/material/import defect found (re-running the preparation reproduces the committed GLB byte for byte). Browser stress (new, reproducible: `tests/tools/stress.tscn` in the separate "Web Stress" export, launched by `stress_cannon.html`): Chrome 157 (playwright-cli headless shell, ANGLE D3D11, RTX 5080 laptop), 1152×648, 8 Cannons + 4 Rookies, ≥ 120 moving snowballs: in-engine frame time p50 4.20 / p95 5.60 / p99 8.30 / max 10.90 ms (display-paced 240 Hz; page-side rAF p95 4.30 ms), 978 draw calls (RenderingServer), 417k primitives, 61 MB video memory, 0 console errors (`p15c_stress_web.txt`). Limitations: high-end GPU only; browser vsync hides headroom below 4.17 ms; no low-end/mobile run; ~970 draws is the main risk on weak GPUs. Desktop results (`p15c_stress_desktop.txt`) are not browser evidence.
- Pipeline change: the `prepare_source_model.py` marker finder is generalised (`weapon_tip`: front-most slab along a weapon yaw within a height band); the Cannon's bore marker is unchanged. Profiles added for Ranger and Wax. `PresentationProfile` gains `weapon_yaw_deg` (the weapon, not the body, faces the shot; recoil and tilt follow the weapon axis), `recoil_tilt_deg` and `flash_color`; `tower.gd` binds both new profiles. No gameplay script or data changed.
- Biathlon Ranger (P15-A06): source faces −Y → yaw 180°; boots centred (ground centre measured on the 2 cm contact band; the bipod feet stay above it); fitted by height 1.2 m (1.8 m shown, Rookie 1.87 m); rifle barrel 60° off the body axis (PCA) → `weapon_yaw_deg` 60; `muzzle_A` at the barrel tip (0.47 m high shown); maps 1024² PNG, opaque, single-sided, outline overlay. Reaction: 4 cm recoil along the barrel + 4° muzzle climb, kick 0.04 s / recover 0.22 s, small gold flash 0.25 m at the muzzle; the existing target flash disc marks the instant hit. Damage timing unchanged (instant hit in the same tick; `play_attack` is presentation only). Aim check over 8 directions: barrel vs muzzle→target ≤ 1.7°, muzzle 0.27 m beside the centre line.
- Slope Wax Sprayer (P15-A07): source faces −Y → yaw 180°; height 1.2 m (1.8 m shown), envelope 0.71 m shown (tank pack); the spray wand points along the body axis in the right hand, `muzzle_A` in the nozzle (0.71 m high shown); wax shots now start at the nozzle through the existing `match.gd` presentation offset. Reaction: pump = 6% squash + 3° lean into the spray + 2 cm, kick 0.08 / recover 0.30 s, dark spruce nozzle puff 0.3 m (the shot blob's colour). Status/attack data untouched (no damage added).
- Verification (P15-A08): 10/10 suites PASS; STATE transcripts identical to this session's pre-change run except two added `BOOT -> PREPARE` lines from the new test matches (`p15c_tests.txt`). `test_towers` checks all three static models: grounded height, muzzle height and side, the weapon (not the root) aims, 30 rapid shots bounded, pause freezes, exact return to rest, footprint 0.6 m. `tests/tools/roster_review.gd` (windowed, `p15c_review.txt`): ghost valid/invalid (ghost not animated), select + upgrade (tiers 1-0-1, model kept), sell frees the visual, pause holds the pose, reaction 267/133/67 ms (Ranger, expected 260/130/65) and 383/192/100 ms (Wax, expected 380/190/95) at 1×/2×/4×, 10 s rapid fire at 4× then exact rest for Cannon/Ranger/Wax. Editor process run 0 errors/warnings. Web export exit 0, 0 ERROR/WARNING; `--main-pack` prints only exit-time P18 audio leak lines (Ogg streams held by the Audio autoload, per `--verbose`). Chrome on the exported `build/web`: Ranger + Wax placed by mouse/keyboard, Ranger selected, round 1 won, pause, 1×/2×/4×, Wax sold, 0 console errors, rAF p50 4.20 ms (one 217 ms hitch at the first shots of round 1, likely first-use shader compile).
- Clearance at the nearest legal spot (1.71 m from the centreline, touching footprints at 1.20 m): Cannon 0.049 m past the track edge (unchanged); **Ranger rifle 0.39 m past the track edge (bipod 0.14 m) and up to 0.39 m into a touching neighbour's footprint**; Wax 0.095 m past the edge, 0.105 m into a neighbour's footprint. No camera, footprint or geometry change made: reported for the owner (DEC-041).
- Readability at the normal camera (`p15c_gamecam_roster_*`, `_zoom4x`): characters ~30 px tall at 1152×648; the Ranger reads (goggles, rifle), the Wax reads as red hat + tank pack (wand hidden in the front silhouette), the Cannon is small, and the 2.7 m Label3D names cover neighbouring models at touching footprints (existing behaviour); at 320×180 all towers are colour blobs. All three new-source models are glossy (authored roughness maps, means 0.21–0.40). B-14 self-scores: Cannon 7/3/0, Ranger 7/3/0, Wax 6/4/0 (most 1s are integration decisions, not modeling defects; see the scorecard).
- Recommendation for the next batch: finish the remaining initial-roster visuals first (Snow Sorcerer + Ski Resort Ticket Booth with this pipeline, then Camel Claus, then the AccuRIG Rookie minimal-clip task, which also resolves most cohesion 1s), after the owner settles DEC-041 sizing, so the queued map/snowball slice (P16-T09/T11/T12) is dressed around a settled roster. If the deadline is close, swap: the map/snowball slice is more visible per hour than the Booth.

**Deferred and scope boundaries**
- No additional full-character rigging or complex animation prerequisite. Favor tower-specific procedural activity reactions triggered by existing gameplay events; effects never determine damage. The existing Rookie rig remains authoritative.
- Upgrade-form variants are deferred until the base game is polished (owner note in setup/logistics history); do not force P16-T13 or DEC-032/034 upgrade cosmetics into the immediate slice.
- Winter Games Lodge/Monkey Village and Track Gritter/Spike Factory: no hackathon creation/inclusion; retain concepts for an optional expansion.
- Hockey Slapper and Snowboard Trickster source models exist, but no gameplay definitions/implementations were found. Their reference/model creation does not authorize adding their mechanics to the submission.
- See `docs/DEFERRED_WORK.md`. Keep earlier evidence and decisions as history; the source assets and limited animation direction above supersede conflicting hand-built-only/shared-rig requirements in DEC-039.

**Dev 10 handoff update (owner direction, after Dev 9):** Ranger stays at its present size; rifle overreach is accepted without changing placement geometry (DEC-041). Continue with Sorcerer + Booth integration, plus the explicitly authorized Booth base price and proximity-pickup changes (DEC-042/043). These gameplay changes require their own tests and intentional baseline updates; do not claim the whole batch matches the old economy transcript. Preserve visual-only parity before the gameplay change where practical. G7/P15-T09 remain open; no blanket approval of unresolved material/readability scores is implied. The old map/snowball slice remains queued. Review profile serialization warnings and the first-use Web shot stutter without assuming its cause or expanding scope into a global rewrite.

**Progress: Dev 10 — Sorcerer + Booth (batch A, visual) and Booth price + hover collection (batch B, gameplay), P15-A09–A12 (2026-11-14; new tests unless marked historical)**
- Owner decisions applied: Ranger size kept (DEC-041, no footprint change); Booth base price $750 (DEC-042, ORIGINAL_DEVIATION); hover collection (DEC-043). Rigging/complex animation stay deferred; G7/P15-T09 open.
- Batch A, Snow Sorcerer (P15-A09): source faces −Y → yaw 180°; raw 0.719 m tall, 7 mm below ground; the staff foot touches the ground beside the boots and pulled the contact-band centre 4 cm sideways, so the pipeline gained `ground: largest_cluster` (centre on the boots); fitted by height 1.0 m (1.5 m shown, compact, 80% of the Rookie); `muzzle_A` = staff head (1.33 m shown) via the new `staff_top` marker. Reaction: 6% stretch + 4° lean, kick 0.06 / recover 0.25 s, icy `#8FD8E8` puff 0.35 m at the staff head; shots start there (existing `match.gd` offset). Attack timing, projectiles and damage types unchanged.
- Batch A, Ticket Booth (P15-A10): yaw 180° (counter faces the camera); envelope fit 1.0 m modelled = 1.5 m shown (vertex corners exactly on the 1.5 m data footprint), 2.42 m tall; stationary: no aiming (verified through a round of income: pivot stays facing the camera). New `play_income()` (presentation only, called by `match.gd` when a Booth produces income: pickup, bank deposit or Marketplace pay): 4% bounce + gold window puff 0.45 m. Ticket spawn positions unchanged (1.8 m from the centre, outside the building); 1 of 4 base positions (2 of 8 with upgrades) is behind the building at the game camera, so ticket visuals now draw in the transparent pass without depth test (colour A/B-checked identical) instead of moving them. Production, bank and direct income unchanged.
- Batch A, pipeline/binding: `prepare_source_model.py` gains `largest_ground_cluster` and `staff_top`; earlier GLBs re-prepare byte-identical. `tower.gd` binds both profiles; `_start_reaction()` shared by attacks and income. Profiles created/re-saved through the editor's resource tools: the two Dev 9 `.tres` files lacked their own `uid` (hand-written); the reported "invalid UID" warnings reproduce only with a stale headless UID cache after editor saves and vanish after `--import` (UIDs verified against the `.uid` files). Texture imports set consistent (`compress/mode=2`, `detect_3d/compress_to=0`) — measured afterwards: this still produces WebP → uncompressed RGB8 in video memory, not S3TC (no memory change; open Web task).
- Batch A verification: 10/10 suites PASS, STATE transcripts identical to the pre-change run except added test matches (`p15d_tests_visual.txt`); `test_towers` static-visual checks now cover the Sorcerer and a Booth building check (2.42 m, inside 1.5 m, window marker, stationary, income reaction to exact rest). `roster_review.gd -- dev10` (`p15d_review.txt`): nearest legal Sorcerer 0.010 m past the track edge, 0.017 m into a neighbour footprint; Booth at its nearest legal spot −0.305 m (inside); ghost valid/invalid (not animated); select + upgrade (tiers 1-0-1, model kept); sell frees the visual; pause holds; reaction 317/158/79 ms (Sorcerer, expected 310/155/78) and 300/150/75 ms (Booth) at 1×/2×/4×; 10 s rapid fire at 4× → exact rest for all reacting towers. Editor process run 0 errors/warnings. Blender clay/silhouette/close-up QA and B-14: Sorcerer 6/4/0, Booth 8/2/0 (`p15d_b14_scorecard.md`).
- Batch B, Booth price (P15-A11): `price` 1250 → 750, status `ORIGINAL_DEVIATION`, notes/role updated; upgrade prices, income (4 × $50), lifetime 15 s, footprint unchanged; sellback = 70% of actual spent (tested $750 → $525, with an upgrade included).
- Batch B, hover collection (P15-A12): `match.gd` `hover_collect_radius_m = 1.0` (export, implementation default). `collect_cursor` is explicit gameplay input: the match sets it each frame from the real mouse only after a mouse motion inside the window, never over a hovered HUD control (pause/end overlays included) or outside the viewport; it clears on window mouse-exit/focus loss; headless tests and bots never feed it (`set_collect_cursor()` instead). Applied in the sim tick after the tick's drops and before expiry (a still cursor takes a new ticket on its drop tick; hover wins a same-tick expiry, with no salvage); every ticket within the radius goes through the one `collect()` path (credited once; click unchanged). Paused = no tick = no collection; ended matches do not collect; between rounds collects. Help: HUD hint "hover tickets", How to Play text, Booth tooltip/role.
- Batch B verification: 10/10 suites PASS. New `test_towers` `_test_booth_price` and `_test_ticket_hover` (0.99 m in / 1.01 m out, two in one tick, no repeat credit, click then hover once, paused, same-tick expiry order, expired pays nothing, still cursor on a new drop, between rounds, after defeat, Bank unaffected). Transcript differences vs batch A all come from the price (`p15d_tests_gameplay.txt`): test_upgrades/test_towers +$500 wherever a Booth is bought; full_run bots: Mixed/Hero buy the Booth earlier (income 600/400 → 800), Booth economy invested 2350 → 1850, income 6000 → 6800, 125 → 131 lives; Rookie-only and solo runs identical; all policies still WON where they did and DEC-029 speed equivalence still IDENTICAL. Real-mouse checks: editor run (hover collected, paused not, resumed yes) and Chrome on the exported build (`p15d_web_hover.txt`: hover credited once, click on the same spot added nothing, paused sweep nothing, 0 console errors). UI blocking was not exercised with a ticket under a panel (no HUD panel overlaps a ticket spot in this layout); it is covered by the hovered-control check and the pause overlay.
- Web: release export exit 0, 0 ERROR/WARNING; `--main-pack` only the known exit-time P18 audio lines. Browser stress, full mix (2 each of all six towers, ≥ 120 snowballs, Chrome 157 headless shell, ANGLE D3D11, RTX 5080 laptop): p50 4.20 / p95 4.40 / p99 4.70 ms, max 250.6 ms (one frame), 962 draws, 343k primitives, 85.6 MB video memory, 0 console errors; roster mix p95 4.40 ms (`p15d_stress_web.txt`). Display-paced 240 Hz; high-end GPU only.
- First-shot stutter (`p15d_stutter_web.txt`): repeatable, not a one-off — every load shows long frames at the first placement (~235 ms), first round start (246 ms; 1.87 s on a fresh browser profile) and first shot (100–175 ms); round 2's first shots show none. Cause not proven (consistent with first-draw shader/pipeline compilation or first audio use).
- Readability at the normal camera (`p15d_gamecam_roster_*`): the Booth is the strongest tower read; the Sorcerer reads as a red hat with a faint icy staff tip (thin prop on a compact body); Label3D names still cover neighbours at touching footprints; 320×180: towers are colour blobs, the Booth stays recognisable.

### 12.1.2 Owner observations implemented alongside paused Dev 11 (2026-11-14)

**Scope and coordination:** Dev 11 (Camel integration, Sorcerer size, bounded texture/stutter work) was in progress but paused by the owner's model usage limit. This batch handles independent owner observations. It does not replace Dev 11, claim its work completed, or approve P15-T09/G7. Do not overwrite these changes when resuming; inspect the current tree, especially `scenes/main/match.gd` and `match.tscn`. Hero/profile/preparation sources and other chats' existing import changes were left alone.

**Implemented trials**
- OBS-PICKUP: `hover_collect_radius_m` default 1.0 -> **2.0 m** in world XZ (owner requested 2x). Existing click tolerance remains 0.6 m; ticket values, authoritative positions, lifetime, Bank/Marketplace, expiry and $750 Booth price remain unchanged.
- OBS-TICKET-FX: `scripts/presentation/ticket_effects.gd` animates the existing ticket visual from the Booth window/muzzle marker to its original resting point over 0.42 s with an upward/outward arc and settling scale. On hover/click it accelerates toward the collection point over 0.22 s, following valid cursor input. Authoritative payment/removal still occurs immediately in `collect()`; the detached effect cannot pay or expire again. Instant same-tick collection is supported. Effects advance on game ticks (pause/speed respected), clean up on finish/expiry/scene teardown, and collected effects are capped at 48.
- OBS-CAMERA: `scenes/main/gameplay_camera.gd` exposes elevation, focus and orbit distance. Default elevation **60 -> 50 degrees**; preserve original ground focus, orthographic size **46**, map data and projection-based picking. Script attached using `godot_node_set`/`godot_scene_save`, not text editing of the scene. `elevation_degrees=60` restores the previous pitch. No gameplay zoom change was made.
- OBS-CONTACT (EXPERIMENTAL BALANCE): moving-projectile swept-contact tolerance **0.4 -> 0.6 m** via `projectile_hitbox_multiplier=1.5`; set 1.0 to restore baseline. This codebase has no independent projectile-shape radius, so the existing sweep tolerance is the applicable dimension. Enemy physical/visual radius remains 0.4 m. Target ranges, ricochet search distance, hitscan Ranger attacks, burst/explosion radii, damage, speed, lifetime, pierce and visual size are unchanged. Moving shots from Rookie, Cannon, Wax, Sorcerer, hero and projectile sub-attacks share this sweep. More reliable contact intentionally changes encounter outcomes; this is not an identical-gameplay art swap.

**Upgrade/showcase audit**
- `tests/test_upgrades.gd` and `docs/logs/evidence/p10_upgrade_coverage.txt` confirm **9 available upgrades per initial tower**, top/middle/bottom tiers 1-3 = 54/90. All six initial towers meet the requested tier-depth target. The remaining 36 tier-4/5 entries are unavailable; HUD labels them "coming soon", and purchases are refused.
- Existing documented approximations/fillers remain explicitly labelled; availability does not establish full BTD6 fidelity.
- Showcase roster remains six implemented regular towers + Camel Claus. Hockey/Snowboard source art is not authority to add mechanics. Existing deferrals remain in force.
- Tier-4/5 implementation is post-showcase work; upgrade-form cosmetics and broad rigging remain deferred separately.

**Deferred requirements / authoritative backlog**
See `docs/DEFERRED_WORK.md` for desired behavior, reason, phase, considerations and completion criteria:
1. P17/P13-T08: slight zoom/composition review with right/bottom UI safe areas, aspect ratios and full playfield visibility.
2. P17/P13-T05: acknowledged, non-expiring special-enemy introductions before relevant waves; block every start path until acknowledgment, avoid repeat notices within a match. Verified active first introductions: Black r20 (explosion immunity), White r22 (cold immunity; no current cold attack), Camo r24 (detection required), Aurora r25 (energy/fire/plasma immunity). Metal/Lead remains deferred.
3. P19-T05–T10: **required final Web optimization/acceptance gate**, covering target devices, frame times, loading/download, draw calls, meshes, textures/VRAM, shaders, VFX and late-wave entity counts. Retain reasonable resource practices now; do not indefinitely defer a blocking regression.
4. Final P17 visual polish then P19: evaluate subtle pixel aesthetic, low-res 3D vs selective effects/material/filtering; initially compare crisp HUD/text; no pixel shader implemented now.
5. P21: tiers 4–5 as potential later extension, clearly unavailable in showcase.

**Verification and limits**
- Headless baseline: all ten existing suites passed before edits. After edits: those ten plus `tests/test_playfeel.gd` pass (11/11); `observations_tests.json` and per-suite logs under `docs/logs/evidence/`.
- New tests cover 2 m pickup boundaries, spawn origin/settling, paused visuals, magnetic movement, immediate once-only credit, same-tick spawn collection, original-vs-expanded swept misses/hits, unchanged splash reach, and camera projection roundtrips with zoom unchanged.
- The legacy 1 m hover ordering/expiry fixture explicitly selects radius 1 m; the new suite independently verifies the new default. This preserves coverage rather than changing the fixture's unrelated timing assertions.
- Full-run speed equivalence still passes. Before/after bot lives: Rookie-only 147 -> 147; mixed roster 145 -> 147; hero mix 150 -> 150; Booth-economy 131 -> 141. These are measured consequences of the contact experiment, not a balance-parity claim. Solo Ranger remains 4 lives, Cannon 147, Sorcerer 37, Wax loses r4. Review fairness by playing before locking the multiplier.
- Web export to separate `build/observations_web/` succeeded. Browser checks/captures and any remaining manual review are recorded in the appended SESSION_LOG entry.
- Native windowed review attempts crashed at startup with Windows exit 3221225725 before rendering; headless tests and Web work. No claim of successful native-window visual verification. Existing exit-time resource cleanup warnings also appear in the pre-change baseline.
- MCP tools are available through a temporary stdio client calling the installed local server: `godot_status`/`godot_project_info` confirmed Godot 4.7.2, no connected editor. Scene operations can use its headless backend. Direct filesystem/GDScript edits, headless tests, Web export/browser checks and standalone Blender commands are available; no user reconnection is required for those operations.
- Camera angle, ticket motion and contact multiplier remain owner-review/tuning items, not final art sign-off.

**Next:** resume the authorized Dev 11 work on top of this batch, then selected Rookie integration and queued map/snowball slice. Keep final P17 composition/onboarding/pixel exploration and P19 Web acceptance visible; do not expand the roster or begin broad optimizations prematurely.

### 12.1.3 Dev 11 — Camel Claus, Sorcerer 1.7 m, bounded Web-cost pass (2026-11-15)

- Batch A (`535b958`, visual only): Camel Claus and Sorcerer as in P15-A13–A15 / DEC-044/045. Verification: 11/11 suites with identical transcripts (`p15e_tests_visual.txt`); `roster_review.gd -- dev11` (ghost, selection, sell, pause, reactions 283/142/60 ms hero and 313/158/79 ms Sorcerer at 1x/2x/4x, rapid fire -> exact rest; review-tool refill fixed so snowballs no longer all respawn at the exit); editor run 0 errors; Web export + Chrome round 1 with the hero, 0 errors; Blender QA + B-14 Camel 7/3/0, Sorcerer 8/2/0.
- Batch B (`9af1285`): Dev 10's "mode 2 still RGB8" was a stale artifact (editing `.import` params never rebuilt the maps). Real rebuild -> BC1/BC3 + BC5: 98.5 -> 42.5 MB browser video memory, same frame time, visually identical. Stalls: fresh page title 10.3–10.5 s, match 5.2–5.9 s, round start 2.2–2.6 s; reload 2.3/1.1/0.3 s. An audio-locked probe reproduces them and pre-drawing every material removes them (first-draw material/shader variants; GL stage not profiled), but a full warm-up costs 14.6 s fresh / 2.5 s reload vs ~5.3 / ~1.1 s removed, so none shipped. Next actions in `p15e_stutter_web.txt` and DEFERRED_WORK.
- Not done: real-browser hover test with a ticket under a HUD panel (optional); low-end/mobile measurements. P15-T09/G7 not marked.

### 12.1.4 Main-menu Christmas village (owner request, 2026-11-15)

**Implemented P17 menu slice; not a G7/G8 or full UI sign-off.** The owner supplied lumoize's animated Sketchfab FBX and requested a perpetual camera orbit around the central tree, then a wider-angle lens.

- Original **Christmas Low-poly Scene** by **lumoize**: https://sketchfab.com/3d-models/christmas-low-poly-scene-7984bd6024db4b89928ddeb625eebac0 . Public Sketchfab API verified **CC BY 4.0**, 2026-11-15. Source/author/license snapshot and original hash saved under `art_src/environment/christmas_village/`; download preserved. Root `CREDITS.md` includes source, author, license, adaptation notes and audio-credit link. Owner update: no main-menu credit overlay; public attribution belongs in the game website credits. Root CREDITS.md retains it with the source, and website/README.md contains the copy-ready credit and publication TODO.
- `art_src/tools/prepare_menu_village.py` imports the FBX in standalone Blender, normalizes around the tree's actual geometry (XZ origin in Godot), batches 322 static mesh objects, retains animated parent transforms, adjusts roughness/emission and exports a runtime GLB plus a derived Blender file. Runtime mesh objects: 21 vs 342 source meshes; approximately 154k source triangles. Solid-color materials, no texture dependencies.
- Smoke object motion is preserved and baked into one concurrent looping timeline (source frames 2–490, 24 fps). Blender's FBX importer cannot import the source material animation; lights remain steadily emissive. This limitation is documented, rather than claiming original blinking materials were retained.
- `scenes/ui/menu_background.tscn/.gd` supplies an isolated SubViewport world, winter lighting and a **perspective 72-degree vertical FOV camera**, radius **12 m**, height **6.5 m** (owner requested lower than initial 8.5 m), look height **3.2 m**, orbit speed **2 degrees/sec** (180 sec/revolution). Camera always looks at the tree at horizontal origin; parameters are exported for tuning.
- Owner lighting revision: reduce sun/ambient energy to 0.7/0.35 with linear tonemapping to retain snow detail. Restore source smooth-shading flags during static batching (previous batching flattened them); give only `Ice_Sheet` a separate blue `RinkIce` material, leaving shared house glass unchanged. Original FBX remains untouched. Add a pale winter sky, Web-compatible depth mist (16–44 m, central tree clear), and a snow horizon below the diorama so its outer edge no longer exposes an empty backdrop. Current visual evidence is `menu_lighting_web_final.png` / `menu_lighting_web_orbit.png`; earlier `menu_village_*` captures show the initial lighting.
- `title_screen.tscn` changes made through Godot scene/node tools: backdrop behind the 2D menu, controls on left so central tree remains visible. The initial bottom attribution bar was removed through scene/node tools at the owner's request; attribution moves to the website. Existing How to Play/Settings panels stay usable and are darkened for text readability; orbit continues underneath. Gameplay scene is not modified.
- Tests: `test_menu_background` (camera radius/target/FOV, source smoke animation and looping, absence of the removed credit bar and functional panels), `test_ui`, `test_audio` PASS. `godot_run_start(mode=process, headless=true)` + error output: exit 0, no gameplay script errors; existing exit-time resource cleanup diagnostic remains.
- Web export: separate `build/menu_preview_web/`, exit 0. Chrome smoke checks at 1152x648 plus narrow 800x650: animation/orbit visible, How/Settings open/back, Play enters the match; console 0 errors/warnings. Evidence `docs/logs/evidence/menu_village_*`, including `menu_village_web_final.png`, `menu_village_web_how.png`, `menu_village_web_settings.png`, `menu_village_web_narrow.png`, `menu_village_web_play.png`.
- Final Web performance/low-end validation remains P19; this menu-only slice does not resolve remaining Rookie integration, map dressing or other UI work.

### 12.1.5 Deadline handoff after Dev 11 (owner: approximately seven hours remaining)

**Owner direction:** prioritize efficient implementation and a finished submission. Time and model usage are limited; avoid repeated broad audits, speculative refactors, redundant renders and approval stops for routine choices. This is a prioritized handoff, not completion evidence for its tasks.

- **Rookie scope update (owner, DEC-046):** keep the functional existing runtime assets/models/elf_rookie.glb for submission. Skip all selected-Rookie preparation, new clips, posing, re-rigging and replacement work. Preserve the AccuRIG source for later; it is not a submission blocker. This supersedes the Rookie-first sequence in earlier prompts and sections.
- **Hero decision resolved:** keep the larger current **2.52 m displayed hero** (1.68 m prepared x 1.5 display multiplier). The owner clarified that size is the intended choice regardless of image filenames. The named hero150 comparison actually shows the smaller 2.25 m alternative; do not shrink the runtime hero. Keep mechanics/footprint unchanged.
- **Menu delivered:** use 12.1.4's revised lower orbit/lighting/rink/sky/fog. No creator credit overlay on the menu. Website publication TODO in website/README.md includes lumoize, source/model/author/license links and adaptation wording; root CREDITS.md is retained. Live website attribution is not claimed complete.
- **Recommended remaining allocation:** skip Rookie replacement entirely; about 2 h map/snowball polish; about 90 min essential HUD/onboarding; protect at least 90 min for browser/full-run QA, hosting, credits and submission. Remaining time is contingency. These are work limits, not promises of exact duration.
- **Next art batch:** start directly with P16-T09/T11/T12 and active special shells/P17-T02. Prefer existing kits and reusable resources. Locked route, placements, blockers, projectile/tower contracts, prices and other validated mechanics remain unchanged. Snow > stone > track in luma; Powder visible on snow; decorations cosmetic. Reuse the village only if useful and cheaper than existing map assets; do not drop its full dense scene onto the course.
- **Essential UX follows:** readable right-hand shop/selection/upgrades and hero controls, smaller-window safe areas, fewer overlapping tower labels, obvious wave/pause/speed/result controls; special-enemy acknowledgment notices from DEFERRED_WORK at rounds 20/22/24/25. Check real round data and input-start paths. No new cold attack, enemy types or balance changes.
- **Browser performance:** recommended deadline choice is to leave the measured full pre-draw warm-up out; it lengthens load time. Prioritize actual freeze/crash/playability defects and bounded improvements over another broad research pass. Earlier 42.5 MB and stutter measurements predate the new menu and are not measurements of the final candidate.
- **Keep deferred:** selected Rookie replacement (owner DEC-046), extra towers (including Hockey/Snowboarder), Village/Spike Factory, new rigs, elaborate animations, tier-4/5 and upgrade-model production, pixel-shader exploration and nonessential microdetail. Finish the current game rather than enlarging scope.
- **Verification cadence:** focused tests per meaningful batch; one complete regression suite after integrated changes, then a real exported browser smoke/stress check. Repeat only after relevant changes/failures. Keep short truthful evidence, commit only owned files, pull --rebase before each push without sweeping/stashing other chats' work. Do not mark owner acceptance, fresh-player testing, low-end results or submission gates complete without evidence.

### 12.1.6 Dev 12 — submission build (2026-11-15)

- Batch A (`4fcd4b4`, `d098ca5`): `scenes/world/course_dressing.gd` (node `SkiCircuit/Dressing`) builds cosmetic dressing from the locked waypoints/bounds/blockers at load: snow berms on both track edges (mitred), START/FINISH arches, slalom flags on bend outsides, the Pond blocker styled as a frozen rink with boards and curling stones, split-rail fence outside the long edges, instanced pine margins outside the buildable ground and clear of the entry/exit lanes, snow ground/backdrop. Nothing joins `Blockers`: placement/LOS unchanged (test_map PASS). Snow > track luma kept; Powder reads on the track with its outline. `scripts/presentation/pop_effects.gd`: pooled (32) puff + ring in the broken layer's colour on `layer_broken`, sim time. Existing shells, special marker bands/letters (B/W/A/C) and roll reused. Web cost after a density cut: browser stress full mix 432k primitives, 1,007 draws, p95 6.8 ms (before dressing 357k / 969 / 5.1 ms; first cut 759k / 7.7 ms) (`dev12_stress_web.txt`).
- Batch B (`ccd7f4c`, `27bd116`): special-snowball introductions from round data (Black 20, White 22, Camo 24, Aurora 25); `match.start_round()` (Space, Start button, bots) opens the notice instead of spawning; one Continue/Space acknowledges and starts; echo and paused refused; once per match; a new match resets. Text matches current data (White: no current cold attack). Tests in `test_match`; round loops in tests acknowledge (transcripts unchanged). HUD: winter theme, notice panel, purchase floaters (-$ / refusal reason), phase wording, tower names only when selected/ghosted, selected card stacked under the shop.
- Batch C: 12/12 suites; release export 0 ERROR/WARNING; release excludes F3/F4 (debug-only, hint text stripped); ZIP `build/archive/claus_for_alarm_rc_web_d098ca5.zip` (33.7 MB, index.html at root) tested from an extracted copy (see 12.1 rows). Hosted itch page: no embed visible (not verified). Not done: hosted check, late-round browser playthrough to round 20+ (verified in editor/tests only), low-end/mobile, fresh-player test.

### 12.1.7 Dev 13 owner-requested visual overhaul - implemented locally (owner review pending)

Requested after reviewing Dev 12 screenshots. Implemented in Dev 13 (2026-11-15) with local evidence; **not visually approved by the owner** and not hosted. The suggested Christmas ski-lodge palette is the working proposal; the owner explicitly requested themed wood/snow/Christmas UI and the BTD6-style sidebar organization.

- [x] **V13-T01 - Composition checkpoint:** one actual gameplay capture with corrected terrain, dedicated sidebar and representative selected-tower view at 1280x720; inspect before propagating styling. **Evidence (Dev 13, local; owner visual acceptance open):** Checkpoint `dev13_checkpoint1_1280.png` (sidebar, cards, selected-tower view, terrain) inspected before propagating; before: `dev13_before_1280.png`.
- [x] **V13-T02 - Snow/lighting:** recover highlight detail; add subtle broad snow variation, fine grain/wind streaks and blue-gray shadow definition. Preserve Powder contrast; verify actual Web output. **Evidence (Dev 13, local; owner visual acceptance open):** Baked tileable `snow_detail.png` (broad patches, grain, wind streaks) in one world-mapped snow shader; sun 0.6 -> 0.32 warm, blue ambient 0.62; Web: `dev13_web_*.png`.
- [x] **V13-T03 - Organic course/rink:** textured groomed trail, softer irregular banks/corners and organic ice shoreline. Keep locked enemy route/placement/LOS; preserve logical BoxMesh blocker proxies and make blocked ground visually understandable. **Evidence (Dev 13, local; owner visual acceptance open):** Ribbon trail = logical capsule track (round outer joins radius hw about each waypoint, sharp inner), corduroy track shader darker than snow; irregular banks; organic ice + snow rim covering the hidden Pond BoxMesh; test_map PASS.
- [x] **V13-T04 - Dedicated right sidebar:** compact portrait-card shop; selected tower/upgrades in the sidebar; compact status and controls. Reserve playfield space and refit camera/input mapping. Verify whole route, picking, ticket hover and 800x600 layout. **Evidence (Dev 13, local; owner visual acceptance open):** 248-unit sidebar; `gameplay_camera.fit()` (orthographic size 46 at the base UI, h_offset) keeps picking/ghost/range/floaters exact; collect_cursor null over the sidebar; 1280x720 + 800x600 editor and Web captures.
- [x] **V13-T05 - Seven portraits:** capture actual current runtime models with consistent framing; torso-up characters and appropriate Cannon/Booth crops; static transparent PNGs reused in shop and selected view. Old Rookie retained. **Evidence (Dev 13, local; owner visual acceptance open):** `tests/tools/portrait_capture.gd` renders the 7 runtime tower scenes (old Rookie) into transparent 256 px PNGs `assets/ui/portraits/`, used in cards, details and the hero strip.
- [x] **V13-T06 - Whole UI theme:** cohesive main-menu controls, help/settings, HUD, upgrades/hero, pause, special notices, notifications, tooltips and results/restart. Preserve animated menu environment and website-only public credit placement. **Evidence (Dev 13, local; owner visual acceptance open):** `scripts/ui/lodge_theme.gd` + `lodge_frame.gd` shared by HUD, title, How, Settings, pause, notices, defeat/restart, tooltips, banner. Victory screen uses the same overlay (not captured).
- [x] **V13-T07 - Motion/cursor/feedback:** restrained hover/press/selection animation, purchase/refusal feedback, readable notifications and accurate high-contrast custom cursor; keep interactions immediate and respect reduced motion where available. **Evidence (Dev 13, local; owner visual acceptance open):** Hover lift/press compression (`LodgeTheme.juice`, off under prefers-reduced-motion in the browser), selected-card outline, cash squeeze on purchase, notice/overlay fade, 32 px cursor hotspot (1,1).
- [x] **V13-T08 - Per-tower Pops:** actual layers broken attributed by source tower ID, including splash/secondary/DoT/splits; immune hits/leaks do not count; upgrades retain count, restart/new tower reset. layer_broken magnitude is cash, not pop count. Add focused attribution tests. **Evidence (Dev 13, local; owner visual acceptance open):** `match._count_pop` counts `layer_broken` by source_id onto the placed tower (`tower.pops`); `tests/test_pops.gd` (direct, split children, explosion sub-attack, wax DoT, immune, leak, upgrade, new tower, cash unchanged). Web: Pops 63 / 53.
- [x] **V13-T09 - Integrated validation:** map/placement/notice tests, full regression suite, exported-browser interactions and late rounds, normal/small-window screenshots, bounded stress/loading comparison. No assumed low-end approval. **Evidence (Dev 13, local; owner visual acceptance open):** 13/13 suites; Web smoke (`dev13_web_smoke.txt`); stress full mix p95 5.70 ms, 445k primitives, 1,176 draws (Dev 12: 6.8 ms / 432k / 1,007) (`dev13_stress_web.txt`); first visit ~12.0 s. Not done: browser late rounds/notices, low-end.
- [x] **V13-T10 - Final candidate/handoff:** fresh commit-named ZIP tested from extraction; update stale PUBLISHING artifact entry; hosted verification, website attribution/media and submission confirmation remain separately tracked under P19/P20. **Evidence (Dev 13, local; owner visual acceptance open):** `claus_for_alarm_dev13_web_c10e144.zip` from a clean worktree, tested extracted; PUBLISHING updated. Hosted/website/submission remain P19/P20.

**Already delivered; preserve rather than rebuild**
- [x] Six regular tower kits plus hero and current presentation profiles.
- [x] Functional current Rookie; replacement deferred (DEC-046).
- [x] Larger 2.52 m hero choice recorded (DEC-045).
- [x] Animated winter main menu, corrected rink/lighting/orbit and source attribution records.
- [x] Dev 12 cosmetic map kit and pooled layer-break effect.
- [x] Special-wave notices at rounds 20/22/24/25, with acknowledgment/restart tests.
- [x] Dev 12 HUD functional improvements, release-debug stripping, local ZIP and browser smoke evidence.

**Release priority:** protect at least the final 90 minutes before the recorded 10:00 AM Eastern deadline for final QA/hosting/submission. Preserve the Dev 12 fallback ZIP. Deferrals (Rookie replacement, extra towers, new rigs, tiers 4-5 and pixelation) stay outside the required checklist. Do not check visual acceptance or public-host/submission items from automated local tests alone.

### 12.1.8 Temporary browser loading intro (owner request, 2026-11-15)

- [x] Prepared the Knit + Tin browser intro with knit/Fair Isle/hat/mascot/font assets and recorded asset hashes.
- [x] Adapted title to Claus for Alarm and moved the visual sequence into the Web loading shell: knitted logo reveal, needle motion, subtitle plate, hat drop and rolling-yarn download scarf.
- [x] Actual byte-progress display; engine/menu preparation status; overlay fades only after the title scene's first rendered frame. Owner follow-up: hold four seconds after menu/font readiness before fading so the title and hat reveal are visible even on cached loads; native/editor entry unchanged.
- [x] Web preset integration and reproducible self-contained HTML generator; included font licenses and asset documentation in CREDITS/source README.
- [x] Local exported Web check at 1280x720: loader -> village menu -> Play; 0 normal console errors. Simulated download failure presents retry at 800x600; reduced-motion animation disabled. Menu/UI tests pass; MCP process run exits0 with existing shutdown cleanup diagnostics.
- [ ] Include this updated shell in the final hosted export/ZIP and verify the published transition. Old archives do not update automatically.

Evidence: docs/logs/evidence/startup_*. Preview build: build/startup_preview, local server8162. Sources: art_src/ui/startup; generator art_src/tools/generate_startup_shell.py; template web/startup_shell.template.html. First-use rendering stalls are not fixed by this presentation change.

### 12.1.9 Menu Rookie and Play loading transition (owner request, 2026-11-15)

- [x] Remodeled AccuRIG Rookie prepared as a separate menu-only static GLB; floating bob, gentle turn and tilt in an isolated transparent viewport. Source FBX and old gameplay Rookie untouched; gameplay replacement/rig animation remain deferred.
- [x] Reuse the Knit + Tin browser overlay immediately on Play; load map resource, switch scene, wait for first rendered map frame, then fade. Preserve initial four-second splash hold; reused reveal has a 2.7-second minimum. Repeated Play presses guarded. Native Play has a simple title/status fallback.
- [x] Menu/UI suites pass; MCP process run has only previously recorded shutdown cleanup diagnostics. Chrome export: menu model visible, loading overlay -> map, zero console errors. Evidence: `menu_rookie_web.png`, `menu_map_loading_web.png`, `menu_map_ready_web.png`, `menu_showcase_checks.txt`.
- [ ] Owner visual review and final hosted export/upload. Existing Dev 13 archive does not include these menu/loading changes; preview is `build/startup_preview` on localhost:8162.

The loader covers first-use stalls; it does not eliminate them or guarantee continuous animation while the browser main thread is blocked. Menu-only change does not close P15-T09/G7 or authorize gameplay Rookie replacement.

### 12.1.10 Game-wide typography (owner request, 2026-11-15)

- [x] Reuse old-project Grenze Gotisch (700) for game title/subtitles/headings/announcements and New Rocker for main text, menu buttons, upgrades and hover descriptions.
- [x] Add old-project Barlow Medium as the readable third font for dense statistics, counters/prices, compact hints and world labels. Shared theme plus project default cover runtime-created controls; browser loading shell uses the same fonts.
- [x] Preserve provenance/OFL notices and website credit handoff. Menu/UI tests PASS; MCP process run retains existing shutdown cleanup diagnostic only. Chrome: menu, help at 800x600, loading screen, shop and upgrade tooltips, purchase, round announcement and pause checked, zero console errors. Evidence: `docs/logs/evidence/fonts_*.png`, `fonts_checks.txt`.
- [ ] Owner visual acceptance and fresh hosted export/upload. Local preview: localhost:8162 (`build/startup_preview`); previous ZIPs do not include this typography pass.

### 12.1.11 Presentation finish: vignette, powder, enlarged-view pixelation (owner request, 2026-11-15)

- [x] Universal subtle pixel pass implemented, Web-verified, then **removed by the owner (DEC-050)**; evidence of the tried version kept in `docs/logs/evidence/finish_*.png`.
- [x] Kept: autoload `ScreenFinish` (`scripts/presentation/screen_finish.gd` + `assets/materials/screen_finish.gdshader`), a plain alpha overlay on CanvasLayer 1100 (above game layers max 100 and the embedded-popup canvas 1024): `enabled`, `vignette_strength` 0.08, `snow_opacity` 0.60; mouse ignored; F8 toggles. `tests/test_screen_finish.gd` PASS.
- [x] Kept: stronger pixel finish on enlarged character views: menu Rookie at 1/3 resolution with nearest upscale, shop/upgrade/hero portraits via `assets/materials/portrait_pixel.gdshader` (32 blocks).
- [ ] Owner visual acceptance; no release ZIP or hosted upload includes this pass.

### 12.2 Session log template (append entries; do not rewrite history)

```md
#### SESSION YYYY-MM-DD HH:MM — [agent/model] — [phase / task IDs]
- **Goal:**
- **Read:** HYB-M §...; HYB-A §...; HYB-B §...; REF-M §... (if needed)
- **Repo branch / commit before:**
- **Files changed:**
- **Implementation:**
- **Tests run (actual commands):**
- **Editor/game result:**
- **Web result / browser/device:**
- **Screenshots/logs:**
- **Finished and checked tasks:**
- **Partial tasks / why:**
- **New gap/deviation IDs:**
- **Approved owner decisions:**
- **Known defects:**
- **Repo commit after:**
- **Next suggested 1–4 task IDs:**
```

### 12.3 Decision log (initial entries are proposals, not final approvals)

| Entry | Date | Decision | State | Reason / impacts |
|---|---|---|---|---|
| DEC-001 | 2026-11-13 | Six initial mapped towers + Camel Claus/Quincy; four later mapped families | APPROVED direction | HYB-M M-01/M-06; no excluded families |
| DEC-002 | 2026-11-13 | Mechanics-first with placeholders, art/Blender later | APPROVED direction | HYB-M M-01; HYB-B B-00 |
| DEC-003 | 2026-11-13 | Rolling color-layer snowballs, Powder→Blue→Mint→Violet→Coral and Gold in palette | APPROVED visual direction | Gold semantics still OPEN D-02 |
| DEC-004 | 2026-11-13 | Public title: **Claus for Alarm** | APPROVED | D-01 |
| DEC-005 | 2026-11-13 | Gold mechanics, demo length, precise release upgrade depth | PARTLY CLOSED | D-02 → DEC-018, D-03 → DEC-020; D-07 open |
| DEC-006 | 2026-11-13 | D-02 Gold = configurable special class, not 6th linear layer | SUPERSEDED by DEC-018 | |
| DEC-007 | 2026-11-13 | D-03 short labeled custom round set | SUPERSEDED by DEC-020 | |
| DEC-008 | 2026-11-13 | D-04 v56 Medium baseline prices/lives, configurable | PROPOSED | |
| DEC-009 | 2026-11-13 | D-05 one original ski-course route, 3–5 corners, fixed elevated camera | PROPOSED | Camera choice made in P03-T02 |
| DEC-010 | 2026-11-13 | D-06 winter names + overlays, separate mechanic flags | PROPOSED | |
| DEC-011 | 2026-11-13 | D-07 3×5 architecture, ship only verified tiers | PROPOSED | |
| DEC-012 | 2026-11-13 | D-08 per-field provenance, no "exact parity" claims | PROPOSED | |
| DEC-013 | 2026-11-13 | D-09 hero pose/weapon/costume | CLOSED by DEC-033 | Needed before P15/P16 |
| DEC-014 | 2026-11-13 | D-10 boss / giant snowmass | DEFERRED | Only if scripted + tested |
| DEC-015 | 2026-11-13 | D-11 studio website / host | REQUIRED by rules | Game on itch.io (HTML, single-threaded) + public studio website linking to it; 25/100 judging points (`docs/HACKATHON.md`) |
| DEC-016 | 2026-11-13 | D-12 original college-inspired look, no official marks | PROPOSED | |
| DEC-017 | 2026-11-13 | Basic layers are a strict 1:1 match with BTD6 for balance comparison: Powder=Red, Blue=Blue, Mint=Green, Violet=Yellow, Coral=Pink (same HP, speed, children, cash) | APPROVED (owner) | Supersedes DEC-003's Gold-in-palette part; P05-T01 |
| DEC-018 | 2026-11-13 | D-02: no Gold snowball for now; not needed for the count | APPROVED (owner) | Replaces DEC-006; P05-T11 DEFERRED |
| DEC-019 | 2026-11-13 | Special snowballs mirror BTD6 specials and are DEFERRED until the game is functional and most towers + art are in. Provisional names: Black (=Black, explosion-immune), Rainbow (=Rainbow, same role/children), Stone (=Ceramic), Metal (=Lead, sharp-immune), camo variants (=Camo). Schema keeps the property flags; no types, waves or visuals now | APPROVED (owner) | `docs/REGISTRY.md`; P05-T05/T08/T13 (specials), P11-T01–T03/T06/T08/T11 DEFERRED |
| DEC-020 | 2026-11-13 | D-03: rounds = exact BTD6 v56 rounds 1–16 (every round whose groups are only the 5 basic layers; round 17 needs Regrow Yellow), then 3 custom finale rounds 17–19 (ORIGINAL_DEVIATION, basic layers only, dense/fast). Win = survive round 19. Target ~10–12 min at 1× | SUPERSEDED by DEC-025 | Replaces DEC-007; measured ~9.9 min sim + 5 s/round prepare (`docs/logs/evidence/p07_full_run.txt`), so no BTD6 round was cut |
| DEC-021 | 2026-11-13 | D-04: Medium starting lives 150 | APPROVED (owner) | `rules_medium.tres` start_lives |
| DEC-022 | 2026-11-13 | Delete `scenes/main/smoke_test.*` (history in tag `p01-web-smoke`) | APPROVED (owner), done | |
| DEC-023 | 2026-11-14 | Ski Resort Ticket Booth (= Banana Farm) economy is an ORIGINAL_DEVIATION for the 19-round match: ticket value $20 → $50 (price stays $1,250), Valuable Bananas +25% → +50%, Monkey Bank ticket value scaled the same way ($112). Target: base Booth pays back in ~5–7 rounds, upgrades before the finale; a sensible investment, not a trap and not a must-buy | APPROVED (owner), done | Base payback 6.25 rounds, Increased/Greater Production 5/6 rounds; economy bot nets +$1,250 on a round-10 Booth 2-0-0 and still wins (128 lives vs 143 Rookie-only) — `docs/logs/evidence/p10_full_run.txt` |
| DEC-024 | 2026-11-14 | Upgrade tiers whose source page has no numbers ship with a best-guess filler between their neighbours (same stat types, sensible step, source price), labelled PROTOTYPE_ASSUMPTION with a one-line rationale. Tiers 1–3 purchasable on all paths of all six towers; tiers 4–5 stay "coming soon" | APPROVED (owner), done | 54/90 tiers shipped, 9 of them fillers/deviations (`docs/logs/evidence/p10_upgrade_coverage.txt`); unblocks Arcane Blast/Mastery, Dragon's Breath, all Booth/Wax tier 3s |
| DEC-025 | 2026-11-14 | **Demo win = survive round 25.** Rounds 1–25 are the exact BTD6 rounds 1–25 (supersedes DEC-020's 16 + custom finale). Special types that appear in source rounds 17–25 get their mechanics now (placeholder visuals) | APPROVED (owner) | Supersedes DEC-019 deferral only for types needed by rounds ≤25 |
| DEC-026 | 2026-11-14 | **Standing round rule:** every game round = its BTD6 round, 1:1 — same groups, counts, spawn timing and types, with each bloon type replaced by its snowball counterpart (e.g. round 63's ceramic rush exists as the Stone rush). No custom/rebalanced rounds | APPROVED (owner) | Applies to all current and future rounds incl. Endless |
| DEC-027 | 2026-11-14 | **Endless mode ("Continue", like BTD6 freeplay-continue):** after winning round 25 the player may continue, hard cap round 80 (final boss round; stops before DDTs at 90). Source milestones: MOAB r40, BFB r60, ZOMG r80. Rounds 26–80 also follow DEC-026 | APPROVED (owner), DEFERRED | Build after the core game + most towers/art are in |
| DEC-028 | 2026-11-14 | **Blimp-class look (MOAB/BFB/ZOMG):** ice sleds carrying blocks of ice; damage shows as the ice cracking/melting/chipping away; on death the sled tips over and despawns smoothly | APPROVED art direction, DEFERRED | Ships with DEC-027 |
| DEC-029 | 2026-11-14 | Game speeds 1× / 2× / **4×** (ORIGINAL_DEVIATION; BTD6 is 1×/fast) | APPROVED (owner) | Speed only makes the simulation run faster: every round looks and resolves identically at 1×/2×/4× (same spawns, hits, pops, cash, outcomes) |
| DEC-030 | 2026-11-14 | **Full upgrade depth for Endless:** every tier 1–5 on all three paths of all six towers (incl. abilities, e.g. Supply Drop) and Camel Claus levels 6–20 (Blizzard Barrage etc.) get fully implemented, even if a normal 25-round demo never reaches them, because Continue runs to round 80. Missing source numbers use DEC-024 fillers | APPROVED (owner), DEFERRED | Do after the 25-round demo is solid; ships with DEC-027 Endless |
| DEC-031 | 2026-11-14 | **No Regrow snowballs (backburner).** Source rounds with Regrow bloons keep the exact same groups, counts and timing, but spawn the plain snowball type without the regrow property (e.g. round 17's 12 Regrow Yellow → 12 Violet). Logged as a deliberate deviation from DEC-026 | APPROVED (owner) | Regrow may be added far later; see REGISTRY backburner |
| DEC-032 | 2026-11-14 | **Art scope: everything polished** — hero, all six towers (+ upgrade looks for shipped tiers), snowballs, map and UI aim for HYB-B quality; nothing ships as a primitive collage | APPROVED (owner) | Order: style slice → map + snowballs → hero → towers → upgrade looks; owner approves each slice |
| DEC-033 | 2026-11-14 | **D-09 Camel Claus = bipedal mascot**, upright, two-handed ski-pole launcher | APPROVED (owner) | Closes D-09 (was DEC-013 DEFERRED) |
| DEC-034 | 2026-11-14 | **Tower characters = chibi elves** (not chibi humans): same chibi athlete base form, but elf traits (e.g. ears, proportions, festive trims). Elves differ visibly per tower in size, build, outfit and look, and each tower's look evolves as upgrades are bought (tier 1–2 accessories, tier 3 path identity per HYB-B B-05/A-04) | APPROVED (owner) | Overrides HYB-A A-03 "generic athletes" naming; mechanics unchanged |
| DEC-035 | 2026-11-14 | **Audio = AI-generated music + code-synthesized SFX** for now; owner may later swap some for CC0/free downloads. Keep a provenance/credits ledger per file | APPROVED (owner) | HYB-A A-10 mixing/bus rules still apply |
| DEC-037 | 2026-11-14 | **Audio = licensed Willosuna packs** (SFX + music, one author for a consistent warm-cartoony festive style); replaces DEC-035's code-synth SFX (owner: sounded retro/generated) and AI music. Owner chose to commit the processed files to the public repo despite the license's "don't share the files as a pack" clause | APPROVED (owner) | Pixabay unreachable for automation (Cloudflare); Mixkit license unclear for games; Kenney CC0 and Silverman Sound (CC BY) kept as alternates, not shipped |
| DEC-038 | 2026-11-14 | **Audio mix v2 (owner listening):** gameplay music → 168 BPM sleigh-chase loop for all rounds; new **Towers** bus + Settings slider for tower attack + snowball-hit sounds, all +5 dB (≈40% louder) with the slider defaulting to 50% (= 0 dB, headroom to +6 dB); **ambience** bed under the music (wind always; winter-market crowd in matches, crossfading to its intense twin at round 16) on an Ambience bus + slider; heavy shells get 5 variants (snowball hit + 4 ice breaks) | APPROVED (owner) | Renumbered the earlier audio decision to DEC-037 (DEC-036 was already used by the P15 art review; commit `6a2370f` message says DEC-036) |
| DEC-036 | 2026-11-14 | **P15 style slice review:** overall look APPROVED (Lodge, snowballs, elf direction). (A) elf towers + hero shown at **1.5× display scale** (footprint/range unchanged). (B) skin rosier with cheek blush, dark timber and stone darker; tokens added to `ART_STYLE.md` incl. Black/White/Aurora shells. (C) Rookie base look = overhand hand-throw + snowball satchel, no sling (sling/launcher = top-path upgrade look, B-05.1). (D) "Purple" snowball renamed **Aurora** (letter A); internal id `purple` stays frozen (STABLE_IDS). (E) Blender MCP add-on updated (2.0, protocol 16) | APPROVED (owner) | Rookie revise pass to the B-14 gate follows |
| DEC-040 | 2026-11-14 | **Cannon proof presentation choices (P15-A02/A03):** displayed size set by the footprint (envelope 0.66 m vs 0.6 m footprint → 0.93 m tall, about half the Rookie's height); muzzle puff warm gold `#F9C96D` instead of snow white (white was invisible on snow); AnimationPlayer clips advance in simulation time (Rookie idle pauses and speeds with the game; ghost Rookie static); runtime maps 1024² PNG | PARTLY APPROVED (owner, Dev 9 prompt): sim-time animation (pause + 1×/2×/4×), still placement ghosts and the gold muzzle flash ACCEPTED; Cannon size KEPT PROVISIONALLY (no further 8% shrink for the ~1 px track overlap); final size/readability approval OPEN until a coherent roster is compared at the normal gameplay camera | Presentation only; no stats, footprints, timing or placement changed (`p15a_tests.txt`). Alternatives if rejected: a larger Cannon accepting more track overlap, or a snow-tinted puff with an outline |
| DEC-041 | 2026-11-14 | **Ranger / Wax Sprayer presentation (P15-A06/A07):** characters fitted by height 1.2 m modelled (1.8 m shown, like the Rookie), not by footprint; the Ranger's rifle therefore reaches 1.0 m from the centre (footprint 0.6 m): 0.39 m past the track edge and up to 0.39 m into a touching neighbour's footprint; Wax tank pack 0.71 m; the weapon (not the body) faces the shot (`weapon_yaw_deg`, Ranger 60°); Ranger recoil 4 cm + 4° muzzle climb with a small gold flash (A-04 'minimal flash'); Wax pump/lean with a dark spruce nozzle puff matching the shot blob; browser stress via a separate 'Web Stress' preset (feature-tagged main scene), release build unchanged | PARTLY APPROVED (owner): keep Ranger at current size and accept rifle reach; do not shrink or change footprint. Other visual review items remain open. | Presentation only; no stats, footprints, ranges, timing or placement changed (`p15c_tests.txt`). Alternatives: a smaller Ranger (envelope fit ≈ 0.8 m modelled / 1.2 m shown, inconsistent with the Rookie), or keep the size and accept the reach; a wax-tinted puff instead of spruce |
| DEC-039 | 2026-11-14 | **Elf base redesign from owner-generated references** (`references/characters/christmas_elf_v1/`, chosen TOP ROW body + warm neutral head): blonde forelock and side tufts, big green eyes with lashes, small red button nose, closed smile, rounded knit beanie with fur band and pompom (no drooping tip), horizontal-quilt navy jacket with fur collar/cuffs, brown belt with gold buckle, gold zipper, teal trousers, brown curled-toe boots, bare hands. Face = **mix of sculpted geometry and painted texture detail** (not texture-only, not over-detailed). Work in **two reviews**: (1) whole-model overhaul, (2) re-rig last (clavicles, raised-arm rest, clean shoulder weights; keep bone names, B-11 sockets, idle_loop/attack). Hand-built in Blender scripts, no AI mesh generation (keeps one shared, rig-reusable elf base) | APPROVED (owner); review 1 delivered 2026-11-14 | Supersedes the current Rookie face/cap/mitten look in `ART_STYLE.md` once review 1 is approved (sheet also drops the DEC-036 satchel); new tokens hair `#F2BC3B`, nose `#E8574A`, iris `#4FA83A` (`cc_art.PAL`); images are concept guides, not calibrated blueprints. Deviation: `--main-pack` exit-time "resources still in use" count 2 → 8 (benign cleanup-order line, now includes the eye texture) |
| DEC-042 | 2026-11-14 | **Ticket Booth base purchase price = $750**, replacing $1,250 by explicit owner direction. Preserve existing income amounts, upgrade prices and footprint unless separately authorized. Mark base price ORIGINAL_DEVIATION; update price-dependent tests, documentation and sellback expectations. | APPROVED (owner); IMPLEMENTED Dev 10 batch B (`13dadad`, `_test_booth_price`, `p15d_tests_gameplay.txt`) | A deliberate gameplay/balance change, not part of visual-only parity. Base income remains 4 x $50 per round: nominal 3.75 full production rounds to recover base purchase cost if fully collected, excluding timing and upgrades. |
| DEC-043 | 2026-11-14 | **Ticket money collects automatically when the cursor is near a dropped pickup**, without requiring a click. Preserve click collection, once-only ledger credit, expiry rules, Bank and Marketplace semantics. | APPROVED (owner) behavior; IMPLEMENTED Dev 10 batch B (`13dadad`: `hover_collect_radius_m` 1.0, tick-ordered explicit input, `_test_ticket_hover`, `p15d_web_hover.txt`); exact radius is an implementation default, not an owner-selected value | Recommended starting radius: configurable 1.0 m in world XZ, using cursor-to-ground projection. Process collection as explicit gameplay input, not VFX. Check stationary cursor/new drops and multiple pickups; suppress proximity collection while paused, over UI, outside viewport or after match end. Test preparation/between-round collection explicitly. |
| DEC-044 | 2026-11-14 | **Sorcerer / Booth presentation (P15-A09/A10):** Sorcerer fitted by height 1.0 m modelled (1.5 m shown, compact: 80% of the Rookie), staff-head cast pulse (6% stretch, 4° lean) with an icy `#8FD8E8` puff; Booth fitted to its 1.5 m footprint (2.42 m tall), stationary, 4% bounce + gold window puff on every income event; ticket visuals drawn without depth test so tickets behind the building stay visible (positions unchanged) | APPROVED (owner, Dev 11 prompt) with the taller option: Sorcerer 1.13 m modelled = 1.70 m shown (P15-A15, `535b958`); Booth presentation as proposed | Presentation only; batch A gameplay transcripts identical (`p15d_tests_visual.txt`). Alternatives: a taller Sorcerer (1.15 m modelled, 1.7 m shown) for a stronger staff read; moving ticket spawn positions to the camera side (a gameplay-data change, not made) |
| DEC-045 | 2026-11-15 | **Camel Claus presentation (P15-A13/A14):** 1.68 m modelled = 2.52 m shown (41 px vs 27–30 px for elves at the game camera); envelope 0.885 m shown: 0.225 m past the track edge, 0.245 m into touching neighbours at the nearest legal spot (Ranger rifle 0.39 m accepted); cues: wind-up, recoil + gold puff, Frenzy elastic recoil + red ring, Focus lean + cyan reticle + goggle glow, level-up hat glint + gold ring; supplied launcher is a crossbow, used as supplied | SIZE APPROVED (owner, 2026-11-15): use the larger current 2.52 m hero, not the 2.25 m hero150 comparison. Cues remain as delivered; no new explicit cue-quality sign-off. | Presentation only; footprint, timing, ricochet, projectile counts, XP unchanged (`p15e_tests_visual.txt`). Alternative: 1.5 m modelled (2.25 m shown, `*_hero150*`) |
| DEC-046 | 2026-11-15 | **Skip selected Rookie replacement for the hackathon:** retain functional assets/models/elf_rookie.glb and its current animations. Preserve the AccuRIG FBX as a future source, but do not prepare, pose, re-rig, create clips or replace the runtime model now. Start next work with map/snowballs, then essential UX. | APPROVED (owner) | Submission scope reduction; no runtime change required, no blanket P15-T09/G7 sign-off. Supersedes earlier Rookie-first handoffs. |
| DEC-047 | 2026-11-15 | **Dev 13 presentation (owner prompt):** "Christmas ski lodge" UI (dark timber frames, navy/spruce panels, cream text, festive-red primary, gold highlights, restrained snow caps/garland on major frames), BTD6-style full-height right sidebar with portrait cards, per-tower Pops (= layer_broken by source tower). Implemented as shared code theme (`LodgeTheme`/`LodgeFrame`). Kept owner zoom 46 at the base UI. Combat/economy/waves/route/placement unchanged. | OWNER DIRECTION (implemented; visual review pending) | Presentation only; Dev 12 ZIP kept as fallback |
| DEC-048 | 2026-11-15 | **Dev 13 upgrade/VFX audit (owner prompt):** all 54 tier 1-3 upgrades verified to change stats (`tests/test_audit.gd`). Hot Cocoa Barrier (BTD6 Wall of Fire) now leaves a 1.2 m fire zone at the target for 4.5 s, hitting up to 10 snowballs every 0.2 s (`AttackDefinition.zone_*`). Substitutes where the BTD6 effect needs content we do not have (no MOAB-class snowballs, no camo-reveal system): Big-Game Breaker (MOAB Mauler) +1 blast damage; Giant Snowball Wax (MOAB Glue) +3 base / +2 splatter pierce; Goggle Shimmer (Shimmer) 25% faster attacks. Per-damage-family projectiles/impacts, Ranger tracers, special snowball shells instead of letters, pop shards instead of the hit "*". Tiers 4-5 stay deferred. | OWNER DIRECTION (implemented; balance review pending) | Zone tick/radius/duration and substitute values are PROTOTYPE_ASSUMPTION |
| DEC-049 | 2026-11-15 | **Presentation finish (owner prompt):** whole composed screen gets a subtle pixel pass (3 base-UI px cells, 30% blend; owner asked for "noticeable, just barely" after 2 px/15% read as invisible), faint vignette 0.08 and static powder in the bottom corners, text included (no masking). Enlarged character views get a stronger finish (menu Rookie 1/3-res render, portraits 32 blocks). Toggle F8. Supersedes the ART_STYLE section 9 "do not implement pixelation yet" deferral. | Owner |
| DEC-050 | 2026-11-15 | **Universal pixel pass removed (owner):** after review the owner rejected screen-wide pixelation. `ScreenFinish` keeps only the faint vignette and bottom-corner powder as an alpha overlay (no screen read); enlarged-view pixelation (menu Rookie, portraits) stays. | Owner |
| DEC-051 | 2026-11-15 | **Ambient snow (owner prompt, P17-T07 slice):** gentle snowfall over the whole course plus an occasional spiral gust (a corkscrew ribbon of flakes crossing the map, 4.5 s, every 6-13 s). Cosmetic, real time (falls while paused, ignores 2x/4x), unseeded RNG, never touches the simulation; flakes small, translucent, cool-rimmed so they read on snow without resembling snowballs. Reduced motion: half the flakes, slower, no gusts. Shader-animated (2 draw calls, no per-frame CPU per flake). | Owner | Counts/sizes/interval are PROTOTYPE_ASSUMPTION; FX Low/High setting (P17-T12) not added |

### 12.4 Risk register and responses

| Risk ID | Probability / impact | Early warning | Response / owner decision |
|---|---|---|---|
| R-01 Source-data gaps | High / High | Inability to validate a purchased tier's attack/crosspath | Flag GAP, implement only verified tier, defer late paths; never invent parity |
| R-02 Scope exceeds jam | High / High | No playable loop while multiple art assets underway | Protect S0/G3/G6; cut content not architecture; postpone full tier art |
| R-03 Web export/host | Medium / Critical | Editor works but browser fails | P01 smoke test, host test every gate, preserve last known-good zip |
| R-04 AI-generated primitive models | High / High | Pretty render but bad silhouette/joins | HYB-B B-14 clay/silhouette and multi-view rejection; revise geometry |
| R-05 Sim/art coupling | Medium / High | Moving map assets alters hit ranges or enemies | Stable IDs/coordinates; presentation-only swaps; regression snapshots |
| R-06 Inaccurate copied balance | High / High | v56 tables misdescribed as latest game | Provenance per field; source version overlay; no “exact” label without evidence |
| R-07 Framerate collapse | Medium / High | FPS degrades with many split snowballs | Pooling, LOD, batching, VFX limits; preserve sim correctness |
| R-08 Poor first-time UX | Medium / High | Testers cannot find start/place/upgrade | P13 fresh-player test; clear legend/feedback, tutorial |
| R-09 Lost work / AI drift | Medium / High | Uncommitted changes, silent spec rewrites | Batch tasks, Git checkpoints, session logs, doc hierarchy |
| R-10 IP / originality | Medium / High | Source characters/meshes/audio copied too literally | Original assets, credited licensed sources, distinctive design review |
| R-11 Hero XP/pacing mismatch | High / Medium | Lv10 never appears in short demo | Label custom pacing or communicate inaccessible milestones; no fake BTD6 fidelity |
| R-12 Site/submission dependencies | Medium / High | Last-minute host/website problems | Verify organizer requirement P00, site skeleton early if required |

### 12.5 Change request protocol

When owner wants to modify a tower, enemy, upgrade, map, art direction or scope:

1. Create `CR-###` with **what**, **why**, **hybrid MD sections affected**, **source-vs-original classification**, **tasks touched**, **test changes** and **release deadline impact**.
2. If numeric: update `HYB-M`, balance data/overlays, targeted scenario tests and status; revisit geometry if range/path changed.
3. If art-only: update `HYB-A` and/or `HYB-B`; keep numeric data untouched; rerun Web readability/performance and asset swap tests.
4. If asset-model change affects placement, socket or collision: require both engineering and creative approval and refresh old alpha tests.
5. Update this master plan tasks, milestone status, decision log and change log. Changes cannot silently reclassify `DEFERRED` as `COMPLETE`.
6. Release candidate changes should be small and risk-assessed; back out a regression instead of attempting uncontrolled last-minute redesign.

### 12.6 Plan revision history

| Revision | Date | Author | Summary |
|---|---|---|---|
| v1.0 | 2026-11-13 | ChatGPT | Initial cross-referenced full master plan. No code run or game scene modified. |
| v1.1 | 2026-11-14 | Opus 5.5 | P05/P06 leftovers ticked with P08 evidence; P08–P09 ticked; G4 ✅; status table refreshed. |
| v1.2 | 2026-11-14 | Opus 5.5 | Dev 9: P15-A05–A08 (Cannon proof checks, Ranger + Wax integration), DEC-040 owner choices, DEC-041 proposed, 12.1/12.1.1 updated. |
| v1.3 | 2026-11-14 | Opus 5.5 | Dev 10: P15-A09–A12 (Sorcerer + Booth visual; Booth $750 and hover collection), DEC-042/043 implemented, DEC-044 proposed, 12.1/12.1.1 updated. |
| v1.4 | 2026-11-15 | Opus 5.5 | Dev 11: observations batch committed as found; P15-A13–A16, DEC-044 approved, DEC-045 proposed, 12.1/12.1.3 updated. |
| v1.5 | 2026-11-15 | Opus 5.5 | Dev 12: course dressing, break puffs, special-wave notices, HUD skin/layout, RC package; 12.1/12.1.6 updated. |

---

## 13. Definition of done and final submission checklist

**The event build is DONE only when all applicable boxes are checked (nonapplicable optional items must be explicitly marked N/A with justification, not silently checked).**

- [ ] **SHIP-T01** — Game launched and finished on an independently accessed hosted browser URL.
- [ ] **SHIP-T02** — Winter Sports visual theme is instantly recognizable: sports-themed towers, ski course, winter equipment and Camel Claus mascot.
- [ ] **SHIP-T03** — Main mechanic—color-layered rolling snowballs—accurately downgrades and visibly communicates current layer and important resistances.
- [ ] **SHIP-T04** — At least source-verified or clearly labeled implemented initial tower subset is purchasable; unsupported/unverified upgrades not represented as finished.
- [ ] **SHIP-T05** — Core mechanics (placement, target rules, damage, economy, waves, hero if included, lives, pause, win, lose, restart) work from a clean start.
- [ ] **SHIP-T06** — Economy is coherent with selected round set, and a non-developer player can win by at least two tested builds.
- [ ] **SHIP-T07** — Actual implemented hero levels/abilities work correctly and are not misrepresented as a full 20-level completed mode if unreachable.
- [ ] **SHIP-T08** — No high-severity crash, duplicate cash, impossible round, missing browser asset or input blocker on supported browsers.
- [ ] **SHIP-T09** — Final models have professional form continuity and silhouette readability, or remaining temporary elements are consciously scoped and visually coherent.
- [ ] **SHIP-T10** — Audio/music is original or properly licensed, controllable and browser-unlocked; mute does not remove critical game information.
- [ ] **SHIP-T11** — UI displays valid placement, affordability, tower stats, upgrade locks, lives, money, wave status and results reliably.
- [ ] **SHIP-T12** — Final release test logs, screenshots, Git hash, Web bundle and host URL archived.
- [ ] **SHIP-T13** — Public description and credit/licensing statements accurate; no suggestion of official BTD6/Ninja Kiwi affiliation.
- [ ] **SHIP-T14** — All organizer-required deliverables including studio website (if mandated) and submission fields verified and submitted.
- [ ] **SHIP-T15** — A stranger can understand the goal and start playing quickly with no developer instruction or special installation.

### Final owner review signoff

- **Release scope actually shipped:** `S0 / S1 / S2 / S3` (circle/annotate)
- **Declared original balance deviations:** `[link to log]`
- **Known accepted limitations:** `[list]`
- **Web build URL and submission receipt:** `[links]`
- **QA evidence folder:** `[path]`
- **Creative director approval:** `PENDING`

---

## 14. External technical references and provenance

The below are live documentation links to verify with the actual installed tool version before execution. They supplement—but do not replace—the attached hybrid and research references.

- **Godot official — Web exporting:** https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html . Web exports need WebAssembly/WebGL 2.0 and Compatibility renderer. Godot 4's C# path is not supported for the Web as documented; GDScript is the intended path. The single-threaded export is generally the preferred/default path for broad web hosts. Some host or browser configurations have different security/header requirements when threads are enabled; test real deployment.
- **Godot official — 3D asset formats:** https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/available_formats.html . glTF 2.0 / GLB is recommended; `.blend` automatic import is available with Blender installed but does not replace verifying the actual shipped GLB.
- **Primary source of design provenance:** `HYB-M M-14`, `HYB-A A-14`, `HYB-B B-18`, plus BTD6 reference volumes in `references/research/`. These cite current/older BTD6 sources and label uncertain or v56-derived numbers.
- **Web game audio/platform note:** Browser audio permission can require user interaction; accept a UI click to unlock gameplay audio and document test outcomes. Do not treat a successfully imported sound as a browser playback test.

---

**MASTER PLAN CLOSING CONTRACT:** The plan's job is to keep an AI-driven project **small, safe, source-aware, testable and maintainable**, not to substitute vague plans for code or to call unfinished features complete. On the first real coding session, authorize **P00 only**, verify the actual workspace, then move deliberately through **P01 Web smoke → P02–P14 mechanics and placeholder technical alpha → P15–P18 art/model/UI/audio polish → P19–P20 hosted release and submission**. The full-depth mapped BTD6 upgrades and four expansion tower families remain documented future work rather than a silent hackathon promise.

