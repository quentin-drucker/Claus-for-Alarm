extends SceneTree
## P07 vertical slice: a greedy Rookie-only bot plays every round (P07-T12). Checks per round that pop cash
## equals the round's RBE minus leaked RBE (P07-T09), the ledger balances, the match ends in WON, and a rerun
## gives the identical ledger. Prints the per-round report and total simulated play time (D-03 length target).
## Run: godot --headless --path . -s res://tests/test_full_run.gd   (exit 1 = failure)

const MATCH: String = "res://scenes/main/match.tscn"
const STEP: float = 1.0 / 60.0
## Seconds a player spends in PREPARE between rounds (buying, pressing Start); counted in play time only.
const PREPARE_S: float = 5.0

var _failures: int = 0


func _check(ok: bool, what: String) -> void:
	if not ok:
		_failures += 1
		printerr("FAIL: " + what)


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var first: Array = _play(true)
	var second: Array = _play(false)
	_check(first == second, "rerun gives the identical ledger and result")
	print("test_full_run: %s" % ("PASS" if _failures == 0 else "%d FAILURES" % _failures))
	quit(1 if _failures > 0 else 0)


## Valid Rookie spots, best first: most track length (0.25 m samples) inside range, ties by position.
func _spots(m: Node3D, rookie: Resource) -> Array[Vector2]:
	var range_m: float = rookie.range_units * 0.1 + m.HIT_RADIUS_M
	var samples: Array[Vector3] = []
	for i: int in int(m.course.length() / 0.25):
		samples.append(m.course.position_at(i * 0.25))
	var scored: Array = []
	var b: Rect2 = m.course.bounds
	for x: int in range(int(b.position.x * 2), int(b.end.x * 2)):
		for z: int in range(int(b.position.y * 2), int(b.end.y * 2)):
			var p: Vector2 = Vector2(x, z) * 0.5
			if m.course.check_placement(p, rookie.footprint_units * 0.1, Array([], TYPE_VECTOR3, &"", null)) != "":
				continue
			var cover: int = samples.filter(func(s: Vector3) -> bool: return Vector2(s.x, s.z).distance_to(p) <= range_m).size()
			scored.append([cover, p])
	scored.sort_custom(func(a: Array, c: Array) -> bool: return a[0] > c[0] or (a[0] == c[0] and (a[1].x < c[1].x
			or (a[1].x == c[1].x and a[1].y < c[1].y))))
	var out: Array[Vector2] = []
	for s: Array in scored:
		out.append(s[1])
	return out


func _play(report: bool) -> Array:
	var content: Node = root.get_node("Content")
	var rookie: Resource = content.get_tower(&"snowball_rookie")
	var m: Node3D = load(MATCH).instantiate()
	root.add_child(m)
	m.clock.set_process(false)
	var spots: Array[Vector2] = _spots(m, rookie)
	var play_s: float = 0.0
	var lines: PackedStringArray = ["round  sim_s  RBE  leaked  pop$  bonus$  cash  lives  towers"]
	while not m.is_over():
		while m.ledger.cash >= rookie.price and not spots.is_empty():  # buy in PREPARE, best spot first
			if m.try_place(rookie, spots.pop_front()) == null:
				continue
		var lives_before: int = m.lives
		var tx_before: int = m.ledger.transactions.size()
		var tick_before: int = m.clock.tick
		_check(m.start_round(), "round %d starts" % (m.round_index + 2))
		while m.state == m.State.ROUND_SPAWN or m.state == m.State.ROUND_CLEANUP:
			m.clock.advance(STEP)
		var i: int = m.round_index
		var pop: int = 0
		var bonus: int = 0
		for t: Dictionary in m.ledger.transactions.slice(tx_before):
			if t.reason == &"pop":
				pop += t.amount
			elif t.reason == &"round_bonus":
				bonus += t.amount
		var leaked: int = lives_before - m.lives
		var sim_s: float = (m.clock.tick - tick_before) * STEP
		play_s += sim_s + PREPARE_S
		if not m.is_over() or m.state == m.State.WON:
			_check(pop == content.round_rbe(i) - leaked, "round %d: pop $%d == RBE %d - leaked %d"
					% [i + 1, pop, content.round_rbe(i), leaked])
		lines.append("%5d  %5.1f  %3d  %6d  %4d  %6d  %4d  %5d  %6d" % [i + 1, sim_s, content.round_rbe(i), leaked,
				pop, bonus, m.ledger.cash, m.lives, m.towers_root.get_child_count()])
	var balance: int = 0
	for t: Dictionary in m.ledger.transactions:
		balance += t.amount
		_check(t.balance == balance and balance >= 0, "ledger running balance at tick %d" % t.tick)
	_check(balance == m.ledger.cash, "ledger sums to cash")
	_check(m.state == m.State.WON, "Rookie-only bot survives the finale (state %s, round %d)"
			% [m.State.keys()[m.state], m.round_index + 1])
	_check(not m.start_round() and m.try_place(rookie, spots[0] if spots else Vector2.ZERO) == null, "frozen after end")
	lines.append("result %s, play time %.1f min (sim + %ds prepare per round), %d towers"
			% [m.State.keys()[m.state], play_s / 60.0, PREPARE_S, m.towers_root.get_child_count()])
	if report:
		print("\n".join(lines))
		FileAccess.open("res://docs/logs/evidence/p07_full_run.txt", FileAccess.WRITE).store_string("\n".join(lines) + "\n")
	var result: Array = [m.state, m.lives, str(m.ledger.transactions)]
	m.free()
	return result
