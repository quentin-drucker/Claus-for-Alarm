extends SceneTree
## One-off data builder (2026-11-14): owner-approved fillers for every tier 1-3 without source numbers, the
## missing sourced tier-3s, the Ticket Booth ORIGINAL_DEVIATION economy and shop roles. Kept for provenance.
## Run: godot --headless --path . -s res://tests/tools/build_p10_data.gd < /dev/null

const ADD: int = 0
const MUL: int = 1
const SET: int = 2
const APPEND: int = 3
const ATTACK_FIELDS: PackedStringArray = ["interval_s", "damage", "pierce", "projectile_count", "radius_units",
		"slow_factor", "slow_duration_s", "projectile_speed_units", "projectile_lifetime_s"]
const UPG: String = "https://teemo.dev/game-design/bloons-td-6/wiki/upgrades/"

var effect_script: Script = load("res://scripts/data/upgrade_effect.gd")
var attack_script: Script = load("res://scripts/data/attack_definition.gd")


func _initialize() -> void:
	_sorcerer()
	_ranger()
	_wax()
	_booth()
	_roles()
	print("build_p10_data: done")
	quit()


func e(target: StringName, field: StringName, op: int, value: float = 0.0, attack: Resource = null) -> Resource:
	var fx: Resource = effect_script.new()
	fx.target = target
	fx.field = field
	fx.op = op
	fx.value = value
	fx.attack = attack
	return fx


## New attack; every balance field gets `default_status` unless listed in `statuses`.
func attack(id: StringName, props: Dictionary, statuses: Dictionary, notes: String) -> Resource:
	var a: Resource = attack_script.new()
	a.id = id
	for key: String in props:
		a.set(key, props[key])
	for field: String in ATTACK_FIELDS:
		a.status[field] = statuses.get(field, "NOT_APPLICABLE")
	a.notes = notes
	return a


func ship(tower: Resource, path: int, tier: int, status: String, effects: Array, notes: String, slug: String) -> void:
	var u: Resource = tower.get_upgrade(path, tier)
	u.effects.assign(effects)
	u.status["effects"] = status
	u.notes = notes
	if slug != "":
		u.source_url = UPG + slug + "/"


func _save(tower: Resource) -> void:
	var err: int = ResourceSaver.save(tower, tower.resource_path)
	print("saved %s (%d)" % [tower.resource_path, err])


