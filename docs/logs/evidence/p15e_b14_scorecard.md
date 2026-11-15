# Dev 11 — HYB-B B-14 scorecard: Camel Claus + Snow Sorcerer at 1.7 m (2026-11-15)

Scores: 0 reject · 1 revise · 2 accept. Gate (B-14): no zeros; 2 in ≥ 8 of 10; a 1 in more than two areas needs another
modeling pass. Self-assessed from the captures below; **owner review decides**. Not a P15-T09/G7 sign-off.

Captures: `p15e_<id>_{clay_turnaround,silhouette,closeup}.png` (Blender), `p15e_closeup_lineup.png`,
`p15e_gamecam_lineup(_crop4x).png`, `p15e_closeup_lineup_hero150.png` / `p15e_gamecam_lineup_hero150_crop4x.png`
(the 1.5 m-modelled alternative), `p15e_camel_claus_{closeup_rest,windup,frenzy_firing,levelup,focus}.png` (+ `_feedback_sheet`),
`p15e_gamecam_hero_frenzy.png`, `p15e_thumb_320x180.png`; measurements `p15e_review.txt`, `p15e_prepare_<id>.log`.

| Category | Camel Claus (2.52 m shown) | Snow Sorcerer (1.70 m shown) |
|---|---|---|
| Silhouette | 1 — side view reads camel (S-neck, snout, sack); from the front and at the game camera the hat, ears and goggles carry the read and the launcher sits inside the outline (front silhouette is a hatted mascot, not "camel" by outline alone) | 2 — now 1.7 m: the snowflake staff head clears the hat line at the game camera (lineup crop) |
| Organic connections | 2 — head/neck/torso continuous, ears seated | 2 |
| Fitted clothing / gear | 2 — scarf wraps, goggles strap on the hat, mittens grip the launcher, sack strapped | 2 |
| Hard-surface construction | 2 — candy-striped crossbow launcher with stock and limbs | 2 |
| Material coherence | 1 — glossy authored roughness, same as the other Tripo models | 1 — same |
| Rig / action | 2 — unrigged by owner scope: aim on the pivot (launcher axis = body axis, 0.0° aim error), wind-up from the cooldown, recoil 5 cm + 3° climb, gold puff at the launcher, Frenzy elastic recoil + red pulse ring, Focus lean + cyan reticle + goggle glow, level-up hat glint + gold XP ring; all in sim time | 2 — unchanged cast pulse; muzzle marker re-derived at 1.508 m |
| Art family cohesion | 1 — matches the Tripo family, not the runtime procedural Rookie | 1 — same |
| Gameplay readability | 2 — 41 px tall at the game camera vs 27–30 px for the elves: the tallest defender, clearly the hero; at 320×180 a warm-orange blob | 2 — 27 px (was ~24), staff readable in the lineup; labels of neighbours still cover it at touching footprints (existing) |
| Godot Web suitability | 2 — 25k tris, 3 × 1024² maps, browser round with 0 errors (batch B measures memory/stalls) | 2 |
| Originality | 2 — owner's camel mascot; no Quincy likeness | 2 |
| **2s / 1s / 0s** | **7 / 3 / 0** | **8 / 2 / 0** |

Deviation for the owner: the supplied Camel holds a two-handed candy-striped crossbow launcher, not the "ski-pole
launcher" of DEC-033 / ART_STYLE §1. The supplied model is used as delivered (no remodel in scope).

## Measured (prepared GLBs)

| Asset | Game tris | Surfaces (+ outline) | Textures |
|---|---|---|---|
| camel_claus.glb | 24,994 | 1 (+1) | 3 × 1024² (albedo, ORM, normal) |
| snow_sorcerer.glb | 12,508 | 1 (+1) | 3 × 1024² (unchanged maps, geometry rescaled) |
