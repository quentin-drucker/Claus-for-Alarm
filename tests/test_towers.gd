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
	_test_booth_price()
	_test_ticket_hover()
	_test_base_report()
	_check(_completed.size() == 9, "every test function completed (%s)" % [_completed])
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
	# id, displayed height (m), muzzle height (m), min cosine of the muzzle bearing to the shot (weapons point at it;
	# the Sorcerer's staff is held beside the body, never behind): Cannon (P15-A02), Ranger + Wax (Dev 9), Sorcerer
	# (Dev 10); prepare logs p15c_* / p15d_*.
	for row: Array in [[&"avalanche_cannon", 0.934, 0.613, 0.5], [&"biathlon_ranger", 1.80, 0.467, 0.5],
			[&"slope_wax_sprayer", 1.80, 0.714, 0.5], [&"snow_sorcerer", 1.695, 1.508, -0.25]]:
		_check_static_visual(row[0], row[1], row[2], row[3])
	_check_booth_visual()
	_completed.append("_test_cannon_visual")


## Static (unrigged) GLB on a visual pivot: grounded at its height, muzzle marker on the weapon, the weapon (not the
## root) aims, rapid fire stays bounded, pause freezes the reaction and it returns exactly to rest.
func _check_static_visual(id: StringName, height: float, muzzle_y: float, min_cos: float) -> void:
	var m: Node3D = _new_match()
	var t: Node3D = m.try_place(content.get_tower(id), SPOT)
	var p: Resource = t._profile
	var model: Node3D = t._model
	_check(model != null and t._anim == null and t._flash != null, "%s: static GLB, muzzle puff, no clip" % id)
	var mesh: MeshInstance3D = model.find_children("*", "MeshInstance3D")[0]
	var box: AABB = mesh.global_transform * mesh.get_aabb()
	_check(absf(box.position.y) < 0.01 and absf(box.end.y - height) < 0.02, "%s grounded, %.2f m tall (%s)" % [id,
			height, box])
	var dir: Vector3 = Vector3(1, 0, 0)
	t.play_attack(dir)
	_check(absf(t._pivot.rotation.y - (atan2(-1.0, 0.0) - deg_to_rad(p.weapon_yaw_deg))) < 1e-4
			and t.rotation == Vector3.ZERO, "%s: visual pivot aims the weapon, gameplay root does not turn" % id)
	var muzzle: Vector3 = t.muzzle_position() - t.position
	var flat: Vector3 = Vector3(muzzle.x, 0.0, muzzle.z)
	_check(absf(muzzle.y - muzzle_y) < 0.02 and flat.length() < 1.0 and flat.dot(dir) > min_cos * flat.length(),
			"%s: muzzle marker on the shot side (%s)" % [id, muzzle])
	for i: int in 30:  # far faster than any upgrade: a shot every 2 ticks
		t.play_attack(dir)
		t.animate(STEP)
		t.animate(STEP)
		_check(model.position.length() <= p.recoil_m + 1e-5 and absf(model.scale.y - 1.5) <= 1.5 * absf(p.recoil_squash) + 1e-5
				and model.basis.orthonormalized().get_euler().length() <= deg_to_rad(absf(p.recoil_tilt_deg)) + 1e-4,
				"%s: reaction stays bounded" % id)
	m.clock.paused = true
	var held: Transform3D = model.transform
	_sim(m, 0.5)
	_check(model.transform == held and held != Transform3D(Basis.from_scale(Vector3.ONE * 1.5)),
			"%s: pause freezes the reaction" % id)
	m.clock.paused = false
	_sim(m, 1.0)
	_check(model.transform == Transform3D(Basis.from_scale(Vector3.ONE * 1.5)) and not t._flash.visible,
			"%s: reaction returns exactly to rest (%s)" % [id, model.transform])
	_check(m.towers_root.get_child_count() == 1 and is_equal_approx(t.footprint().z, 0.6), "%s: footprint 0.6 m" % id)
	m.free()


## Ticket Booth building (Dev 10): grounded 2.42 m, inside its 1.5 m footprint, stationary (faces the camera through
## a round of income and never aims), window marker in front, income reaction returns exactly to rest.
func _check_booth_visual() -> void:
	var m: Node3D = _new_match()
	m.ledger.credit(0, 2000, &"test", 0)
	var t: Node3D = m.try_place(content.get_tower(&"ski_resort_ticket_booth"), Vector2(12.0, 1.5))
	var model: Node3D = t._model
	var mesh: MeshInstance3D = model.find_children("*", "MeshInstance3D")[0]
	var box: AABB = mesh.global_transform * mesh.get_aabb()
	var half: float = 0.0  # widest vertex from the centre (the AABB corner overstates the rounded roof)
	for v: Vector3 in mesh.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]:
		var w: Vector3 = mesh.global_transform * v - t.position
		half = maxf(half, Vector2(w.x, w.z).length())
	_check(absf(box.position.y) < 0.01 and absf(box.end.y - 2.42) < 0.02 and half <= 1.5 + 0.005,
			"booth grounded, 2.42 m tall, corners within the 1.5 m footprint (%s)" % box)
	var window: Vector3 = t.muzzle_position() - t.position
	_check(window.z > 0.9 and absf(window.y - 1.237) < 0.02, "booth window marker faces the camera (%s)" % window)
	m.start_round()
	var reacted: bool = false
	for i: int in 60 * 30:
		m.clock.advance(STEP)
		reacted = reacted or t._recoil_t != INF
	_check(reacted, "booth income triggers its reaction")
	_check(is_equal_approx(t._pivot.rotation.y, PI) and t.rotation == Vector3.ZERO, "booth stays still (never aims)")
	t.animate(10.0)
	_check(model.transform == Transform3D(Basis.from_scale(Vector3.ONE * 1.5)) and not t._flash.visible,
			"booth reaction returns exactly to rest")
	_check(is_equal_approx(t.footprint().z, 1.5), "booth footprint 1.5 m")
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


