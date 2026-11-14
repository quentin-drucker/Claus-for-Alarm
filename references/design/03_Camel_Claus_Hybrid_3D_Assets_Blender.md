# Camel Claus — Hybrid 3D Asset Modeling, Blender & Godot Production Specification

**Edition:** H0 — November 13, 2026. **Status:** an asset-production contract for creative review, **NOT a build authorization**.  
**Gameplay authority:** `01_Camel_Claus_Hybrid_Gameplay_and_Balance.md`.  
**Aesthetic/UI authority:** `02_Camel_Claus_Hybrid_Art_UI_Audio.md`.  
**Technical art references:** uploaded `BTD6_3D_Asset_Modeling_and_Blender_Production_Reference.md` (especially A-04/A-05/A-08/A-10/A-12–A-17) and `BTD6_Art_Audio_Visuals_and_UX.md` (V-03/V-05/V-09/V-10).

> **NON-NEGOTIABLE MODELING CHARTER:** Primitives are valid for grayboxing and blockouts. Final assets must **NOT** look like recognizable stacked spheres/cylinders/cones/boxes. Organic anatomy must be sculpted into convincingly continuous masses with designed transitions. Separate clothes, props, armor and machinery must have believable **fitted contact, thickness, weight, attachments and material boundaries**. Quality must survive neutral-material renders and a 360° turntable. Smooth shading does NOT fix a primitive collage. Maintain artist-quality master models, then optimize for Godot's Compatibility Web renderer; artistic ambition must not silently destroy framerate.

## B-00. Scope and non-goals

### Locked initial deliverable roster (modeling may start only after technical phase approval)

1. `hero_camel_claus`: polished mascot camel hero; **Quincy** mechanical progression (Lv1–20 defined by gameplay volume).
2. `tower_snowball_rookie`: chibi winter athlete; **Dart Monkey** mechanical family.
3. `tower_avalanche_cannon`: animated snow cannon emplacement; **Bomb Shooter** mechanical family.
4. `tower_biathlon_ranger`: chibi biathlon shooter; **Sniper Monkey** mechanical family.
5. `tower_slope_wax_sprayer`: chibi slope-wax technician; **Glue Gunner** mechanical family.
6. `tower_snow_sorcerer`: festival conjurer athlete; **Wizard Monkey** mechanical family.
7. `tower_ski_resort_ticket_booth`: small resort kiosk/building; **Banana Farm** economic family.

**Approved later-only**: Hockey Slapper (Boomerang), Snowboard Trickster (Ninja), Winter Games Lodge (Village), Track Gritter (Spike Factory). **Excluded entirely from roster planning**: Dartling Gunner, Monkey Ace, Engineer/Rink Engineer, Ice Monkey/Figure Skater, Tack Shooter/Puck Carousel, Alchemist/Hot Cocoa Coach. **Enemy art:** five conventional colored rolling snowballs plus a visual Gold concept awaiting its final mechanical meaning, with separate special-property and giant-snowball asset families. **Environment:** one original festive winter sports campus ski-circuit diorama; UI portraits can reuse high-res master models.

**Non-goals for this file:** reconstructing/copying Ninja Kiwi's actual 3D meshes, rigs, textures, shaders, icons, symbols, upgrade models or track geometry; calculating tower damage; deciding all the implementation phases; automatically creating 150 separate tier meshes; producing assets now. It is a *creative spec* guiding future Blender production.

## B-01. Desired modeling quality relative to the BTD6 reference

BTD6 is a useful example of stylized proportions, exaggerated gear and strong top-down readability. It is *not* evidence of exact source topology or a required polygon count. Our original characters should have smoother **form integration** and more polished close-up render quality than minimal toy-blockouts, while still reading quickly in a small fixed camera.

**Four quality scales**: (1) overview map screenshot, where silhouette is king; (2) game camera tower size, where equipment and color block communicate roles; (3) selected-tower portrait, where costume and facial craftsmanship matter; (4) full-size 360° turntable/marketing, where anatomy and seams cannot be hidden by distance. Each asset must pass at least (2) and (4); hero must excel at (3) and (4).

**Style contrast examples:** a convincing cartoon snout has sculpted brow/bridge, cheeks, jaw, muzzle and nostril cavities continuous with the head rather than one colored sphere intersecting another; a ski jacket has fitted body volume, sculpted puff segmentation and cuffs; a snow cannon has fabricated housing, welded-looking mounts, appropriately seated wheels/runners, interior muzzle depth and logically connected recoil mechanism instead of a cylinder placed atop a box.

### Rejection criteria for AI-generated assets

- Visible sphere-on-neck, cylinder-on-torso, polygonal/primitive head, glued-on separate muzzle or stump limbs that cannot bend.
- Floating goggles, hand grips not enclosing tools, cap not conforming to skull, scarf clipping into throat/shoulders, coat buttons hovering above fabric.
- Ski boots not touching snow, hockey/pole props passing through gloves, weapon emitter not aligned with projectile orientation.
- Identical roughness and exaggerated plastic gloss across cloth, wood, ice and metal.
- Missing back-of-head / bottom-of-weapon / inside-collar geometry visible in the game camera or turntable.
- Impossible hard-surface mechanics (lever missing hinge, nozzle attached with no bracket, roof floating above walls, tread unconnected to chassis).
- Mesh looks good only in dark dramatic lighting or from a single three-quarter view; clay render reveals elementary intersecting solids.
- T3/T4/T5 cosmetic change only alters an RGB color while supposedly transforming weapon mode/specialization; crosspath attachment covers hero face or primary weapon.
- Decimated game asset loses signature silhouette or breaks armature deformation; export appears distorted or ignores material colors in Godot.

### Not every adjacent surface should be fused

The body of a camel's neck/torso/head should be a coherent soft tissue flow; the hat, scarf, launcher and boots should be separate material-appropriate pieces with deliberate attachment. Cannon barrel/trunnion/chassis should be separate articulated pieces with coherent mechanical contact. Ice shell and external armor may be separate because they're different layers. Avoid indiscriminate voxel-remeshing the entire tower with equipment into one uneditable blob.

