extends SceneTree
## P15-A04 review captures + measurements for the Avalanche Cannon art binding (needs a window, not --headless).
##   godot --path . -s res://tests/tools/cannon_review.gd -- review           # screenshots, ghost/select/upgrade/sell,
##                                                                            # pause + 1x/2x/4x, track clearance
##   godot --path . -s res://tests/tools/cannon_review.gd -- stress [greybox] # 120-snowball load, 8 Cannons + 4 Rookies
## Writes docs/logs/evidence/p15a_*. Presentation checks only: the regression suites own gameplay.

const MATCH: String = "res://scenes/main/match.tscn"
const OUT: String = "res://docs/logs/evidence/p15a_"
const SIZE: Vector2i = Vector2i(1152, 648)
## Track distance (m) of the review Cannon (same spot as tests/test_towers.gd SPOT).
const REVIEW_AT: float = 14.0
const ALL_IMMUNE: Array[StringName] = [&"immune_corrosive", &"immune_energy", &"immune_explosion", &"immune_glue",
		&"immune_normal", &"immune_plasma", &"immune_sharp", &"immune_shatter", &"immune_cold"]

var m: Node3D
var content: Node
var log_lines: PackedStringArray = []


func _initialize() -> void:
	_run.call_deferred()


func _say(line: String) -> void:
	print(line)
	log_lines.append(line)


func _run() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	DisplayServer.window_set_size(SIZE)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	content = root.get_node("Content")
	m = load(MATCH).instantiate()
	root.add_child(m)
	await _frames(5)
	m.ledger.cash = 100000
	m.lives = 1000000
	if args.has("stress"):
		await _stress(args.has("greybox"))
	else:
		await _review()
	FileAccess.open(OUT + ("stress%s.txt" % ("_greybox" if args.has("greybox") else "") if args.has("stress")
			else "review.txt"), FileAccess.WRITE).store_string("\n".join(log_lines) + "\n")
	quit()


func _frames(n: int) -> void:
	for i: int in n:
		await process_frame


## Waits (real time, at most `timeout_s`) until the tower has just fired; false on timeout.
func _wait_fire(tower: Node3D, timeout_s: float) -> bool:
	var end: int = Time.get_ticks_msec() + int(timeout_s * 1000.0)
	while Time.get_ticks_msec() < end:
		await process_frame
		if tower._recoil_t < 0.02:
			return true
	return false


func _shot(name: String) -> Image:
	await _frames(2)
	var img: Image = root.get_texture().get_image()
	img.save_png(OUT + name + ".png")
	return img


## Track tangent-normal frame at distance d: [point, unit normal (XZ)].
func _frame_at(d: float) -> Array:
	var p: Vector3 = m.course.position_at(d)
	var t: Vector3 = (m.course.position_at(d + 0.2) - m.course.position_at(d - 0.2)).normalized()
	return [p, Vector3(-t.z, 0.0, t.x), t]


## Closest legal centre to the track on the given side (sign) at distance d, in 1 cm steps.
func _nearest_legal(def: Resource, d: float, side: float, along: float = 0.0) -> Vector2:
	var f: Array = _frame_at(d)
	for i: int in 300:
		var w: Vector3 = f[0] + f[1] * side * (1.0 + i * 0.01) + f[2] * along
		if m.placement_reason(def, Vector2(w.x, w.z)) == "":
			return Vector2(w.x, w.z)
	return Vector2.INF


func _track_distance(p: Vector2) -> float:
	var best: float = INF
	var pts: PackedVector3Array = m.course.waypoints
	for i: int in pts.size() - 1:
		var q: Vector2 = Geometry2D.get_closest_point_to_segment(p, Vector2(pts[i].x, pts[i].z),
				Vector2(pts[i + 1].x, pts[i + 1].z))
		best = minf(best, p.distance_to(q))
	return best


## Worst visual reach over the track edge for the tower's model over 24 aim directions (m; > 0 = over the track).
func _worst_overhang(tower: Node3D) -> float:
	var mesh: MeshInstance3D = tower._model.find_children("*", "MeshInstance3D")[0]
	var verts: PackedVector3Array = mesh.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	var worst: float = -INF
	var keep: float = tower._pivot.rotation.y
	for k: int in 24:
		tower._pivot.rotation.y = TAU * k / 24.0
		var xf: Transform3D = mesh.global_transform
		for j: int in range(0, verts.size(), 4):
			var w: Vector3 = xf * verts[j]
			if w.y < 0.35:  # only the low parts can touch the track surface (sled feet, frame)
				worst = maxf(worst, m.course.track_half_width - _track_distance(Vector2(w.x, w.z)))
	tower._pivot.rotation.y = keep
	return worst


func _aim_camera(target: Vector3, size: float) -> void:
	var cam: Camera3D = m.camera
	var fwd: Vector3 = -cam.global_transform.basis.z
	var centre: Vector3 = cam.global_position + fwd * (-cam.global_position.y / fwd.y)
	cam.global_position += target - centre
	cam.size = size


