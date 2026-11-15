# Dev 9 — HYB-B B-14 scorecard: prepared Tripo models (2026-11-14)

Scores: 0 reject · 1 revise · 2 accept. Gate (B-14): no zeros; 2 in ≥ 8 of 10; a 1 in more than two areas needs another
modeling pass. Self-assessed by the agent from the QA captures below; **owner review decides**. Not a P15-T09/G7 sign-off.

Captures: `p15c_<id>_clay_turnaround.png` (front, right, back, left, 3/4 neutral clay), `p15c_<id>_silhouette.png`
(game camera + front, flat black), `p15c_<id>_closeup.png` (Blender EEVEE, source PBR maps), Godot:
`p15c_closeup_roster_rest.png`, `p15c_<id>_closeup_{firing,rest}.png`, `p15c_gamecam_roster_{idle,firing}.png` (+ `_zoom4x`),
`p15c_thumb_320x180.png`. Measurements: `p15c_review.txt`, `p15c_prepare_<id>.log`.

| Category | Avalanche Cannon | Biathlon Ranger | Slope Wax Sprayer |
|---|---|---|---|
| Silhouette | 2 — sled feet, drum, side tank read in black | 2 — rifle breaks the outline, beanie + pompom, side-on marksman stance | 1 — tanks dominate; the spray wand sits inside the front/game-camera silhouette (ART_STYLE rule 2: role prop away from the body) |
| Organic connections | n/a (2) — machine | 2 — head, ears, hair one surface; no seams in clay | 2 — same |
| Fitted clothing / gear | 2 — drum sits in the yoke on trunnions, snow loads rest on top | 2 — both hands grip the stock/fore-end, bipod under the barrel, collar/scarf seated | 2 — harness and apron straps, hose runs from the wand to the tank pack |
| Hard-surface construction | 2 — bolted yoke, trunnion hubs, sled cross-beams; bore is a shallow recessed disc (no barrel depth) | 2 — stock, barrel bands, scope on a mount, bipod legs | 2 — tanks with caps/gauge, nozzle head |
| Material coherence | 1 — wood/metal/snow differ by colour, but all similarly glossy (roughness map mean 0.40); "metal" painted non-metal (metallic ≈ 2%) | 1 — very glossy everywhere (roughness mean 0.21): cloth reads as vinyl | 1 — glossy (roughness mean 0.38) |
| Rig / action | 2 — recoil + squash on the visual pivot in sim time; puff at the bore marker; aim error 0° | 2 — barrel (not body) aims via `weapon_yaw_deg` 60°; recoil along the barrel + 4° muzzle climb; flash at the barrel tip; aim error ≤ 1.7° | 2 — pump (squash + 3° lean) in sim time; puff at the nozzle; shots start at the nozzle; aim error ≤ 2.5° |
| Art family cohesion | 1 — cohesive with Ranger/Wax (same Tripo family/palette), not with the runtime procedural Rookie | 1 — same | 1 — same |
| Gameplay readability | 1 — 0.93 m shown (half the 1.8 m characters), ~6 px at 320×180; Label3D names of neighbours cover it at touching footprints | 1 — reads at the game camera (goggles, rifle), but the rifle reaches 1.0 m from the centre: 0.39 m past the track edge and up to 0.39 m into a touching neighbour's footprint | 1 — reads as red hat + tank pack; the wand barely shows at the game camera |
| Godot Web suitability | 2 — browser stress (8 Cannons + 4 Rookies, 120 snowballs) p95 5.6 ms at the 240 Hz display cap, 0 console errors | 2 — browser stress roster mix p95 5.3 ms, 0 errors | 2 — same run |
| Originality | 2 | 2 — original elf marksman | 2 — original elf wax technician |
| **2s / 1s / 0s** | **7 / 3 / 0** | **7 / 3 / 0** | **6 / 4 / 0** |

By the letter of the gate all three are "revise" (more than two 1s). Most 1s are **not modeling defects**:

- Material coherence: the gloss is authored in the supplied roughness maps (identical in Blender and Godot; import
  verified: albedo, normal, ORM roughness/metallic all bound, opaque, single-sided). Fix options (owner): accept the
  vinyl-toy look, or a roughness floor/remap in the preparation script (would change the source-art look).
- Art family cohesion: the runtime Rookie is still the old procedural model (owner boundary for this batch). The
  four Tripo models share one family; replacing the Rookie (separate task) resolves most of this.
- Readability: size/footprint/camera decisions, reported, not compensated (see the report and DEC-041).
- Wax silhouette is the one source-model shape note: the role prop is held in front of the body.

## Performance table (measured)

| Asset | Game tris | Surfaces (+ outline overlay) | Textures | Notes |
|---|---|---|---|---|
| avalanche_cannon.glb | 24,996 | 1 (+1) | 3 × 1024² PNG (albedo, ORM, normal), VRAM-compressed on import | static |
| biathlon_ranger.glb | 24,996 | 1 (+1) | same | static, 16 faces differ from a normal recalculation (no visible defect in clay or Godot) |
| slope_wax_sprayer.glb | 24,988 | 1 (+1) | same | static |

Stress (`tests/tools/stress.tscn`, 900 frames after 120 warm-up, 120 moving immune Coral kept topped up, 1152×648):

| Run | Frame ms p50 / p95 / p99 / max | Draw calls p50 | Primitives p50 | Video mem |
|---|---|---|---|---|
| Desktop (vsync off) cannon mix 8 C + 4 R | 1.22 / 1.66 / 2.47 / 3.60 | 968 | 417k | 57.3 MB |
| Desktop roster mix 3 each | 1.15 / 1.64 / 2.62 / 3.60 | 996 | 388k | 56.7 MB |
| Desktop roster mix, greybox non-Rookie towers | 1.23 / 1.75 / 2.80 / 3.94 | 948 | 268k | 56.7 MB |
| **Chrome** (display-paced 240 Hz) cannon mix | 4.20 / 5.60 / 8.30 / 10.90 | 978 | 417k | 61.4 MB |
| **Chrome** roster mix | 4.20 / 5.30 / 7.20 / 10.70 | 968 | 388k | 60.8 MB |

Device: Windows 11, RTX 5080 laptop GPU (Chrome: ANGLE D3D11, WebGL 2). Limitations: high-end GPU only; the browser
always paces to the display, so p50 = the 4.17 ms refresh and headroom below it is not measured; no low-end/mobile
device; ~970 draw calls per frame is the main Web risk on weaker GPUs (mostly the 120 snowballs + outlines, the
greybox run shows the models add ~2–5% draws and ~120k primitives).

## Known remaining defects / notes

Cannon bore has no depth; Ranger rifle overreach (above); Wax wand hidden in the front silhouette; all three glossy.
Hidden geometry not checked under the hats (single shell, no interior).