## B-02. Reference boards, planning and geometric scale

For every hero/tower asset, AI Blender agent produces a short concept sheet: (a) readable black silhouette, (b) front/side/three-quarter orthographic or controlled perspective, (c) top-down gameplay camera crop, (d) named equipment pieces and attach points, (e) material swatches and light plan. Include **original differences from BTD6**, not screenshots copied into a concept as a model template. Tag with `source_mechanical_family`, `creative_owner`, `license/provenance`, `visual_status`, and `approval`.

**Choose in-game unit-scale once** during greybox: e.g., base athlete height = 1.0 reference size (not necessarily 1 Godot meter), hero = 1.3–1.5× height, snowball tier shell radius relative to track width, range radii using same reference units. These ratios are [PROPOSED] and MUST be evaluated at final camera, not assumed exact BTD6 proportions. Change of world scale after tower placement/range test requires an explicit approved remap.

**Master scene orientation**: decide world axes and front direction once (`+Z` or `-Z` forward consistently), origin at ground-contact center, Y-up for Godot, named root node and sockets. The Blender source must use correct transforms and real-world scale *consistently*. Apply transforms before export where safe; preserve rigs and animation rest states.

## B-03. Shared toy-like athlete base: one premium model, multiple distinct towers

**Anatomical style thesis:** energetic fantasy winter athlete with oversized expressive head (roughly one-third body height as a candidate), compact padded torso, short athletic limbs, mitten hands that can grip sports equipment, boots, face with integrated eyesockets/cheeks/mouth, asymmetric stance and pleasant expression. Human-like enough for props/gestures but **not realistic human anatomy** and **not an undisguised BTD6 monkey**. Differentiation is largely from hats, stance, clothing, color accents, and one unmistakable prop/weapon.

### Shared body geometry rules

- Model a *single sculptable anatomical core* covering face/skull, neck, torso and limbs where continuous; avoid literally fusing legs to jacket props unless needed for close-up skin. Construct topology for shoulder/elbow/hip/knee articulation, not a static brick body.
- Build a library of **legitimate shape variants**, not just recolors: stocky engineer, slim biathlon, padded rookie, broad-shouldered wax tech, robed magician. Reuse skeleton where plausible, but don't force identical body proportions when it destroys a role silhouette.
- Face components: eyebrows and eyelids should conform to facial planes; curved mouth cavity/edge with plausible cheek deformation; nose should not look like a sphere glued on.
- Costume library: padded jacket, sport bib, helmet, knit cap, goggles, earmuffs, gloves, boots, scarf, knee pad, shoulder pouch, belt buckles, athletic medals. All designed with appropriate thickness and contact.
- Attachment sockets: `hand_l`, `hand_r`, `muzzle`, `launcher_tip`, `backpack`, `head_goggle`, `wrist_left`, `wrist_right`, `effects_top`, `root_ground`, `portrait_camera_target`.
- Normal idle/aim/attack variants should preserve unique personality; weapon must remain directed at valid enemy aimpoint with no arm snapping or wrist inversion.

### Reuse architecture: sculpt once, distribute carefully

```
athlete_master_hi.blend
  body_high_sculpt
  controlled_character_retopology
  common_armature
  base_face_shapekeys
  modular_costume_library
  camera_renders_and_silhouette_previews

asset_exports/athlete_family/
  athlete_sport_body.glb
  athlete_rookie_costume.glb
  athlete_biathlon_costume.glb
  athlete_slope_technician_costume.glb
  athlete_sorcerer_costume.glb
```

The master source is **editable Blender**. The game receives optimized versioned GLBs. Mesh intersections allowed temporarily under clothing must not render as Z-fighting, exposed gaps or clipping in any required animation. Face blend shapes and glove fingers may be simplified for gameplay if close-up facial rendering still passes.

## B-04. Camel Claus: hero model, rig, upgrades and animation brief

### Silhouette and body

Hero Camel Claus must remain an anatomically recognizable camel from front/side/three-quarter while being highly stylized. Large characterful head, round muzzle with sculpted transition into cheeks, strong eyelid/brow expression, curved and smoothly continuous neck rising from shoulders, leg roots integrated into torso (not cylindrical peg legs), distinctive feet/hooves and deliberate hump architecture. **The main risk is a necklace of default primitives.** Rework anatomy until a clay render shows a believable continuous mascot body. A small scarf and goggles can sit above skin as independent pieces.

### Costume and weapon

- Winter champion jacket/vest in team blue; festive accent red, optionally numbered bib or medal; ergonomic goggles shaped to skull; a knit scarf genuinely wrapped around the neck with realistic folding and thickness; high-quality sculpted knitted hat/helmet with optional drooping tip, not a default cone.
- **Ski-pole bow / pellet launcher** made from curved lightweight metal sporting poles and elastic/cable mechanism, designed to launch small snowballs. NOT a straight copy of Quincy's bow art. A two-handed hold may be demanding for a quadrupedal camel: choose **standing mascot bipedal pose** or a strapped foreleg-mounted launcher and commit; don't use a body rig that can't operate the selected weapon.
- Distinct `pellet_origin_a`, `pellet_origin_b`, `pellet_origin_c`, `storm_target_locator`, `snowball_backpack`, `focus_goggle` bones/sockets; addition at level 6/19 should swap/activate appropriate barrels with NO weapon-body intersections.
- Expressions: eager focus, celebratory smile, serious Focus stance, ability exertion, defeated/concerned face, idle blink. Face readable at hero portrait scale.

### Hero progression L1–20: asset group plan

