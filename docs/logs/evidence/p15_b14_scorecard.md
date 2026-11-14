# P15 style slice — HYB-B B-14 scorecard (2026-11-14)

Scores: 0 reject · 1 revise · 2 accept. Gate (B-14): no zeros; 2 in ≥ 8 of 10; a 1 in more than two areas needs another
modeling pass. Self-assessed by the agent; **owner review decides**.

| Category | Rookie elf | Snowball shell + band | Lodge |
|---|---|---|---|
| Silhouette | 2 — cap, ears, raised snowball arm read in black silhouette | 2 — lumpy crust + spiral wraps, not a UV sphere | 2 — gable, chimney, snow load |
| Organic connections | 2 — head/ears/nose one surface; jacket+sleeves one garment | 2 — one continuous shell | n/a (2) — snow loads blended |
| Fitted clothing / gear | 1 — trims, strap and cap follow the real garment sections; snowball sits in front of the mitten, not gripped by fingers | 2 — band seated, inner faces removed | 2 — roof rests on walls, notched log corners, wired lights, seated wreath |
| Hard-surface construction | 1 — satchel/buckle are simple soft forms | n/a (2) | 2 — logs, fascia, frames, sills, chimney cap; shutters are plain bevelled boards |
| Material coherence | 1 — roughness hierarchy per family, but flat colours, no knit/leather texture yet | 1 — one crust material, tint + vertex AO | 2 — timber / stone / snow / glow distinct |
| Rig / action | 1 — idle + attack play in Godot, faces target; `muzzle_A` socket exists but shots still spawn at tower centre 0.5 m | 2 — rolls about the travel axis | n/a (2) |
| Art family cohesion | 2 | 2 | 2 |
| Gameplay readability | 1 — only ~22 px tall at 1152×648 (cap + jacket colour read, face does not); see 1.5× comparison | 2 — tints differ in hue and value; B/W/P/C letters kept | 2 — strongest read on the map |
| Godot Web suitability | 1 — imports, 0 errors, Web OK; 12 surfaces + outline overlay ≈ 24 draws per Rookie; no stress scene yet | 1 — 1.4k tris, shared mesh/materials; no 100+ stress scene yet | 2 — one instance, 15.6k tris, 8 surfaces |
| Originality | 2 — original elf design, no BTD6 traces | 2 | 2 |
| **2s / 1s / 0s** | **4 / 6 / 0 → revise pass needed** | **8 / 2 / 0 → passes** | **10 / 0 / 0 → passes** |

## Performance table (measured, Windows 11 / RTX 5080 laptop, Chrome, 1280×720)

| Asset | Game tris | Surfaces (draws incl. outline) | Textures | Notes |
|---|---|---|---|---|
| elf_rookie.glb | 17.3k | 12 (+12 overlay) | none | skinned, 15 bones, 2 actions |
| snowball_shell.glb | 1.4k | 1 (+1 outline pass) | none (vertex AO) | mesh + one material per layer shared by all snowballs |
| snowball_marker.glb | 1.5k | 1 (+1) | none | only on Black/White/Purple/Camo |
| lodge.glb | 15.6k | 8 | none | static |

Browser, round 1 with 3 Rookies: 239.9 fps (display cap), worst frame 8.3 ms, 0 console errors/warnings.
Not yet measured: 100+ snowball stress, texture memory (no textures), low-end device.

## Defects fixed at source during the loop (B-13 step 10)
Floating fur hoops → trims rebuilt from garment cross-sections; boots read as bare feet → dark timber; arm tear at
the shoulder → smooth weights; brows/smile off the face → projected onto the skin; stray catch-light; tennis-ball
seam → spiral rolled-snow wraps; butterfly roof (rotation sign); lumpy roof snow rows; floating light string → wired
catenary; torus wreath → fir-clump wreath + bow; invalid joined mesh → validate().

## Known remaining defects
Snowball high-res master shows a beaded ridge along the spiral lip (game mesh is clean). Elf: 12 material slots
(atlas later), snowball not gripped, muzzle not wired to projectile visuals. Lodge back gable is plain.

---

# Rookie revision (DEC-036) — re-score 2026-11-14

Changes: 1.5× display scale; right mitten now grips the snowball (palm behind, finger lobe over the top-front, thumb
inside); shots start at `muzzle_A` in the hand and blend onto the simulated flight line in ~0.2 s (presentation only);
12 materials → 2 (matte + gloss) with a vertex-colour atlas: rosy skin `#EEA88A` + cheek blush, knit ribs on cap and
mittens, fluffy fur, scuffed boot toes, light-from-above cloth gradient, baked AO; eyes enlarged and aligned to the face
normal, bolder brows; buckle seated on the satchel; label lifted clear of the cap.

| Category | Before | After | Evidence |
|---|---|---|---|
| Silhouette | 2 | 2 | `p15r_elf_rookie_silhouette.png` |
| Organic connections | 2 | 2 | `p15r_elf_rookie_clay_turnaround.png` |
| Fitted clothing / gear | 1 | **2** — snowball gripped; face details, buckle and trims seated on their surfaces | clay turnaround, close-up |
| Hard-surface construction | 1 | **n/a (2)** — no mechanical parts by design (DEC-036 C: hand-throw; sling = later upgrade look) | — |
| Material coherence | 1 | **2** — matte cloth/skin/fur vs gloss eyes/gold; painted knit, fur, blush, AO | `p15r_elf_rookie_closeup.png` |
| Rig / action | 1 | **2** — shots leave the hand (`muzzle_A`), faces target, idle + attack; skeleton reuse proven (`p15r_rig_reuse.md`) | `p15r_godot_gamecam.png` |
| Art family cohesion | 2 | 2 | — |
| Gameplay readability | 1 | **2** — ~33 px at 1152×648: cap, ears, jacket, raised snowball read; face reads as skin + eyes when facing the camera (fine features are portrait-scale, B-01 scale 3) | `p15r_godot_idle_zoom.png`, `p15r_godot_zoom.png` vs `p15_godot_zoom4x_before.png` |
| Godot Web suitability | 1 | **2** — 4 draws per Rookie (was 24); stress 12 Rookies + ~120 snowballs: 240 fps (vsync), p95 4.3 ms, max 6.2 ms, 0 spikes, ~1,060 draws, 21 MB VRAM (desktop); Web 1280×720 240 fps, worst 4.6 ms, 0 console errors | `p15r_godot_stress.png`, `p15r_web_*` |
| Originality | 2 | 2 | — |
| **2s / 1s / 0s** | 4 / 6 / 0 | **10 / 0 / 0 → passes the gate** | |

Still open: the stress test ran on a desktop RTX GPU, not a low-end laptop, and ~1,060 draw calls is high for weak
WebGL devices. If needed, the shell outline `next_pass` can be dropped for small layers. Face detail is not legible at
game scale; that is a camera limit, not a model defect.
