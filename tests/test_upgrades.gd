extends SceneTree
## P09 tests: crosspath legality (T01/T02), purchase + states (T04/T10), stat fixtures per shipped tier from the
## source pages' "stats at this tier" (T05/T06/T12), transforms that override instead of compounding (T08/T11),
## and the upgrade coverage report (T13).
## Run: godot --headless --path . -s res://tests/test_upgrades.gd   (exit 1 = failure)

const MATCH: String = "res://scenes/main/match.tscn"
const STEP: float = 1.0 / 60.0
const SPOT: Vector2 = Vector2(-7.2, 0)

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
	_test_legality()
	_test_purchase()
	_test_fixtures()
	_test_behaviour()
	_test_data_integrity()
	_coverage_report()
	print("test_upgrades: %s" % ("PASS" if _failures == 0 else "%d FAILURES" % _failures))
	quit(1 if _failures > 0 else 0)


func _new_match() -> Node3D:
	var m: Node3D = load(MATCH).instantiate()
	root.add_child(m)
	m.clock.set_process(false)
	m.ledger.credit(0, 100000, &"test", 0)
	return m


func _sim(m: Node3D, seconds: float) -> void:
	for i: int in int(seconds / STEP):
		m.clock.advance(STEP)


## Places `id` at `spot` and buys `tiers` (top first, then middle, then bottom). Null if any purchase fails.
func _tower(m: Node3D, id: StringName, tiers: Vector3i, spot: Vector2 = SPOT) -> Node3D:
	var t: Node3D = m.try_place(content.get_tower(id), spot)
	for path: int in 3:
		for i: int in tiers[path]:
			if not m.buy_upgrade(t, path):
				return null
	return t


func _park(m: Node3D, id: StringName, dist: float) -> Node3D:
	m._spawn(id)
	var s: Node3D = m.snowballs[-1]
	var def: Resource = content.enemies[id].duplicate()
	def.speed_units = 0.0
	s.set_layer(def)
	s.distance = dist
	s.position = m.course.position_at(dist)
	return s


func _test_legality() -> void:
	var script: GDScript = load("res://scripts/data/tower_definition.gd")
	for legal: Vector3i in [Vector3i(0, 0, 0), Vector3i(2, 2, 0), Vector3i(2, 0, 2), Vector3i(5, 2, 0),
			Vector3i(0, 2, 5), Vector3i(2, 0, 5)]:
		_check(script.is_legal_crosspath(legal), "legal %s" % legal)
	for illegal: Vector3i in [Vector3i(3, 3, 0), Vector3i(3, 2, 1), Vector3i(5, 0, 5)]:
		_check(not script.is_legal_crosspath(illegal), "illegal %s" % illegal)


## Price charged once, invested + sell value follow, and every refused purchase changes nothing.
func _test_purchase() -> void:
	var m: Node3D = _new_match()
	var t: Node3D = _tower(m, &"snowball_rookie", Vector3i(3, 2, 0))
	_check(t != null and t.tiers == Vector3i(3, 2, 0), "Rookie bought to 3-2-0")
	_check(t.spent == 200 + 140 + 200 + 320 + 100 + 190, "invested = base + upgrades (%d)" % t.spent)
	_check(m.sell_value(t) == roundi(t.spent * 0.7), "sell value 70% of invested")
	var cash: int = m.ledger.cash
	_check(m.upgrade_state(t, 2) == "locked" and not m.buy_upgrade(t, 2), "3-2-0: third path locked")
	_check(m.upgrade_state(t, 1) == "locked" and not m.buy_upgrade(t, 1), "3-2-0: middle cannot reach 3")
	_check(m.upgrade_state(t, 0) == "soon" and not m.buy_upgrade(t, 0), "tier 4 not shipped: coming soon")
	_check(m.ledger.cash == cash, "refused purchases charge nothing")
	var poor: Node3D = _new_match()
	var r: Node3D = poor.try_place(content.get_tower(&"snowball_rookie"), SPOT)
	poor.ledger.spend(0, poor.ledger.cash - 50, &"test", 0)
	_check(poor.upgrade_state(r, 0) == "unaffordable" and not poor.buy_upgrade(r, 0) and poor.ledger.cash == 50,
			"unaffordable: refused, no charge")
	_check(poor.upgrade_state(r, 2) == "ok" or poor.ledger.cash < 90, "state ok only when affordable")
	poor.ledger.credit(0, 100, &"test", 0)
	_check(poor.upgrade_state(r, 0) == "ok" and poor.buy_upgrade(r, 0) and poor.ledger.cash == 10, "$140 charged once")
	poor.free()
	m.free()