| Milestone | Visual addition | Technical event |
|---:|---|---|
| 1 | strong base hero with one compact pellet launcher | primary 1-pellet ricochet |
| 3 | subtle speed glow/elastic recoil and snow-particle speed lines | Snowball Frenzy unlocked |
| 4 | *mechanical* visor slides down, precise barrel alignment, Focus icon | **v57 Focus stance** on/off; longer range, projectile speed, slower fire |
| 5 | refined goggles with light-readable anti-whiteout emblem | detection unlock |
| 6 | second launcher aperture / dual ammo trail | projectiles 1→2 |
| 7 | energetic impact glint on programmed explosive volley | third-shot explosive attack |
| 10 | cape/scarf wind effect and original storm particles | Blizzard Barrage unlocked |
| 11–18 | progressive jersey emblem/medal, controlled material accents | attack/ability stat increases per technical table |
| 19 | third real launcher aperture and correctly emitted third pellet | projectiles 2→3 |
| 20 | heroic finish pose, richer ability visual (still performant) | maximum speed/storm strength |

**Do not manually author 20 distinct hero meshes.** Use 4–5 milestone accessory states, bone animations and material/VFX changes. Hero levels still work mechanically in place of finished art during technical phase.

### Hero rig & QA

Rig essentials: spine/neck chain with believable S curvature, jaw/face controls, ears and eyelids, shoulder/foreleg/hand manipulation, scarf dynamics via lightweight bones/animation, weapon sockets, grounded foot contacts. Avoid massive physics simulation for cloth in Web build. Render front, side, back, hero three-quarter, and gameplay camera under clay and final materials; inspect all 5 milestone stages and two ability animations. If the character reads like a donkey/horse with a random hump glued on, revise anatomy.

## B-05. Six initial tower modeling briefs — geometry, variants and rejection tests

### B-05.1 Snowball Rookie — Dart Monkey reference

**Base:** shared athlete body in padded varsity snowsuit, cap, mitten pouch. Attack is an earnest overhand snowball release via compact sling; one snowball projectile, not a visible dart. The high-pierce source branches require a distinct industrial/sports transformation at later tiers.

**Top path t3–t5:** a clever counterweighted **ice-boulder sling/launcher** that can throw large packed-ice spheres; build curved support beam, proper pivot and believable counterweight, not sphere sitting on cylinder. T4 reinforces suspension and barrel, T5 large boulder cradle with visible breakup chambers. **Source:** Spike-o-pult → Juggernaut → Ultra-Juggernaut.

**Middle t3–t5:** multiple wrist-mounted snow launchers or three-pocket sling integrated into glove bracers; t4 player-led team rally props; t5 bright champion league transformation kit. The underlying BTD6 Fan Club transformation affects nearby Dart-family units: if adapted, visual indicator must apply to affected Rookies but not randomly to other towers. **Source:** Triple Shot → Super Monkey Fan Club → Plasma Monkey Fan Club.

**Bottom t3–t5:** skis or snow crossbow with broad ice bolt. Design rails, strap, sight lens, bow-string tension geometry and secondary crosspath attachments that don't obstruct vision. **Source:** Crossbow → Sharp Shooter → Crossbow Master. **v57 rule:** t5 shoots TWO parallel projectiles at a slower per-volley interval; model must have two physical muzzle/rail outputs.

**QA:** from gameplay camera, base Rookie, boulder specialist, fan club leader, and snow crossbow are visually distinct in silhouettes; all projectile anchors align with rig; t5 two bolts visible and not trivially overlapping.

### B-05.2 Avalanche Cannon — Bomb Shooter reference

**Base:** a compact sports-resort snow cannon mounted on sculpted sled runners, with reinforced muzzle and warming housing. Cannon must be mechanically functional-looking: separate steel tube, painted shell, real trunnions, recoil guide or mount, fastening plate, intake chamber, pressure hoses; at least two material families. A generic cylinder on a cube is rejected.

**Top path t3–t5:** larger shell/chamber and bracing with attention to true area-splash radius; T4 ground-stunning shockwave collars; T5 oversized mountain-crusher chassis, front footings and blast flare. **Source:** Really Big Bombs, Bloon Impact, Bloon Crush.

**Middle path t3–t5:** precision heavy-target missile; sleek but stylized angled snow/ice rockets, with coherent rocket eject socket and stabilizers; large-target sensor and focus paint markings. **Source:** MOAB Mauler → MOAB Assassin → MOAB Eliminator. The v57 source changed missile eject markers: model accurate projectile origin/arc instead of a projectile that mysteriously appears above the barrel.

**Bottom path t3–t5:** outward-facing fragment tubes, subdivided snow casings, safety covers, large cluster rack. **Source:** Cluster Bombs → Recursive Cluster → Bomb Blitz. Keep fragment count and once-per-round t5 ability **gameplay-driven**; visual rack is not permission to triple attack rate.

**QA:** muzzle axis, blast socket, anchored runners, no floating tubes, readable three paths, no snow-particle burst from cannon base when shot originates at muzzle, reasonable triangle/material/draw calls.

### B-05.3 Biathlon Ranger — Sniper Monkey reference

**Base:** premium shared humanoid athlete with winter race bib, sports visor, properly strapped goggles, ski boots, long **fantasy snow-pellet target launcher**. Keep competition-sport theme and avoid visually realistic military weapon styling; stylized equipment remains clearly precision long-range. Deliberate shouldering/hand grip and scope contact; no hovering rifle.

**Top path t3–t5:** heavier competition barrel, telescopic sight, reinforced targeting shoulder, medal insignia. Show target-priority strength without implying wide area blasts. **Source:** Deadly Precision → Maim MOAB → Cripple MOAB. Use recoil, lens and narrow focused shot; do not force all Snipers to use physical long-distance projectile collision if BTD6 hitscan-like behavior is reference.

**Middle path t3–t5:** multi-hit ricochet ammo and detachable **Cash Drop / Ammo Drop** beacon at t4 (v57). Build single backpack with interchangeable bright cash ticket crate versus icy ammo crate display; two modes share actual cooldown. **Source:** Bouncing Bullet → Supply Drop → Elite Sniper. Bonus income manifests as tickets, not random money particles created by the mesh.

**Bottom path t3–t5:** replace manual reload with plausible sports launcher magazine, ergonomic receiver, automatic loading cycle; larger recoiling prop, not instant unexplained bullet stream. **Source:** Semi-Automatic → Full Auto → Elite Defender.

