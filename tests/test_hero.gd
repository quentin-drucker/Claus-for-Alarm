extends SceneTree
## P10 hero tests: singleton + price (T01/T11), ricochet (T02), round XP (T03), level application once (T04),
## Snowball Frenzy (T05/T09), Focused Shot (T06), camo at 5 (T07), level fixtures 1/3/4/5/6/7/10/19/20 (T08/T12),
## and the highest level a normal 25-round match reaches (written to docs/logs/evidence/p10_hero_levels.txt).
## Run: godot --headless --path . -s res://tests/test_hero.gd   (exit 1 = failure)

const MATCH: String = "res://scenes/main/match.tscn"
const STEP: float = 1.0 / 60.0
const SPOT: Vector2 = Vector2(-7.2, 0)  # 1.8 m from the track at distance 14

var _failures: int = 0
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
	_test_placement()
	_test_levels()
	_test_ricochet()
	_test_frenzy()
	_test_focus()
	_test_round_xp()
	_test_visual()
	_check(_completed.size() == 7, "every test function completed (%s)" % [_completed])
	print("test_hero: %s" % ("PASS" if _failures == 0 else "%d FAILURES" % _failures))
	quit(1 if _failures > 0 else 0)


func _new_match(cash: int = 0) -> Node3D:
	var m: Node3D = load(MATCH).instantiate()
	root.add_child(m)
	m.clock.set_process(false)
	if cash > 0:
		m.ledger.credit(0, cash, &"test", 0)
	return m


func _sim(m: Node3D, seconds: float) -> void:
	for i: int in int(round(seconds / STEP)):
		m.clock.advance(STEP)


func _park(m: Node3D, id: StringName, dist: float) -> Node3D:
	m._spawn(id)
	var s: Node3D = m.snowballs[-1]
	var def: Resource = content.enemies[id].duplicate()
	def.speed_units = 0.0
	s.set_layer(def)
	s.distance = dist
	s.position = m.course.position_at(dist)
	return s


func _test_placement() -> void:
	var m: Node3D = _new_match()
	var hero_def: Resource = content.hero
	_check(m.shop[-1] == hero_def and m.shop.size() == 7, "hero is the 7th shop entry")
	var cash: int = m.ledger.cash
	var h: Node3D = m.try_place(hero_def, SPOT)
	_check(h != null and m.ledger.cash == cash - 540 and hero_def.price == 540, "hero placed for $540 (v56 Medium)")
	_check(m.placement_reason(hero_def, Vector2(0.5, 0)) == "Only one Camel Claus per match"
			and m.try_place(hero_def, Vector2(0.5, 0)) == null, "a second hero is refused")
	for path: int in 3:
		_check(not m.buy_upgrade(h, path) and m.upgrade_state(h, path) == "max", "no tower upgrade path %d on the hero" % path)
	_check(not m.use_frenzy() and not m.toggle_focus(), "level 1: hotkeys cannot force Frenzy or Focus")
	m.sell(h)
	m.ledger.credit(0, 1000, &"test", 0)
	_check(m.hero_node() == null and m.placement_reason(hero_def, SPOT) == "", "after selling, the hero can be placed again")
	m.free()
	_completed.append("_test_placement")


