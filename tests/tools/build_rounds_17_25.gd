extends SceneTree
## One-off data builder (DEC-025/026/031), kept for provenance: writes the special snowballs needed by BTD6 rounds
## 17-25 and the exact rounds 17-25 (teemo.dev, "Bloons TD 6 game data, version 56", fetched 2026-11-14).
## Run: godot --headless --path . -s res://tests/tools/build_rounds_17_25.gd < /dev/null

const PROPS_URL: String = "https://teemo.dev/game-design/bloons-td-6/systems/bloons-and-properties/"
const ROUND_URL: String = "https://teemo.dev/game-design/bloons-td-6/wiki/rounds/round-%d/"
const ENEMY_STATUS: Dictionary[String, String] = {
	"speed_units": "VERIFIED_SOURCE", "child_count": "VERIFIED_SOURCE", "cash_per_pop": "VERIFIED_SOURCE"}
## id, display name, speed, child, count, properties, notes. Camo is a modifier that stays on every layer below.
const ENEMIES: Array = [
	[&"black", "Black", 45.0, &"coral", 2, [&"immune_explosion"],
		"BTD6 Black Bloon (v56): 45 u/s, 2 Pink, RBE 11. \"Black blocks Explosion.\""],
	[&"white", "White", 50.0, &"coral", 2, [&"immune_cold"],
		"BTD6 White Bloon (v56): 50 u/s, 2 Pink, RBE 11. \"White blocks freezing (Cold, Metal Freeze, Frigid).\" No shipped attack is cold."],
	[&"purple", "Purple", 75.0, &"coral", 2, [&"immune_energy", &"immune_fire", &"immune_plasma"],
		"BTD6 Purple Bloon (v56): 75 u/s, 2 Pink, RBE 11. \"Purple blocks Plasma, Fire and Energy.\""],
	[&"camo_mint", "Camo Mint", 45.0, &"camo_blue", 1, [&"camo"], "BTD6 Camo Green: Green stats, camo kept by its children."],
	[&"camo_blue", "Camo Blue", 35.0, &"camo_powder", 1, [&"camo"], "BTD6 Camo Blue: Blue stats + camo."],
	[&"camo_powder", "Camo Powder", 25.0, &"", 0, [&"camo"], "BTD6 Camo Red: Red stats + camo."],
]
## round -> groups [enemy, count, start_s, sent_over_s] in page order. Regrow Yellow -> violet (DEC-031).
const ROUNDS: Dictionary = {
	17: [[&"violet", 12, 0.0, 5.0]],
	18: [[&"mint", 60, 0.0, 25.0], [&"mint", 20, 25.0, 1.817]],
	19: [[&"mint", 10, 0.0, 2.888], [&"violet", 5, 2.855, 2.333], [&"coral", 15, 5.958, 7.617], [&"violet", 4, 13.48, 2.284]],
	20: [[&"black", 6, 0.0, 5.246]],
	21: [[&"coral", 10, 10.84, 5.139], [&"coral", 4, 16.68, 1.438], [&"violet", 40, 0.09, 10.0]],
	22: [[&"white", 16, 0.0, 8.0]],
	23: [[&"black", 7, 0.0, 2.5], [&"white", 7, 4.82, 2.0]],
	24: [[&"camo_mint", 1, 0.0, 1.0], [&"blue", 20, 3.0, 6.0]],
	25: [[&"violet", 25, 0.0, 14.0], [&"purple", 10, 17.14, 4.0]],
}
const REGROW_ROUNDS: Array[int] = [17, 19, 25]


func _initialize() -> void:
	for e: Array in ENEMIES:
		var d: Resource = load("res://scripts/data/enemy_definition.gd").new()
		d.id = e[0]
		d.display_name = e[1]
		d.speed_units = e[2]
		d.child_id = e[3]
		d.child_count = e[4]
		d.properties.assign(e[5])
		d.source_url = PROPS_URL
		d.status = ENEMY_STATUS.duplicate()
		d.notes = e[6]
		_save(d, "res://resources/enemies/%s.tres" % e[0])
	for n: int in ROUNDS:
		var r: Resource = load("res://scripts/data/round_definition.gd").new()
		r.id = StringName("round_%02d" % n)
		r.source_url = ROUND_URL % n
		for g: Array in ROUNDS[n]:
			var group: Resource = load("res://scripts/data/spawn_group.gd").new()
			group.enemy_id = g[0]
			group.count = g[1]
			group.start_s = g[2]
			group.duration_s = g[3]
			r.groups.append(group)
		var regrow: bool = n in REGROW_ROUNDS
		r.status["groups"] = ("ORIGINAL_DEVIATION" if regrow else "VERIFIED_SOURCE")
		r.notes = "Exact BTD6 v56 standard round %d (counts, start, sent-over)." % n
		if regrow:
			r.notes += " DEC-031: Regrow Yellow spawns as plain Violet (same count and timing; RBE unchanged)."
		_save(r, "res://resources/rounds/round_%02d.tres" % n)
	quit(0)


func _save(res: Resource, path: String) -> void:
	var err: Error = ResourceSaver.save(res, path)
	print("%s %s" % [path, "OK" if err == OK else "ERROR %d" % err])