func _review() -> void:
	var cannon_def: Resource = content.get_tower(&"avalanche_cannon")
	var rookie_def: Resource = content.get_tower(&"snowball_rookie")
	var side: float = -1.0
	var spot: Vector2 = _nearest_legal(cannon_def, REVIEW_AT, side)
	var cannon: Node3D = m.try_place(cannon_def, spot)
	_say("nearest legal Cannon centre %s: %.3f m from the centreline (half width %.2f + footprint 0.60)" % [spot,
			_track_distance(spot), m.course.track_half_width])
	# Nearest legal neighbours: a Rookie and a second Cannon either side along the track, touching footprints.
	var n1: Vector2 = Vector2.INF
	var n2: Vector2 = Vector2.INF
	for i: int in 200:
		var a: float = 1.0 + i * 0.01
		if n1 == Vector2.INF:
			n1 = _nearest_legal(rookie_def, REVIEW_AT, side, a)
		if n2 == Vector2.INF:
			n2 = _nearest_legal(cannon_def, REVIEW_AT, side, -a)
	var rookie: Node3D = m.try_place(rookie_def, n1)
	var cannon2: Node3D = m.try_place(cannon_def, n2)
	_say("neighbours: Rookie %.3f m, Cannon %.3f m from the Cannon (footprints touch at 1.20)" % [spot.distance_to(n1),
			spot.distance_to(n2)])
	var mesh: MeshInstance3D = cannon._model.find_children("*", "MeshInstance3D")[0]
	var box: AABB = mesh.global_transform * mesh.get_aabb()
	_say("Cannon AABB y %.4f..%.4f m (float/sink check), size %s" % [box.position.y, box.end.y, box.size])
	_say("muzzle_A world %s (tower at y 0)" % [cannon.muzzle_position()])
	_say("worst low-part overhang past the track edge over 24 aims: %.3f m (> 0 = over the track)" % _worst_overhang(cannon))
	var material: BaseMaterial3D = mesh.mesh.surface_get_material(0)
	_say("material %s: albedo tex %s, normal %s/%s, ORM rough %s metal %s, transparency %d, cull %d, overlay %s" % [
			material.resource_name, material.albedo_texture != null, material.normal_enabled,
			material.normal_texture != null, material.roughness_texture != null, material.metallic_texture != null,
			material.transparency, material.cull_mode, mesh.material_overlay != null])
	await _shot("gamecam_placed")
	# Placement ghost, valid beside the track and invalid on it.
	var free_spot: Vector2 = _nearest_legal(cannon_def, 30.0, side)
	m.begin_placing(cannon_def)
	m.set_process(false)  # drive the ghost exactly as match._process does, without depending on the OS cursor
	var on_track: Vector3 = m.course.position_at(30.0)
	for pair: Array in [["ghost_valid", Vector3(free_spot.x, 0.0, free_spot.y)], ["ghost_invalid", on_track]]:
		var p: Vector3 = pair[1]
		m.ghost.visible = true
		m.ghost.position = Vector3(p.x, 0.0, p.z)
		m.ghost.show_ghost(m.placement_reason(cannon_def, Vector2(p.x, p.z)))
		await _shot(pair[0])
	_say("ghost: valid reason '%s', on-track reason '%s'" % [m.placement_reason(cannon_def, free_spot),
			m.placement_reason(cannon_def, Vector2(on_track.x, on_track.z))])
	m.set_process(true)
	m.cancel()
	# Selection + upgrades keep the same model and footprint.
	m.select(cannon)
	var ok_up: bool = m.buy_upgrade(cannon, 0) and m.buy_upgrade(cannon, 2)
	await _shot("selected_upgraded")
	_say("selected + upgraded %s -> tiers %s, model kept %s, footprint %s" % [ok_up, cannon.tiers,
			is_instance_valid(cannon._model), cannon.footprint()])
	m.select(null)
	# Round 1: watch the Cannon fire; pause mid-recoil.
	m.start_round()
	_say("round 1: Cannon fired %s" % await _wait_fire(cannon, 30.0))
	while cannon._recoil_t < 0.04:  # into the kick, so the pause probe holds a non-rest pose
		await process_frame
	await _shot("gamecam_firing")
	var t0: float = cannon._recoil_t
	m.set_paused(true)
	var held: Vector3 = cannon._model.position
	var held_flash: bool = cannon._flash.visible
	await _frames(30)
	_say("pause at recoil t=%.3f s: model offset %s -> %s after 30 frames (flash %s -> %s)" % [t0, held,
			cannon._model.position, held_flash, cannon._flash.visible])
	await _shot("paused_midrecoil")
	m.set_paused(false)
	# Close-up while firing.
	var keep_xf: Transform3D = m.camera.global_transform
	var keep_size: float = m.camera.size
	_aim_camera(Vector3(spot.x, 0.5, spot.y), 7.0)
	_top_up(20, true)  # round 1 may be over: immune Coral keep the towers firing for the remaining captures
	await _wait_fire(cannon, 30.0)
	while cannon._recoil_t < 0.04:
		await process_frame
	m.clock.paused = true  # hold the kick peak; the clock directly, so the HUD pause menu stays closed
	await _shot("closeup_firing")
	m.clock.paused = false
	await _frames(40)
	await _shot("closeup_rest")
	m.camera.global_transform = keep_xf
	m.camera.size = keep_size
	# Reaction length in real time at 1x/2x/4x (simulation time is fixed: kick 0.05 + recover 0.30 s).
	for speed: float in [1.0, 2.0, 4.0]:
		m.clock.speed = speed
		_top_up(20, true)
		if not await _wait_fire(cannon, 30.0):
			_say("speed %dx: Cannon did not fire within 30 s" % speed)
			continue
		var start: int = Time.get_ticks_usec()
		while cannon._recoil_t != INF:
			await process_frame
		_say("speed %dx: recoil + recovery took %.0f ms real (expected %.0f)" % [speed,
				(Time.get_ticks_usec() - start) / 1000.0, 350.0 / speed])
	m.clock.speed = 1.0
	await _frames(10)
	var img: Image = await _shot("gamecam_round1")
	img.resize(320, 180, Image.INTERPOLATE_LANCZOS)
	img.save_png(OUT + "thumb_320x180.png")
	# Selling removes the visual with the tower.
	var before: int = m.towers_root.get_child_count()
	m.sell(cannon2)
	await _frames(2)
	_say("sell: towers %d -> %d, freed %s" % [before, m.towers_root.get_child_count(), not is_instance_valid(cannon2)])
	_say("rookie still animated by AnimationPlayer: %s" % [rookie._anim != null])


