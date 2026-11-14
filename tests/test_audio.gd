extends SceneTree
## P18: Audio router maps each gameplay event to its SFX on the SFX bus, rate-limits pop storms, clicks every Button.
## Run: godot --headless --path . -s res://tests/test_audio.gd   (exit 1 = failure)

var _failures: int = 0


func _check(ok: bool, what: String) -> void:
	if not ok:
		_failures += 1
		printerr("FAIL: " + what)


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var audio: Node = root.get_node("Audio")
	var events: Node = root.get_node("Events")
	for sfx_name: StringName in audio.SFX:
		var p: AudioStreamPlayer = audio._players[sfx_name]
		_check(p.stream != null and p.bus == &"SFX", "%s loaded on SFX bus" % sfx_name)
	_check(AudioServer.get_bus_index(&"SFX") >= 0 and AudioServer.get_bus_index(&"Music") >= 0, "buses exist")
	var cases: Array = [
		[&"layer_broken", ["powder", "blue"], &"pop_1"], [&"layer_broken", ["camo_mint", "blue"], &"pop_3"],
		[&"layer_broken", ["black", "coral"], &"pop_heavy"], [&"enemy_immune", ["explosion"], &"immune"],
		[&"enemy_leaked", ["coral"], &"leak"], [&"tower_placed", ["snowball_rookie"], &"place"],
		[&"tower_upgraded", ["x"], &"upgrade"], [&"tower_sold", [], &"sell"], [&"purchase_failed", ["x"], &"deny"],
		[&"attack_fired", ["avalanche_cannon_base"], &"cannon"], [&"attack_fired", ["biathlon_ranger_m1"], &"ranger"],
		[&"attack_fired", ["snow_sorcerer_base"], &"chime"], [&"attack_fired", ["camel_claus_base"], &"hero_shot"],
		[&"attack_fired", ["snowball_rookie_base"], &"throw"], [&"status_applied", ["slope_wax_sprayer_base"], &"wax"],
		[&"income_collected", [], &"ticket"], [&"ability_used", ["snowball_frenzy"], &"frenzy"],
		[&"ability_used", ["focused_shot"], &"focus"], [&"hero_level_up", [], &"level_up"],
		[&"round_started", [], &"round_start"], [&"round_complete", ["1"], &"round_complete"]]
	for c: Array in cases:
		events.send(c[0], 0, 0, 1.0, Vector3.ZERO, PackedStringArray(c[1]))
		_check(audio._players[c[2]].playing, "%s %s -> %s" % [c[0], c[1], c[2]])
	var first: int = audio._last_start[&"pop_1"]
	await create_timer(0.01).timeout
	events.send(&"layer_broken", 0, 0, 1.0, Vector3.ZERO, PackedStringArray(["powder", "blue"]))
	_check(audio._last_start[&"pop_1"] == first, "pop inside its min gap is merged")
	var button: Button = Button.new()
	root.add_child(button)
	await create_timer(0.05).timeout
	button.pressed.emit()
	_check(audio._players[&"click"].playing, "any Button plays the UI click")
	print("test_audio: %s" % ("PASS" if _failures == 0 else "%d FAILURES" % _failures))
	quit(1 if _failures > 0 else 0)
