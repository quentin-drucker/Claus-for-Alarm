> Public planning snapshot. This is a development document, not a feature list. Deferred ideas and historical decisions are preserved; repository-relative references refer to the source project.

# Camel Claus — Hybrid Art Direction, UI/UX, VFX & Audio Specification

**Edition:** H0 — awaiting creative review, November 13, 2026. **Purpose:** the project-specific visual/presentation design authority, not a BTD6 asset-reuse guide and not authorization to start building assets.  
**Companions:** `01_Camel_Claus_Hybrid_Gameplay_and_Balance.md` (meaning of mechanics) and `03_Camel_Claus_Hybrid_3D_Assets_Blender.md` (mesh construction and Blender handoff).  
**Primary research:** `BTD6_Art_Audio_Visuals_and_UX.md` and `BTD6_3D_Asset_Modeling_and_Blender_Production_Reference.md` (uploaded November 13, 2026).

> **Creative thesis [LOCKED/PROPOSED]:** *A charming miniature winter-games festival at a snowy, fictionalized Connecticut College. Camel Claus—the single camel hero—leads a cast of toy-like humanoid winter athletes and sporting machines against magical rolling colored snowballs. The scene is festive and legible like a polished cartoon tower defense game, but its silhouettes, colors, environment layout, icons, models, soundtrack and interface are wholly original.* The goal is **professional, smooth, intentionally modeled geometry and expressive interaction**, not rough primitives in a game engine.

## A-00. Reading labels and creative locks

- `[LOCKED]`: user's explicit preference. `[PROPOSED]`: an option for review. `[REFERENCE]`: a BTD6 observation or link, not a model or layout to copy. `[QA]`: a measurable approval check.
- Studio/team: Camel Claus; game title **Claus for Alarm**. Do **not** silently rename the studio, player hero or game.
- Mandatory themes: winter sports **and** festive/Christmas atmosphere, with an intentional Connecticut College/camel connection; not merely blue snow and Santa hats on unrelated characters.
- Defending towers: fantasy toy-like humanoid athletes or machines, **not a camel clone for every role**; the camel is exclusively the special hero.
- Snowball opponents: expressive rolling snowballs whose color shell reveals layer depth; outer layer changes on damage. Basic palette: Powder → Blue → Mint → Violet → Coral, and Gold as a striking sixth visual class whose *mechanical status is awaiting approval*. Special properties have additional patterns/shapes. Read `01...md/M-03` before making Gold a generic six-hit enemy.
- Initial unit art roster: Snowball Rookie, Avalanche Cannon, Biathlon Ranger, Slope Wax Sprayer, Snow Sorcerer, Ski Resort Ticket Booth, Camel Claus. Planned future art: Hockey Slapper, Snowboard Trickster. DEFERRED beyond the hackathon: Winter Games Lodge and Track Gritter; retain existing concepts for a possible expansion, with no further production until re-authorized. No art batches for excluded towers (Dartling, Ace, Engineer, Ice, Tack, Alchemist equivalents).
- **Visual target:** appealing stylized cartoon sophistication, smoothly integrated characters and objects, higher production quality in close inspection than simple intersecting spheres/cylinders; controlled planar stylization is okay where intentional. See modeling file for hard rejection rules.

## A-01. Visual identity and contrast hierarchy

### Design keywords

**Snowy / athletic / warm / playful / precise / collectible / toy-diorama / festival / expressive / readable / original / premium-stylized.** Avoid realism, horror, grunge, arbitrary generic AI 'low poly', and the appearance of an assembled primitive kit. At the battlefield camera the map must communicate the enemy **path first**, then unique threats, then defender locations, then detailed decoration.

### Shapes

| Layer | Dominant shapes | Why |
|---|---|---|
| Hero Camel Claus | proud S-curved neck, rounded muzzle integrated into cheeks, two humps if art-directed as a Bactrian stylization (not mandatory), expressive brows, festive ski-pole launcher | recognizable mascot at 1/4 camera scale |
| Athlete towers | large soft heads and winter hats, low center of gravity, short limbs, hand-sized iconic sports props | shared skeleton, readability and economy of modeling |
| Mechanical towers | strong single-purpose silhouettes: cannon tube, kiosk roof, track gritter hopper, ski-lodge roofline | immediate function without close reading |
| Snowball enemies | mostly spherical but deliberately sculpted snow/ice shell contour, colored skin, rotating patterns, high-value specialty attachments | layer state legibility at speed |
| Terrain | long broad snow shapes, planted pine silhouettes, skating pond, recognizable ski slope and chalet outlines | distinct map framing without clutter |
| HUD | large rounded rectangles/pucks, wooden-lodge-inspired framing and restrained colored highlights | quick decisions in a fast moving game |