## [level, pierce, interval, projectiles, range, camo, frenzy x, frenzy cooldown, frenzy unlocked, focus unlocked]
func _test_levels() -> void:
	var m: Node3D = _new_match(1000)
	var h: Node3D = m.try_place(content.hero, SPOT)
	var rows: Array = [
		[1, 3, 0.95, 1, 50.0, false, 3.0, 60.0, false, false],
		[3, 4, 0.95, 1, 50.0, false, 3.0, 60.0, true, false],
		[4, 4, 0.95, 1, 52.0, false, 3.0, 60.0, true, true],
		[5, 4, 0.95, 1, 52.0, true, 3.0, 60.0, true, true],
		[6, 4, 0.95, 2, 52.0, true, 3.0, 60.0, true, true],
		[7, 4, 0.95, 2, 52.0, true, 3.0, 60.0, true, true],
		[10, 6, 0.95, 2, 52.0, true, 3.0, 60.0, true, true],
		[19, 9, 0.25, 3, 54.0, true, 4.0, 45.0, true, true],
		[20, 9, 0.2, 3, 54.0, true, 4.0, 45.0, true, true],
	]
	for row: Array in rows:
		m.set_hero_level(row[0])
		var a: Resource = h.attacks[0]
		var got: Array = [h.level, a.pierce, snappedf(a.interval_s, 0.001), a.projectile_count, h.range_units, a.detects_camo,
				h.frenzy_multiplier, h.frenzy_cooldown_s, h.has_unlock("snowball_frenzy"), h.has_unlock("focused_shot")]
		_check(str(got) == str(row), "level %d fixture %s (got %s)" % [row[0], row, got])
	_check(h.has_unlock("blizzard_barrage"), "level 10+ unlocks Blizzard Barrage in data (not playable: unreachable)")
	# Applied once: rebuilding twice or levelling down and up gives identical stats, shared data untouched.
	m.set_hero_level(6)
	h.rebuild_stats()
	h.rebuild_stats()
	_check(h.attacks[0].projectile_count == 2 and h.attacks[0].pierce == 4, "level 6 stats stable across rebuilds")
	# Level 6 in play (reachable by round 25): one attack = two shots, each hits the same Coral once -> 2 layers.
	var coral: Node3D = _park(m, &"coral", 14.0)
	_sim(m, 0.5)
	_check(coral.def.id == &"mint", "level 6: one attack, two shots, Coral -> Mint (got %s)" % coral.def.id)
	m.snowballs.erase(coral)
	coral.free()
	m.set_hero_level(2)
	_check(h.attacks[0].projectile_count == 1 and h.range_units == 50.0 and h.level == 2, "levelling down rebuilds from data")
	_check(content.hero.attacks[0].pierce == 3 and content.hero.attacks[0].projectile_count == 1, "hero data untouched")
	var ups: int = _events.filter(func(e: RefCounted) -> bool: return e.type == &"hero_level_up").size()
	_check(ups > 0, "hero_level_up events sent")
	m.free()
	_completed.append("_test_levels")


## One shot, pierce 3, bounces to the two other snowballs 1 m apart: all three pop from a single attack.
func _test_ricochet() -> void:
	var m: Node3D = _new_match(1000)
	var h: Node3D = m.try_place(content.hero, SPOT)
	for d: float in [14.0, 15.0, 16.0]:
		_park(m, &"powder", d)
	_events.clear()
	_sim(m, 0.5)
	var fired: int = _events.filter(func(e: RefCounted) -> bool: return e.type == &"attack_fired" and e.source_id == h.entity_id).size()
	_check(fired == 1 and m.snowballs.is_empty(), "one ricochet shot pops 3 snowballs (fired %d, left %d)" % [fired, m.snowballs.size()])
	m.free()
	_completed.append("_test_ricochet")


## Frenzy: 3x attack speed for 8 s, 60 s cooldown from activation; timers run only during rounds, freeze on pause,
## follow 2x; no second activation while active/recharging; a new match starts clean.
func _test_frenzy() -> void:
	var m: Node3D = _new_match(1000)
	var h: Node3D = m.try_place(content.hero, SPOT)
	m.set_hero_level(3)
	_check(m.frenzy_state() == "ready" and m.use_frenzy(), "level 3: Frenzy activates")
	_check(is_equal_approx(h.attacks[0].interval_s, 0.95 / 3.0) and m.frenzy_state() == "active", "Frenzy: interval 0.95 / 3")
	_check(not m.use_frenzy(), "no second activation while active")
	_sim(m, 2.0)  # PREPARE: timers frozen between rounds
	_check(is_equal_approx(h.frenzy_left, 8.0), "Frenzy does not run down between rounds (%s)" % h.frenzy_left)
	m.start_round()
	_sim(m, 2.0)
	_check(absf(h.frenzy_left - 6.0) < 0.02 and absf(h.frenzy_cooldown_left - 58.0) < 0.02, "2 s of round: 6 s left, cooldown 58 s")
	m.set_paused(true)
	_sim(m, 5.0)
	_check(absf(h.frenzy_left - 6.0) < 0.02, "pause freezes Frenzy")
	m.set_paused(false)
	m.toggle_speed()
	_sim(m, 3.0)  # 2x: 3 s wall = 6 s sim
	_check(m.frenzy_state() == "cooldown" and is_equal_approx(h.attacks[0].interval_s, 0.95),
			"2x: 6 s sim ends Frenzy, interval back to 0.95 (%s, %s)" % [m.frenzy_state(), h.attacks[0].interval_s])
	_check(absf(h.frenzy_cooldown_left - 52.0) < 0.05 and not m.use_frenzy(), "recharging 52 s, cannot activate")
	m.free()
	m = _new_match(1000)
	m.try_place(content.hero, SPOT)
	_check(m.frenzy_state() == "locked", "new match: fresh level-1 hero, Frenzy locked")
	m.free()
	_completed.append("_test_frenzy")


