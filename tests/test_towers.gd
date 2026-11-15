extends SceneTree
## P08 base-kit tests, one per tower (P08-T02..T06): each tower's distinct mechanic on parked snowballs.
## Run: godot --headless --path . -s res://tests/test_towers.gd   (exit 1 = failure)

const MATCH: String = "res://scenes/main/match.tscn"
const STEP: float = 1.0 / 60.0
const SPOT: Vector2 = Vector2(-7.2, 0)  # valid spot 1.8 m from the track at distance 14

var _failures: int = 0
## Test functions that ran to their end: a script error aborts a function without calling _check.
var _completed: Array[String] = []
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
	_test_cannon_visual()
	_test_ranger()
	_test_wax()
	_test_sorcerer()
	_test_booth()
	_test_base_report()
	_check(_completed.size() == 7, "every test function completed (%s)" % [_completed])
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
	_completed.append("_test_cannon")


## P15-A02/A03: the Cannon's art binding is presentation only. Grounded GLB at the 1.5x display scale, shots start
## at the bore marker, rapid-fire recoil returns exactly to rest (no drift), and pause freezes the reaction.
func _test_cannon_visual() -> void:
	var m: Node3D = _new_match()
	var cannon: Node3D = m.try_place(content.get_tower(&"avalanche_cannon"), SPOT)
	var model: Node3D = cannon._model
	_check(model != null and cannon._anim == null and cannon._flash != null, "cannon: static GLB, muzzle puff, no clip")
	var mesh: MeshInstance3D = model.find_children("*", "MeshInstance3D")[0]
	var box: AABB = mesh.global_transform * mesh.get_aabb()
	_check(absf(box.position.y) < 0.01 and absf(box.end.y - 0.934) < 0.02, "cannon grounded, 0.93 m tall (%s)" % box)
	var muzzle: Vector3 = cannon.muzzle_position() - cannon.position
	_check(absf(muzzle.y - 0.613) < 0.02 and Vector2(muzzle.x, muzzle.z).length() < 0.6, "bore marker (%s)" % muzzle)
	cannon.play_attack(Vector3(1, 0, 0))
	_check(absf(cannon._pivot.rotation.y - atan2(-1.0, 0.0)) < 1e-4 and cannon.rotation == Vector3.ZERO,
			"visual pivot aims, gameplay root does not turn")
	for i: int in 30:  # far faster than any upgrade: a shot every 2 ticks
		cannon.play_attack(Vector3(1, 0, 0))
		cannon.animate(STEP)
		cannon.animate(STEP)
		_check(model.position.z <= 0.12 + 1e-5 and model.scale.y >= 1.5 * 0.92 - 1e-5, "recoil stays bounded")
	m.clock.paused = true
	var held: Vector3 = model.position
	_sim(m, 0.5)
	_check(model.position == held and model.position.z > 0.0, "pause freezes the recoil")
	m.clock.paused = false
	_sim(m, 1.0)
	_check(model.position == Vector3.ZERO and model.scale == Vector3.ONE * 1.5 and not cannon._flash.visible,
			"recoil returns exactly to rest (%s, %s)" % [model.position, model.scale])
	_check(m.towers_root.get_child_count() == 1 and is_equal_approx(cannon.footprint().z, 0.6), "footprint unchanged (0.6 m)")
	m.free()
	_completed.append("_test_cannon_visual")


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
	_completed.append("_test_ranger")