Three-stage appearance readability: **far** (path, major tower, large threat), **normal** (role, shell color, gear), **close** (face, mesh quality, knit/metal/ice variation). An expensive render that fails 320×180 legibility is an art failure.

### Proposed semantic palette (original design tokens; review/adjust after screenshots)

| Token | Proposed HEX | Use and contrast role |
|---|---|---|
| Snow base | `#E7F4F8` | calm terrain; distinct from Powder enemy via shadow and outlines |
| Shadow snow | `#AFC7D5` | creases, drift form, footsteps |
| Glacier ice | `#8FD8E8` | terrain ice and placement hint; distinct from Blue snowball |
| Forest teal | `#1B6D68` | evergreen and outlines; grounded visual mass |
| Midnight spruce | `#173C4E` | high-contrast HUD text and dark trim |
| College-style navy | `#20517A` | player team emphasis; avoid claiming an official brand color |
| Festive red | `#D9545C` | scarves, cabins, warm interactive details |
| Warm gold | `#F9C96D` | income/economy and special snowball gold *with different shapes* |
| Cabin timber | `#A8795A` | warm wood detailing in environment/menus |
| Accessible alert | `#C73E49` | invalid placement, life loss, unaffordable; add symbol/shape cue |
| Success green | `#3F9B7B` | valid placement and purchase state with icon redundancy |
| Primary text | `#173548` | large, readable labels on pale cards |
| Overlay shade | `#132A3ACC` | panel backing against busy playfield |

**Layer-specific enemy swatches** (not to be confused with UI semantic colors): Powder `#DBE9F5`; Blue `#72CEF5`; Mint `#4ACAAA`; Violet `#BD8DF1`; Coral `#F59471`; Gold `#F6CF65`. Use a thin dark/neutral contour and distinct highlight texture on **Powder** so it does not vanish into snow terrain. Gold additionally needs raised ridges or emblem to distinguish it from a gold resource pickup. Test under color blindness simulation and grayscale.

### Materials

Use high-value **stylized material families**: brushed powder snow; clear translucent ice accents; knit/wool scarves with shape-level folds; padded waterproof sports gear; glossy-but-not-mirror ski equipment; warm painted lodge wood; slightly rough molded plastic machine casings; warm festive lights. Geometry should carry the large-scale forms; textures should not disguise an unmodeled head or coat. Favor roughness/specular control and accessible readability over photoreal noisy microtextures. BTD6's camera and color hierarchy are [REFERENCE], not a mandate to reproduce its brown UI borders or precise colors.

## A-02. BTD6 winter map case studies and original map layout

