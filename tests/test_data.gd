extends SceneTree
## P02 tests: content load/validation/determinism, crosspath legality, broken fixtures, simulation clock.
## Run: godot --headless --path . -s res://tests/test_data.gd   (exit 1 = failure)

var _failures: int = 0


func _check(ok: bool, what: String) -> void:
	if not ok:
		_failures += 1
		printerr("FAIL: " + what)


func _initialize() -> void:
	var content_script: GDScript = load("res://scripts/core/content.gd")
	var content: Node = content_script.new()
	content.load_from("res://resources/")
	_check(content.errors.is_empty(), "real content validates: %s" % "\n".join(content.errors))
	_check(content.towers.size() == 6 and content.enemies.size() == 5 and content.rounds.size() == 10,
			"6 towers, 5 enemies, 10 rounds")
	for tower: Resource in content.towers:
		_check(tower.upgrades.size() == 15, "%s has 3x5 upgrades" % tower.id)

	# Determinism: a second load gives the identical report (same order, same values).
	var report: String = content.status_report()
	var again: Node = content_script.new()
	again.load_from("res://resources/")
	_check(again.status_report() == report, "loader is deterministic")
	again.free()
	_check(not report.contains("[MISSING]"), "every balance value has a status")
	DirAccess.make_dir_recursive_absolute("res://docs/logs/evidence")
	FileAccess.open("res://docs/logs/evidence/p02_status_report.txt", FileAccess.WRITE).store_string(report + "\n")

	# Golden RBE: layer chain Powder..Coral = 1..5; rounds 1-10 match the source round pages.
	var expected_rbe: Array[int] = [20, 35, 35, 71, 59, 57, 75, 92, 90, 204]
	for i: int in 10:
		_check(content.round_rbe(i) == expected_rbe[i], "round %d RBE %d" % [i + 1, content.round_rbe(i)])
	_check([&"powder", &"blue", &"mint", &"violet", &"coral"].map(content.rbe) == [1, 2, 3, 4, 5], "layer RBE")
	var r1: Array = content.rounds[0].schedule()
	_check(r1.size() == 20 and is_equal_approx(r1[-1][0], 17.51), "round 1: 20 spawns over 17.51 s")

	# Crosspath legality (M-07) and wrong-branch rejection.
	var tower_script: GDScript = load("res://scripts/data/tower_definition.gd")
	for legal: Vector3i in [Vector3i(5, 2, 0), Vector3i(0, 2, 5), Vector3i(2, 0, 5), Vector3i(0, 0, 0), Vector3i(2, 2, 0)]:
		_check(tower_script.is_legal_crosspath(legal), "legal %s" % legal)
	for illegal: Vector3i in [Vector3i(3, 3, 0), Vector3i(1, 1, 1), Vector3i(6, 0, 0), Vector3i(5, 0, 3), Vector3i(-1, 0, 0)]:
		_check(not tower_script.is_legal_crosspath(illegal), "illegal %s" % illegal)
	var rookie: Resource = content.get_tower(&"snowball_rookie")
	_check(not rookie.can_upgrade(Vector3i(5, 2, 0), 2), "5-2-0 cannot open the third path")
	_check(not rookie.can_upgrade(Vector3i(3, 2, 0), 1), "3-2-0 cannot raise middle to 3")
	_check(not rookie.can_upgrade(Vector3i(5, 0, 0), 0), "no tier 6")
	_check(rookie.can_upgrade(Vector3i(2, 2, 0), 0), "2-2-0 can go to 3-2-0")

	_test_fixtures(content_script)
	_test_clock()
	content.free()
	print("test_data: %s" % ("PASS" if _failures == 0 else "%d FAILURES" % _failures))
	quit(1 if _failures > 0 else 0)


