# Dev 10 — HYB-B B-14 scorecard: Snow Sorcerer + Ski Resort Ticket Booth (2026-11-14)

Scores: 0 reject · 1 revise · 2 accept. Gate (B-14): no zeros; 2 in ≥ 8 of 10; a 1 in more than two areas needs another
modeling pass. Self-assessed from the captures below; **owner review decides**. Not a P15-T09/G7 sign-off.

Captures: `p15d_<id>_{clay_turnaround,silhouette,closeup}.png` (Blender), `p15d_<id>_closeup_{firing,rest}.png`,
`p15d_closeup_roster_rest.png`, `p15d_gamecam_roster_{idle,firing}.png` (+ `_idle_zoom4x`), `p15d_booth_tickets*.png`,
`p15d_thumb_320x180.png`; measurements `p15d_review.txt`, `p15d_prepare_<id>.log`.

| Category | Snow Sorcerer | Ski Resort Ticket Booth |
|---|---|---|
| Silhouette | 1 — compact robed elf; the staff is thin and vertical beside the body, so the role prop breaks the outline only as a line; at the game camera it reads as a red hat with an icy dot | 2 — gabled chalet booth, snow roof, counter + lamps |
| Organic connections | 2 — head, ears, hair continuous | n/a (2) — building |
| Fitted clothing / gear | 2 — mitten grips the staff, cape and collar seated | 2 — roof rests on posts, counter and lamps mounted |
| Hard-surface construction | 2 — staff with bands and snowflake head | 1 — front is detailed; back and side walls are plain panels |
| Material coherence | 1 — glossy authored roughness, like the other Tripo models | 1 — snow, timber and paint differ by colour, all similarly glossy |
| Rig / action | 2 — cast pulse (6% stretch + 4° lean) in sim time, icy puff at the staff head, shots start there; aim error ≤ 2.4° | 2 — stationary (pivot never turns, verified through a round of income), small bounce + gold window puff on each income event |
| Art family cohesion | 1 — matches the Tripo family, not the runtime procedural Rookie | 1 — same |
| Gameplay readability | 1 — 1.5 m shown (compact by design) and the thinnest prop of the roster; labels of neighbours cover it at touching footprints | 2 — strongest tower read on the map; 1 of 4 base ticket spots (2 of 8 with upgrades) is behind the 2.4 m building, now drawn on top so it stays visible |
| Godot Web suitability | 2 — browser full-mix stress p95 4.4 ms, 0 errors (12.5k tris) | 2 — same run (25k tris) |
| Originality | 2 | 2 |
| **2s / 1s / 0s** | **6 / 4 / 0** | **8 / 2 / 0** |

Sorcerer is "revise" by the letter of the gate; its 1s are silhouette/readability (thin prop on a compact body: a
size or prop-scale decision, not compensated here), the shared Tripo gloss and the old-Rookie cohesion gap. Booth passes.

## Performance (measured)

| Asset | Game tris | Surfaces (+ outline) | Textures |
|---|---|---|---|
| snow_sorcerer.glb | 12,508 | 1 (+1) | 3 × 1024² (albedo, ORM, normal) |
| ski_resort_ticket_booth.glb | 25,000 | 1 (+1) | 3 × 1024² |

Texture memory note (all Tripo models): the maps import as WebP and upload as uncompressed RGB8 with mipmaps
(~5.6 MB each in video memory); `compress/mode=2` in this project did not produce VRAM-compressed (S3TC) textures. All
six tower models are preloaded by `tower.gd` `PROFILES`, so their 15 maps are resident in every match: video memory
~86 MB in the browser stress (Dev 9: ~61 MB with three models). Main memory risk for low-end/mobile Web.
