extends SceneTree
## Dev 13 selected-tower Pops: one pop = one layer_broken attributed to that placed tower (source_id). Checks direct
## hits, split children, explosion sub-attacks, wax damage over time, immune hits and leaks (no pops), upgrades keep
## the count, a new tower starts at 0, and pop cash is unchanged (one `pop` ledger credit per counted pop).
## Run: godot --headless --path . -s res://tests/test_pops.gd   (exit 1 = failure)

const MATCH: String = "res://scenes/main/match.tscn"

var _failures: int = 0
var _broken: Dictionary = {}  # source_id -> layer_broken events seen by the test itself


func _check(ok: bool, what: String) -> void:
	if not ok:
		_failures += 1
		printerr("FAIL: " + what)


func _initialize() -> void:
	_run.call_deferred()


func _on_event(e: RefCounted) -> void:
	if e.type == &"layer_broken":
		_broken[e.source_id] = _broken.get(e.source_id, 0) + 1


func _run() -> void:
	var content: Node = root.get_node("Content")
	root.get_node("Events").emitted.connect(_on_event)
	var m: Node3D = load(MATCH).instantiate()
	root.add_child(m)
	m.clock.set_process(false)
	await process_frame
	m.ledger.credit(0, 5000, &"test", 0)
	var rookie: Node3D = m.try_place(content.get_tower(&"snowball_rookie"), Vector2(-7.2, 0))
	var cannon: Node3D = m.try_place(content.get_tower(&"avalanche_cannon"), Vector2(3.5, 0))
	var wax: Node3D = m.try_place(content.get_tower(&"slope_wax_sprayer"), Vector2(0.5, 0))
	_check(rookie and cannon and wax and rookie.pops == 0 and cannon.pops == 0, "towers placed, pops start at 0")
	var cash_before: int = m.ledger.cash

	# Direct hit, 2 damage on Black: Black breaks and splits, the leftover damage breaks both Coral children = 3 pops.
	m._spawn(&"black")
	var black: Node3D = m.snowballs[-1]
	black.position = m.course.position_at(20.0)
	m.damage_snowball(black, 2, &"normal", rookie.entity_id)
	_check(rookie.pops == 3 and _broken.get(rookie.entity_id, 0) == 3, "direct hit + split children: 3 pops (%d)" % rookie.pops)
	var pop_cash: int = 0
	for t: Dictionary in m.ledger.transactions:
		if t.reason == &"pop" and t.source_id == rookie.entity_id:
			pop_cash += 1
	_check(pop_cash == rookie.pops, "one pop credit per counted pop (cash path unchanged)")
	_check(m.ledger.cash > cash_before, "pop cash still paid")

	# Immune: explosion on Black = no pops, no cash.
	m._spawn(&"black")
	var black2: Node3D = m.snowballs[-1]
	black2.position = m.course.position_at(30.0)
	m.damage_snowball(black2, 1, &"explosion", cannon.entity_id)
	_check(cannon.pops == 0, "immune hit gives no pops")

	# Explosion sub-attack through the real projectile-contact path: every break credited to the cannon.
	for s: Node3D in m.snowballs.duplicate():
		m._leak(s)
	var leaked_pops: int = rookie.pops + cannon.pops
	_check(leaked_pops == 3, "leaks give no pops")
	m._spawn(&"mint")
	var mint: Node3D = m.snowballs[-1]
	mint.position = m.course.position_at(25.0)
	m._spawn(&"blue")
	m.snowballs[-1].position = mint.position + Vector3(0.3, 0, 0)
	var hit: Dictionary[int, bool] = {}
	m._hit(cannon.attacks[0], mint, hit, Vector3.RIGHT, cannon.entity_id)
	_check(cannon.pops > 0 and cannon.pops == _broken.get(cannon.entity_id, 0),
			"projectile + explosion: %d pops, %d events" % [cannon.pops, _broken.get(cannon.entity_id, 0)])
	_check(rookie.pops == 3, "other towers unaffected")

	# Damage over time (corrosive wax): the wax tower gets the pops from the tick loop.
	for s: Node3D in m.snowballs.duplicate():
		m._leak(s)
	m.state = m.State.ROUND_CLEANUP
	m._spawn(&"blue")
	var blue: Node3D = m.snowballs[-1]
	blue.slow_left = 10.0
	blue.dot_damage = 1
	blue.dot_interval = 0.1
	blue.dot_timer = 0.05
	blue.dot_source = wax.entity_id
	for k: int in 6:
		m._on_tick(1.0 / 60.0)
	_check(wax.pops == 1 and _broken.get(wax.entity_id, 0) == 1, "damage over time credits the wax tower (%d)" % wax.pops)

	# Upgrades keep the count; a new tower starts at zero.
	m.buy_upgrade(rookie, 0)
	_check(rookie.pops == 3, "upgrade keeps pops")
	var fresh: Node3D = m.try_place(content.get_tower(&"snowball_rookie"), Vector2(-7.2, 3.0))
	_check(fresh != null and fresh.pops == 0, "new tower starts at 0")
	m.free()
	print("test_pops: %s" % ("PASS" if _failures == 0 else "%d FAILURES" % _failures))
	quit(1 if _failures > 0 else 0)
