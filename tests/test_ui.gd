extends SceneTree
## P13 essentials: title screen panels, volume sliders drive the Music/SFX buses (0 = mute), shop tooltips with
## cost/role, readable disabled reasons on shop / upgrade / start buttons, hero panel states.
## Run: godot --headless --path . -s res://tests/test_ui.gd   (exit 1 = failure)

const TITLE: String = "res://scenes/ui/title_screen.tscn"
const MATCH: String = "res://scenes/main/match.tscn"

var _failures: int = 0
var content: Node


func _check(ok: bool, what: String) -> void:
	if not ok:
		_failures += 1
		printerr("FAIL: " + what)


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	content = root.get_node("Content")
	_test_title()
	await _test_hud()
	print("test_ui: %s" % ("PASS" if _failures == 0 else "%d FAILURES" % _failures))
	quit(1 if _failures > 0 else 0)


func _test_title() -> void:
	var t: Control = load(TITLE).instantiate()
	root.add_child(t)
	_check(t.get_node("%Menu").visible and not t.get_node("%HowPanel").visible, "title opens on the menu")
	t.get_node("%HowButton").pressed.emit()
	_check(t.get_node("%HowPanel").visible and not t.get_node("%Menu").visible, "How to Play shows")
	var how: String = t.get_node("%HowPanel/Box/HowText").text
	_check("25 rounds" in how, "How to Play explains winning")
	_check(["B = Black", "W = White", "A = Aurora", "C = Camo", "1x / 2x / 4x"].all(func(s: String) -> bool: return s in how),
			"How to Play: special-type legend and speeds (P13-T05)")
	t.get_node("%HowBack").pressed.emit()
	t.get_node("%SettingsButton").pressed.emit()
	_check(t.get_node("%SettingsPanel").visible, "Settings shows")
	var music: int = AudioServer.get_bus_index("Music")
	var sfx: int = AudioServer.get_bus_index("SFX")
	_check(music > 0 and sfx > 0, "Music and SFX buses exist")
	t.get_node("%MusicSlider").value = 0.5
	_check(absf(AudioServer.get_bus_volume_db(music) - linear_to_db(0.5)) < 0.01 and not AudioServer.is_bus_mute(music),
			"music slider 0.5 -> %.1f dB" % linear_to_db(0.5))
	t.get_node("%SfxSlider").value = 0.0
	_check(AudioServer.is_bus_mute(sfx), "sfx slider 0 mutes the bus")
	var towers: int = AudioServer.get_bus_index("Towers")
	t.get_node("%TowerSlider").value = 0.5
	_check(absf(AudioServer.get_bus_volume_db(towers)) < 0.01, "tower slider default 0.5 -> 0 dB (P18)")
	t.get_node("%TowerSlider").value = 1.0
	_check(absf(AudioServer.get_bus_volume_db(towers) - linear_to_db(2.0)) < 0.01, "tower slider 1.0 -> +6 dB")
	t.get_node("%TowerSlider").value = 0.5
	_check(AudioServer.get_bus_index("Ambience") > 0, "Ambience bus exists")
	t.get_node("%MusicSlider").value = 1.0  # leave the saved settings at their defaults
	t.get_node("%SfxSlider").value = 1.0
	_check(not AudioServer.is_bus_mute(sfx) and is_zero_approx(AudioServer.get_bus_volume_db(music)), "back to 0 dB")
	t.free()


func _test_hud() -> void:
	var m: Node3D = load(MATCH).instantiate()
	root.add_child(m)
	m.clock.set_process(false)
	await process_frame  # the HUD builds its buttons after the match is ready
	var hud: CanvasLayer = m.get_node("HUD")
	var booth: Button = hud._shop_buttons[5]
	_check(booth.disabled and "need $600" in booth.text, "Booth shop button says how much is missing (%s)" % booth.text)
	_check("$1250" in booth.tooltip_text and "Income" in booth.tooltip_text, "Booth tooltip: cost + role")
	_check("Range 32" in hud._shop_buttons[0].tooltip_text, "Rookie tooltip shows its stats")
	_check(hud._start.text == "Start round 1 (Space)" and not hud._start.disabled, "start button ready")
	var rookie: Node3D = m.try_place(content.get_tower(&"snowball_rookie"), Vector2(-7.2, 0))
	m.ledger.credit(0, 2000, &"test", 0)
	for i: int in 2:
		m.buy_upgrade(rookie, 0)
	m.ledger.spend(0, m.ledger.cash - 10, &"test", 0)
	m.select(rookie)
	_check("need $" in hud._upgrade_buttons[0].text and hud._upgrade_buttons[0].disabled, "unaffordable upgrade: %s" % hud._upgrade_buttons[0].text)
	m.ledger.credit(0, 5000, &"test", 0)
	m.buy_upgrade(rookie, 0)
	m.buy_upgrade(rookie, 1)
	m.buy_upgrade(rookie, 1)
	m.select(rookie)
	_check("locked: only two paths" in hud._upgrade_buttons[2].text, "third path locked reason: %s" % hud._upgrade_buttons[2].text)
	_check("locked: only one path past tier 2" in hud._upgrade_buttons[1].text, "second path tier-3 lock reason: %s" % hud._upgrade_buttons[1].text)
	_check(hud._upgrade_buttons[0].tooltip_text != "", "upgrade tooltip describes the effect")
	var hero: Node3D = m.try_place(content.hero, Vector2(0.5, 0))
	_check(hero != null and hud._shop_buttons[6].disabled and "on the course" in hud._shop_buttons[6].text, "hero shop button: on the course")
	_check(hud._hero_panel.visible and "unlocks at level 3" in hud._frenzy.text and hud._frenzy.disabled, "hero panel: Frenzy locked reason")
	m.set_hero_level(3)
	hud._refresh_hero()
	_check(not hud._frenzy.disabled and "READY" in hud._frenzy.text, "hero panel: Frenzy ready")
	m.start_round()
	_check(hud._start.disabled and hud._start.text == "Round in progress", "start button explains why it is disabled")
	# P13-T06 placeholder feedback: banner, immune text, leak text, income text (presentation only).
	var fb: Control = hud.feedback
	_check(fb._banner.text == "Round 1" and fb._banner.modulate.a > 0.0, "banner: Round 1 (%s)" % fb._banner.text)
	m._spawn(&"black")
	var black: Node3D = m.snowballs[-1]
	black.position = m.course.position_at(20.0)
	m.damage_snowball(black, 1, &"explosion", 0)
	m._leak(black)
	root.get_node("Events").send(&"income_collected", 0, 0, 50, m.course.position_at(10.0))
	var texts: Array = fb.get_children().map(func(c: Node) -> String: return c.text)
	_check("IMMUNE" in texts and "-11 lives" in texts and "+$50" in texts, "floating feedback texts %s" % [texts])
	m.free()