## DEC-042 (Dev 10): base price $750 (ORIGINAL_DEVIATION); upgrade prices unchanged; sellback from what was spent.
func _test_booth_price() -> void:
	var booth: Resource = content.get_tower(&"ski_resort_ticket_booth")
	_check(booth.price == 750 and booth.status["price"] == "ORIGINAL_DEVIATION", "booth costs $750 (ORIGINAL_DEVIATION)")
	_check(booth.get_upgrade(0, 1).price == 500 and booth.get_upgrade(1, 1).price == 300
			and booth.get_upgrade(2, 1).price == 250, "booth tier-1 upgrade prices unchanged (%d/%d/%d)" % [
			booth.get_upgrade(0, 1).price, booth.get_upgrade(1, 1).price, booth.get_upgrade(2, 1).price])
	var m: Node3D = _new_match()
	var spot: Vector2 = Vector2(12.0, 1.5)
	_check(m.ledger.cash == 650 and m.try_place(booth, spot) == null and m.ledger.cash == 650,
			"$650 start cash cannot buy it, nothing charged")
	m.ledger.credit(0, 100, &"test", 0)
	var t: Node3D = m.try_place(booth, spot)
	_check(t != null and m.ledger.cash == 0 and t.spent == 750, "exactly $750 buys it (cash %d)" % m.ledger.cash)
	_check(m.sell_value(t) == roundi(750 * 0.7), "sellback from the $750 invested: $%d" % m.sell_value(t))
	m.ledger.credit(0, booth.get_upgrade(1, 1).price, &"test", 0)
	_check(m.buy_upgrade(t, 1) and t.spent == 750 + booth.get_upgrade(1, 1).price
			and m.sell_value(t) == roundi(t.spent * 0.7), "invested includes upgrades; sellback follows it")
	m.sell(t)
	_check(m.ledger.cash == roundi((750 + booth.get_upgrade(1, 1).price) * 0.7), "sale pays the sellback once")
	m.free()
	_completed.append("_test_booth_price")


