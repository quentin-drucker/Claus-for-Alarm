# Claus for Alarm — Art Style Sheet (P15-T01)

One page. Sources: HYB-A A-01/A-03/A-05/A-12, HYB-B B-01/B-03/B-07/B-09/B-14, decisions DEC-032…035.
Status: **PROPOSED — owner directs the look.** Values marked *(proposal)* are not A-01 tokens and need sign-off.

## 1. Shape language

| Family | Shape rule | Never |
|---|---|---|
| Elves (towers) | soft pear/egg masses, big round head, pointed ears that sweep up-and-back, short padded limbs, big boots with a curled toe, one oversized role prop | stick limbs, sphere-on-cylinder joints, cone hats |
| Camel Claus (hero) | S-curved neck, long muzzle blended into cheeks, upright mascot stance, two-handed ski-pole launcher (DEC-033) | donkey/horse read, hump glued on |
| Snowballs | near-spheres with a lumpy packed crust, one tier-specific groove/fleck pattern that turns as they roll | perfect UV sphere, flat colour |
| Buildings / props | chunky chalet massing, thick snow loads, deep overhangs, bevelled timber; every part rests on something | roof wedge on a box, floating parts |

Silhouettes read in this order at the game camera: **track → snowball threats → defenders → decoration** (A-01).

## 2. Proportions and scale (1 Godot unit = 1 m; tower range unit = 0.1 m)

| Asset | Height | Head | Notes |
|---|---|---|---|
| Elf base (Snowball Rookie) | **1.20 m** to cap top (1.35 m with cap tip) | ≈ 0.40 of body height | fits the Rookie footprint (r 0.6 m) |
| Other elves (later) | 0.95–1.15 × base | same head | build differs per tower (DEC-034): slim Ranger, broad Wax tech, short robed Sorcerer |
| Camel Claus | **1.4 × elf** (≈ 1.7 m) | — | hero must out-scale every elf (B-02) |
| Snowball shell | ⌀ 0.80 m (sim contact radius 0.4 m) | — | a snowball is ~⅔ of an elf's height |
| Lodge | 5 × 4 m footprint, ~3.6 m to ridge | — | sits exactly on the Lodge blocker box |

Origin = ground-contact centre. Models face Blender **+Y** (= Godot −Z); idle towers turn to face the camera.

## 3. Palette (HYB-A A-01 tokens)

Characters: jacket **College navy `#20517A`**, trims/cap **Festive red `#D9545C`**, fur cuffs/pompom **Snow base
`#E7F4F8`**, buckles/bells **Warm gold `#F9C96D`**, boots **Cabin timber `#A8795A`**, eyes/brows/outline
**Midnight spruce `#173C4E`**, trousers **Forest teal `#1B6D68`**.
Snowballs: Powder `#DBE9F5`, Blue `#72CEF5`, Mint `#4ACAAA`, Violet `#BD8DF1`, Coral `#F59471` (A-01 enemy swatches).
Environment: Snow base / Shadow snow `#AFC7D5`, Cabin timber, Festive red, Warm gold (lit windows), Forest teal.

*Proposals (no A-01 token exists):* elf skin **`#F2C7A5`** (warm peach); dark timber **`#6E4B37`** for beams;
stone plinth **`#8C9AA6`**; special-shell colours Black **`#2B2F36`**, White **`#F7FBFF`**, Purple **`#7A3FD6`** (the
P11 placeholders, kept).

## 4. Materials (B-09 families, Compatibility renderer, no textures in this slice)

| Family | Roughness | Metal | Look |
|---|---|---|---|
| Skin | 0.55 | 0 | soft vinyl toy |
| Puffy cloth (jacket, trousers) | 0.85 | 0 | quilted grooves in geometry, matte |
| Knit / fur trim | 0.95 | 0 | chunky, matte, lighter value than the cloth it edges |
| Leather boots | 0.6 | 0 | slight sheen |
| Gold buckles/bells | 0.35 | 0.8 | only small accents |
| Eyes | 0.15 | 0 | glossy, one baked white catch-light |
| Snow crust (snowballs) | 0.75 | 0 | vertex-colour AO + crust pattern × tier tint |
| Painted timber | 0.8 | 0 | bevelled planks, never flat boxes |
| Snow load | 0.9 | 0 | soft drift profile, overhangs the eaves |
| Window glow | — | — | warm gold, emissive 1.5 (no real lights) |

One material per surface family; a whole elf is one skinned mesh with ≤ 8 material slots.

## 5. Lighting

Game scene: one warm-white **sun** from upper-left-front with shadows, cool sky-blue ambient (current match setup
kept; no lighting change in this slice). Clay QA renders use a neutral 3-point Workbench/EEVEE rig: lighting must never
hide geometry (A-12).

## 6. Outline and shading

- Characters and snowballs: **inverted-hull outline** in Midnight spruce (`grow` ≈ 1.5–4 cm), so small forms and
  pale Powder snowballs stay legible on white snow. Environment has **no** outline (it reads by mass and value).
- Shading is plain PBR-lite (StandardMaterial3D), no cel ramp; form comes from geometry + baked vertex AO.

## 7. Readability rules at the game camera (ortho, 46 m wide, 60° pitch ≈ 28 px per metre at 1280 px)

1. An elf is ~34 px tall: cap colour, jacket colour and the role prop must each cover ≥ 4 px blocks.
2. The role prop is oversized (≥ ¼ body height) and held away from the body so it breaks the silhouette.
3. Value contrast: dark jacket body against white snow; light trims separate head from body.
4. Snowball tiers must differ in hue **and** pattern; specials keep their B/W/P/C letter markers (non-colour cue).
5. Powder keeps its dark outline; nothing white-on-white without a contour.
6. Thumbnail test: at 320×180 the track, the snowballs and every tower stay identifiable (A-12).