**QA:** goggles contact, clean glove to launcher grip, different T3 identities, global targeting UI and FX align despite normal camera; middle ability art switches state without suggesting two separate cooldowns.

### B-05.4 Slope Wax Sprayer — Glue Gunner reference

**Base:** comic winter-sports ski-maintenance expert. One hand holds a curved wax sprayer with shaped nozzle and trigger, another supports a connected hose, rear tank seated on padded harness with realistic straps and buckles. Costume should be workshop-tech but cozy: ski apron, insulated gloves, goggles, boots and toolbelt. No free-floating hose or pump.

**Top path t3–t5:** increase high-pressure tank capacity, chemically active translucent de-icing potion, dangerous-but-playful canister labels (original icons, not chemical realism), fancier nozzle and spatters; source Dissolver → Liquefier → Solver. Character pose reflects stronger flow and damage-over-time without pretending it is an Ice Monkey freeze.

**Middle path t3–t5:** widen nozzle into sprayer array, eventually overhead sprinkler/storm launcher; multi-target spray emissions correspond to gameplay. Source Glue Hose → Glue Strike → Glue Storm. **v57** cost and special attack refinements documented in technical volume.

**Bottom path t3–t5:** heavier traction fluid/viscosity tank with clamp-muzzle and braided reinforced hoses. Dramatically stronger slowing and giant-snowball wax effects, distinct from increasing visual temperature/blue frost. Source MOAB Glue → Relentless Glue → Super Glue. Keep enough material difference that player sees **wax/slush**, not generic ice magic.

**QA:** tube continuity, tank mount straps, hose physics not required, viscoelastic splash VFX attaches to enemy status, no unexpected melting of model geometry, one wax-coated status overlay per enemy not 20 stacking transparent shells.

### B-05.5 Snow Sorcerer — Wizard Monkey reference

**Base:** playful winter festival conjurer, not a duplicate of BTD6 Wizard Monkey: fitted blue sports coat with distinctive snow-hood or performance cape, rounded friendly face, staff/ice baton formed from carved snowflake or ski-pole components, little foot warmers, enchanted mitten. Connect torso/neck/head anatomy with purposeful sculpted shapes; robe/cape has actual thickness, shoulder fit and controlled folds.

**Top path t3–t5:** a crystalline focus wand and luminous snow prism modules, more controlled and powerful guided shards. Source Arcane Mastery → Arcane Spike → Archmage. Wizard's mechanical energy damage class is not synonymous with literal snow or 'freeze'; make impacts precise rather than always freezing.

**Middle path t3–t5:** contrast with **warm-cold dual-element magic** (mulled-cocoa orange sparks, frosted blue flames) which mirrors Fireball/Wall of Fire/Dragon's Breath/Phoenix rather than turning all attacks into ice, because you want to preserve damage types. A unique original **snowbird spirit** (NOT a Phoenix clone) becomes summon visual; remains a separate optimized mesh with simple flap rig and VFX sockets. Source Dragon's Breath → Summon Phoenix → Wizard Lord Phoenix.

**Bottom path t3–t5:** shimmering goggles and signal flare for detection/decamo; haunted snow silhouettes emerge from defeated enemies as **original ghostly snow constructs**. Source Shimmer → Necromancer → Prince of Darkness. These are distinct small summon models, not a copy of monkey zombies.

**QA:** consistent elemental color logic and immunity cues, spirit model not too dense for browser, summon origin linked to valid spawn events, robe does not clip with staff in aiming animation.

### B-05.6 Ski Resort Ticket Booth — Banana Farm reference

**Base:** a small wooden winter resort kiosk with a steep snow-covered roof, gently lit transaction window, lift pass dispenser, large enough footprint to telegraph an income building; beautiful interlocking timber/roof construction with realistic bevels and snow deposition. The roof must not be a triangular primitive floating on a box. Distinguish money pickups from Golden snowballs (different shape, spinning rectangular pass/token and distinctive mint/economic sparkle).

**Top path t3–t5:** expand to **Resort Expansion / Research Chalet / Winter Games Central** with additional ticket printers, machinery, output chutes and carefully designed roof/gutter variation. Source Banana Plantation → Banana Research Facility → Banana Central. Keep produced tickets/material visible but never let cosmetic printing control actual cash or payout timing.

**Middle path t3–t5:** professional ledger and resort bank, vault windows, banking register and subtle closed storage state; click-to-collect sign/readout. Source Monkey Bank → IMF Loan → Monkey-Nomics. Visual bank must show accrued money with UI numeric value, not solely by the number of tokens around it.

**Bottom path t3–t5:** automated vending/sponsor booth with conveyor and banner, income auto-collection. Source Marketplace → Central Market → Monkey Wall Street. Use one compact modular building kit to cover variations instead of building five entirely different cabins.

**QA:** ticket emissive readable at gameplay camera, snow roof doesn't obscure lane, building stands convincingly on terrain, modular variants have no seam gaps, footprints don't change silently with cosmetics, upgrade variants don't block line-of-sight when the simulation doesn't model it.

## B-06. Four PLANNED towers: future-ready briefs, not asset production orders

### Hockey Slapper (Boomerang)

Reuse athlete rig; distinctive hockey stick must truly contact gloves, a puck curved rebound attack must not be confused with a straight moving snowball. Top path: precision ricochet plus orbiting pucks; middle: faster slapshots and charge animation; bottom: oversized heavy puck with snowball pushback. T3 path silhouettes: orbit halo / motorized stick / huge weighted puck. QA: animation grips, curved puck trails, no copy of Boomerang Monkey equipment.

### Snowboard Trickster (Ninja)

Reuse a more athletic pose; snowboard blade attaches to boots with bindings, not hovering under model. Rotating snowflake discs and stealth-themed jumps are original fantasy features; do not copy Ninja Monkey mask/hood design. Top: multiple discs; middle: sabotage-oriented squad gear and whiteout glyphs; bottom: heavy sticky snowbomb. Source camo detection is intrinsic, so goggles design and UI must indicate it from base tier. QA: board fasteners, body balance, separable throw accessories.

