extends Node
## Presentation stress scene (P15-A04 follow-up, Dev 9): the real match with ~120 moving, immune Coral snowballs kept
## topped up and a tower mix firing at them; prints frame-time / draw-call stats as STRESS lines.
##   Desktop: godot --path . res://tests/tools/stress.tscn -- cannon|roster|full [greybox]
##   Browser: export preset "Web Stress" (build/web_stress), open stress_cannon.html / stress_roster.html (COMMANDS.md)
## Mixes: cannon = 8 Cannons + 4 Rookies (the Dev 8 desktop mix); roster = 3 each of Rookie/Cannon/Ranger/Wax;
## full = 2 each of all six towers (Dev 10, Booths drop tickets that stay uncollected).
## Presentation measurement only: never used by the regression suites.

const MATCH: PackedScene = preload("res://scenes/main/match.tscn")
const ALL_IMMUNE: Array[StringName] = [&"immune_corrosive", &"immune_energy", &"immune_explosion", &"immune_glue",
		&"immune_normal", &"immune_plasma", &"immune_sharp", &"immune_shatter", &"immune_cold"]
const SNOWBALLS: int = 120
const WARMUP_FRAMES: int = 120
const FRAMES: int = 900

var m: Node3D
var _label: Label


func _ready() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var mix: String = "full" if args.has("full") else "roster" if args.has("roster") else "cannon"
	if not OS.has_feature("web"):
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)  # browsers always pace to the display
	m = MATCH.instantiate()
	add_child(m)
	_label = Label.new()
	_label.position = Vector2(8, 120)
	_label.add_theme_color_override(&"font_color", Color.BLACK)
	add_child(_label)
	_run(mix, args.has("greybox"))


func _say(line: String) -> void:
	print("STRESS " + line)
	_label.text += line + "\n"


func _run(mix: String, greybox: bool) -> void:
	for i: int in 5:
		await get_tree().process_frame
	m.ledger.cash = 100000
	m.lives = 1000000
	var ids: Array[StringName] = []
	for i: int in 12:
		if mix == "full":
			ids.append([&"snowball_rookie", &"avalanche_cannon", &"biathlon_ranger", &"slope_wax_sprayer",
					&"snow_sorcerer", &"ski_resort_ticket_booth"][i % 6])
		elif mix == "roster":
			ids.append([&"snowball_rookie", &"avalanche_cannon", &"biathlon_ranger", &"slope_wax_sprayer"][i % 4])
		else:
			ids.append(&"avalanche_cannon" if i % 3 != 2 else &"snowball_rookie")
	var placed: int = 0
	var d: float = 6.0
	while placed < ids.size() and d < m.course.length() - 4.0:
		for side: float in [-1.0, 1.0]:
			if placed < ids.size():
				var def: Resource = Content.get_tower(ids[placed])
				var spot: Vector2 = _nearest_legal(def, d, side)
				if spot != Vector2.INF and m.try_place(def, spot):
					placed += 1
		d += 5.0
	if greybox:
		for t: Node3D in m.towers_root.get_children():
			if t.def.id != &"snowball_rookie":
				t._set_model(null)
	var counts: Dictionary = {}
	for t: Node3D in m.towers_root.get_children():
		counts[t.def.id] = counts.get(t.def.id, 0) + 1
	m.start_round()
	_top_up(true)
	for i: int in WARMUP_FRAMES:  # shader compile, first shots
		await get_tree().process_frame
	var times: Array[float] = []
	var draws: Array[int] = []
	var prims: Array[int] = []
	var snow_min: int = 1000
	var shots: int = 0
	var last: int = Time.get_ticks_usec()
	for i: int in FRAMES:
		await get_tree().process_frame
		_top_up(false)
		var now: int = Time.get_ticks_usec()
		times.append((now - last) / 1000.0)
		last = now
		draws.append(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME))
		prims.append(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME))
		snow_min = mini(snow_min, m.snowballs.size())
		shots = maxi(shots, m.shots.size())
	var mean: float = times.reduce(func(a: float, b: float) -> float: return a + b, 0.0) / times.size()
	times.sort()
	draws.sort()
	prims.sort()
	var slow: int = times.filter(func(t: float) -> bool: return t > 1.5 * times[times.size() / 2]).size()
	_say("mix %s%s on %s: %s, snowballs >= %d (immune Coral, moving), max live shots %d" % [mix,
			" (GREYBOX non-Rookie towers)" if greybox else "", OS.get_name(), counts, snow_min, shots])
	_say("viewport %s, vsync %s, %d frames: frame ms mean %.2f p50 %.2f p95 %.2f p99 %.2f max %.2f; frames > 1.5x p50: %d" % [
			get_viewport().get_visible_rect().size, DisplayServer.window_get_vsync_mode() != 0, times.size(), mean, times[times.size() / 2],
			times[int(times.size() * 0.95)], times[int(times.size() * 0.99)], times[-1], slow])
	_say("draw calls p50 %d max %d; primitives p50 %d max %d; video mem %.1f MB; adapter %s / %s; renderer %s" % [
			draws[draws.size() / 2], draws[-1], prims[prims.size() / 2], prims[-1],
			RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_VIDEO_MEM_USED) / 1048576.0,
			RenderingServer.get_video_adapter_vendor(), RenderingServer.get_video_adapter_name(),
			ProjectSettings.get_setting("rendering/renderer/rendering_method")])
	_say("DONE")
	if not OS.has_feature("web"):
		get_tree().quit()


func _nearest_legal(def: Resource, d: float, side: float) -> Vector2:
	var p: Vector3 = m.course.position_at(d)
	var t: Vector3 = (m.course.position_at(d + 0.2) - m.course.position_at(d - 0.2)).normalized()
	var n: Vector3 = Vector3(-t.z, 0.0, t.x)
	for i: int in 300:
		var w: Vector3 = p + n * side * (1.0 + i * 0.01)
		if m.placement_reason(def, Vector2(w.x, w.z)) == "":
			return Vector2(w.x, w.z)
	return Vector2.INF


func _top_up(spread: bool) -> void:
	var length: float = m.course.length()
	while m.snowballs.size() < SNOWBALLS:
		m._spawn(&"coral")
		var s: Node3D = m.snowballs[-1]
		var def: Resource = Content.enemies[&"coral"].duplicate()
		def.properties = ALL_IMMUNE.duplicate()
		s.set_layer(def)
		if spread:
			s.distance = length * (m.snowballs.size() - 1) / float(SNOWBALLS)
			s.position = m.course.position_at(s.distance)