## Focused Shot (v57, level 4): interval x1.25, projectile speed x1.25, range x1.2; toggles back exactly.
func _test_focus() -> void:
	var m: Node3D = _new_match(1000)
	var h: Node3D = m.try_place(content.hero, SPOT)
	m.set_hero_level(4)
	_check(m.toggle_focus() and h.focus, "Focus on at level 4")
	var a: Resource = h.attacks[0]
	_check(is_equal_approx(a.interval_s, 0.95 * 1.25) and is_equal_approx(a.projectile_speed_units, 300.0 * 1.25)
			and is_equal_approx(h.range_units, 52.0 * 1.2), "Focus: interval x1.25, speed x1.25, range x1.2")
	m.set_hero_level(3)
	_check(not h.has_unlock("focused_shot") and not m.toggle_focus(), "below level 4 Focus cannot be toggled")
	m.set_hero_level(4)
	_check(m.toggle_focus() and not h.focus and is_equal_approx(h.attacks[0].interval_s, 0.95) and h.range_units == 52.0,
			"Focus off restores the level-4 stats")
	m.free()
	_completed.append("_test_focus")


## XP per round (20r + 20, 40r - 380 after round 20) arrives at each round end; a hero placed before round 1 levels at the right boundary.
## Report: XP and level after every round of the 25-round match -> highest reachable level.
func _test_round_xp() -> void:
	var m: Node3D = _new_match(100000)
	var h: Node3D = m.try_place(content.hero, SPOT)
	m.lives = 1000000  # XP must not depend on the defence holding; leaks are irrelevant here
	var lines: PackedStringArray = ["P10 hero XP in a normal match (hero placed before round 1, BTD6 round XP 20r+20, 40r-380 from round 21).",
			"round  xp_gained  total_xp  level"]
	var xp: int = 0
	var reached: Dictionary = {}
	while not m.is_over():
		m.start_round()
		while m.state == m.State.ROUND_SPAWN or m.state == m.State.ROUND_CLEANUP:
			m.clock.advance(STEP)
		var r: int = m.round_index + 1
		xp += 20 * r + 20 if r <= 20 else 40 * r - 380
		_check(h.xp == xp, "round %d: hero XP %d (got %d)" % [r, xp, h.xp])
		reached.get_or_add(h.level, r)
		lines.append("%5d  %9d  %8d  %5d" % [r, 20 * r + 20 if r <= 20 else 40 * r - 380, h.xp, h.level])
	_check(m.state == m.State.WON, "XP match won")
	_check(reached.get(2) == 3 and reached.get(3) == 7 and reached.get(4) == 12 and reached.get(5) == 18 and reached.get(6) == 25,
			"levels 2/3/4/5/6 after rounds 3/7/12/18/25 (got %s)" % [reached])
	_check(h.level == 6, "highest level in a 25-round match = 6 (got %d)" % h.level)
	lines.append("Reached: level 2 after round %d, 3 after %d (Snowball Frenzy), 4 after %d (Focused Shot), 5 after %d (camo), 6 after %d (two shots: only once round 25 is won)."
			% [reached.get(2), reached.get(3), reached.get(4), reached.get(5), reached.get(6)])
	lines.append("Max level in a normal match: %d (%d XP; level 7 needs 11,960). Level 6 is implemented (fixtures); levels 7-20 data only until DEC-030."
			% [h.level, h.xp])
	FileAccess.open("res://docs/logs/evidence/p10_hero_levels.txt", FileAccess.WRITE).store_string("\n".join(lines) + "\n")
	print("\n".join(lines))
	m.free()
	_completed.append("_test_round_xp")