### Winter Games Lodge (Village)

Building buff hub; structurally modeled timber lodge with sport pennants, signal tower, shop awning. Top: athletic academy; middle: radial communications/radar; bottom: commercial building. Buildings should read as support not an attacking cannon. QA: aura ring matches gameplay range, lodge footprint correct, no random collision block across path.

### Track Gritter (Spike Factory)

Mechanical hazard station with hopper, rotating grit wheel, distributor chutes, clear under-track placement zone. Top: larger grit hazard / heavy mines; middle: high-speed spreading and all-track effects; bottom: long-lasting hazard stockpiles. Distinguish grit from enemy snowball particles. QA: track hazard spawning matches simulation, hazards legible, no per-grit particle draw-call explosion.

## B-07. Rolling snowballs: mesh family, layers, variants and animation

### Core model architecture

**Design principle:** Snowballs are highly readable rolling enemies, but don't use a perfect unshaded UV Sphere with a color swap and call it finished. Create a subtly irregular sculpted snow crust, compressed edges, cold specular crystals, distinct shell roughness and baked soft creases. Every visual tier is consistent enough that color change reads as damage progression while different enough to survive low-saturation displays. Animating the rolling texture/pattern is a key part of the concept.

| Tier/class | Form and material | At a glance |
|---|---|---|
| Powder | packed snow, pale blue side shadow, thin dark contour and two chunky crystalline flecks | first/weakest, visible against snow terrain |
| Blue | darker blue ice chips at rim, low-frequency swirl groove | second layer |
| Mint | green translucent accents and asymmetrical squiggle strip | third layer |
| Violet | frosted lavender with angular facet/motif accents | fourth layer |
| Coral | warm soft-pink packed ice, more dynamic segmentation | fifth layer |
| Gold [approval pending] | gold/yellow composite crust, engraved star notch, extra visible ring | special future tier or advanced armored state; **no numerical assumptions** |

**Enemy attributes** must have independent overlays/variants, not an explosion of asset copies: `camo_overlay`, `regrow_stitches`, `fortified_armor`, `lead_cap`, `purple_magic_stripes`, `black_core`, `white_core`, `zebra_ring`, `ceramic_crack_stage`. Ensure external overlays are conforming, seated and do not Z-fight with the base snow shell. For performance prefer instanced small meshes, controlled material variants and selectively activated decals.

### Damage breakup rendering choices

**Recommended runtime approach:** keep canonical simulation enemy type `type_id`, update `VisualState` on `layer_broken` to swap a lightweight shell mesh/material and spawn a **pooled** crumble effect. Preserve world path progress. High-damage hits may skip multiple appearances; do NOT slow the simulation to play each intermediate shell animation. For armored outer shells, a separate crack-stage mesh or material parameter is appropriate. Do not store five nested physically simulated shells inside every enemy unless profiling proves the approach safe.

**Rolling:** orientation derived from track tangent and travel distance/radius; vary spin around curved sections, add small non-physics wobble via separate visual child. The collider follows path and can remain a simple sphere or capsule even when the visual mesh is more advanced. Visual breakup/death should not create physical projectile colliders accidentally.

### Large class / boss hierarchy

Distinguish large classes with independent geometry: (1) heavy compact boulder with obvious plates; (2) multi-lobed compacted avalanche roll; (3) crown-like protrusions and bands; (4) fast narrow snow torpedo; (5) giant composite glacial ball with at least two shell stages. **These are original visual concepts for BTD6 MOAB-class roles**; their combat health/children/speed must be sourced separately. Do not just increase radius of Powder sphere while retaining a one-layer child chain.

### Snowball QA

- At gameplay zoom, Powder is visible on white snow; Blue/Mint/Violet/Coral distinguishable; Gold does not look like the currency pickup.
- A one-hit layer break clearly shows the next lower tier within a fraction of a second; no fake pop on immune hits.
- Snowball rolls along direction of travel, not always around screen world up.
- Child spawn causes no unwanted double cash, frame-time spike or missing visual references; rendering is event-driven.
- All attribute badges and cracks visible without opening inspection tooltip. Huge waves remain legible with VFX reduced.

## B-08. Winter-sports environment asset production inventory

### Battlefield structure: priority order

**Tier E0 (needed for graybox, temporary):** track path, placement mask, neutral ground plane, camera, border collider, exit gate, spawn gate, 3–5 rough blocks for no-placement zones. **Tier E1 (first art pass):** continuous finished ski-course surface, snow berms, fir trees, one lodge, one frozen pond, fence, lamp. **Tier E2 (production polish):** bleachers, rink/curling motif, gondola cabin + supports, festival arches, decorative poles, presents, warming hut, colorful banners, flags, ski equipment racks. **Tier E3 (optional polish):** ambient skiers outside path, chimney smoke, small animals, subtle footprints/particle wind, distant mountains, building window loops. This is a production priority taxonomy, **not** the later master checklist.

### Individual environment asset constraints

| Asset | Must be visually modeled | Avoid |
|---|---|---|
| Ski track | slight bank/berm and worn/groomed grooves; consistent continuous width | texture line drawn over flat snow with no spatial form |
| Snowbank | smooth natural drift profile with wind-driven shaping and multiple scales | chain of overlapping white spheres |
| Evergreen tree | trunk taper/roots, intentional asymmetric branch clusters, snow adhering to branch upsides | cone stacks on cylinder trunk |
| Ski-lift tower | real frame, pulley wheel/hub, cable, load-bearing mount and separate gondola | floating cuboids on two thin poles |
| Gondola cabin | curved roof, seating hints, cable bracket, glass/glazing with cheap opacity | empty floating square with no attachment |
| Ski/chalet lodge | consistent timber/chalet structure, fitted roof, overhang, snow loads, lit windows | roof wedge not touching walls, 10 overlapping boxes |
| Curling/hockey rink | correct iconic line/target graphics on solid frozen surface; surrounding dasher/rail | thin circle overlay with no rink meaning |
| Fence/rail | stakes embedded in terrain, proper cable/wire, curve around route | disconnected sticks along path |
| Terrain transitions | snow-to-ice-to-dirt material borders with blended geometry and trimmed edging | a visible square texture seam |
| Lamp and holiday lights | lantern housing, hanging brackets, warm emissive core and surrounding low-cost light effect | bright sphere light in midair |
| Campus-inspired clocktower | stylized massing and original roof details; avoid direct branded building scan | unlicensed official emblems, malformed primitive collage |
| Presents/decor | bevelled package, conforming ribbon, folded wrap, fitted wreath | cubes with floating colored planes |
| Mountain horizon | layered distant silhouettes and atmospheric color falloff | huge close-up detailed mountain geometry |