**Real BTD6 references:** [Alpine Run](https://teemo.dev/game-design/bloons-td-6/wiki/maps/alpine-run/) is snowy and uses ski-resort motifs; [Skates](https://teemo.dev/game-design/bloons-td-6/wiki/maps/skates/) combines snowy outer land, frozen pond, looping movement and interactables; [One Two Tree](https://teemo.dev/game-design/bloons-td-6/wiki/maps/one-two-tree/) uses a decorated Christmas-feeling composition and distinctive placement reveals. All source links are *layout-communication references*; DO NOT copy routes, obstacles, camera crops, holiday decorations, icons or proprietary map pieces. The v56 extracted page says approximate track occupancy of 22–23% for these maps; not a law for the new map.

**Original candidate: `Conn Winter Games — Ski Circuit` [PROPOSED].** A miniature snow-covered festival surrounded by pines and campus-inspired architecture (originalized rather than a trace of an existing campus map). One entry starting gate sits upper-left; a winding, visually unmistakable **ski-course ribbon** snakes past a curling rink, dips around the central winter-games lodge, continues past a frozen pond and exits through the far finish gate. Competitors or skiers on a **background ski lift** move slowly outside firing lines. Snowball invaders roll downhill as if escaping a magical snowstorm.

### Map composition design contract

1. **Path geometry first:** validate gameplay turning radius, tower-line intersections, effective tower range, waypoint path correctness, sell/rebuild positions, and enough viable placement surface. Path should be a continuous graphic object with visible berm edges, icy sled marks, low ski-course poles, and start/finish gates.
2. **No confusing terrain overlap:** Powder snowballs need a darker under-shadow and thin shell border; path surface should be warmer/darker bluish-gray than snowball shell, not an identical white.
3. **Main props:** winter-games chalet, curling rink rectangle with scoring ring, bleachers, slope fencing, ski-lift stations, a small campus clocktower motif, evergreen clusters, warming hut, festival flags, gift-stacked maintenance carts.
4. **Placement affordance:** player understands where a tower can sit from ground type and ghost range rings. The ski course itself remains unbuildable. Buildable snow has a subtle lower-noise surface material. Decorative obstacles visually agree with the collider rules.
5. **Ski lift:** optional slow cable-car motion and gentle sound; no functional gameplay effect without explicit mechanical specification, especially no hidden LOS blocker.
6. **Winter sport identity:** add hockey puck targets, skis, curling stone rack, ski poles, snowboard rack and festive flags without accidentally suggesting those props are purchasable defenders.
7. **Christmas theme:** warmly illuminated cabin windows, tasteful light strings, garlands, fir trees, presents, jingle motifs, snowfall. Avoid turning the map into a giant red/green collage that competes with the snowball colors.
8. **Safety and performance:** ambient skiers and background ornaments use reduced LOD/culling; distant peaks belong to sky/backdrop, not dense near-field polygons. Make an obvious natural boundary, not an unexplained invisible wall.
9. **Camera:** fixed elevated perspective (orthographic or modest perspective—decide after greybox testing), stable enough that cursor-to-world interactions and tower range are predictable. No mandatory camera orbit during match.
10. **Victory framing:** exit gate/lodge can glow when defended successfully, while losing shows a broken festival finish-line banner; avoid elaborate cinematics until core match functions.

### Geometry and blocking mock targets [PROPOSED]

- Aim for 1 readable continuous route with 3–5 strategically significant curves, not a source-map trace.
- Keep at least two easy beginner placement areas directly adjacent to the entry section and one good location at a central bend. Avoid layouts that make global-targeting sniper trivially superior to every other tower.
- Place festival props on *outside* edge clusters, with a comparatively quiet center so enemies and tower range circles remain visible.
- Use a small fixed palette for terrain materials and decoration; region complexity should come from carefully authored shapes and composition, not random scattering.
- For testing, generate a labeled overhead map drawing containing path waypoints, blocked masks, tower footprint scales, line-of-sight occluders, and key art-placement anchors.

**State-dependent art:** during technical development use colored strips, cubes and simple placeholders. On final art pass, map geometry replaces them without moving any gameplay path coordinates unless the technical balance document and round tests are intentionally updated. This is a hard dependency.

## A-03. Character art bible: Camel Claus versus regular defenders

### Camel Claus [HERO]

Camel Claus should read as a *single unmistakable mascot hero*: a friendly camel in an oversized blue winter jacket and knitted scarf, a festive red-and-white hat/helmet, sculpted goggles, and a **two-handed ski-pole-inspired launcher** whose short compressed snowball pellets visibly ricochet. Avoid a literal BTD6 Quincy visual clone: different species/anatomy, costume design, weapon silhouette, posing and portrait treatment. The hero gets bigger facial expressivity, level-up confetti, and a highly readable ability ready state.

**Visual level evolution [revised Quincy Lv4 Focus]:** level 1–3 base outfit and ammo; level 4 focus stance raises a crisp precision-goggle visor and tightens aiming pose; level 5 goggle brightness makes whiteout detection clear; level 6 doubles launch slots; level 7 adds periodic sparkling burst pellets; level 10 activates the large snowball storm VFX; level 15 upgrades the Frenzy effect; level 19 visually shows a third launching channel. **Art is not the source of exact stat changes**; reference technical M-09 and M-11.

### Athletes' shared grammar

A full-size hero camel can be distinct from regular athlete silhouettes without making everyone else generic. Regular towers have a shared base fantasy athlete anatomy with large head, short-to-medium neck, sturdy torso, thick cuffs, gloves, big boots and sports-hat variations. Each athlete's **primary equipment** is bigger than real life for top-down readability. Facial structure has eye sockets, cheeks, lids, brows, nose and mouth volumes, not floating spheres. Clothing should visibly fit the skeleton: padded elbows/shoulders, scarves that wrap, goggles with correctly seated straps and buckles, ski boots with believable cuffs.

**No realism:** soft vinyl/stop-motion cartoon or premium animated film character proportions; no detailed human skin pores, anatomically adult faces, or realistic rifles. Each silhouette must convey either snowball thrower, biathlon, technician or sorcerer even in an untextured silhouette test.

## A-04. Initial defender presentation matrix: signature identity across upgrade paths

| Unit | BTD6 mechanical source | Tier-0 silhouette | Top path look | Middle path look | Bottom path look | Unique audiovisual cue |
|---|---|---|---|---|---|---|
| Snowball Rookie | Dart | chibi thrower, bright cap and small pellet bag | heavy spherical ice boulder launcher with reinforced arms | multiple pocket launchers, team badge and rally gestures | sporty snow crossbow / targeting lens | crisp tiny *crump* with shallow snow puff |
| Avalanche Cannon | Bomb Shooter | small stout winter cannon on sled mount | increasingly wide muzzle, heavy chassis and visible shock collars | long snow missile rail, targeting fin and air-jet | cluster chambers, multi-vent barrels | resonant soft boom, rolling snow debris |
| Biathlon Ranger | Sniper | winter marksman with long fantasy sports launcher, bipod and goggles | heavy precision barrel and reinforced boots | communications antenna, marked magazine and supply beacon | larger automatic sports launcher and recoil pose | tight precise snap, minimal flash, target ping |
| Slope Wax Sprayer | Glue | ski technician with curved wax tank and hose | translucent active dissolving fluid, pressure tank and warning bands | dual-nozzle spray manifold, wide coating cloud, storm gauges | clamp/thick-viscosity sprayer with strong skid marks | sticky splat, wax drip and subtle slosh |
| Snow Sorcerer | Wizard | short festival magician in padded robe, snowflake-shaped staff | high-control focused glowing staff and large snow crystal | ember-to-white-hot magical snowboard/bird spirit, warm-cold vortex | dark blue ghost-snow summons and arcane lantern | warm/chime shimmer with airy trail |
| Ski Resort Ticket Booth | Banana Farm | small painted lift-pass kiosk, lit ticket window | larger chalet/back-office, more ticket printers | tall bank-style resort ledger, banner and secure dropbox | automated vending/sponsor stand, conveyor | soft ticket dispenser, coin chime, accepted purchase |

**Path identity rule:** the source upgrade path affects visuals through `primary_visual_state`; secondary tier-1/2 crosspath attaches limited detail via `secondary_accessory_set`, and does not obscure primary t3/t4/t5 silhouette. Tier 3 must clearly differ from other paths without requiring a HUD. Tier 5 can change the major form; if full t5 model is too expensive for jam, a distinctive major prop/animation is acceptable, but never leave a t5 mechanically invisible.

### Later-only roster [SCOPE CONTROL]

| Later tower | Source | Visual core | Strongest upgrade-path cue |
|---|---|---|---|
| Hockey Slapper | Boomerang | hockey athlete with curving oversized puck | orbiting pucks / turbo stick / heavy check |
| Snowboard Trickster | Ninja | snowboarder with spinning star-snowflakes | broad disc volley / sabotage crew / sticky charge |
| Winter Games Lodge | Monkey Village | lodge/radio station building | training center / radar equipment / commercial complex |
| Track Gritter | Spike Factory | compact path-gritting machine | giant grit hopper / rapid grit sprayers / long-lived packed hazards |

**Avoid** investing modeling time in later-only units before the user authorizes roster expansion. They may exist as a line in the HUD/inventory design but should not be accidentally implemented as disabled nonsense buttons.

## A-05. Snowball enemy visual system and feedback

### Layer visualization

The base enemy must be a **complete sculpted snow/ice shell**, with a layered-material transition that is intelligible at running speed. On a 1-damage layer pop, current shell fractures rapidly, ejecting 3–8 low-cost snow fragments (visual budget target, not BTD6 measured particle count), revealing the next **smaller/different-colored** snowball. The new shell needs a short settling squash or wobble. Do not force dramatic camera shake or full-screen flash for basic hits. Snowballs should roll about correct axes along tangent to track; pattern seams and ice glints should rotate naturally rather than scrolling randomly.

**Important mechanical constraint:** no health bar is necessary for the five common linear color layers. Damage should visibly reveal next tier. A highly armored special type may need crack progression and a subtle injury indicator. Gold is **not yet assigned a canonical underlying BTD6 type**; do not color-code a standard Purple or Black class as Gold while lying about damage/properties.

### Enemy appearance contract

| Enemy / attribute | Silhouette/material cue | Combat feedback | QA anti-confusion |
|---|---|---|---|
| Powder | pearl white core, cool outline, blue shadow band | white powder spray and crisp tiny breakup | must remain legible on white map snow |
| Blue | saturated blue crystalline flecks | exposes Powder on 1 relevant hit | hue distinct from track ice |
| Mint | green-turquoise striation | exposes Blue | distinct from pine green |
| Violet | violet/indigo stripes | exposes Mint | distinct from magical sorcerer VFX |
| Coral | sunset peach zig-zags | exposes Violet | distinct from cabin lights |
| Gold [pending] | bright gold filigree / sculpted ridge | only after mechanical definition | gold currency remains distinct |
| Camo / Whiteout | moving pale scanlines or triangular snowflake glyph | brief detection shimmer when acquired | different from Powder via non-color cue |
| Regrow / Repacking | pulsing stitched snow seam / sprout-like ice spikes | soft reverse-crack particle when layer returns | never just unexplained HP reversal |
| Armored / Lead | hard steel cap around snow shell | metal tick and spark; no standard hit breakup when immune | not mistaken for golden boss |
| Black / White / Purple | unique shell emboss/stripe and clearly different material | type-dependent immune rejection | labels or tooltip in inspect panel |
| Ceramic / Packed Ice | thick plates, visible cracks | heavy crack; internal colored children | shell state visibly deteriorates |
| Giant / MOAB family | differentiated huge rolling snow formations: single shell, double shell, angular ridge, stealth fast sphere, colossal mixed ice mass | thunderous crack at shell break; controlled smaller-spawn effect | never just same sphere scaled 10× |

**Technical/VFX coupling:** the art module receives typed hit events with resulting `enemy_shell_id`, `is_immune`, `did_spawn_children`, `status_applied`; it must never calculate HP from the material. Multiple layers destroyed in one frame must produce a short **aggregated** effect to avoid hundreds of particles.

## A-06. Interface architecture: screen-by-screen

### Boot / title and home

Initial splash uses original studio label **Camel Claus** then a game title and modest snowy backdrop. Scene behind menu can be a small cinematic orbit of the *same* festival level (if inexpensive) or a static illustrated 3D diorama of lodge + slope + hero. One principal **PLAY** action; other actions `HOW TO PLAY`, `SETTINGS`, `CREDITS`, optional `HIGH SCORE`. Snowflakes move slowly enough not to distract; none should masquerade as clickable controls. On first web audio playback, browser may require interaction before sound starts; don't treat that as a defect if handled gracefully.

### Pre-match configuration

Map thumbnail, one-sentence rule, starting cash/lives/round, difficulty, optional hero portrait (only Camel Claus available at MVP), cosmetics preview. Avoid complicated multi-mode navigation for a single playable map. Give meaningful tutorial text describing color-layer snowballs and their special properties; **do not claim Gold 6 HP unless approved**.

### Preparation phase HUD

Proposed layout: compact lives/currency/round cluster at top-left; central playfield uninterrupted; right vertical six-tower purchase palette with icons and costs; lower-left hero portrait/XP/ability slots; lower-right round start and speed controls with unmistakable paused state. If display aspect ratio narrows, slide shop into collapsible panel without moving interaction targets unpredictably.

### Selecting a tower

Click tower type → hover terrain with an unplaced transparent silhouette, correctly scaled footprint and range ring, green/blue validity mark, and red warning with why placement is invalid. Confirm place; tool returns to normal or remains in placement mode based on documented user setting. Unaffordable tower icons must remain readable but visually disabled. Pressing Escape cancels placement. The tooltip explains cost and role instead of only listing BTD6 source jargon.

### Inspecting existing tower

On click, present a portrait, upgrade path grid (top/middle/bottom), current targeting policy, active counters, buffs, range, sell price, next legal upgrade, and an obvious close button. Upgrade cards must distinguish **owned / affordable / unaffordable / locked by crosspath / final tier**. Display real prices after difficulty modifiers. Unique source ability effects like Supply Drop and Fan Club-style ability get a visible button and description. Don't let the right-side panel cover a critical path exit or half the map.

### Camel Claus hero panel

Show hero XP bar, numeric level, next-level synopsis, **Snowball Frenzy** (level 3), **Blizzard Barrage** (level 10), auto-level text, and a **Focused Shot** toggle at level 4. The Focus toggle should explain "greater range and projectile speed, slower firing" with distinct aim-line preview, and must be keyboard-operable. This reflects verified BTD6 v57 mechanic; see technical M-09/M-11.

### Biathlon Ranger special panel

At the correct mapped Sniper middle-path tier-4, show **Cash Drop / Ammo Drop** mode switch. Explain that both modes share ability cooldown. Cash mode triggers currency-themed supply; Ammo mode triggers temporary offensive empowerment. The artwork must make the two modes distinguishable before purchase and after use. **Do not add an independent second cooldown** without technical authorization.

### Status, pause, results and game over

Pause stops all simulation and ability timers; preserve the selected unit and disabled states. `Restart`, `Settings`, `Quit to Menu`, `Resume`. HUD has clear `Round X / Y`, next-wave arrow and game-speed state. Win screen: festival lodge lights brighten, medal confetti and hero celebration, short stats such as waves survived, snowballs burst, cash invested, most effective tower; defeat: snow-covered finish gate and replay button. Avoid huge unskippable transitions.

## A-07. UX state matrix and input affordances

| Event | Visual response | Audio response | Mechanical readout |
|---|---|---|---|
| Hover purchase icon | 1–3% scale lift / soft outline (proposed) | quiet soft tick if enabled | price and role tooltip |
| Attempt unaffordable purchase | brief restrained red tint + price wiggle | low soft deny sound | price remains legible, cash unchanged |
| Placement valid | translucent green/white footprint, range | soft hover tone (optional) | cursor may place |
| Placement invalid | crossed red footprint, specific reason | optional very quiet negative tick | cursor cannot place |
| Tower placed | 100–180ms soft snow puff/settle | soft stomp/click | cash decreases once |
| Tower selected | base ring + outline + inspect card | quiet selection cue | current tower ID and range |
| Upgrade applied | new prop/equipment appears, card active, compact glow | small triumphant chime | stat/attack changes match data |
| Basic layer pop | outer ice fragments, next hue exposed | bright snow crump | reduce layer, reward cash |
| Immune hit | brief hard spark and distinct `no effect` cue | muted *tink* | no false pop/cash |
| Snowball slowed | subtle waxing trail and low-intensity status symbol | low slosh at application | speed/status timer changed |
| Focus stance activated | goggles/aim reticle and stance icon | concise lens click | range/speed/cooldown formula visible |
| Hero level up | hat pin/medal glint and small XP pulse | uplifting two-note rise | new level/power unlocked |
| Ability available | crisp readable icon edge and short light pulse | optional ready beep only once | cooldown = zero |
| Ability fired | distinctive large-but-bounded signature VFX | event-specific hit sound | ability spent, cooldown starts |
| Income pickup | ticket counter flip and coin glint | soft papery chit | cash balance increment verified |
| Life lost | exit gate flashes, life counter subtracts | short warm warning cue | leak damage exactly once |
| End round | compact celebratory badge | restrained fanfare | fixed completion cash credited |

**Proposed timing ranges in this table are ORIGINAL UI design guesses, not measured BTD6 animations.** Store actual `AnimationPlayer` timings and screenshot review results in later production work.

## A-08. Combat VFX by damage family

**Scope discipline:** generate particle/fade presets for event categories, then recolor/retarget them; avoid unique expensive VFX graph for each level 1–2 upgrade. Five reusable families: `projectile_trail`, `layer_crack`, `area_burst`, `status_overlay`, `ability_special`. More powerful effects add a crisp silhouette and stronger sound first, not 100× particle count.

| Family | Visual language | Resource & performance limit proposal |
|---|---|---|
| Rookie snow pellet | compact white pearl with cool rim and 1–2 particle tail | small emissive cost, short lifetime, pooled |
| Cannon shell explosion | snow flash + larger wedge fragments + circular puff | splash radius visually agrees with hit radius |
| Biathlon precision shot | thin compressed icy line, contact glint, small recoil | effect not a distracting laser beam |
| Wax sprayer | curved liquid clumps with slow drips and coat sheen | overlays expire with gameplay status, not separately |
| Sorcerer bolts | snowflake glyph trail, shifting warm/cold hue | magic and armor immunity clearly distinguishable |
| Farm income | fluttering lift pass/token, kiosk counter flip | collected cash shown without scattering overlapping icons |
| Hero ricochet | visible jump arc that curves to next target | chain count correlates with pierce values |
| Hero explosive pellet | snow-ring at impact; supplementary outer shock crest | per-third-shot rule visible without false every-hit explosions |
| Hero Blizzard Barrage | burst of ice pellets raining on constrained target zone | capped particles/target outline, readability maintained |
| Giant shell break | layered fracturing mesh + short controlled mist | highest priority above ordinary pop effects |

### Particle priority policy

`critical`: life loss, immune warning, hero ability, boss phase, upgrade success. `normal`: current layer break, tank damage, buff. `cosmetic`: snowfall, footsteps, chimney smoke, tree sway, light glints. **Drop cosmetic VFX first when load increases**. Do not suppress gameplay state labels. Have a user setting for `FX Low / Medium / High`, `Reduce screen shake`, and `Reduce motion`.

## A-09. Motion design and world animation

**Athlete idle:** tiny weight shift, scarf/hair or coat bounce, head orientation toward track; do not have every athlete wave continuously. **Attack:** torso anticipates direction, equipment follows through, subtle recoil/pose recovery; actual attack timing and hitboxes come from simulation. **Hero:** neck, face and goggles require believable rigging; muzzle stays structurally fused and skinned rather than a separate ball. **Mechanical:** piston/launcher muzzle and pump should articulate on plausible hinges; resort kiosk window can flip a ticket display.

**Snowballs:** continuous tangent-aligned roll, appropriate rotation based on travel and radius, mild body wobble, color-switch impact; rapid enemies may have subtle motion streak, not excessive blur. **Background:** ski-lift gondola slow loop; distant skiers optionally cross only far non-playable slopes; flags sway; pines respond to gentle wind; chimney smoke rises; snow falls outside dense combat focal area. **UI:** menu card arrivals, upgrade card pulses and badge transitions should have controlled ease-in/out. Avoid over-bouncy modern mobile casino UI.

**Animation quality gates:** no feet sinking into snow, no projectile emitter floating away from hands, no hat clipping through skull, no scarf intersecting muzzle when turning, no Z-fighting on helmet goggles, no rig joints collapsing after export, no pointer click disappearing on full-screen change. See modeling source A-12 and hybrid modeling section B-11.

## A-10. Soundscape and music identity — wholly original

**Music concept [PROPOSED]:** "cozy competitive winter sports festival" — light rhythmic percussion and bass, plucked strings/glockenspiel/sleigh bells used sparingly, airy pads and pizzicato or wooden mallets. Melody should feel modern and intentionally stylized, not harsh synthetic chiptune. Menu track warm/calm, gameplay track lively but unobtrusive, late waves add energy/texture (not necessarily entirely new tracks). Victory short rhythmic flourish; defeat quick, gentle sting. **Never copy BTD6 soundtrack, melody, recording, or recognizable motifs.** BTD6 soundtrack research is in original art volume V-11 but those tracks are evidence of pacing/role only.

**Mixing plan:** master bus, music bus, UI bus, combat SFX bus, ambient bus. UI click/music should be slightly less aggressive than per-hit sounds; cap simultaneous snowball popping via prioritization or sound merging. Avoid playing one full-loud pop per collision when 100 enemies split. Lower music a little during hero ability or win/loss UI, then recover smoothly. Preserve dynamic range under browser speakers and earbuds; avoid sharp transients / constantly repeating piercing high-frequency notes.

| Event | Original foley/synthesis inspiration | Mixing / role |
|---|---|---|
| Small snowball popped | short wet-crisp crushed-snow tap | high-frequency feedback, low level, randomized pitch |
| Large shell cracks | compressed ice/ceramic crumble | heavy low-mid accent, rare and prominent |
| Wax hits | soft slick splat | informs successful slowing |
| Ice immune bounce | muted metallic/glassy knock | informative unsuccessful attack |
| Ski-pole shot | short wood/elastic release | distinguish hero from other projectiles |
| Hockey puck | plastic/rubber thunk with short skating slide | future tower; not in initial production |
| Cannon charge | soft pneumatic *woom* then cushioned snowblast | AoE signature |
| Biathlon shot | soft electronic air-pellet snap | precision without harsh gunfire |
| Sorcerer magic | soft glass-chime swish | mystical without severe upper-band resonance |
| Ticket pickup | receipt flick + satisfying coin-like click | resource pickup informative |
| Hero ability | whoosh swell and melodic ascent | strong priority but not deafening |
| Menu navigation | tiny wooden tap, felt click | consistent tactile UI |
| Round complete | two/three-note medal fanfare | positive transition without 5-second interruption |

**Implementation caution:** browser audio autoplay policy may require a player gesture. Start music after the first legal user interaction if necessary. License/provenance track for every SFX sample, instrument or synthesized clip. Generate original cues or use suitably licensed library with attribution if required.

## A-11. Art data contracts for AI developer

Gameplay code sends `PresentationEvent`; presentation maps events to assets and sound, without reading BTD6 IDs directly. Example:

```yaml
presentation_profile: snowball_rookie
source_fidelity_tags: [v56_mechanics, original_aesthetic]
model_base: res://assets/characters/athletes/rookie_base.glb
portrait: res://assets/ui/portraits/snowball_rookie.webp
materials: [team_blue, winter_white, soft_corals]
vfx:
  fire: vfx_snow_pellet_small
  hit: vfx_snow_layer_crack
  upgrade: vfx_upgrade_medal_pulse
sfx:
  fire: sfx_pellet_release
  hit: sfx_powder_pop
animation_states: [idle, aim, attack, celebrate]
upgrade_visual_policy:
  primary_tier3: replace_equipment_and_headgear
  secondary_tier2: accessory_override_small
```

**Model art authority:** the visual .glb is sourced from `03...md` and Blender, not made from dozens of placeholder MeshInstance3D primitive children. Greybox placeholder scene is a *temporary shell only*. UI tests must work with gray geometry and final geometry alike.

## A-12. Display and accessibility QA

- Test `1920×1080`, `1366×768`, and a narrowed desktop window. Don't insist on a fixed 16:9 window.
- Test browser zoom 90%, fullscreen enter/exit, focus lost/returned, device pixel ratio and mouse coordinates. Mouse picking must remain aligned with world placement; users must still be able to leave fullscreen.
- Check text contrast, disabled affordability versus owned upgrades, mouse/keyboard navigation, tooltip timing, UI safe areas, readable range rings.
- At 320×180 thumbnail, player can identify **track, current major threat, Camel Claus, at least three regular tower types, cash/lives/round**.
- Color blindness: Powder and Mint and valid/invalid cannot rely only on hue. Add stripe/texture icons, labels on hover, or silhouettes.
- Stress scene with 100+ snowballs and many active effects; degrade *cosmetic* density first; audio voice cap; no incorrect cash or enemy hits.
- View clay render and final light rig separately; lighting is not allowed to hide unfinished model geometry.
- Screen captures needed eventually: splash, menu, map preview, initial preparation, placement ghost valid/invalid, selected tower three paths, hero focus, hero ability, waxed enemy, immune enemy, giant shell break, income pickup, paused, victory and defeat.

## A-13. Production sequence dependency — NOT the requested master roadmap

**Phase distinction only:** first the mechanics/UI are testable with temporary circles, cubes and basic text; later replace them with one consistent art kit, then iteration passes for VFX/audio/polish. Do not create master tasks/checklists here, or start modeling all 10 towers before the first playable exists. Since high resolution models and original sound are expensive, prioritize one hero, one base athlete, six initial tower signatures, common enemies and one map, then expand only by explicit request.

**Art deliverable quality:** reference images, concept briefs, actual normal-camera captures, orthographic character sheets, material palette, icon/pictogram family, SFX provenance manifest, browser captures. Asset handoff/acceptance rules live in hybrid modeling volume.

## A-14. Reference evidence and approval questions

**Attached source art chapters:** `[V-03]` style, `[V-04]` readability, `[V-05]` tower visual families, `[V-06]` UI, `[V-07]` player journey, `[V-08]` microinteractions, `[V-09]` VFX, `[V-10]` map, `[V-11]` audio, `[V-12–V-16]` implementation and modeling. **Attached modeling chapters:** `[A-04]` anti-primitive charter, `[A-08]` upgrade identities, `[A-10]` environments, `[A-11]` materials and `[A-16]` QA. Use these as foundational research; this document is the **original game's authoritative creative target**.

**External reference sites:** [BTD6 official Steam](https://store.steampowered.com/app/960090/Bloons_TD_6/), [One Two Tree map](https://teemo.dev/game-design/bloons-td-6/wiki/maps/one-two-tree/), [Skates](https://teemo.dev/game-design/bloons-td-6/wiki/maps/skates/), [Alpine Run](https://teemo.dev/game-design/bloons-td-6/wiki/maps/alpine-run/), [source version notes](https://gameupdatenotifier.com/g/bloons-td-6/v/57-0).

**Review gates:** final title; Gold class semantics; optional map water placement; fixed camera perspective; precise outfit family (snow elves versus generic chibi athletes); presence of any official Connecticut College marks; whether festive soundtrack is instrumental only; art quality versus Web performance tradeoff; whether additional visual content for planned towers is authorized. No finished art production until approved.
