extends SceneTree
## P04 tests: match state machine, flow controls, round completion, leaks, cash, lose/win, clean reset.
## Run: godot --headless --path . -s res://tests/test_match.gd   (exit 1 = failure)

const MATCH: String = "res://scenes/main/match.tscn"
const STEP: float = 1.0 / 60.0

var _failures: int = 0


func _check(ok: bool, what: String) -> void:
	if not ok:
		_failures += 1
		printerr("FAIL: " + what)


func _initialize() -> void:
	_run.call_deferred()  # the tree is live only after _initialize


func _new_match() -> Node3D:
	var m: Node3D = load(MATCH).instantiate()
	root.add_child(m)
	m.clock.set_process(false)  # the test drives time explicitly
	return m


## Advances simulated time until `done` is true or `max_s` passes; returns whether `done` became true.
func _sim(m: Node3D, max_s: float, done: Callable = func() -> bool: return false) -> bool:
	for i: int in int(max_s / STEP):
		m.clock.advance(STEP)
		if done.call():
			return true
	return false


func _run() -> void:
	var events_baseline: int = root.get_node("Events").get_signal_connection_list("emitted").size()
	var content: Node = root.get_node("Content")
	var rules: Resource = content.rules
	var m: Node3D = _new_match()
	var S: Dictionary = m.State
	var seen: Array = []
	m.changed.connect(func() -> void: if seen.is_empty() or seen[-1] != m.state: seen.append(m.state))

	# Start state and purchases.
	_check(m.state == S.PREPARE and m.ledger.cash == rules.start_cash and m.lives == rules.start_lives, "fresh match")
	var rookie: Resource = content.get_tower(&"snowball_rookie")
	var tower: Node3D = m.try_place(rookie, Vector2(-5.5, 0))
	_check(tower != null and m.ledger.cash == 450, "placing charges the price once")
	_check(m.try_place(rookie, Vector2(-5.5, 0)) == null and m.ledger.cash == 450, "overlap refused, no charge")
	_check(m.try_place(content.get_tower(&"ski_resort_ticket_booth"), Vector2(-5.5, -3.5)) == null, "unaffordable refused")
	_check(m.ledger.cash == 450, "refusals never change cash")
	m.sell(tower)  # towers attack since P06; this flow test needs an undefended round
	_check(m.ledger.cash == 450 + 140 and m.towers_root.get_child_count() == 0, "sell returns 70%")

	# Round 1: SPAWN -> CLEANUP -> REWARD -> PREPARE (P04-T10).
	_check(m.start_round() and m.state == S.ROUND_SPAWN, "start round 1")
	_check(not m.start_round() and m.round_index == 0, "second start during a round is ignored")
	_sim(m, 3.0)
	var tick: int = m.clock.tick
	var where: Vector3 = m.snowballs[0].position
	m.set_paused(true)
	_sim(m, 5.0)
	_check(m.clock.tick == tick and m.snowballs[0].position == where, "pause freezes simulation")
	_check(not m.start_round(), "cannot start while paused")
	m.set_paused(false)
	_check(_sim(m, 30.0, func() -> bool: return m.state == S.ROUND_CLEANUP), "all spawned -> CLEANUP")
	_check(m.snowballs.size() > 0 and m._spawn_cursor == 20, "CLEANUP while 20 spawned snowballs still roll (P04-T07)")
	_check(_sim(m, 60.0, func() -> bool: return m.state == S.PREPARE), "round ends back in PREPARE")
	_check(seen == [S.PREPARE, S.ROUND_SPAWN, S.ROUND_CLEANUP, S.ROUND_REWARD, S.PREPARE], "state sequence %s" % [seen])
	_check(m.lives == rules.start_lives - 20, "20 Powder leaks cost exactly 20 lives (got %d)" % m.lives)
	_check(m.ledger.cash == 590 + rules.round_bonus_base + 1, "round 1 bonus $101 (got %d)" % m.ledger.cash)
	_check(m.ledger.transactions.all(func(t: Dictionary) -> bool: return t.reason != &"pop"), "leaks never pay pop cash")
	var round_one_end: int = m.clock.tick
	print("round 1 ended at tick %d; ledger: %s" % [round_one_end, m.ledger.transactions])
	m.free()

	# Reset (P04-T09): a new match starts clean and no event subscriptions leak.
	var fresh: Node3D = _new_match()
	_check(fresh.state == S.PREPARE and fresh.ledger.cash == rules.start_cash and fresh.lives == rules.start_lives
			and fresh.clock.tick == 0 and fresh.round_index == -1 and fresh.snowballs.is_empty()
			and fresh.towers_root.get_child_count() == 0 and fresh.ledger.transactions.size() == 1, "fresh state after reset")
	# Determinism: same inputs, same tick count for round 1.
	fresh.start_round()
	_sim(fresh, 90.0, func() -> bool: return fresh.state == S.PREPARE)
	_check(fresh.clock.tick == round_one_end, "deterministic round 1 (%d vs %d)" % [fresh.clock.tick, round_one_end])

	# Lose: no defenders; rounds 1-4 leak 20+35+35+71 > 150 lives.
	while fresh.start_round():
		_sim(fresh, 120.0, func() -> bool: return fresh.state != S.ROUND_SPAWN and fresh.state != S.ROUND_CLEANUP)
	_check(fresh.state == S.LOST and fresh.lives == 0 and fresh.round_index == 3, "lost in round 4")
	_check(not fresh.start_round() and fresh.try_place(rookie, Vector2(-5.5, 0)) == null, "no actions after LOST")
	fresh.free()

	# Win: survive every round (lives raised only for this flow test).
	var winner: Node3D = _new_match()
	winner.lives = 1000000
	while winner.start_round() or winner.acknowledge_intro():
		_sim(winner, 120.0, func() -> bool: return winner.state != S.ROUND_SPAWN and winner.state != S.ROUND_CLEANUP)
	_check(winner.state == S.WON and winner.round_index == content.rounds.size() - 1, "won after the last round")
	var bonus: int = 0
	for i: int in content.rounds.size():
		bonus += rules.round_bonus_base + i + 1
	_check(winner.ledger.cash == rules.start_cash + bonus, "all round bonuses paid once")
	winner.free()

	# Special-snowball introductions (P13-T05, Dev 12): first rounds come from the round data.
	var probe: Node3D = _new_match()
	var first: Dictionary = {}
	for i: int in content.rounds.size():
		probe.round_index = i - 1
		var kind: StringName = probe._unseen_intro(i)
		while kind != &"":
			first[kind] = i + 1
			probe._intros_seen[kind] = true
			kind = probe._unseen_intro(i)
	_check(first == {&"black": 20, &"white": 22, &"camo": 24, &"purple": 25}, "intro rounds from data: %s" % [first])
	probe.free()
	var intro: Node3D = _new_match()
	intro.lives = 1000000
	intro.round_index = 18  # next round is 20 (first Black)
	_check(not intro.start_round() and intro.intro == &"black" and intro.state == S.PREPARE and intro.round_index == 18
			and intro.snowballs.is_empty(), "round 20 opens the Black notice instead of spawning")
	_check(not intro.start_round() and not intro.can_start_round() and intro.round_index == 18,
			"repeated start (Space/Start button) while the notice is open does nothing")
	_sim(intro, 5.0, func() -> bool: return false)
	_check(intro.state == S.PREPARE and intro.snowballs.is_empty(), "no spawn while waiting for acknowledgment")
	var space: InputEventKey = InputEventKey.new()
	space.keycode = KEY_SPACE
	space.pressed = true
	space.echo = true
	intro._unhandled_input(space)
	_check(intro.intro == &"black" and intro.state == S.PREPARE, "held Space (echo) does not acknowledge")
	intro.set_paused(true)
	_check(not intro.acknowledge_intro() and intro.intro == &"black" and intro.state == S.PREPARE,
			"paused: Continue is refused and the notice stays")
	intro.set_paused(false)
	space.echo = false
	intro._unhandled_input(space)
	_check(intro.intro == &"" and intro.state == S.ROUND_SPAWN and intro.round_index == 19, "one Space press acknowledges and starts round 20")
	_sim(intro, 120.0, func() -> bool: return intro.state == S.PREPARE)
	_check(intro.start_round() and intro.round_index == 20, "round 21 (Black again) starts directly: once per match")
	_sim(intro, 120.0, func() -> bool: return intro.state == S.PREPARE)
	_check(not intro.start_round() and intro.intro == &"white", "round 22 opens the White notice")
	intro.free()
	var again: Node3D = _new_match()
	again.round_index = 18
	_check(not again.start_round() and again.intro == &"black", "a new match (restart) shows the notices again")
	again.free()

	_check(root.get_node("Events").get_signal_connection_list("emitted").size() == events_baseline, "no leaked subscriptions")
	print("test_match: %s" % ("PASS" if _failures == 0 else "%d FAILURES" % _failures))
	quit(1 if _failures > 0 else 0)
