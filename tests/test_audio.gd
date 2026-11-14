extends SceneTree
## P18: Audio router maps each gameplay event to its SFX slot on the SFX bus, varies variants/pitch, rate-limits pop
## storms, plays the Cannon's blast on its own hits, clicks every Button, and has every music slot on disk.
## Run: godot --headless --path . -s res://tests/test_audio.gd   (exit 1 = failure)

var _failures: int = 0
var audio: Node


func _check(ok: bool, what: String) -> void:
	if not ok:
		_failures += 1
		printerr("FAIL: " + what)


func _initialize() -> void:
	_run.call_deferred()


func _playing(slot: StringName) -> bool:
	return audio._players[slot].any(func(p: AudioStreamPlayer) -> bool: return p.playing)


func _run() -> void:
	audio = root.get_node("Audio")
	var events: Node = root.get_node("Events")
	for slot: StringName in audio.SFX:
		_check(not audio._players[slot].is_empty(), "%s has a file" % slot)
		for p: AudioStreamPlayer in audio._players[slot]:
			_check(p.stream != null and p.bus == &"SFX", "%s loaded on SFX bus" % slot)
	_check(audio._players[&"crunch"].size() == 12, "12 snow-crunch variants")
	for slot: StringName in audio.MUSIC_LOOPS:
		_check(ResourceLoader.exists(audio.MUSIC_DIR + slot + ".ogg"), "music %s on disk" % slot)
	var cases: Array = [
		[&"layer_broken", ["camo_mint", "blue"], &"crunch"], [&"layer_broken", ["black", "coral"], &"crunch_heavy"],
		[&"enemy_immune", ["explosion"], &"immune"], [&"enemy_leaked", ["coral"], &"leak"],
		[&"tower_placed", ["snowball_rookie"], &"place"], [&"tower_placed", ["camel_claus"], &"place_hero"],
		[&"tower_upgraded", ["x"], &"upgrade"], [&"tower_sold", [], &"sell"], [&"purchase_failed", ["x"], &"deny"],
		[&"attack_fired", ["avalanche_cannon_base"], &"cannon_fire"], [&"attack_fired", ["biathlon_ranger_m1"], &"ranger"],
		[&"attack_fired", ["snow_sorcerer_base"], &"chime"], [&"attack_fired", ["snow_sorcerer_fireball"], &"fireball"],
		[&"attack_fired", ["camel_claus_base"], &"hero_shot"], [&"attack_fired", ["snowball_rookie_base"], &"throw"],
		[&"status_applied", ["slope_wax_sprayer_base"], &"wax"], [&"income_collected", [], &"ticket"],
		[&"income_banked", [], &"ticket_bank"], [&"pickup_spawned", [], &"ticket_spawn"],
		[&"ability_ready", ["snowball_frenzy"], &"ability_ready"], [&"ability_used", ["snowball_frenzy"], &"frenzy"],
		[&"hero_level_up", [], &"level_up"], [&"round_started", [], &"round_start"],
		[&"round_complete", ["1"], &"round_complete"]]
	for c: Array in cases:
		events.send(c[0], 0, 0, 1.0, Vector3.ZERO, PackedStringArray(c[1]))
		_check(_playing(c[2]), "%s %s -> %s" % [c[0], c[1], c[2]])
	events.send(&"ability_used", 0, 0, 0.0, Vector3.ZERO, PackedStringArray(["focused_shot"]))
	_check(_playing(&"focus_off"), "Focused Shot off -> focus_off")
	# Cannon blast: only hits whose source is a placed Cannon.
	events.send(&"enemy_hit", 41, 0, 1.0, Vector3.ZERO, PackedStringArray(["powder"]))
	_check(not _playing(&"cannon_boom"), "a non-Cannon hit plays no blast")
	events.send(&"tower_placed", 42, 0, 375.0, Vector3.ZERO, PackedStringArray(["avalanche_cannon"]))
	events.send(&"enemy_hit", 42, 0, 1.0, Vector3.ZERO, PackedStringArray(["powder"]))
	_check(_playing(&"cannon_boom"), "a Cannon hit plays its blast")
	# Layer pitch: Powder plays brighter than Coral.
	audio._last_start.erase(&"crunch")
	audio.play(&"crunch", audio.LAYER_PITCH["powder"])
	var powder: float = audio._players[&"crunch"][audio._last_variant[&"crunch"]].pitch_scale
	audio._last_start.erase(&"crunch")
	audio.play(&"crunch", audio.LAYER_PITCH["coral"])
	var coral: float = audio._players[&"crunch"][audio._last_variant[&"crunch"]].pitch_scale
	_check(powder > coral, "Powder crunch pitched above Coral (%.2f > %.2f)" % [powder, coral])
	_check(audio._last_variant[&"crunch"] != -1, "variant tracked")
	var first: int = audio._last_start[&"crunch"]
	await create_timer(0.01).timeout
	events.send(&"layer_broken", 0, 0, 1.0, Vector3.ZERO, PackedStringArray(["powder", "blue"]))
	_check(audio._last_start[&"crunch"] == first, "crunch inside its min gap is merged")
	var button: Button = Button.new()
	root.add_child(button)
	await create_timer(0.05).timeout
	button.pressed.emit()
	_check(_playing(&"click"), "any Button plays the UI click")
	print("test_audio: %s" % ("PASS" if _failures == 0 else "%d FAILURES" % _failures))
	quit(1 if _failures > 0 else 0)