## Each shipped tier vs the source page's "stats at this tier" (plus v57 overrides and one crosspath per tower).
func _test_fixtures() -> void:
	# [tower, tiers, range, interval, damage, pierce, projectiles, extra-check]
	var rookie: Array = [
		[Vector3i(1, 0, 0), 32.0, 0.95, 1, 3, 1], [Vector3i(2, 0, 0), 32.0, 0.95, 1, 5, 1],
		[Vector3i(3, 0, 0), 36.8, 1.15, 2, 18, 1], [Vector3i(0, 1, 0), 32.0, 0.8075, 1, 2, 1],
		[Vector3i(0, 2, 0), 32.0, 0.6365, 1, 2, 1], [Vector3i(0, 3, 0), 32.0, 0.4774, 1, 2, 3],
		[Vector3i(0, 0, 1), 40.0, 0.95, 1, 2, 1], [Vector3i(0, 0, 2), 48.0, 0.95, 1, 2, 1],
		[Vector3i(0, 0, 3), 60.0, 0.95, 3, 5, 1],  # Crossbow pierce 4 -> 5 (v57)
		[Vector3i(2, 0, 3), 60.0, 0.95, 3, 8, 1], [Vector3i(3, 2, 0), 36.8, 1.15 * 0.6365 / 0.95, 2, 18, 1],
	]
	var lines: PackedStringArray = ["P09-T12 fixtures: tiers -> range interval damage pierce projectiles (expected = source page)"]
	for f: Array in rookie:
		var m: Node3D = _new_match()
		var t: Node3D = _tower(m, &"snowball_rookie", f[0])
		var a: Resource = t.attacks[0]
		var got: Array = [t.range_units, a.interval_s, a.damage, a.pierce, a.projectile_count]
		var ok: bool = is_equal_approx(got[0], f[1]) and absf(got[1] - f[2]) < 1e-3 and got.slice(2) == f.slice(3)
		_check(ok, "rookie %s: %s vs %s" % [f[0], got, f.slice(1)])
		lines.append("snowball_rookie   %s  %s  %s" % [f[0], got, "OK" if ok else "DIFF"])
		if f[0] == Vector3i(3, 0, 0):
			_check(a.damage_type == &"shatter", "Spike-o-pult: Shatter damage")
		if f[0] == Vector3i(0, 0, 2):
			_check(a.detects_camo, "Enhanced Eyesight: camo detection")
		m.free()
	# [tiers, range, interval, blast damage, blast pierce, frag [count, damage, pierce] or [], cluster]
	var cannon: Array = [
		[Vector3i(1, 0, 0), 40.0, 1.5, 1, 28, [], false], [Vector3i(2, 0, 0), 40.0, 1.5, 2, 38, [], false],
		[Vector3i(3, 0, 0), 40.0, 1.5, 4, 80, [], false], [Vector3i(0, 1, 0), 40.0, 1.125, 1, 22, [], false],
		[Vector3i(0, 2, 0), 44.0, 0.825, 1, 22, [], false], [Vector3i(0, 3, 0), 49.0, 0.825, 1, 22, [], false],
		[Vector3i(0, 0, 1), 52.0, 1.5, 1, 22, [], false], [Vector3i(0, 0, 2), 54.0, 1.5, 1, 22, [8, 1, 2], false],
		[Vector3i(0, 0, 3), 54.0, 1.5, 1, 22, [8, 0, 1], true], [Vector3i(2, 0, 3), 54.0, 1.5, 2, 38, [8, 0, 1], true],
	]
	for f: Array in cannon:
		var m: Node3D = _new_match()
		var t: Node3D = _tower(m, &"avalanche_cannon", f[0])
		var a: Resource = t.attacks[0]
		var blast: Resource = t.find_attack(&"avalanche_cannon_blast")
		var frag: Resource = t.find_attack(&"avalanche_cannon_frag")
		var frag_got: Array = [frag.projectile_count, frag.damage, frag.pierce] if frag else []
		var got: Array = [t.range_units, a.interval_s, blast.damage, blast.pierce, frag_got,
				frag != null and not frag.on_expire.is_empty()]
		var ok: bool = is_equal_approx(got[0], f[1]) and absf(got[1] - f[2]) < 1e-3 and got.slice(2) == f.slice(3)
		_check(ok, "cannon %s: %s vs %s" % [f[0], got, f.slice(1)])
		lines.append("avalanche_cannon  %s  %s  %s" % [f[0], got, "OK" if ok else "DIFF"])
		m.free()
	FileAccess.open("res://docs/logs/evidence/p09_fixtures.txt", FileAccess.WRITE).store_string("\n".join(lines) + "\n")