## P08-T04 / P06-T08: wax is status only: 50% slow for its duration, no layer damage, no pop cash; a waxed
## snowball is not re-targeted; weaker wax never overrides stronger; a layer break sheds wax unless it soaks;
## glue-immune snowballs ignore it.
func _test_wax() -> void:
	var wax: Resource = content.get_tower(&"slope_wax_sprayer")
	var a: Resource = wax.attacks[0]
	_check(a.damage == 0 and a.slow_factor == 0.5 and a.pierce == 1 and a.slow_duration_s > 0.0, "wax data")
	var m: Node3D = _new_match()
	m.try_place(wax, SPOT)
	m._spawn(&"coral")
	var s: Node3D = m.snowballs[-1]
	s.distance = 12.5
	s.position = m.course.position_at(12.5)
	_events.clear()
	_sim(m, 0.5)
	_check(s.def.id == &"coral" and s.slow_left > a.slow_duration_s - 0.6, "waxed, no layer lost (%s, %.2f s left)"
			% [s.def.id, s.slow_left])
	_check(is_equal_approx(s.current_speed(), s.def.speed_units * 0.5), "speed halved (%.1f)" % s.current_speed())
	_sim(m, 2.0)
	var fired: int = _events.filter(func(e: RefCounted) -> bool: return e.type == &"attack_fired").size()
	_check(fired == 1, "waxed snowball is not re-targeted (fired %d)" % fired)
	_check(_cash(m, &"pop") == 0 and not _events.any(func(e: RefCounted) -> bool: return e.type == &"layer_broken"),
			"no pop cash, no layer broken")
	_sim(m, a.slow_duration_s)
	_check(s.slow_left <= 0.0 and is_equal_approx(s.current_speed(), s.def.speed_units), "wax wears off")

	s.apply_slow(0.5, 5.0, false)
	s.apply_slow(0.3, 9.0, false)
	_check(s.slow_factor == 0.5 and is_equal_approx(s.slow_left, 5.0), "weaker wax ignored")
	s.apply_slow(0.5, 8.0, false)
	_check(is_equal_approx(s.slow_left, 8.0), "equal wax refreshes the duration")
	m.damage_snowball(s, 1, &"sharp", 1)
	_check(s.slow_left <= 0.0, "a layer break sheds ordinary wax")
	s.apply_slow(0.5, 8.0, true)
	m.damage_snowball(s, 1, &"sharp", 1)
	_check(s.slow_left > 0.0, "soaking wax survives a layer break")
	var immune: Node3D = _park(m, &"blue", 30.0, [&"immune_glue"])
	m._apply(a, immune, 1)
	_check(immune.slow_left <= 0.0, "glue-immune snowball ignores wax")
	m.free()
	_completed.append("_test_wax")


## P08-T05: energy bolt, damage 1, pierce 3: four snowballs on one spot -> three pop; an energy-immune one
## still uses a pierce (like Lead vs darts) and takes nothing, while sharp damage still works on it.
func _test_sorcerer() -> void:
	var sorcerer: Resource = content.get_tower(&"snow_sorcerer")
	var a: Resource = sorcerer.attacks[0]
	_check(a.damage_type == &"energy" and a.pierce == 3 and a.damage == 1 and is_equal_approx(a.interval_s, 1.1),
			"sorcerer data")
	var m: Node3D = _new_match()
	m.try_place(sorcerer, SPOT)
	for i: int in 4:
		_park(m, &"powder", 14.0)
	_sim(m, 0.5)
	_check(m.snowballs.size() == 1 and _cash(m, &"pop") == 3, "pierce 3 pops 3 of 4 (left %d)" % m.snowballs.size())
	m.free()

	m = _new_match()
	m.try_place(sorcerer, SPOT)
	var immune: Node3D = _park(m, &"blue", 14.0, [&"immune_energy"])
	for i: int in 3:
		_park(m, &"powder", 14.0)
	_sim(m, 0.5)
	_check(immune.def.id == &"blue" and m.snowballs.size() == 2, "immune contact uses a pierce: 2 Powders pop (left %d)"
			% m.snowballs.size())
	m.damage_snowball(immune, 1, &"sharp", 1)
	_check(immune.def.id == &"powder", "other damage types still work on an energy-immune layer")
	m.free()
	_completed.append("_test_sorcerer")