## Camel Claus base form (Dev 11, presentation only): grounded 2.52 m GLB on a visual pivot, launcher marker in front,
## every reachable shot (and the level-6 debug volley) starts its visual at the launcher while the simulated origin
## stays the tower position; wind-up / Focus pose / Frenzy ring / level-up glint come from existing state, stay
## bounded under Frenzy fire, freeze on pause and return exactly to rest; footprint unchanged.
func _test_visual() -> void:
	var m: Node3D = _new_match(1000)
	var h: Node3D = m.try_place(content.hero, SPOT)
	var model: Node3D = h._model
	var p: Resource = h._profile
	var rest: Transform3D = Transform3D(Basis.from_scale(Vector3.ONE * 1.5))
	_check(model != null and h._anim == null and h._flash != null and h._frenzy_ring != null and h._glint != null,
			"hero: static GLB, launcher puff, rings and glint")
	var mesh: MeshInstance3D = model.find_children("*", "MeshInstance3D")[0]
	var box: AABB = mesh.global_transform * mesh.get_aabb()
	_check(absf(box.position.y) < 0.01 and absf(box.end.y - 2.52) < 0.03, "hero grounded, 2.52 m tall (%s)" % box)
	_check(is_equal_approx(h.footprint().z, 0.6), "hero footprint 0.6 m unchanged")
	var dir: Vector3 = Vector3(1, 0, 0)
	h.play_attack(dir)
	var muzzle: Vector3 = h.muzzle_position() - h.position
	_check(h.rotation == Vector3.ZERO and absf(muzzle.y - 0.823) < 0.02 and muzzle.x > 0.3 and absf(muzzle.z) < 0.02,
			"launcher marker 0.82 m high, in front along the aim; root never turns (%s)" % muzzle)
	# Real shots: the visual starts at the launcher, the simulated shot at the tower position (XZ).
	for lvl: int in [1, 6]:  # 6 = debug-only volley of two (unreachable in 25 rounds)
		m.set_hero_level(lvl)
		_park(m, &"coral", 14.0)
		m.start_round()
		var fired: Array = []
		for i: int in 240:
			m.clock.advance(STEP)
			if not m.shots.is_empty():
				fired = m.shots.duplicate()
				break
		var offset: Vector3 = h.muzzle_position() - h.position - Vector3.UP * 0.5  # faded by one tick below
		_check(fired.size() == h.attacks[0].projectile_count, "level %d: %d shot(s) fired" % [lvl, fired.size()])
		for shot: RefCounted in fired:
			var start: Vector3 = shot.pos - shot.velocity * STEP
			_check(Vector2(start.x - h.position.x, start.z - h.position.z).length() < 0.05
					and shot.offset.is_equal_approx(offset.move_toward(Vector3.ZERO, m.MUZZLE_BLEND_MPS * STEP)), "level %d: sim origin = tower, visual offset = launcher" % lvl)
		m.free()
		m = _new_match(1000)
		h = m.try_place(content.hero, SPOT)
	model = h._model
	# Level-up: glint + XP pulse once, then gone; a level change down shows nothing.
	m.set_hero_level(4)
	m.clock.advance(STEP)
	_check(h._xp_ring.visible and h._glint.visible, "level-up shows the XP pulse and hat glint")
	_sim(m, 1.0)
	_check(not h._xp_ring.visible and not h._glint.visible, "level-up feedback ends")
	# Focus: held pose eased in, reticle ring; off again = exact rest.
	m.toggle_focus()
	_sim(m, 0.3)
	_check(is_equal_approx(h._focus_k, 1.0) and h._focus_ring.visible and h._lens.visible and model.transform != rest,
			"Focus: pose + reticle + goggle lens")
	m.toggle_focus()
	_sim(m, 0.3)
	_check(model.transform == rest and not h._focus_ring.visible and not h._lens.visible, "Focus off: exact rest")
	# Frenzy: pulse ring while active; rapid fire stays bounded; pause freezes; ring off and exact rest after.
	m.use_frenzy()
	m.clock.advance(STEP)
	_check(h._frenzy_ring.visible, "Frenzy: ring visible while active")
	var squash_max: float = p.recoil_squash * p.frenzy_recoil_mult + p.anticipation_squash + 1e-5
	for i: int in 30:
		h.play_attack(dir)
		h.animate(STEP)
		h.animate(STEP)
		_check(model.position.length() <= p.recoil_m + 1e-5 and model.scale.y >= 1.5 * (1.0 - squash_max)
				and model.basis.orthonormalized().get_euler().length() <= deg_to_rad(4.0), "Frenzy rapid fire bounded")
	m.set_paused(true)
	var held: Transform3D = model.transform
	_sim(m, 0.5)
	_check(model.transform == held and held != rest, "pause freezes the hero pose")
	m.set_paused(false)
	m.start_round()
	_sim(m, 9.0)  # Frenzy (8 s) runs out in a round; no snowballs, so nothing fires
	_check(not h._frenzy_ring.visible and model.transform == rest and m.frenzy_state() == "cooldown",
			"after Frenzy: ring off, exact rest (%s)" % model.transform)
	m.free()
	_completed.append("_test_visual")