**Map performance:** reuse optimized evergreen/tree variations by instancing and rotation; pre-bake decorative static lighting where possible with tested Godot Web support; never give each fairy light its own dynamic omnidirectional light; keep foliage/particles lower priority than attacks and UI. Larger visual props should not cause invisible LOS failures. Coordinate with technical M-05.

## B-09. Materials and texturing standards

**Material library:** `M_snow_powder`, `M_snow_drift_shadow`, `M_ice_track`, `M_packed_ice_enemy`, `M_puffy_winter_cloth`, `M_wool_scarf`, `M_sport_plastic`, `M_ski_metal`, `M_wood_chalet`, `M_glass_goggles`, `M_festival_light`, `M_wax_viscous`, `M_ghost_snow`, `M_gold_special_enemy`, `M_ticket_currency`. Set base color, roughness, metallic where useful, normal detail where economical, alpha only as needed. Distinct macro geometric form is mandatory before any micro normal map.

**High-res master versus game-ready:** make a sculpted, well-finished high-poly source mesh with acceptable close-up quality, and optimize via retopology/decimation + normal baking and carefully chosen silhouette loops for gameplay. Keep high-poly source and export separate; don't ship subdivisions on every enemy. A **2K/4K authoring texture** can be used on hero marketing renders, while actual browser texture atlas size is chosen by on-device profiling; avoid claiming universal 1024/2048/tri limits from BTD6 without source proof.

**Silhouette LoD:** don't decimate the smooth arc of Camel Claus's neck or crucial helmet/weapon shapes; cut hidden undersides, tiny buttons and interior triangles first. Avoid dozens of material slots that cause expensive draw calls for a simple character. Reuse materials and atlases across athlete variants. On snowballs, minimize skeleton and variation mesh costs: they don't need individually rigged facial topology unless art tests justify it.

## B-10. UVs, topology, normals and retopology

- Blockout uses sculpt volumes; final organic head/neck/torso union requires remeshing/bridged custom loops or sculpt + retopo. Select workflow based on rig requirements; **voxel remesh alone does not deliver animation-ready joints**.
- Deformation edge loops around shoulders, knees, elbows, neck base, jaw and eyelids. Face mesh should have contour transitions for expression; don't ask heavy shapekey deformation from triangle soup.
- Hard surface: mechanical parts have justified bevel radii and clean support loops or non-destructive weighted normals; no broken shading on bevels or sharp corners.
- UV islands with reasonable padding, no severe texel stretch on visible costume/face or equipment; overlap only for intentionally mirrored/shared texture areas. Pack to reduce texture churn.
- Origin alignment; consistent axes; apply non-deforming transforms where appropriate; name all pieces and root skeleton; avoid negative scale on exported rigged meshes.
- Verify exported GLB animation transforms and normals in Godot, not only Blender viewport; inspect emissive and transparent effects in Compatibility renderer.

## B-11. Animation, rigs, sockets and game-scene integration

### Athlete animation library

Required before final MVP art signoff: `idle_loop`, `track_target`, `attack`, `impact_recoil`, `celebrate`, optional `upgrade_celebrate` and `ability_use` for relevant towers. Not every unit must use all animations. Animation should be **readable with at most two poses** at game scale and not obscure attack interval control.

### Camel hero animation library

`idle_breathe`, `face_blink`, `turn/aim`, `fire_single`, `fire_double`, `fire_triple`, `focus_on`, `focus_off`, `snowball_frenzy`, `blizzard_barrage`, `celebrate`, `defeat`. Match actual level-unlock anatomy/props. Scarves and ear movement can use baked animation; avoid expensive simulated cloth for ordinary Web runtime.

### Mechanical animation library

Avalanche Cannon: `aim_swivel`, `fire_recoil`, `reload`, `tier_transform`; Ticket Booth: `income_ticket_emit`, `cash_collect`, `upgrade_open_sign`. Blend transitions where tower upgrades might happen mid-round. No inaccurate simulation double-attacks from animation event callbacks; animation events may spawn visual effects **after** simulation has already authorized the shot.

### Asset socket standard

| Socket | Purpose | Affects gameplay? |
|---|---|---|
| `root_ground` | world placement anchor and shadow offset | yes, via consistent transform |
| `aim_pivot` | turret/weapon swivels | presentation receives target vector |
| `muzzle_A/B/C` | attack visual/projectile origins | yes, define matching collision launch policy |
| `effect_center` | ability/status event placement | purely presentational except authored area visualization |
| `weapon_hand_l/r` | equipment contact | render-only |
| `portrait_focus` | target for hero/UI close-up camera | render-only |
| `shadow_anchor` | contact-shadow and selection ring | render-only |
| `projectile_impact` | hit effect and source tracking | render-only, shouldn't determine damage itself |

**Avoid Blender-to-Godot rig surprises:** use one documented skeleton naming scheme and retargeting rule, choose Y-up import behavior, test root motion off/on explicitly, save a low-res and hero-grade LOD, and compare walk/aim animation screenshot before release.

## B-12. Naming, folder layout, dependency and ownership manifest

Proposed source layout beneath a Godot project:

```
assets/
  blender_source/              # store .blend source or use Git LFS if large
    characters/
      hero_camel_claus.blend
      athlete_master.blend
      rookie_gear.blend
      biathlon_gear.blend
      slope_wax_gear.blend
      sorcerer_gear.blend
    machines/
      avalanche_cannon.blend
      ski_ticket_booth.blend
    enemies/
      snowball_shells.blend
      snowball_specials.blend
    environment/
      conn_winter_ski_course.blend
      winter_environment_kit.blend
  exports/
    hero/
    towers/
    snowballs/
    environment/
  portraits/
  materials/
  vfx/
  audio/
  qa_renders/
    clay/
    silhouette/
    turntable/
    game_camera/
```

### Single asset manifest record

```json
{
  "asset_id": "tower_slope_wax_sprayer",
  "gameplay_id": "slope_wax_sprayer",
  "mechanical_reference": "BTD6 Glue Gunner",
  "original_design_status": "PROPOSED",
  "authoring_file": "assets/blender_source/characters/slope_wax_gear.blend",
  "glb_game_export": "assets/exports/towers/slope_wax_sprayer.glb",
  "rig_id": "athlete_common_v1",
  "root_scale_basis": "athlete_body_reference_height_v1",
  "sockets": ["aim_pivot", "muzzle_A", "shadow_anchor"],
  "material_profile": "wax_technician_v1",
  "states": ["base", "top_t3", "middle_t3", "bottom_t3"],
  "lods": ["master_hi", "game_optimized"],
  "renders": ["clay_front", "clay_side", "gamecam", "upgrade_sheet"],
  "status": "NOT_STARTED",
  "reviewer_decision": "PENDING",
  "license_provenance": "original_project_asset"
}
```

**Ownership semantics:** never silently overwrite previously approved .blend masters. A revision changes file version or commits change with QA renders and a visual diff. Approved model asset lives behind one stable resource path so gameplay code isn't rewritten every art pass. Source materials in `references/research/` are reference; `references/design/` hybrid docs are actual project requirements. If asset geometry drives footprint size, that is a **cross-file technical change** requiring review.

## B-13. AI Blender-agent production contract and loop

**Goal:** instruct Opus/GPT/Blender-capable agent to execute work with visual inspection, not merely write a bpy script. The assistant may use Blender MCP to inspect scene and render, but connection state alone does not prove a model exists or passes QA. Produce actual `.blend`, `.glb`, transparent PNG portrait if needed, 4–8 review renders, and concise QA findings.

### Required step sequence per model

1. **Read:** hybrid `01` relevant tower/hero mechanic, hybrid `02` silhouette/VFX palette, hybrid `03` detailed mesh/rig brief, plus original 3D research anti-primitive charter.
2. **Concept:** present shape thesis, primary/mechanical silhouette, art material blocks and proposed top/middle/bottom t3 identities; avoid a close tracer of BTD6 source mesh/texture.
3. **Blockout:** rough shape and pose only; show one quick silhouette render; do not claim final.
4. **Sculpt/mesh:** fuse anatomical continuous masses, refine topological flows, design separate fabricated/fabric components; remove visible primitive roots.
5. **Neutral clay QA:** front, side, three-quarter, top-down, 360° sequence; correct contour and silhouette failures before texturing.
6. **Materials:** apply original palette and appropriate differences (cloth, wood, snow, plastic, wax, metal); enforce roughness and spec hierarchy.
7. **Rig and anchors:** add skeletal controls or mechanical pivots, pose tests, gameplay-aligned projectile sockets and transform axes.
8. **Optimize and export:** preserve master sculpt; create game-ready mesh/LOD and texture atlas; export glTF/GLB.
9. **Test in Godot:** actual Compatibility render in existing project with correct fixed camera, one asset at normal scale and 3–6 adjacent copies, run attack/idle test. Do not assume Blender Eevee preview matches Web build.
10. **Audit and revise:** compare to charter; if any relevant criteria fail, revise actual geometry/material and repeat. Submit asset manifest, source files, QA renders and notes.

### Prompt for a Blender agent — base character model

> Work inside my Godot project's asset pipeline. Read `03_Camel_Claus_Hybrid_3D_Assets_Blender.md`, `02_Camel_Claus_Hybrid_Art_UI_Audio.md` and the relevant gameplay entry in `01_Camel_Claus_Hybrid_Gameplay_and_Balance.md` before modifying files. Produce an **original premium stylized 3D [asset]** with a designed silhouette, coherent high-resolution anatomy, fitted clothing or engineering, artist-quality sculpted transitions and animation-ready structure. Primitives may be used for blocking, but **NOT left as a visibly intersecting primitive assembly**. Use true geometry refinement, retopology, bevels, correct contact and appropriate materials. Maintain editable `.blend` source and optimized `.glb` for Godot Web. Deliver a neutral clay turnaround, black silhouette sheet, normal game-camera capture, a close-up render and a short acceptance-test report. Do not change gameplay stats, wave definitions or tower footprints. If issues appear, revise the model instead of masking them with lights/VFX. Do not recreate Ninja Kiwi asset topology, textures, models or exact character art.

### Prompt for upgrading an existing model

> Review the approved base asset and its primary mechanical source. Create a coherent **path/tier-3 evolution** using equipment, construction, clothing silhouette and pose changes consistent with the source upgrade's mechanical purpose. Keep base model identity; implement primary visuals as a clear silhouette and secondary crosspath as non-dominant modular additions. Test overlapping accessories, attachment pivots and normal game-camera readability. Create only the requested upgrade state; do not prebuild all 150 possible tier items without approval.

## B-14. Measurement, acceptance scoring, and performance gates

### Multi-view anti-primitive scorecard

| Category | 0 — reject | 1 — revise | 2 — accept |
|---|---|---|---|
| Silhouette | form unclear / stock primitives | mostly good, weak pose | recognizable role and fluid intentional contour |
| Organic connections | pasted-on sphere/cylinder heads/limbs | some unexplained seams | sculpted continuous tissue and believable weight |
| Fitted clothing/gear | floats/intersects | minor clipping | seams/fasteners/contact all believable |
| Hard-surface construction | unsupported cylinders/boxes | partial mounting detail | mechanical joints, hubs and supports convincingly built |
| Material coherence | everything same plastic shine | some variation | fabric/metal/wood/ice feel distinct and stylized |
| Rig/action | clipping, wrong aiming sockets | mild pose trouble | exports and animation correctly match sim events |
| Art family cohesion | stylistically isolated | similar palette only | proportions, detailing and shading feel authored together |
| Gameplay readability | unclear at game scale | needs stronger prop | clearly readable silhouette and upgrade branch |
| Godot Web suitability | fails import/performance | import okay but heavy | measured acceptable in representative stress scene |
| Originality | traces BTD6 source character/asset | overly derivative costume | clearly independent recognizable original design |

