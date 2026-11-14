extends SceneTree
## Full-match bots (P07-T12, P08-T11, P09-T14). Each bot follows a shopping plan in PREPARE (in order, waiting
## when it cannot afford the next step; a step ending in "*" repeats forever), collects every ticket pickup the
## moment it lands, and plays every round. Checks per round that pop cash equals the round's RBE minus leaked
## RBE, the ledger balances, the Rookie-only and mixed bots WIN, and a mixed rerun gives the identical ledger.
## Solo bots (one tower type each) are reported, not asserted: they show what each tower can do alone.
## Run: godot --headless --path . -s res://tests/test_full_run.gd   (exit 1 = failure)

const MATCH: String = "res://scenes/main/match.tscn"
const STEP: float = 1.0 / 60.0
## Seconds a player spends in PREPARE between rounds (buying, pressing Start); counted in play time only.
const PREPARE_S: float = 5.0
const NAMES: Dictionary = {&"snowball_rookie": "Rookie", &"avalanche_cannon": "Cannon", &"biathlon_ranger": "Ranger",
		&"slope_wax_sprayer": "Wax", &"snow_sorcerer": "Sorcerer", &"ski_resort_ticket_booth": "Booth", &"camel_claus": "Hero"}
## Steps: a tower id (buy one at its best free spot) or [n, path] (upgrade the n-th tower bought by one tier).
## Rookie-heavy with every other type mixed in, few upgrades, the Booth late. Order bought: 0-2 Rookie, 3 Wax, 4 Rookie, 5 Cannon, 6 Rookie,
## 7 Sorcerer, 8 Rookie, 9 Ranger, 10-11 Rookie, 12 Rookie, 13 Rookie, 14 Booth, then Rookies.
const MIXED: Array = [&"snowball_rookie", &"snowball_rookie", &"snowball_rookie", &"slope_wax_sprayer",
		&"snowball_rookie", &"avalanche_cannon", &"snowball_rookie", &"snow_sorcerer", &"snowball_rookie",
		&"biathlon_ranger", &"snowball_rookie", &"snowball_rookie", [5, 0], &"snowball_rookie", [9, 2],
		&"snowball_rookie", [7, 2], &"ski_resort_ticket_booth", &"snowball_rookie*"]
## P10/P12: hero early, one of every tower among Rookies, then tier-3 upgrades across the roster (incl. new tiers),
## Booth mid-game. Bought: 0-1 Rookie, 2 Hero, 3 Rookie, 4 Wax, 5 Cannon, 6 Rookie, 7 Sorcerer, 8 Ranger, 9-10 Rookie,
## 11 Booth, then Rookies.
const HERO_MIXED: Array = [&"snowball_rookie", &"snowball_rookie", &"camel_claus", &"snowball_rookie",
		&"slope_wax_sprayer", &"avalanche_cannon", &"snowball_rookie", &"snow_sorcerer", &"biathlon_ranger",
		&"snowball_rookie", [5, 0], [5, 0], &"snowball_rookie", [7, 0], [7, 0], &"ski_resort_ticket_booth", [8, 2],
		[8, 2], [4, 1], [4, 1], [11, 0], [0, 0], [0, 0], [5, 0], [7, 0], [8, 2], [4, 0], &"snowball_rookie*"]
## Four Rookies, then a Booth as early as cash allows, its production upgrades (2-0-0), then Rookies.
const BOOTH_ECONOMY: Array = [&"snowball_rookie", &"snowball_rookie", &"snowball_rookie", &"snowball_rookie",
		&"ski_resort_ticket_booth", [4, 0], [4, 0], &"snowball_rookie*"]

var _failures: int = 0
var content: Node
var _spot_cache: Dictionary = {}


