extends SceneTree
## P05/P06 tests: layer chain damage table, overflow, pop cash, immunity, camo, target priority, pierce,
## per-shot hit history, 1x vs 2x equivalence.
## Run: godot --headless --path . -s res://tests/test_combat.gd   (exit 1 = failure)

const MATCH: String = "res://scenes/main/match.tscn"
const STEP: float = 1.0 / 60.0
const LAYERS: Array[StringName] = [&"powder", &"blue", &"mint", &"violet", &"coral"]
const SPOT: Vector2 = Vector2(-7.2, 0)  # valid Rookie spot 1.8 m from the track at distance 14

var _failures: int = 0
var _events: Array = []


func _check(ok: bool, what: String) -> void:
	if not ok:
		_failures += 1
		printerr("FAIL: " + what)


func _initialize() -> void:
	_run.call_deferred()


func _new_match() -> Node3D:
	var m: Node3D = load(MATCH).instantiate()
	root.add_child(m)
	m.clock.set_process(false)
	return m


func _sim(m: Node3D, seconds: float) -> void:
	for i: int in int(seconds / STEP):
		m.clock.advance(STEP)


func _pop_cash(m: Node3D) -> int:
	var total: int = 0
	for t: Dictionary in m.ledger.transactions:
		if t.reason == &"pop":
			total += t.amount
	return total


## A copy of a layer that does not move, so shots can be aimed at a fixed spot.
func _parked(content: Node, id: StringName) -> Resource:
	var def: Resource = content.enemies[id].duplicate()
	def.speed_units = 0.0
	return def


func _run() -> void:
	var content: Node = root.get_node("Content")
	root.get_node("Events").emitted.connect(func(e: RefCounted) -> void: _events.append(e))
	_test_damage_table(content)
	_test_immunity_and_camo(content)
	_test_priority(content)
	_test_pierce_and_history(content)
	_test_speed_equivalence(content)
	print("test_combat: %s" % ("PASS" if _failures == 0 else "%d FAILURES" % _failures))
	quit(1 if _failures > 0 else 0)


## P05 exit proof: every basic layer x damage 1..6 -> resulting layer and cash, exactly the BTD6 chain.
func _test_damage_table(content: Node) -> void:
	var m: Node3D = _new_match()
	var lines: PackedStringArray = ["layer  dmg  -> result   cash  (BTD6: each hit removes `dmg` layers, $1 per layer)"]
	for start: int in LAYERS.size():
		for dmg: int in range(1, 7):
			m._spawn(LAYERS[start])
			var s: Node3D = m.snowballs[-1]
			var cash_before: int = m.ledger.cash
			m.damage_snowball(s, dmg, &"sharp", 99)
			var left: int = start - dmg  # index of the remaining layer, < 0 = destroyed
			var result: String = "popped" if left < 0 else String(LAYERS[left])
			var got: String = "popped" if not m.snowballs.has(s) else String(s.def.id)
			var paid: int = m.ledger.cash - cash_before
			_check(got == result and paid == mini(dmg, start + 1), "%s x%d -> %s $%d (got %s $%d)"
					% [LAYERS[start], dmg, result, mini(dmg, start + 1), got, paid])
			lines.append("%-6s %d    -> %-8s $%d" % [LAYERS[start], dmg, got, paid])
			if m.snowballs.has(s):
				m.snowballs.erase(s)
				s.free()
	_check(content.enemies.values().all(func(e: Resource) -> bool: return e.cash_per_pop == 1), "$1 per layer")
	DirAccess.make_dir_recursive_absolute("res://docs/logs/evidence")
	FileAccess.open("res://docs/logs/evidence/p05_damage_table.txt", FileAccess.WRITE).store_string("\n".join(lines) + "\n")
	# Event order for one Coral popped one layer at a time: 5 layer_broken, the last one ends the chain.
	_events.clear()
	m._spawn(&"coral")
	var coral: Node3D = m.snowballs[-1]
	for i: int in 5:
		m.damage_snowball(coral, 1, &"sharp", 7)
	var chain: Array = _events.filter(func(e: RefCounted) -> bool: return e.type == &"layer_broken").map(
			func(e: RefCounted) -> String: return "%s>%s" % [e.tags[0], e.tags[1]])
	_check(chain == ["coral>violet", "violet>mint", "mint>blue", "blue>powder", "powder>"], "chain %s" % [chain])
	m.free()