**Approval gate:** no zero scores. Target two in at least eight of the ten areas; an asset with one in more than two areas needs another modeling pass. This is a **proposed art review rubric**, not a universal industry standard.

### Mandatory QA captures

- Front, side, rear and 3/4 **neutral clay** model screenshots; compare facial/neck transitions, fabric and props.
- Pure black silhouette at gameplay camera with transparent/white background; ensure primary function recognized.
- 360° smooth turntable / six views; if a rig fails in the back view, it is not ready.
- Low-resolution 320×180 and native 1080p screenshot with another 3–6 towers to see overlap/readability.
- One motion sequence per type (Camel hero focus/attack; athlete throwing/shooting; machine recoil; ticket booth pickup; snowball layer break).
- Godot imported GLB test with actual material and renderer, verified muzzle/footprint positions.
- Performance table measured on the target platform: render frame times, draw calls, total triangles/meshes, texture memory, and GPU/CPU budget if profiling tooling permits. **No fake universal triangle counts.**

### Placeholder-to-final swap acceptance

The final model must be interchangeable with its technical placeholder without changing: purchase price; tower positioning; target radius; projectile collision damage; wave timing; hero XP; economy; legal upgrades; UI hit-test zones. If higher model requires footprint adjustment, trigger explicit technical review and new balance tests. Do not have Blender-generated visual transform silently become attack-range multiplier.

## B-15. Practical browser constraints and fallback strategies

Godot 4.7.2 project was configured with **Compatibility renderer** and GDScript for Web export. Check the project's actual Godot version and import settings rather than blindly assuming every Blender shader works after GLB export. Reference: [Godot available 3D scene formats](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/available_formats.html), [Godot 3D optimization](https://docs.godotengine.org/en/stable/tutorials/performance/optimizing_3d_performance.html), [Godot import configuration](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/import_configuration.html).

**Fallback quality policy:** when FPS degrades, preserve readable facial/weapon silhouette and deliberate sculpt; reduce hidden geo, microdetail, distant trees, particle volume, transparent layers, shadow/light complexity, and materials. Scale texture atlas intelligently; reuse material instances; rely on engine LOD/instancing when effective. Avoid replacing the model with a literal cylinder/sphere proxy as final art. Placeholders are only for simulation phase.

**Snowball population stress:** dozens to hundreds of moving enemies should use a single or few mesh families with material variants and mostly unrigged static geometry; status overlays should be selective, particles pooled; child snowballs get correct new shell and path status. An attractive close-up enemy with 20 4K materials and independently animated bones won't survive this phase.

## B-16. Boundaries between gameplay and modeling teams

| Situation | Gameplay document rules | Modeling document obligations |
|---|---|---|
| Snowball cracked | damage resolver removes exact source layer | display next shell, brief breakup, no extra damage |
| Glue/wax applied | status manager controls slow/duration | wax film and sound visibly persist/expire accordingly |
| Focus stance | hero's cooldown/range/projectile speed change at Lv4 | visor/pose/reticle toggle with matching state |
| New projectile barrel | attack definition controls count and firing times | instantiate correctly aligned muzzle and barrel mesh |
| Ticket income | economy ledger credits money | optional card/ticket animation; does not generate cash |
| Path changes | path and range changes alter balance | do not move route just for composition silently |
| Upgrade bought | valid crosspath state and price | switch tier identity, accessories and UI card |
| Photo/portrait | no mechanical change | use high-resolution master view and matching current costume |
| Lag | simulation profiling identifies bottleneck | cull/LOD/batch meshes, cap VFX, preserve enemy layer clarity |

## B-17. Approval gates and open decisions (before art phase)

**Confirmed:** one camel hero + six initial towers; four future towers only; colored layered rolling snowballs with chosen palette; nonrealistic cute humanoid sports characters; professional sculpted quality; main prototype technical placeholders first. **Still to decide:** exact Camel Claus bipedal/foreleg weapon pose, final unit proportions and hero scale, ski resort/map exact silhouette, logo and name, whether campus branding is fictionalized, how Gold mechanically fits, exact gear design for Wizard's winter-sports identity, optimal detail under browser performance, potential use of optional animated ski lift.

**Do not build a master roadmap yet.** Once all three hybrid MDs have been approved, a separate requested **master development plan** should index them, track dependencies, make phases checkable and assign QA gates. This file supplies asset-specific requirements only, not a project-tracking substitute.

## B-18. Sources and authorship notes

**Attached primary:** `BTD6_3D_Asset_Modeling_and_Blender_Production_Reference.md`, A-01/A-04/A-05/A-06/A-07/A-08/A-09/A-10/A-11/A-12/A-13/A-14/A-15/A-16/A-17, plus `BTD6_Art_Audio_Visuals_and_UX.md` V-03/V-05/V-09/V-10/V-12/V-13. The BTD6 volume is a *reference to study*, not a license to redistribute models. The proposed asset procedures, acceptance rubric, proportions, and project structures in this hybrid document are creative design **proposals**, not statements of Ninja Kiwi's original asset production internals.

**External context:** [BTD6 official game](https://store.steampowered.com/app/960090/Bloons_TD_6/); [winter map Alpine Run](https://teemo.dev/game-design/bloons-td-6/wiki/maps/alpine-run/); [winter map Skates](https://teemo.dev/game-design/bloons-td-6/wiki/maps/skates/); [One Two Tree](https://teemo.dev/game-design/bloons-td-6/wiki/maps/one-two-tree/); [Godot glTF](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/available_formats.html).
