extends SceneTree
## P10 hero tests: singleton + price (T01/T11), ricochet (T02), round XP (T03), level application once (T04),
## Snowball Frenzy (T05/T09), Focused Shot (T06), camo at 5 (T07), level fixtures 1/3/4/5/6/7/10/19/20 (T08/T12),
## and the highest level a normal 19-round match reaches (written to docs/logs/evidence/p10_hero_levels.txt).
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
	_check(_completed.size() == 6, "every test function completed (%s)" % [_completed])
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


## XP per round (20r + 20) arrives at each round end; a hero placed before round 1 levels at the right boundary.
## Report: XP and level after every round of the 19-round match -> highest reachable level.
func _test_round_xp() -> void:
	var m: Node3D = _new_match(100000)
	var h: Node3D = m.try_place(content.hero, SPOT)
	m.lives = 1000000  # XP must not depend on the defence holding; leaks are irrelevant here
	var lines: PackedStringArray = ["P10 hero XP in a normal match (hero placed before round 1, BTD6 round XP 20r+20).",
			"round  xp_gained  total_xp  level"]
	var xp: int = 0
	var reached: Dictionary = {}
	while not m.is_over():
		m.start_round()
		while m.state == m.State.ROUND_SPAWN or m.state == m.State.ROUND_CLEANUP:
			m.clock.advance(STEP)
		var r: int = m.round_index + 1
		xp += 20 * r + 20
		_check(h.xp == xp, "round %d: hero XP %d (got %d)" % [r, xp, h.xp])
		reached.get_or_add(h.level, r)
		lines.append("%5d  %9d  %8d  %5d" % [r, 20 * r + 20, h.xp, h.level])
	_check(m.state == m.State.WON, "XP match won")
	_check(reached.get(2) == 3 and reached.get(3) == 7 and reached.get(4) == 12 and reached.get(5) == 18,
			"levels 2/3/4/5 after rounds 3/7/12/18 (got %s)" % [reached])
	_check(h.level == 5, "highest level in a 19-round match = 5 (got %d)" % h.level)
	lines.append("Reached: level 2 after round %d, 3 after %d (Snowball Frenzy), 4 after %d (Focused Shot), 5 after %d (camo)."
			% [reached.get(2), reached.get(3), reached.get(4), reached.get(5)])
	lines.append("Max level in a normal match: %d (%d XP; level 6 needs 6,780). Levels 6-20 are data only (test_hero fixtures)."
			% [h.level, h.xp])
	FileAccess.open("res://docs/logs/evidence/p10_hero_levels.txt", FileAccess.WRITE).store_string("\n".join(lines) + "\n")
	print("\n".join(lines))
	m.free()
	_completed.append("_test_round_xp")
