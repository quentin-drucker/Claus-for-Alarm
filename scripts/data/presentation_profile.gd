class_name PresentationProfile
extends Resource
## Art binding for one gameplay id (P14-T05, P15-A02). Presentation only: the simulation never reads it.
## Per-model scale, facing, ground contact and placement centre are baked into the GLB by
## art_src/tools/prepare_source_model.py; only the shared display scale is applied here.

## Runtime model. Optional: an AnimationPlayer with `idle`/`attack`, marker nodes `muzzle_A` and `effect_center`
## (hero: also `focus_goggle` and `hat_top`).
@export var model: PackedScene
## Applied once to the modelled GLB (DEC-036: 1.5 for tower models). Footprint and range stay data.
@export var display_scale: float = 1.5
## Old procedural Rookie: colour lives in the COLOR_0 vertex atlas, which the glTF import does not always flag.
@export var vertex_color_albedo: bool = false
## Procedural shot reaction (0 = none): slide back along the aim by this many metres, with a squash, then recover.
@export var recoil_m: float = 0.0
## Vertical squash at the kick peak (0.08 = 8% shorter, half that wider). Scales about the ground origin.
@export var recoil_squash: float = 0.0
@export var recoil_kick_s: float = 0.05
@export var recoil_recover_s: float = 0.3
## Pitch at the kick peak, about the axis across the weapon (degrees; + lifts the muzzle / leans back, - leans in).
@export var recoil_tilt_deg: float = 0.0
## Weapon direction relative to the model's forward (degrees, Godot rotation.y sense: + turns toward -X). Aiming
## turns the pivot so the weapon, not the body, faces the shot; recoil and tilt follow the weapon axis.
@export var weapon_yaw_deg: float = 0.0
## Snow puff diameter at `muzzle_A` in displayed metres (0 = none).
@export var muzzle_flash_m: float = 0.0
## Puff colour (default warm gold, DEC-040: reads on white snow).
@export var flash_color: Color = Color(0.976, 0.788, 0.427, 0.85)

@export_group("Hero")
## Wind-up before the next shot while engaged (seconds of the first attack's cooldown; 0 = none): a small crouch
## and lean into the aim that the shot releases. Read from the cooldown only, so it never changes shot timing.
@export var anticipation_s: float = 0.0
@export var anticipation_squash: float = 0.0
@export var anticipation_tilt_deg: float = 0.0
## Focused Shot stance (doc 02 A-03: "tightens aiming pose"): held lean and crouch, eased in and out.
@export var focus_tilt_deg: float = 0.0
@export var focus_squash: float = 0.0
## Snowball Frenzy (doc 03: "speed glow / elastic recoil"): recoil squash multiplier while Frenzy is active.
@export var frenzy_recoil_mult: float = 1.0
## Ground ring colours (Frenzy pulse, Focus reticle) and the level-up glint (doc 02 "hat pin glint, XP pulse").
@export var frenzy_color: Color = Color(0.91, 0.33, 0.25, 0.75)
@export var focus_color: Color = Color(0.56, 0.85, 0.91, 0.8)
@export var level_up_color: Color = Color(0.976, 0.788, 0.427, 0.9)
## Radius of the hero's ground rings in displayed metres (outside the model envelope).
@export var ring_radius_m: float = 0.0