func _immune_def(id: StringName) -> Resource:
	var def: Resource = content.enemies[id].duplicate()
	def.properties = ALL_IMMUNE.duplicate()
	return def


func _top_up(count: int, spread: bool) -> void:
	var length: float = m.course.length()
	while m.snowballs.size() < count:
		m._spawn(&"coral")
		var s: Node3D = m.snowballs[-1]
		s.set_layer(_immune_def(&"coral"))
		if spread:
			s.distance = length * (m.snowballs.size() - 1) / float(count)
			s.position = m.course.position_at(s.distance)


func _stress(greybox: bool) -> void:
	var cannon_def: Resource = content.get_tower(&"avalanche_cannon")
	var rookie_def: Resource = content.get_tower(&"snowball_rookie")
	var want: Array[Resource] = []
	for i: int in 12:
		want.append(cannon_def if i % 3 != 2 else rookie_def)  # 8 Cannons + 4 Rookies
	var placed: int = 0
	var d: float = 6.0
	while placed < want.size() and d < m.course.length() - 4.0:
		for side: float in [-1.0, 1.0]:
			var spot: Vector2 = _nearest_legal(want[placed], d, side) if placed < want.size() else Vector2.INF
			if spot != Vector2.INF and m.try_place(want[placed], spot):
				placed += 1
		d += 5.0
	var cannons: int = m.towers_root.get_children().filter(func(t: Node3D) -> bool:
		return t.def.id == &"avalanche_cannon").size()
	if greybox:
		for t: Node3D in m.towers_root.get_children():
			if t.def.id == &"avalanche_cannon":
				t._set_model(null)
	m.start_round()
	_top_up(120, true)
	await _frames(120)  # warm-up (shader compile, first shots)
	var times: Array[float] = []
	var draws: Array[int] = []
	var prims: Array[int] = []
	var snow_min: int = 1000
	var last: int = Time.get_ticks_usec()
	var shots: int = 0
	for i: int in 900:
		await process_frame
		_top_up(120, false)
		var now: int = Time.get_ticks_usec()
		times.append((now - last) / 1000.0)
		last = now
		draws.append(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME))
		prims.append(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME))
		snow_min = mini(snow_min, m.snowballs.size())
		shots = maxi(shots, m.shots.size())
	await _shot("stress%s" % ("_greybox" if greybox else ""))
	times.sort()
	draws.sort()
	prims.sort()
	var mean: float = times.reduce(func(a: float, b: float) -> float: return a + b, 0.0) / times.size()
	_say("stress %s: %d towers (%d Cannons + %d Rookies), snowballs >= %d (immune Coral, moving), max live shots %d,"
			% ["GREYBOX cannons" if greybox else "Cannon GLB", placed, cannons, placed - cannons, snow_min, shots])
	_say("  %d frames vsync off at %s: frame ms mean %.2f p50 %.2f p95 %.2f p99 %.2f max %.2f" % [times.size(), SIZE,
			mean, times[times.size() / 2], times[int(times.size() * 0.95)], times[int(times.size() * 0.99)], times[-1]])
	_say("  draw calls p50 %d max %d; primitives p50 %d max %d; video mem %.1f MB; renderer %s / %s" % [
			draws[draws.size() / 2], draws[-1], prims[prims.size() / 2], prims[-1],
			RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_VIDEO_MEM_USED) / 1048576.0,
			RenderingServer.get_video_adapter_name(), ProjectSettings.get_setting("rendering/renderer/rendering_method")])
