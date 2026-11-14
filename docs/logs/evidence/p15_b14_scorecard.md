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