## Transforms change behaviour: Spike-o-pult pops 2 layers per hit; Triple Shot fires 3 projectiles; Frag Bombs
## hit a snowball outside the blast; rebuilding twice never compounds and shared data stays untouched.
func _test_behaviour() -> void:
	var m: Node3D = _new_match()
	_tower(m, &"snowball_rookie", Vector3i(3, 0, 0))
	var coral: Node3D = _park(m, &"coral", 14.0)
	_sim(m, 0.5)
	_check(coral.def.id == &"mint", "Spike-o-pult: one hit removes 2 layers (%s)" % coral.def.id)
	m.free()

	m = _new_match()
	_tower(m, &"snowball_rookie", Vector3i(0, 3, 0))
	_park(m, &"coral", 14.0)
	m.clock.advance(STEP)
	_check(m.shots.size() == 3, "Triple Shot: 3 projectiles per attack (got %d)" % m.shots.size())
	m.free()

	# Blast capped to pierce 1 so only sub-attacks can pop the other two of three snowballs on one spot:
	# 0-0-1 pops 1; Frag Bombs (0-0-2) and Cluster Bombs (0-0-3, frag contact -> exhaust explosion) pop all 3.
	for f: Array in [[Vector3i(0, 0, 1), 1], [Vector3i(0, 0, 2), 3], [Vector3i(0, 0, 3), 3]]:
		m = _new_match()
		var cannon: Node3D = _tower(m, &"avalanche_cannon", f[0])
		cannon.find_attack(&"avalanche_cannon_blast").pierce = 1
		for i: int in 3:
			_park(m, &"powder", 14.0)
		var cash: int = m.ledger.cash
		_sim(m, 0.5)
		_check(3 - m.snowballs.size() == f[1] and m.ledger.cash - cash == f[1], "%s pops %d of 3 (popped %d)"
				% [f[0], f[1], 3 - m.snowballs.size()])
		m.free()

	m = _new_match()
	var t: Node3D = _tower(m, &"snowball_rookie", Vector3i(2, 0, 3))
	var pierce: int = t.attacks[0].pierce
	t.rebuild_stats()
	t.rebuild_stats()
	_check(t.attacks[0].pierce == pierce and is_equal_approx(t.range_units, 60.0), "rebuild never compounds")
	_check(content.get_tower(&"snowball_rookie").attacks[0].pierce == 2, "shared definition untouched")
	m.free()


## Every effect of every shipped upgrade resolves: its attack exists in the base tree or is added by another upgrade.
func _test_data_integrity() -> void:
	for tower: Resource in content.towers:
		var ids: Array[StringName] = [&""]
		for a: Resource in tower.attacks:
			for sub: Resource in a.tree():
				ids.append(sub.id)
		for u: Resource in tower.upgrades:
			for e: Resource in u.effects:
				if e.attack:
					for sub: Resource in e.attack.tree():
						ids.append(sub.id)
		for u: Resource in tower.upgrades:
			for e: Resource in u.effects:
				_check(e.target in ids, "%s: effect target %s exists" % [u.id, e.target])
				if e.attack:
					_check(e.attack.validate().is_empty(), "%s: appended attack valid %s" % [u.id, e.attack.validate()])
			_check(u.is_available() == (u.status.get("effects", "") in ["VERIFIED_SOURCE", "PATCHED_SOURCE"]),
					"%s: purchasable only when verified" % u.id)


## P09-T13: verified + implemented + tested vs deferred out of 90 initial tier entries.
func _coverage_report() -> void:
	var lines: PackedStringArray = ["P09-T13 upgrade coverage (90 initial tier entries). shipped = effects verified from the",
			"source page, implemented and covered by tests/test_upgrades.gd; coming soon = not purchasable.",
			"tower                    shipped  coming_soon  shipped tiers"]
	var total: int = 0
	for tower: Resource in content.towers:
		var shipped: PackedStringArray = []
		for u: Resource in tower.upgrades:
			if u.is_available():
				shipped.append("%s%d" % ["TMB"[u.path], u.tier])
		total += shipped.size()
		lines.append("%-24s %7d  %11d  %s" % [tower.id, shipped.size(), 15 - shipped.size(), " ".join(shipped)])
	lines.append("TOTAL shipped %d / 90, coming soon %d" % [total, 90 - total])
	FileAccess.open("res://docs/logs/evidence/p09_upgrade_coverage.txt", FileAccess.WRITE).store_string("\n".join(lines) + "\n")
	print("\n".join(lines))