func _sorcerer() -> void:
	var t: Resource = load("res://resources/towers/snow_sorcerer.tres")
	var base: StringName = &"snow_sorcerer_base"
	ship(t, 0, 1, "PROTOTYPE_ASSUMPTION", [e(base, &"pierce", ADD, 1), e(base, &"projectile_lifetime_s", MUL, 1.5)],
			"Page has no numbers (shots last longer, seek behind cover). Filler: pierce 3 -> 4 (between base 3 and Arcane Mastery 7), lifetime x1.5. No homing.", "guided-magic")
	ship(t, 0, 2, "VERIFIED_SOURCE", [e(base, &"damage", ADD, 1)], "Damage 1 -> 2.", "arcane-blast")
	ship(t, 0, 3, "VERIFIED_SOURCE", [e(&"", &"range_units", ADD, 20), e(base, &"interval_s", MUL, 0.5),
			e(base, &"damage", ADD, 1), e(base, &"pierce", ADD, 3)],
			"Range 40 -> 60, cooldown 1.1 -> 0.55 s, damage 2 -> 3, pierce -> 7 (+3 on top of the Guided Magic filler).", "arcane-mastery")
	var fire: Resource = attack(&"snow_sorcerer_wall_fire", {"pierce": 15, "damage_type": &"plasma", "radius_units": 15.0},
			{"damage": "VERIFIED_SOURCE", "pierce": "VERIFIED_SOURCE", "radius_units": "PROTOTYPE_ASSUMPTION"},
			"Wall of Fire contact: damage 1, pierce 15 (page). Radius assumed; the lingering wall is not modelled.")
	var wall: Resource = attack(&"snow_sorcerer_wall", {"interval_s": 6.5, "pierce": 10, "damage_type": &"plasma",
			"on_contact": [fire]}, {"interval_s": "VERIFIED_SOURCE", "damage": "VERIFIED_SOURCE", "pierce": "VERIFIED_SOURCE",
			"projectile_count": "VERIFIED_SOURCE", "projectile_speed_units": "PROTOTYPE_ASSUMPTION",
			"projectile_lifetime_s": "PROTOTYPE_ASSUMPTION"}, "Wall of Fire: 6.5 s, damage 1 plasma, pierce 10 (page).")
	ship(t, 1, 2, "PROTOTYPE_ASSUMPTION", [e(&"", &"attacks", APPEND, 0, wall)],
			"Adds Wall of Fire (6.5 s, damage 1, pierce 10 + contact 1/15 from the page). Page gives no DoT numbers: the wall is one 15 u fire burst where it lands, not a lingering wall.", "wall-of-fire")
	var breath: Resource = attack(&"snow_sorcerer_breath", {"interval_s": 0.135, "damage": 2, "pierce": 3,
			"damage_type": &"plasma", "projectile_lifetime_s": 0.15}, {"interval_s": "VERIFIED_SOURCE",
			"damage": "VERIFIED_SOURCE", "pierce": "VERIFIED_SOURCE", "projectile_count": "VERIFIED_SOURCE",
			"projectile_speed_units": "PROTOTYPE_ASSUMPTION", "projectile_lifetime_s": "PROTOTYPE_ASSUMPTION"},
			"Dragon's Breath: 0.135 s, damage 2 plasma, pierce 3 (page); short life = flamethrower reach ~45 u.")
	ship(t, 1, 3, "VERIFIED_SOURCE", [e(&"", &"attacks", APPEND, 0, breath), e(&"snow_sorcerer_fireball", &"projectile_count", SET, 3),
			e(&"snow_sorcerer_fireball", &"spread_deg", SET, 15), e(&"snow_sorcerer_fireball_blast", &"damage", SET, 3),
			e(&"snow_sorcerer_wall", &"interval_s", SET, 4.5), e(&"snow_sorcerer_wall", &"pierce", SET, 20)],
			"Fireballs 1 -> 3 (15 deg spread assumed), Fireball blast damage 1 -> 3, Wall 6.5 -> 4.5 s and pierce 10 -> 20, adds Dragon's Breath.", "dragons-breath")
	ship(t, 2, 3, "VERIFIED_SOURCE", [e(&"", &"range_units", ADD, 10)],
			"Range 50 -> 60. The de-camo Shimmer attack is DEFERRED with the camo snowballs (DEC-019).", "shimmer")
	_save(t)


func _ranger() -> void:
	var t: Resource = load("res://resources/towers/biathlon_ranger.tres")
	var base: StringName = &"biathlon_ranger_base"
	ship(t, 0, 3, "VERIFIED_SOURCE", [e(base, &"damage", ADD, 13)],
			"Damage 7 -> 20. +50 vs Ceramic not applied (no Stone snowballs, DEC-019).", "deadly-precision")
	ship(t, 1, 3, "PROTOTYPE_ASSUMPTION", [e(base, &"pierce", SET, 3), e(base, &"bounce_range_units", SET, 30)],
			"Pierce 1 -> 3, bounces to 2 new targets (page). Bounce reach 30 u is assumed (not on the page).", "bouncing-bullet")
	ship(t, 2, 3, "VERIFIED_SOURCE", [e(base, &"interval_s", MUL, 1.0 / 3.0)],
			"Cooldown 0.7791 -> 0.2597 s (x1/3). Page pierce 5 not applied: a global instant hit has one target.", "semi-automatic")
	_save(t)