func _test_immunity_and_camo(content: Node) -> void:
	var m: Node3D = _new_match()
	m._spawn(&"blue")
	var s: Node3D = m.snowballs[-1]
	var immune: Resource = content.enemies[&"blue"].duplicate()
	immune.properties = Array([&"immune_sharp"], TYPE_STRING_NAME, &"", null)  # Lead-like fixture (DEFERRED type, framework only)
	s.set_layer(immune)
	_events.clear()
	var cash: int = m.ledger.cash
	m.damage_snowball(s, 3, &"sharp", 5)
	_check(m.snowballs.has(s) and s.def == immune and m.ledger.cash == cash, "immune: no damage, no cash")
	_check(_events.size() == 1 and _events[0].type == &"enemy_immune", "immune: one enemy_immune event")
	m.damage_snowball(s, 1, &"explosion", 5)
	_check(s.def.id == &"powder", "other damage types still break an immune_sharp layer")

	var camo: Resource = content.enemies[&"powder"].duplicate()
	camo.properties = Array([&"camo"], TYPE_STRING_NAME, &"", null)
	s.set_layer(camo)
	var targeting: GDScript = load("res://scripts/core/targeting.gd")
	_check(targeting.pick(m.snowballs, s.position, 5.0, 0, false) == null, "camo: invisible without detection")
	_check(targeting.pick(m.snowballs, s.position, 5.0, 0, true) == s, "camo: targetable with detection")
	m.free()


func _test_priority(content: Node) -> void:
	var m: Node3D = _new_match()
	var targeting: GDScript = load("res://scripts/core/targeting.gd")
	var origin: Vector3 = m.course.position_at(10.0)
	for spec: Array in [[&"powder", 8.0], [&"coral", 9.0], [&"blue", 12.0], [&"blue", 12.0]]:
		m._spawn(spec[0])
		var s: Node3D = m.snowballs[-1]
		s.distance = spec[1]
		s.position = m.course.position_at(spec[1])
	var ids: Array = m.snowballs.map(func(s: Node3D) -> int: return s.entity_id)
	var pick: Callable = func(p: int) -> int: return targeting.pick(m.snowballs, origin, 50.0, p, false).entity_id
	_check(pick.call(0) == ids[2], "First = furthest along; tie -> lower id")
	_check(pick.call(1) == ids[0], "Last = least far")
	_check(pick.call(2) == ids[1], "Close = nearest to the tower")
	_check(pick.call(3) == ids[1], "Strong = highest RBE (Coral)")
	_check(targeting.pick(m.snowballs, origin, 0.1, 0, false) == null, "nothing in range -> no target")
	m.free()


## Three parked Powders on one spot: pierce 2 pops two, pierce 1 pops one; a Coral hit by one shot
## loses exactly one layer even though it stays in contact (hit history follows the snowball id).
func _test_pierce_and_history(content: Node) -> void:
	var rookie: Resource = content.get_tower(&"snowball_rookie")
	for pierce: int in [2, 1]:
		var m: Node3D = _new_match()
		var def: Resource = rookie.duplicate(true)
		def.attacks[0].pierce = pierce
		m.try_place(def, SPOT)
		for i: int in 3:
			m._spawn(&"powder")
			var s: Node3D = m.snowballs[-1]
			s.set_layer(_parked(content, &"powder"))
			s.distance = 14.0
			s.position = m.course.position_at(14.0)
		_check(m.towers_root.get_child(0).position.distance_to(m.snowballs[0].position) < 3.2, "parked in range")
		_sim(m, 0.5)  # one attack (interval 0.95 s), shot lands and expires
		_check(m.snowballs.size() == 3 - pierce, "pierce %d pops %d (left %d)" % [pierce, pierce, m.snowballs.size()])
		_check(_pop_cash(m) == pierce, "pierce %d pays $%d" % [pierce, pierce])
		m.free()

	var m: Node3D = _new_match()
	m.try_place(rookie, SPOT)
	m._spawn(&"coral")
	var coral: Node3D = m.snowballs[-1]
	coral.set_layer(_parked(content, &"coral"))
	coral.distance = 14.0
	coral.position = m.course.position_at(14.0)
	_sim(m, 0.5)
	_check(coral.def.id == &"violet" and _pop_cash(m) == 1, "one shot, one layer (got %s)" % coral.def.id)
	m.free()


## P06-T11: 2x speed changes wall time only. Same ticks -> identical ledgers and lives.
func _test_speed_equivalence(content: Node) -> void:
	var results: Array = []
	for speed: float in [1.0, 2.0]:
		var m: Node3D = _new_match()
		m.try_place(content.get_tower(&"snowball_rookie"), SPOT)
		m.try_place(content.get_tower(&"snowball_rookie"), Vector2(0, -3))
		m.clock.speed = speed
		for r: int in 3:  # fixed 60 s per round so both runs see exactly the same ticks
			m.start_round()
			for i: int in int(60.0 / STEP / speed):
				m.clock.advance(STEP)
			_check(m.state == m.State.PREPARE, "round %d done within 60 s at %sx" % [r + 1, speed])
		results.append([m.clock.tick, m.lives, str(m.ledger.transactions)])
		m.free()
	_check(results[0] == results[1], "1x and 2x identical: %s vs %s" % [results[0].slice(0, 2), results[1].slice(0, 2)])
	_check(results[0][2].contains("pop"), "towers actually popped snowballs")