func _check(ok: bool, what: String) -> void:
	if not ok:
		_failures += 1
		printerr("FAIL: " + what)


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	content = root.get_node("Content")
	var out: PackedStringArray = []
	var rookie: Array = _play([&"snowball_rookie*"], "Rookie-only", out)
	_check(rookie[0] == 5, "Rookie-only bot survives round 25")  # State.WON
	var mixed: Array = _play(MIXED, "Mixed roster", out)
	_check(mixed[0] == 5, "mixed-roster bot survives round 25")
	var hero: Array = _play(HERO_MIXED, "Hero + mixed roster (tier-3 upgrades, Frenzy when ready)", out)
	_check(hero[0] == 5, "hero + mixed-roster bot survives round 25")
	var booth: Array = _play(BOOTH_ECONOMY, "Booth economy (report only)", out)
	# DEC-029: speed only runs the simulation faster. Same plan at 2x / 4x -> identical events, ledger, lives, end tick.
	out.append("== Speed equivalence (DEC-029): [state, lives, ledger, event digest, end tick] vs 1x")
	for run: Array in [[HERO_MIXED, hero, "Hero + mixed"], [[&"snowball_rookie*"], rookie, "Rookie-only"],
			[BOOTH_ECONOMY, booth, "Booth economy"]]:
		for speed: float in ([2.0, 4.0] if run[2] == "Hero + mixed" else [4.0]):
			var again: Array = _play(run[0], "", [], speed)
			_check(again == run[1], "%s at %dx identical to 1x" % [run[2], speed])
			out.append("%s at %dx: %s (end tick %d, %d events digest %d)" % [run[2], speed,
					"IDENTICAL" if again == run[1] else "DIFFERENT", again[4], again[5], again[3]])
	for id: StringName in [&"avalanche_cannon", &"biathlon_ranger", &"snow_sorcerer", &"slope_wax_sprayer"]:
		_play([StringName(String(id) + "*")], "Solo " + NAMES[id], out)
	print("\n".join(out))
	FileAccess.open("res://docs/logs/evidence/p12_full_run_25.txt", FileAccess.WRITE).store_string("\n".join(out) + "\n")
	print("test_full_run: %s" % ("PASS" if _failures == 0 else "%d FAILURES" % _failures))
	quit(1 if _failures > 0 else 0)


## Valid spots for `def`, best first: most track (0.25 m samples) inside range; the Booth wants the least
## track nearby (out of the way); global towers use a 6 m radius as "close to the action". Ties by position.
func _spots(m: Node3D, def: Resource) -> Array[Vector2]:
	if _spot_cache.has(def.id):
		return _spot_cache[def.id].duplicate()
	var range_m: float = 6.0 if def.global_range else def.range_units * 0.1 + m.HIT_RADIUS_M
	var samples: Array[Vector2] = []
	for i: int in int(m.course.length() / 0.25):
		var p: Vector3 = m.course.position_at(i * 0.25)
		samples.append(Vector2(p.x, p.z))
	var scored: Array = []
	var b: Rect2 = m.course.bounds
	for x: int in range(int(b.position.x * 2), int(b.end.x * 2)):
		for z: int in range(int(b.position.y * 2), int(b.end.y * 2)):
			var p: Vector2 = Vector2(x, z) * 0.5
			if m.course.check_placement(p, def.footprint_units * 0.1, Array([], TYPE_VECTOR3, &"", null)) != "":
				continue
			var cover: int = 0  # upstream track counts double at the entry, fading to 1x at the finish
			for k: int in samples.size():
				if samples[k].distance_to(p) <= range_m:
					cover += 200 - 100 * k / samples.size()
			scored.append([-cover if def.attacks.is_empty() else cover, p])
	scored.sort_custom(func(a: Array, c: Array) -> bool: return a[0] > c[0] or (a[0] == c[0] and (a[1].x < c[1].x
			or (a[1].x == c[1].x and a[1].y < c[1].y))))
	var out: Array[Vector2] = []
	for s: Array in scored:
		out.append(s[1])
	_spot_cache[def.id] = out
	return out.duplicate()


