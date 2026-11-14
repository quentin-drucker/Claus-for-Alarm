extends SceneTree
## P08 base-kit tests, one per tower (P08-T02..T06): each tower's distinct mechanic on parked snowballs.
## Run: godot --headless --path . -s res://tests/test_towers.gd   (exit 1 = failure)

const MATCH: String = "res://scenes/main/match.tscn"
const STEP: float = 1.0 / 60.0
const SPOT: Vector2 = Vector2(-7.2, 0)  # valid spot 1.8 m from the track at distance 14

var _failures: int = 0
var _events: Array = []
var content: Node


func _check(ok: bool, what: String) -> void:
	if not ok:
		_failures += 1
		printerr("FAIL: " + what)


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	content = root.get_node("Content")
	root.get_node("Events").emitted.connect(func(e: RefCounted) -> void: _events.append(e))
	_test_cannon()
	_test_ranger()
	print("test_towers: %s" % ("PASS" if _failures == 0 else "%d FAILURES" % _failures))
	quit(1 if _failures > 0 else 0)


func _new_match() -> Node3D:
	var m: Node3D = load(MATCH).instantiate()
	root.add_child(m)
	m.clock.set_process(false)
	return m


func _sim(m: Node3D, seconds: float) -> void:
	for i: int in int(seconds / STEP):
		m.clock.advance(STEP)


## A snowball of layer `id` that does not move, parked at track distance `dist`.
func _park(m: Node3D, id: StringName, dist: float, properties: Array[StringName] = []) -> Node3D:
	m._spawn(id)
	var s: Node3D = m.snowballs[-1]
	var def: Resource = content.enemies[id].duplicate()
	def.speed_units = 0.0
	def.properties = properties
	s.set_layer(def)
	s.distance = dist
	s.position = m.course.position_at(dist)
	return s


func _cash(m: Node3D, reason: StringName) -> int:
	var total: int = 0
	for t: Dictionary in m.ledger.transactions:
		if t.reason == reason:
			total += t.amount
	return total


## P08-T02 / P06-T05: one contact projectile (pierce 1) makes one explosion (pierce 22, damage 1) that hits
## every snowball in its radius, never one outside it, never an explosion-immune one; blast pierce caps
## the explosion on its own; overlapping layers each lose exactly one layer.
func _test_cannon() -> void:
	var cannon: Resource = content.get_tower(&"avalanche_cannon")
	var blast: Resource = cannon.attacks[0].on_contact[0]
	_check(cannon.attacks[0].pierce == 1 and cannon.attacks[0].damage == 0 and blast.pierce == 22
			and blast.damage == 1 and blast.damage_type == &"explosion", "cannon data: contact 1 / blast 22")
	var m: Node3D = _new_match()
	m.try_place(cannon, SPOT)
	var group: Array[Node3D] = []
	for d: float in [14.0, 14.4, 14.8, 15.2]:
		group.append(_park(m, &"powder", d))
	var coral: Node3D = _park(m, &"coral", 14.6)
	var immune: Node3D = _park(m, &"blue", 14.2, [&"immune_explosion"])
	var far: Node3D = _park(m, &"powder", 10.0)
	_check(far.position.distance_to(group[0].position) > blast.radius_units * 0.1 + 0.8, "far snowball outside blast")
	_events.clear()
	_sim(m, 0.5)  # one attack: interval 1.5 s
	var fired: int = _events.filter(func(e: RefCounted) -> bool: return e.type == &"attack_fired").size()
	_check(fired == 1, "one attack fired (got %d)" % fired)
	_check(group.all(func(s: Node3D) -> bool: return not m.snowballs.has(s)), "all 4 Powders in the blast popped")
	_check(m.snowballs.has(coral) and coral.def.id == &"violet", "Coral lost exactly one layer (%s)" % coral.def.id)
	_check(m.snowballs.has(immune) and immune.def.id == &"blue", "explosion-immune snowball untouched")
	_check(m.snowballs.has(far), "snowball outside the radius untouched")
	_check(_cash(m, &"pop") == 5, "pop cash = 5 layers (got %d)" % _cash(m, &"pop"))
	m.free()

	# Blast pierce is its own cap: 2 of 4 grouped snowballs; the contact projectile still hits only one.
	var narrow: Resource = cannon.duplicate_deep()
	narrow.attacks[0].on_contact[0].pierce = 2
	m = _new_match()
	m.try_place(narrow, SPOT)
	for d: float in [14.0, 14.4, 14.8, 15.2]:
		_park(m, &"powder", d)
	_sim(m, 0.5)
	_check(m.snowballs.size() == 2, "blast pierce 2 pops 2 of 4 (left %d)" % m.snowballs.size())
	m.free()


## P08-T03: whole-map targeting with line of sight (the Lodge blocks it), not a big radius. Instant hit,
## damage 2, pierce 1; Strong picks the highest RBE anywhere visible; undetected camo is skipped.
func _test_ranger() -> void:
	var ranger: Resource = content.get_tower(&"biathlon_ranger")
	_check(ranger.global_range and ranger.range_units == 0.0, "ranger: global targeting, no radius")
	var m: Node3D = _new_match()
	var t: Node3D = m.try_place(ranger, Vector2(15.0, -3.0))  # east of the Lodge (x 9..14, z -5..-1)
	_check(t != null, "ranger placed beside the Lodge")
	t.priority = 1  # Last: would pick the hidden snowball if sight were ignored
	var hidden: Node3D = _park(m, &"coral", 46.0)  # (6, -3): the Lodge is in between
	var seen: Node3D = _park(m, &"coral", 61.0)  # (12, 6): clear line
	_check(not m.course.has_line_of_sight(t.position, hidden.position), "Lodge blocks the line to (6, -3)")
	_sim(m, 0.1)
	_check(seen.def.id == &"mint" and hidden.def.id == &"coral", "instant hit on the visible one, damage 2 (seen %s, hidden %s)"
			% [seen.def.id, hidden.def.id])
	m.free()

	m = _new_match()
	t = m.try_place(ranger, Vector2(0.0, 8.5))
	t.priority = 3  # Strong
	var weak: Node3D = _park(m, &"powder", 61.0)
	var strong: Node3D = _park(m, &"coral", 12.0)
	var camo: Node3D = _park(m, &"coral", 13.0, [&"camo"])
	var twin: Node3D = _park(m, &"coral", 12.0)  # same spot as `strong`: pierce 1 must leave it alone
	_check(t.position.distance_to(strong.position) > 10.0, "target is far beyond any tower radius")
	_sim(m, 0.1)
	_check(strong.def.id == &"mint" and twin.def.id == &"coral" and camo.def.id == &"coral" and weak.def.id == &"powder",
			"Strong: highest visible RBE, pierce 1, camo skipped (strong %s twin %s camo %s)" % [strong.def.id,
			twin.def.id, camo.def.id])
	_sim(m, 1.6)  # second shot after 1.59 s: next strongest (the twin Coral)
	_check(twin.def.id == &"mint", "second shot after the 1.59 s interval")
	m.free()