## P08-T06: no targeting; 4 pickups x $50 per round (ORIGINAL_DEVIATION, owner 2026-11-14), spread over the round; collected pickups pay once into
## the ledger as ticket_income; uncollected ones expire after 15 s and pay nothing; a sold booth drops no more.
func _test_booth() -> void:
	var booth: Resource = content.get_tower(&"ski_resort_ticket_booth")
	_check(booth.attacks.is_empty() and booth.pickups_per_round == 4 and booth.cash_per_pickup == 50
			and booth.pickup_lifetime_s == 15.0, "booth data")
	var m: Node3D = _new_match()
	m.ledger.credit(0, 2000, &"test", 0)
	var t: Node3D = m.try_place(booth, Vector2(12.0, 1.5))
	_check(t != null, "booth placed in the open")
	_events.clear()
	var times: Array[int] = []
	m.start_round()
	while m.state == m.State.ROUND_SPAWN or m.state == m.State.ROUND_CLEANUP:
		var before: int = m.pickups.size()
		m.clock.advance(STEP)
		if m.pickups.size() > before:
			times.append(m.clock.tick)
		if m.pickups.size() == 2 and _cash(m, &"ticket_income") == 0:
			m.collect(m.pickups[0])
			m.collect_at(m.pickups[0].pos)  # click on the ground beside it
	_check(times.size() == 4 and times[3] - times[0] > 60, "4 drops spread over the round (ticks %s)" % [times])
	_check(_cash(m, &"ticket_income") == 100, "2 collected = $100 (got %d)" % _cash(m, &"ticket_income"))
	_check(not _events.any(func(e: RefCounted) -> bool: return e.type == &"attack_fired"), "booth never attacks")
	_sim(m, 16.0)
	_check(m.pickups.is_empty() and _cash(m, &"ticket_income") == 100, "uncollected pickups expire unpaid")
	var expired: int = _events.filter(func(e: RefCounted) -> bool: return e.type == &"pickup_expired").size()
	_check(expired == 2, "2 expired events (got %d)" % expired)
	m.start_round()
	_sim(m, 0.1)
	m.sell(t)
	while m.state == m.State.ROUND_SPAWN or m.state == m.State.ROUND_CLEANUP:
		m.clock.advance(STEP)
	var dropped: int = _events.filter(func(e: RefCounted) -> bool: return e.type == &"pickup_spawned").size()
	_check(dropped <= 5, "sold booth stops dropping (total drops %d)" % dropped)
	m.free()
	_completed.append("_test_booth")


## P08-T10: base stats vs HYB-M M-10 (v56 Medium) for all six, with provenance; writes the comparison report.
func _test_base_report() -> void:
	# id: [price, range (0 = global/none), interval, damage, pierce, extra]
	var expected: Dictionary = {
		&"snowball_rookie": [200, 32.0, 0.95, 1, 2, ""],
		&"avalanche_cannon": [375, 40.0, 1.5, 0, 1, "blast dmg 1 pierce 22"],
		&"biathlon_ranger": [350, 0.0, 1.59, 2, 1, "global LOS"],
		&"slope_wax_sprayer": [225, 46.0, 1.0, 0, 1, "slow 0.5"],
		&"snow_sorcerer": [250, 40.0, 1.1, 1, 3, "energy"],
		&"ski_resort_ticket_booth": [1250, 0.0, 0.0, 0, 0, "4 x $50 / round"],
	}
	var lines: PackedStringArray = ["P08-T10 base kit vs M-10 (v56 Medium). Provenance per field from the .tres status.",
			"id                       price  range  interval  dmg  pierce  extra                 footprint  match"]
	_check(content.towers.size() == 6, "exactly the six initial towers (no excluded families)")
	for t: Resource in content.towers:
		var e: Array = expected[t.id]
		var a: Resource = t.attacks[0] if not t.attacks.is_empty() else null
		var got: Array = [t.price, t.range_units, a.interval_s if a else 0.0, a.damage if a else 0, a.pierce if a else 0]
		var extra: String = ""
		match t.id:
			&"avalanche_cannon":
				extra = "blast dmg %d pierce %d" % [a.on_contact[0].damage, a.on_contact[0].pierce]
			&"biathlon_ranger":
				extra = "global LOS" if t.global_range else "RADIUS"
			&"slope_wax_sprayer":
				extra = "slow %s" % a.slow_factor
			&"snow_sorcerer":
				extra = String(a.damage_type)
			&"ski_resort_ticket_booth":
				extra = "%d x $%d / round" % [t.pickups_per_round, t.cash_per_pickup]
		var ok: bool = got == e.slice(0, 5) and extra == e[5]
		_check(ok, "%s base kit matches M-10: %s %s" % [t.id, got, extra])
		lines.append("%-24s %5d  %5.1f  %8.2f  %3d  %6d  %-21s %5.1f %s  %s" % [t.id, t.price, t.range_units,
				got[2], got[3], got[4], extra, t.footprint_units, t.status.footprint_units.left(4), "OK" if ok else "DIFF"])
	lines.append("Assumptions (PROTOTYPE_ASSUMPTION): projectile speed/lifetime (all), Cannon blast radius 18,")
	lines.append("Wax duration 11 s, Cannon/Sorcerer footprint 6, Booth drop timing (even over the round).")
	FileAccess.open("res://docs/logs/evidence/p08_base_stats.txt", FileAccess.WRITE).store_string("
".join(lines) + "
")
	_completed.append("_test_base_report")