## Executes plan steps while affordable. Returns false when waiting for cash (or out of spots).
func _shop(m: Node3D, plan: Array, cursor: Array[int], bought: Array[Node3D], spots: Dictionary) -> void:
	while cursor[0] < plan.size():
		var step: Variant = plan[cursor[0]]
		var repeat: bool = step is StringName and String(step).ends_with("*")
		if step is Array:
			var tower: Node3D = bought[step[0]] if step[0] < bought.size() else null
			if tower == null or m.upgrade_state(tower, step[1]) in ["max", "soon", "locked"]:
				cursor[0] += 1  # impossible step: skip rather than stall
				continue
			if not m.buy_upgrade(tower, step[1]):
				return
		else:
			var id: StringName = StringName(String(step).trim_suffix("*"))
			var def: Resource = content.hero if id == content.hero.id else content.get_tower(id)
			if m.ledger.cash < def.price:
				return
			var free: Array = spots.get_or_add(def.id, _spots(m, def))
			var placed: Node3D = null
			while placed == null and not free.is_empty():
				placed = m.try_place(def, free.pop_front())
			if placed == null:
				cursor[0] += 1
				continue
			bought.append(placed)
		if not repeat:
			cursor[0] += 1


## Plays one match with `plan` at clock `speed`. The bot acts inside the clock's tick signal, right after the
## match's own tick, so every purchase, pickup, Frenzy and round start lands on the same simulation tick at 1x, 2x
## and 4x (a player's input is also handled between ticks). Appends a report to `out` when `title` is set.
## Returns [state, lives, ledger, event digest, end tick, event count, play seconds].
func _play(plan: Array, title: String, out: PackedStringArray, speed: float = 1.0) -> Array:
	var m: Node3D = load(MATCH).instantiate()
	root.add_child(m)
	m.clock.set_process(false)
	m.clock.speed = speed
	var pops: Dictionary = {}  # tower entity id -> layers broken
	var immune: Dictionary = {}  # damage type -> blocked hits
	var leaks: Dictionary = {}  # leaked snowball type -> lives lost
	var b: Dictionary = {"frenzies": 0, "digest": 0, "events": 0, "lives": 0, "tx": 0, "tick": 0, "play_s": 0.0,
			"end_tick": 0, "worst": [0, 0]}
	var on_event: Callable = func(e: RefCounted) -> void:
		b.digest = hash([b.digest, e.type, e.tick, e.source_id, e.target_id, e.magnitude, e.tags])
		b.events += 1
		if e.type == &"layer_broken":
			pops[e.source_id] = pops.get(e.source_id, 0) + 1
		elif e.type == &"ability_used" and "snowball_frenzy" in e.tags:
			b.frenzies += 1
		elif e.type == &"enemy_immune":
			immune[e.tags[0]] = immune.get(e.tags[0], 0) + 1
		elif e.type == &"enemy_leaked":
			leaks[e.tags[0]] = leaks.get(e.tags[0], 0) + int(e.magnitude)
	root.get_node("Events").emitted.connect(on_event)
	var cursor: Array[int] = [0]
	var bought: Array[Node3D] = []
	var spots: Dictionary = {}
	var lines: PackedStringArray = ["== %s" % title, "round  sim_s  RBE  leaked  pop$  ticket$  cash  lives  towers"]
	var report: Callable = func() -> void:  # the round that just ended
		var i: int = m.round_index
		var pop: int = 0
		var tickets: int = 0
		for t: Dictionary in m.ledger.transactions.slice(b.tx):
			if t.reason == &"pop":
				pop += t.amount
			elif t.reason == &"ticket_income":
				tickets += t.amount
		var leaked: int = b.lives - m.lives
		if leaked > b.worst[1]:
			b.worst = [i + 1, leaked]
		b.play_s += (m.clock.tick - b.tick) * STEP + PREPARE_S
		if m.state != m.State.LOST:
			_check(pop == content.round_rbe(i) - leaked, "%s round %d: pop $%d == RBE %d - leaked %d"
					% [title, i + 1, pop, content.round_rbe(i), leaked])
		lines.append("%5d  %5.1f  %3d  %6d  %4d  %7d  %4d  %5d  %6d" % [i + 1, (m.clock.tick - b.tick) * STEP,
				content.round_rbe(i), leaked, pop, tickets, m.ledger.cash, m.lives, m.towers_root.get_child_count()])
	var on_tick: Callable = func(_dt: float) -> void:
		if m.is_over():
			if b.end_tick == 0:
				b.end_tick = m.clock.tick
				report.call()
			return
		for p: Variant in m.pickups.duplicate():
			m.collect(p)
		m.use_frenzy()  # no-op unless the hero is level 3+ and it is ready
		if m.state != m.State.PREPARE:
			return
		if m.round_index >= 0:
			report.call()
		for t: Node3D in m.towers_root.get_children():
			m.collect_bank(t)
		_shop(m, plan, cursor, bought, spots)
		b.lives = m.lives
		b.tx = m.ledger.transactions.size()
		b.tick = m.clock.tick
		_check(m.start_round(), "%s: round %d starts" % [title, m.round_index + 2])
	m.clock.ticked.connect(on_tick)
	while b.end_tick == 0:
		m.clock.advance(STEP)
	var play_s: float = b.play_s
	var balance: int = 0
	for t: Dictionary in m.ledger.transactions:
		balance += t.amount
		_check(t.balance == balance and balance >= 0, "%s: ledger running balance at tick %d" % [title, t.tick])
	_check(balance == m.ledger.cash, "%s: ledger sums to cash" % title)
	_check(not m.start_round(), "%s: frozen after end" % title)
	var sim_s: float = play_s - PREPARE_S * (m.round_index + 1)
	lines.append("result %s at round %d, %d lives, play time %.1f min at 1x, %.1f min at 4x (sim + %ds prepare per round)"
			% [m.State.keys()[m.state], m.round_index + 1, m.lives, play_s / 60.0,
			(sim_s / 4.0 + PREPARE_S * (m.round_index + 1)) / 60.0, PREPARE_S])
	lines.append("most lives leaked: %s; leaked by type %s; immune hits by damage type %s"
			% ["none" if b.worst[1] == 0 else "round %d (%d)" % b.worst, leaks, immune])
	if m.hero_node():
		lines.append("hero level %d, %d XP; Frenzy used %d times" % [m.hero_node().level, m.hero_node().xp, b.frenzies])
	# Per tower type: count, invested, layers popped (pop $), pops per $100 invested, booth income.
	var by_type: Dictionary = {}
	for tower: Node3D in m.towers_root.get_children():
		var row: Array = by_type.get_or_add(tower.def.id, [0, 0, 0, 0])
		row[0] += 1
		row[1] += tower.spent
		row[2] += pops.get(tower.entity_id, 0)
	for t: Dictionary in m.ledger.transactions:
		if t.reason == &"ticket_income":
			by_type[&"ski_resort_ticket_booth"][3] += t.amount
	lines.append("type      count  invested  pops  pops/$100  tickets$   (tiers)")
	for id: StringName in by_type:
		var row: Array = by_type[id]
		var tiers: PackedStringArray = []
		for tower: Node3D in m.towers_root.get_children():
			if tower.def.id == id and tower.tiers != Vector3i.ZERO:
				tiers.append("%d-%d-%d" % [tower.tiers.x, tower.tiers.y, tower.tiers.z])
		lines.append("%-9s %5d  %8d  %4d  %9.1f  %8d   %s" % [NAMES[id], row[0], row[1], row[2],
				100.0 * row[2] / maxi(row[1], 1), row[3], " ".join(tiers)])
	if title != "":
		out.append_array(lines)
	root.get_node("Events").emitted.disconnect(on_event)
	var result: Array = [m.state, m.lives, str(m.ledger.transactions), b.digest, b.end_tick, b.events, play_s]
	m.free()
	return result