## DEC-043 (Dev 10): hover collection as explicit input (set_collect_cursor), applied in the tick after the drops and
## before expiry; every ticket within 1.0 m (world XZ) is collected once, through collect(); click still works.
func _test_ticket_hover() -> void:
	var booth: Resource = content.get_tower(&"ski_resort_ticket_booth")
	var m: Node3D = _new_match()
	_check(is_equal_approx(m.hover_collect_radius_m, 2.0) and m.collect_cursor == null and not m._mouse_in_window,
			"owner doubled default radius to 2.0 m; no cursor input in headless runs")
	# Keep this legacy ordering/expiry fixture at its original radius. New-radius boundaries
	# and visual lifecycle are exercised independently in test_playfeel.gd.
	m.hover_collect_radius_m = 1.0
	m.ledger.credit(0, 2000, &"test", 0)
	var b: Node3D = m.try_place(booth, Vector2(12.0, 1.5))
	for k: int in 4:
		m._drop_pickup(b, k)
	var p: Array = m.pickups.duplicate()
	var paid: Callable = func() -> int: return _cash(m, &"ticket_income")
	# Just inside / just outside the radius.
	m.set_collect_cursor(p[0].pos + Vector3(0.99, 0.0, 0.0))
	m.clock.advance(STEP)
	_check(p[0] not in m.pickups and paid.call() == 50, "0.99 m away: collected ($%d)" % paid.call())
	m.set_collect_cursor(p[1].pos + Vector3(0.0, 0.0, 1.01))
	m.clock.advance(STEP)
	_check(p[1] in m.pickups and paid.call() == 50, "1.01 m away: not collected")
	# Several within reach at once: all collected in one tick, each once.
	p[2].pos = p[1].pos + Vector3(0.5, 0.0, 0.0)
	m.set_collect_cursor(p[1].pos + Vector3(0.25, 0.0, 0.0))
	m.clock.advance(STEP)
	_check(p[1] not in m.pickups and p[2] not in m.pickups and paid.call() == 150, "two nearby tickets in one tick")
	m.clock.advance(STEP)
	_check(paid.call() == 150, "no second credit on the next tick")
	# Click and hover on the same ticket: credited once.
	m.set_collect_cursor(null)
	_check(m.collect_at(p[3].pos) and paid.call() == 200, "click still collects")
	m.set_collect_cursor(p[3].pos)
	m.clock.advance(STEP)
	_check(paid.call() == 200 and not m.collect_at(p[3].pos), "click then hover: credited once")
	# Paused: nothing collected; resumes on the next real tick.
	m._drop_pickup(b, 0)
	var q: Object = m.pickups[0]
	m.set_collect_cursor(q.pos)
	m.clock.paused = true
	m.clock.advance(STEP)
	_check(q in m.pickups and paid.call() == 200, "paused: no hover collection")
	m.clock.paused = false
	m.clock.advance(STEP)
	_check(q not in m.pickups and paid.call() == 250, "unpaused: collected")
	# Same-tick expiry vs hover: hover runs first, so the ticket pays its full value once and no salvage is added.
	m._drop_pickup(b, 1)
	q = m.pickups[0]
	q.life = STEP * 0.5
	q.ratio = 0.5
	m.set_collect_cursor(q.pos)
	_events.clear()
	m.clock.advance(STEP)
	_check(paid.call() == 300 and not _events.any(func(e: RefCounted) -> bool: return e.type == &"pickup_expired"),
			"hover beats same-tick expiry: full value once, no salvage ($%d)" % paid.call())
	# Expired before the cursor arrives: nothing to collect.
	m.set_collect_cursor(null)
	m._drop_pickup(b, 2)
	var spot: Vector3 = m.pickups[0].pos
	_sim(m, 15.1)
	m.set_collect_cursor(spot)
	m.clock.advance(STEP)
	_check(m.pickups.is_empty() and paid.call() == 300, "expired ticket pays nothing on hover")
	# A still cursor takes a new ticket the tick it drops (the round's 4th drop position, k = 3).
	_check(m.state == m.State.PREPARE, "between rounds (PREPARE)")
	var k3: Vector3 = b.position + Vector3(cos(3 * 2.4), 0.0, sin(3 * 2.4)) * (b.footprint().z + 0.3)
	m.set_collect_cursor(k3)
	m.start_round()
	var seen_on_ground: bool = false
	var before: int = paid.call()
	while m.state == m.State.ROUND_SPAWN and paid.call() < before + 50:
		m.clock.advance(STEP)
		seen_on_ground = seen_on_ground or m.pickups.any(func(x: Object) -> bool: return x.pos.distance_to(k3) < 0.01)
	_check(paid.call() == before + 50 and not seen_on_ground, "still cursor: the 4th drop is collected on its tick")
	# Between rounds the match is active: a ticket left on the ground is still collected by hover.
	while m.state != m.State.PREPARE:
		m.clock.advance(STEP)
	m.set_collect_cursor(null)
	m._drop_pickup(b, 0)
	q = m.pickups[-1]
	m.set_collect_cursor(q.pos)
	before = paid.call()
	m.clock.advance(STEP)
	_check(m.state == m.State.PREPARE and q not in m.pickups and paid.call() == before + 50,
			"between rounds: hover collects")
	# After the match ends: no hover collection.
	m.set_collect_cursor(null)
	m._drop_pickup(b, 0)
	q = m.pickups[-1]
	m.lives = 0
	m.start_round()
	m.clock.advance(STEP)
	m.set_collect_cursor(q.pos)
	before = paid.call()
	m.clock.advance(STEP)
	_check(m.is_over() and q in m.pickups and paid.call() == before, "after defeat nothing is collected")
	m.free()
	# Bank drops no tickets, so a parked cursor changes nothing: the bank fills as before.
	m = _new_match()
	m.ledger.credit(0, 100000, &"test", 0)
	b = m.try_place(booth, Vector2(12.0, 1.5))
	for tier: int in 3:
		m.buy_upgrade(b, 1)
	m.set_collect_cursor(Vector3(b.position.x, 0.0, b.position.z))
	m.start_round()
	while m.state == m.State.ROUND_SPAWN or m.state == m.State.ROUND_CLEANUP:
		m.clock.advance(STEP)
	_check(b.bank == roundi(4 * 112 * 1.15) and _cash(m, &"ticket_income") == 0, "Bank: deposits only, hover takes nothing")
	m.free()
	# The real-mouse path (UI blocking, viewport edge) needs a window: checked in the editor run and in the browser.
	_completed.append("_test_ticket_hover")


## P08-T10: base stats vs HYB-M M-10 (v56 Medium) for all six, with provenance; writes the comparison report.
func _test_base_report() -> void:
	# id: [price, range (0 = global/none), interval, damage, pierce, extra]
	var expected: Dictionary = {
		&"snowball_rookie": [200, 32.0, 0.95, 1, 2, ""],
		&"avalanche_cannon": [375, 40.0, 1.5, 0, 1, "blast dmg 1 pierce 22"],
		&"biathlon_ranger": [350, 0.0, 1.59, 2, 1, "global LOS"],
		&"slope_wax_sprayer": [225, 46.0, 1.0, 0, 1, "slow 0.5"],
		&"snow_sorcerer": [250, 40.0, 1.1, 1, 3, "energy"],
		&"ski_resort_ticket_booth": [750, 0.0, 0.0, 0, 0, "4 x $50 / round"],
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