func _wax() -> void:
	var t: Resource = load("res://resources/towers/slope_wax_sprayer.tres")
	var base: StringName = &"slope_wax_sprayer_base"
	var splat: StringName = &"slope_wax_sprayer_splatter"
	ship(t, 0, 2, "PROTOTYPE_ASSUMPTION", [e(base, &"dot_damage", SET, 1), e(base, &"dot_interval_s", SET, 2.0),
			e(splat, &"dot_damage", SET, 1), e(splat, &"dot_interval_s", SET, 2.0)],
			"Page: waxed snowballs lose a layer 'every few seconds', no number. Filler: 1 layer every 2 s while waxed.", "corrosive-glue")
	ship(t, 0, 3, "VERIFIED_SOURCE", [e(base, &"interval_s", MUL, 0.5), e(base, &"pierce", ADD, 1),
			e(base, &"dot_interval_s", SET, 0.5), e(splat, &"dot_interval_s", SET, 0.5)],
			"Cooldown 1 -> 0.5 s, pierce 1 -> 2, solvent melts 2 layers per second (page in-game text).", "bloon-dissolver")
	ship(t, 1, 3, "VERIFIED_SOURCE", [e(&"", &"range_units", ADD, 12), e(base, &"interval_s", SET, 0.34)],
			"Range 46 -> 58, cooldown 1 -> 0.34 s.", "glue-hose")
	ship(t, 2, 2, "PROTOTYPE_ASSUMPTION", [e(base, &"slow_factor", SET, 0.7), e(splat, &"slow_factor", SET, 0.7)],
			"Page: 'slows even more', no number. Filler: slow 50% -> 70%.", "stronger-glue")
	ship(t, 2, 3, "PROTOTYPE_ASSUMPTION", [e(base, &"slow_duration_s", ADD, 2), e(splat, &"slow_duration_s", ADD, 2)],
			"MOAB Glue only affects large snowballs, which this build does not have (DEC-019). Filler so the tier does something: wax lasts 2 s longer.", "moab-glue")
	_save(t)


func _booth() -> void:
	var t: Resource = load("res://resources/towers/ski_resort_ticket_booth.tres")
	t.cash_per_pickup = 50
	t.status["cash_per_pickup"] = "ORIGINAL_DEVIATION"
	t.notes = "Base kit: M-10 (v56) except cash per pickup: ORIGINAL_DEVIATION $20 -> $50 (owner 2026-11-14) so a $1,250 Booth pays back in ~6 rounds of a 19-round match. Footprint radius 15 from the source page. 4 pickups per round; pickups rot after 15 s."
	ship(t, 0, 3, "VERIFIED_SOURCE", [e(&"", &"pickups_per_round", ADD, 8)], "Pickups per round 8 -> 16.", "banana-plantation")
	ship(t, 1, 2, "ORIGINAL_DEVIATION", [e(&"", &"cash_per_pickup", MUL, 1.5)],
			"Source: +25% value. ORIGINAL_DEVIATION +50% ($50 -> $75) so it pays back in ~8 rounds on a base Booth.", "valuable-bananas")
	ship(t, 1, 3, "ORIGINAL_DEVIATION", [e(&"", &"cash_per_pickup", MUL, 1.5), e(&"", &"bank_capacity", SET, 7000),
			e(&"", &"bank_interest", SET, 0.15)],
			"Bank: capacity $7,000, 15% interest per round (page). Pickup value source $20 -> $45; scaled with the Booth deviation: $75 -> $112. Tickets go straight into the bank; withdraw from the card.", "monkey-bank")
	ship(t, 2, 1, "VERIFIED_SOURCE", [e(&"", &"auto_collect_ratio", SET, 0.5)],
			"Uncollected tickets auto-collect at half value (page text). Bigger collect radius not modelled (click collect).", "ez-collect")
	ship(t, 2, 2, "PROTOTYPE_ASSUMPTION", [e(&"", &"auto_collect_ratio", SET, 0.9), e(&"", &"sell_bonus", ADD, 0.1)],
			"Page: auto-collect 'almost full value' (filler 90%), sell-back +10% (page).", "banana-salvage")
	ship(t, 2, 3, "VERIFIED_SOURCE", [e(&"", &"pickups_per_round", SET, 16), e(&"", &"auto_collect_ratio", SET, 1.0)],
			"16 tickets per round paid directly, no pickups (page).", "marketplace")
	_save(t)


func _roles() -> void:
	var roles: Dictionary = {
		"snowball_rookie": "Cheap all-rounder: throws snowballs at one target at a time.",
		"avalanche_cannon": "Splash damage: each shot bursts and hits a crowd.",
		"biathlon_ranger": "Hits anywhere it can see (whole map), strong single shots.",
		"slope_wax_sprayer": "Support: waxes snowballs to slow them; no damage at first.",
		"snow_sorcerer": "Magic bolts that pierce several snowballs.",
		"ski_resort_ticket_booth": "Income: drops tickets every round; click them to collect cash.",
	}
	for id: String in roles:
		var t: Resource = load("res://resources/towers/%s.tres" % id)
		t.role = roles[id]
		_save(t)
