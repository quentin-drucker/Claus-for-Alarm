# Active source models

One named folder and one FBX per model. Texture directories retain their exported relative names so dependencies stay together. `art_src/.gdignore` excludes source assets from runtime imports.

| Model | Active FBX |
| --- | --- |
| Snowball Rookie | [Rigged final](snowball_rookie/snowball_rookie_rigged.fbx) |
| Camel Claus | [FBX](camel_claus/camel_claus.fbx) |
| Avalanche Cannon | [FBX](avalanche_cannon/avalanche_cannon.fbx) |
| Biathlon Ranger | [FBX](biathlon_ranger/biathlon_ranger.fbx) |
| Slope Wax Sprayer | [FBX](slope_wax_sprayer/slope_wax_sprayer.fbx) |
| Snow Sorcerer | [FBX](snow_sorcerer/snow_sorcerer.fbx) |
| Ski Resort Ticket Booth | [FBX](ski_resort_ticket_booth/ski_resort_ticket_booth.fbx) |
| Hockey Slapper | [FBX](hockey_slapper/hockey_slapper.fbx) |
| Snowboard Trickster | [FBX](snowboard_trickster/snowboard_trickster.fbx) |

Reference images are collected in `references/`. Older Rookie FBXs/GLB and historical manifests are retained in `../archive/model_collection_before_cleanup/`; those old manifests describe the pre-cleanup paths and are not the current model index.

Use the existing AccuRIG Rookie as the authoritative Rookie model. No additional rigging or complex per-character animation is required for the current time-limited build. Other models use simple shared whole-object activity animation when implemented. See [deferred work](../../docs/DEFERRED_WORK.md).

All 79 original files were preserved and hash-verified during reorganization. No FBX contents or textures were re-exported. Runtime integration and visual/rig validation are separate tasks.

## Runtime preparation (P15-A01)

`art_src/tools/prepare_source_model.py` turns a source FBX into a runtime GLB without touching the source folder
(headless Blender, see `docs/COMMANDS.md`). The `PROFILES` table in the script holds each model's decisions; `inspect`
re-measures every source. Conventions: 1 unit = 1 m, origin = ground-contact centre = gameplay position and turn axis,
faces Blender +Y (= Godot −Z). The GLB holds the **modelled** size; the 1.5× display scale (DEC-036) is applied once at
runtime by the model's `resources/presentation/<id>.tres`.

| Model | Raw import (source units): height · ground offset · centre offset · envelope r | Notes | Prepared |
| --- | --- | --- | --- |
| Avalanche Cannon | 0.946 · 0 · (0.002, 0.000) · 0.668 | muzzle faces −Y; one stray 1-face island (the 3 open edges) | **yes**: yaw 180°, envelope 0.44 m (0.66 m shown), 0.62 m (0.93 m shown), stray face deleted, 1024² PNG maps, `muzzle_A` (0, 0.141, 0.409), `effect_center` (0, 0, 0.311) |
| Snowball Rookie (AccuRIG) | 1.000 · 0 · (−0.001, −0.003) · 0.437 | 71 bones, armature scale 0.01, only `0_T-Pose` actions, embedded diffuse/normal | no (runtime keeps `elf_rookie.glb`) |
| Camel Claus | 1.000 · 0 · (−0.001, −0.076) · 0.338 | recalculated normals disagree on 11k faces: the recalc is unreliable on this mesh, check visually before changing | no |
| Biathlon Ranger | 1.000 · 0 · (−0.067, 0.080) · 0.559 | faces −Y; rifle barrel 60° off the body axis toward the character's left at 27% height (PCA, pitched ~3° down); ground centre = boots (the bipod feet stay above the 2 cm band); 16 faces differ from a recalc (no visible defect) | **yes** (Dev 9): yaw 180°, height 1.2 m (1.8 m shown, = Rookie), envelope 0.67 m (1.0 m shown: the rifle), `muzzle_A` (−0.426, 0.458, 0.312) at the barrel tip, `effect_center`; profile `weapon_yaw_deg` 60 |
| Slope Wax Sprayer | 1.000 · 0 · (−0.005, −0.037) · 0.392 | faces −Y; spray wand in the right hand points along the body axis (0.26 m right of centre), nozzle at ~40% height; tank pack sets the envelope | **yes** (Dev 9): yaw 180°, height 1.2 m (1.8 m shown), envelope 0.47 m (0.71 m shown), `muzzle_A` (0.281, 0.304, 0.476) in the nozzle, `effect_center` |
| Snow Sorcerer | 0.719 · −0.007 · (−0.036, −0.035) · 0.326 | 7 mm below ground, 12.5k tris | no |
| Ski Resort Ticket Booth | 1.000 · 0 · (0.000, 0.001) · 0.619 | building; data footprint r 1.5 m | no |
| Hockey Slapper | 0.786 · −0.011 · (0.103, −0.053) · 0.287 | no gameplay (not in the submission) | no |
| Snowboard Trickster | 0.801 · 0 · (0.008, 0.014) · 0.299 | object yaw −10°; no gameplay | no |

All sources: one mesh, one material (Principled, HASHED blend in Blender, opaque JPEG maps: base colour, normal,
roughness, metallic; 2048²), ~12.5k–25k tris. Raw measurements: `docs/logs/evidence/p15a_source_inspect.txt`.
Sizes for the other towers are decided when each is prepared (envelope vs its footprint, height vs the Rookie);
they are not copied from the Cannon. Machines are fitted by envelope (Cannon: footprint), characters by height
(ART_STYLE §2 base elf 1.2 m; Ranger and Wax: DEC-041 proposed). Muzzle markers come from `weapon_tip()`: the front-most
3 cm slab along the weapon's yaw inside a height band, 4 cm back (the Cannon's bore marker is reproduced exactly).
Prepare logs: `docs/logs/evidence/p15c_prepare_<id>.log`; QA renders `p15c_<id>_{clay_turnaround,silhouette,closeup}.png`
(`qa_render.py` with the prepared `.blend`); B-14: `p15c_b14_scorecard.md`.

Integration status (Dev 9): Cannon, Ranger and Wax Sprayer are bound in game (`resources/presentation/<id>.tres`) and
verified in the editor and the exported Web build; **owner approval of their size/readability is still open**, and
availability of the other sources (Sorcerer, Booth, Camel Claus, AccuRIG Rookie) is not integration.