## Test-only fixture (P02-T13): tiny valid set, then one deliberate defect per validator.
func _test_fixtures(content_script: GDScript) -> void:
	var c: Node = content_script.new()
	c.rules = _def("match_rules", &"fx_rules", {"start_cash": "PROTOTYPE_ASSUMPTION",
			"start_lives": "PROTOTYPE_ASSUMPTION", "round_bonus_base": "PROTOTYPE_ASSUMPTION", "sell_ratio": "PROTOTYPE_ASSUMPTION"})
	var attack: Resource = _def("attack_definition", &"fx_attack", {"interval_s": "PROTOTYPE_ASSUMPTION",
			"damage": "PROTOTYPE_ASSUMPTION", "pierce": "PROTOTYPE_ASSUMPTION", "projectile_count": "PROTOTYPE_ASSUMPTION",
			"splash_pierce": "NOT_APPLICABLE", "slow_factor": "NOT_APPLICABLE"})
	c.hero = _def("hero_definition", &"fx_hero", {"price": "PROTOTYPE_ASSUMPTION", "range_units": "PROTOTYPE_ASSUMPTION",
			"footprint_units": "PROTOTYPE_ASSUMPTION"})
	c.hero.attack = attack
	c.hero.level_xp.assign([0, 10])
	c.hero.level_changes.append_array([{}, {"pierce": 4}])
	var tower: Resource = _def("tower_definition", &"fx_tower", {"price": "PROTOTYPE_ASSUMPTION",
			"range_units": "PROTOTYPE_ASSUMPTION", "footprint_units": "PROTOTYPE_ASSUMPTION",
			"pickups_per_round": "NOT_APPLICABLE", "cash_per_pickup": "NOT_APPLICABLE"})
	tower.attacks.append(attack)
	for tier: int in [1, 2]:
		var upgrade: Resource = _def("upgrade_definition", StringName("fx_up%d" % tier), {"price": "PROTOTYPE_ASSUMPTION"})
		upgrade.tier = tier
		tower.upgrades.append(upgrade)
	c.towers.append(tower)
	var inner: Resource = _def("enemy_definition", &"fx_inner", {"speed_units": "PROTOTYPE_ASSUMPTION",
			"child_count": "PROTOTYPE_ASSUMPTION", "cash_per_pop": "PROTOTYPE_ASSUMPTION"})
	var outer: Resource = inner.duplicate()
	outer.id = &"fx_outer"
	outer.child_id = &"fx_inner"
	outer.child_count = 2
	c.enemies[inner.id] = inner
	c.enemies[outer.id] = outer
	var round_def: Resource = _def("round_definition", &"fx_round", {"groups": "PROTOTYPE_ASSUMPTION"})
	var group: Resource = load("res://scripts/data/spawn_group.gd").new()
	group.enemy_id = &"fx_outer"
	group.count = 3
	round_def.groups.append(group)
	c.rounds.append(round_def)
	_check(c.validate().is_empty(), "fixture validates: %s" % "\n".join(c.validate()))
	_check(c.rbe(&"fx_outer") == 3 and c.round_rbe(0) == 9, "fixture RBE")

	_expect_error(c, func() -> void: tower.price = -5, "negative value", func() -> void: tower.price = 0)
	_expect_error(c, func() -> void: tower.status.erase("price"), "missing status",
			func() -> void: tower.status["price"] = "PROTOTYPE_ASSUMPTION")
	_expect_error(c, func() -> void: tower.status["price"] = "GUESS", "unknown status",
			func() -> void: tower.status["price"] = "PROTOTYPE_ASSUMPTION")
	_expect_error(c, func() -> void: tower.upgrades[0].tier = 3, "prerequisite", func() -> void: tower.upgrades[0].tier = 1)
	_expect_error(c, func() -> void: tower.upgrades[0].tier = 2, "duplicate upgrade", func() -> void: tower.upgrades[0].tier = 1)
	_expect_error(c, func() -> void: outer.child_id = &"fx_missing", "undefined child", func() -> void: outer.child_id = &"fx_inner")
	_expect_error(c, func() -> void: inner.child_id = &"fx_outer"; inner.child_count = 1, "loops",
			func() -> void: inner.child_id = &""; inner.child_count = 0)
	_expect_error(c, func() -> void: group.enemy_id = &"fx_missing", "undefined enemy", func() -> void: group.enemy_id = &"fx_outer")
	_expect_error(c, func() -> void: group.count = 0, "count <= 0", func() -> void: group.count = 3)
	_expect_error(c, func() -> void: c.hero.level_xp[1] = 0, "not increasing", func() -> void: c.hero.level_xp[1] = 10)
	c.free()


func _expect_error(c: Node, breaker: Callable, needle: String, fixer: Callable) -> void:
	breaker.call()
	var errors: PackedStringArray = c.validate()
	_check(Array(errors).any(func(e: String) -> bool: return e.contains(needle)), "validator reports '%s' (got %s)" % [needle, errors])
	fixer.call()
	_check(c.validate().is_empty(), "fixture valid again after '%s'" % needle)


func _def(script_name: String, id: StringName, status: Dictionary) -> Resource:
	var def: Resource = load("res://scripts/data/%s.gd" % script_name).new()
	def.id = id
	def.status.assign(status)
	return def


## P02-T08: fixed step, speed as time scale, pause, long-frame cap.
func _test_clock() -> void:
	var clock: Node = load("res://scripts/core/sim_clock.gd").new()
	var ticks: Array[int] = [0]
	clock.ticked.connect(func(_dt: float) -> void: ticks[0] += 1)
	for i: int in 60:
		clock.advance(1.0 / 60.0)
	_check(clock.tick == 60 and ticks[0] == 60, "1 s at 1x = 60 ticks (got %d)" % clock.tick)
	clock.speed = 2.0
	for i: int in 60:
		clock.advance(1.0 / 60.0)
	_check(clock.tick == 180, "1 s at 2x = 120 more ticks (got %d)" % clock.tick)
	clock.paused = true
	_check(clock.advance(5.0) == 0 and clock.tick == 180, "paused clock does not tick")
	clock.paused = false
	clock.speed = 1.0
	_check(clock.advance(10.0) == clock.MAX_STEPS_PER_FRAME, "a 10 s frame runs at most MAX_STEPS_PER_FRAME")
	clock.free()
