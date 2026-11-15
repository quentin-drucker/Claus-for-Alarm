extends SceneTree
## Review captures + measurements for the prepared tower models next to the Rookie (needs a window, not --headless):
##   godot --path . -s res://tests/tools/roster_review.gd            # Dev 9: Ranger + Wax      -> p15c_*
##   godot --path . -s res://tests/tools/roster_review.gd -- dev10   # Dev 10: Sorcerer + Booth -> p15d_*
##   godot --path . -s res://tests/tools/roster_review.gd -- dev11   # Dev 11: Camel Claus + 1.7 m Sorcerer, full roster
##                                                                   # + Booth, hero Frenzy/Focus/level-up -> p15e_*
## Writes docs/logs/evidence/. Presentation checks only: the regression suites own gameplay.

const MATCH: String = "res://scenes/main/match.tscn"
const SIZE: Vector2i = Vector2i(1152, 648)
const BOOTH: StringName = &"ski_resort_ticket_booth"
## Track distance (m) of the Booth's nearest legal spot (Dev 10; away from the roster row).
const BOOTH_AT: float = 40.0
## Track distance (m) of the roster row's Rookie (the Cannon review spot, tests/test_towers.gd SPOT).
const ROW_AT: float = 14.0
const SIDE: float = -1.0
## Everything but glue: the Wax Sprayer can still target them, nothing pops them.
const IMMUNE: Array[StringName] = [&"immune_corrosive", &"immune_energy", &"immune_explosion", &"immune_normal",
		&"immune_plasma", &"immune_sharp", &"immune_shatter", &"immune_cold"]

var m: Node3D
var content: Node
var log_lines: PackedStringArray = []
var towers: Dictionary = {}  # id -> roster tower
var _spawned: int = 0
var dev11: bool = OS.get_cmdline_user_args().has("dev11")
var dev10: bool = dev11 or OS.get_cmdline_user_args().has("dev10")
var OUT: String = "res://docs/logs/evidence/%s_" % ("p15e" if dev11 else "p15d" if dev10 else "p15c")
const HERO: StringName = &"camel_claus"
## Row order along the track (Wax first: past the Ranger the straight meets an obstacle; Dev 10 puts the Sorcerer
## before it). The Booth (1.5 m footprint) stands on its own spot. REACTORS = everything that reacts (Booth: income).
var ROSTER: Array[StringName] = [&"slope_wax_sprayer", &"snowball_rookie", &"avalanche_cannon", &"biathlon_ranger"]
var SHOOTERS: Array[StringName] = [&"avalanche_cannon", &"biathlon_ranger", &"slope_wax_sprayer"]
var NEW: Array[StringName] = [&"biathlon_ranger", &"slope_wax_sprayer"]
var REACTORS: Array[StringName] = []


func _initialize() -> void:
	if dev10:
		ROSTER.push_front(&"snow_sorcerer")
		SHOOTERS.append(&"snow_sorcerer")
		NEW.assign([&"snow_sorcerer", BOOTH])
	if dev11:
		ROSTER.insert(1, HERO)
		SHOOTERS.append(HERO)
		NEW.assign([HERO, &"snow_sorcerer"])
	REACTORS.assign(SHOOTERS + ([BOOTH] if dev10 else []))
	_run.call_deferred()


func _def(id: StringName) -> Resource:
	return content.hero if id == HERO else content.get_tower(id)


func _say(line: String) -> void:
	print(line)
	log_lines.append(line)


func _run() -> void:
	DisplayServer.window_set_size(SIZE)
	content = root.get_node("Content")
	m = load(MATCH).instantiate()
	root.add_child(m)
	await _frames(5)
	m.ledger.cash = 100000
	m.lives = 1000000
	await _review()
	FileAccess.open(OUT + "review.txt", FileAccess.WRITE).store_string("\n".join(log_lines) + "\n")
	quit()


func _frames(n: int) -> void:
	for i: int in n:
		await process_frame


func _shot(name: String) -> Image:
	await _frames(2)
	var img: Image = root.get_texture().get_image()
	img.save_png(OUT + name + ".png")
	return img


func _labels(on: bool) -> void:
	for t: Node3D in m.towers_root.get_children():
		t._label.visible = on


## Waits (real time, at most `timeout_s`) until the tower has just fired; false on timeout. Wax is cleared every
## frame so the Sprayer keeps finding unwaxed targets.
func _wait_fire(tower: Node3D, timeout_s: float) -> bool:
	var end: int = Time.get_ticks_msec() + int(timeout_s * 1000.0)
	while Time.get_ticks_msec() < end:
		_keep_firing()
		await process_frame
		if tower._recoil_t < 0.02:
			return true
	return false


## Keeps a round running with targets for every tower: restarts the round, tops up immune Coral, clears wax.
func _keep_firing() -> void:
	if m.state == m.State.PREPARE:
		m.start_round()
	_top_up(24)
	for s: Node3D in m.snowballs:
		s.slow_left = 0.0


func _frame_at(d: float) -> Array:
	var p: Vector3 = m.course.position_at(d)
	var t: Vector3 = (m.course.position_at(d + 0.2) - m.course.position_at(d - 0.2)).normalized()
	return [p, Vector3(-t.z, 0.0, t.x), t]


## Closest legal centre to the track on the given side at distance d (+ `along` the tangent), in 1 cm steps.
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


func _verts(tower: Node3D) -> PackedVector3Array:
	var mesh: MeshInstance3D = tower._model.find_children("*", "MeshInstance3D")[0]
	return mesh.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]


## Over 24 aims: worst reach past the track edge (all parts, and parts below 0.35 m that could touch the surface)
## and worst reach into the neighbour's footprint circle (m; > 0 = over).
func _clearance(tower: Node3D, neighbour: Vector3, aims: int = 24) -> Vector3:
	var mesh: MeshInstance3D = tower._model.find_children("*", "MeshInstance3D")[0]
	var verts: PackedVector3Array = _verts(tower)
	var worst: Vector3 = -Vector3.INF
	var keep: float = tower._pivot.rotation.y
	for k: int in aims:
		tower._pivot.rotation.y = TAU * k / 24.0 if aims > 1 else keep
		var xf: Transform3D = mesh.global_transform
		for j: int in range(0, verts.size(), 4):
			var w: Vector3 = xf * verts[j]
			var over: float = m.course.track_half_width - _track_distance(Vector2(w.x, w.z))
			worst.x = maxf(worst.x, over)
			if w.y < 0.35:
				worst.y = maxf(worst.y, over)
			worst.z = maxf(worst.z, neighbour.z - Vector2(w.x - neighbour.x, w.z - neighbour.y).length())
	tower._pivot.rotation.y = keep
	return worst


func _aim_camera(target: Vector3, size: float) -> void:
	var cam: Camera3D = m.camera
	var fwd: Vector3 = -cam.global_transform.basis.z
	var centre: Vector3 = cam.global_position + fwd * (-cam.global_position.y / fwd.y)
	cam.global_position += target - centre
	cam.size = size


func _top_up(count: int) -> void:
	var length: float = m.course.length()
	while m.snowballs.size() < count:
		m._spawn(&"coral")
		var s: Node3D = m.snowballs[-1]
		var def: Resource = content.enemies[&"coral"].duplicate()
		def.properties = IMMUNE.duplicate()
		s.set_layer(def)
		# Golden-ratio spread: refills land all along the track, not all at the exit after the first wave leaks.
		_spawned += 1
		s.distance = length * fmod(_spawned * 0.618034, 1.0)
		s.position = m.course.position_at(s.distance)


func _review() -> void:
	if dev11:  # the hero ghost first: once a hero stands, any hero ghost is invalid ("Only one Camel Claus")
		await _ghosts([HERO])
	# Roster row: Rookie, Cannon, Ranger, Wax at the nearest legal spots along one straight, touching footprints.
	var along: float = -1.2 * (ROSTER.size() - 3)
	var row_centre: Vector3 = Vector3.ZERO
	for id: StringName in ROSTER:
		var def: Resource = _def(id)
		var t: Node3D = null
		while t == null and along < 20.0:
			var spot: Vector2 = _nearest_legal(def, ROW_AT, SIDE, along)
			t = m.try_place(def, spot) if spot != Vector2.INF else null
			along += 0.01
		along += 1.19
		towers[id] = t
		row_centre += t.position / ROSTER.size()
		var mesh: MeshInstance3D = t._model.find_children("*", "MeshInstance3D")[0]
		var box: AABB = mesh.global_transform * mesh.get_aabb()
		_say("%s at %s, %.3f m from the centreline: AABB y %.3f..%.3f, footprint %.2f" % [id,
				Vector2(t.position.x, t.position.z), _track_distance(Vector2(t.position.x, t.position.z)),
				box.position.y, box.end.y, t.footprint().z])
	var ids: Array = towers.keys()
	if dev10:  # the Booth at its nearest legal spot to the track
		var bdef: Resource = content.get_tower(BOOTH)
		var b: Node3D = m.try_place(bdef, _nearest_legal(bdef, BOOTH_AT, SIDE))
		towers[BOOTH] = b
		var bm: MeshInstance3D = b._model.find_children("*", "MeshInstance3D")[0]
		var bb: AABB = bm.global_transform * bm.get_aabb()
		var c: Vector3 = _clearance(b, Vector3(INF, INF, 0.0), 1)
		_say("%s at %s, %.3f m from the centreline: AABB y %.3f..%.3f, footprint %.2f, past the track edge %.3f m" % [
				BOOTH, Vector2(b.position.x, b.position.z), _track_distance(Vector2(b.position.x, b.position.z)),
				bb.position.y, bb.end.y, b.footprint().z, c.x])
	for i: int in ids.size() - 1:
		_say("  spacing %s -> %s: %.3f m (footprints touch at 1.20)" % [ids[i], ids[i + 1],
				towers[ids[i]].position.distance_to(towers[ids[i + 1]].position)])
	await _shot("gamecam_roster_idle")
	# Clearance at the nearest legal spot and to the nearest legal neighbours (the towers beside it in the row).
	for i: int in ids.size():
		if ids[i] == &"snowball_rookie":
			continue
		for j: int in [i - 1, i + 1]:
			if j < 0 or j >= ids.size():
				continue
			var t: Node3D = towers[ids[i]]
			var n: Node3D = towers[ids[j]]
			var c: Vector3 = _clearance(t, Vector3(n.position.x, n.position.z, n.footprint().z))
			_say("%s over 24 aims: past the track edge %.3f m (parts < 0.35 m high: %.3f m); into the %s footprint %.3f m"
					% [ids[i], c.x, c.y, ids[j], c.z])
	for id: StringName in NEW:
		var t: Node3D = towers[id]
		var mesh: MeshInstance3D = t._model.find_children("*", "MeshInstance3D")[0]
		var mat: BaseMaterial3D = mesh.mesh.surface_get_material(0)
		_say("%s material: albedo tex %s, normal %s, roughness tex %s, metallic tex %s (metallic %.2f), transparency %d,"
				% [id, mat.albedo_texture != null, mat.normal_enabled and mat.normal_texture != null,
				mat.roughness_texture != null, mat.metallic_texture != null, mat.metallic, mat.transparency]
				+ " cull %d, outline overlay %s, surfaces %d" % [mat.cull_mode, mesh.material_overlay != null,
				mesh.mesh.get_surface_count()])
	# Muzzle alignment during aiming: for 8 aims at a target 10 m away, the barrel axis vs the line muzzle -> target.
	for id: StringName in SHOOTERS:
		var t: Node3D = towers[id]
		var worst_deg: float = 0.0
		var worst_side: float = 0.0
		for k: int in 8:
			var dir: Vector3 = Vector3(sin(TAU * k / 8.0), 0.0, cos(TAU * k / 8.0))
			t.play_attack(dir)
			var mz: Vector3 = t.muzzle_position()
			var to_target: Vector3 = t.position + dir * 10.0 - mz
			to_target.y = 0.0
			var barrel: Vector3 = t._pivot.global_transform.basis * (Basis(Vector3.UP,
					deg_to_rad(t._profile.weapon_yaw_deg)) * Vector3.FORWARD)
			worst_deg = maxf(worst_deg, rad_to_deg(barrel.angle_to(to_target)))
			var rel: Vector3 = mz - t.position
			worst_side = maxf(worst_side, absf(dir.cross(Vector3(rel.x, 0.0, rel.z)).y))
		_say("%s aim: barrel vs muzzle->target (10 m) worst %.1f deg; muzzle %.2f m beside the centre line" % [id,
				worst_deg, worst_side])
		t._recoil_t = INF
		t.animate(0.0)
	if dev10:
		await _ticket_visibility(towers[BOOTH])
	await _ghosts(NEW.filter(func(id: StringName) -> bool: return id != HERO))
	await _selection_upgrades()
	await _firing()  # ends by selling the new towers
	if dev11:
		await _lineup()


## Placement ghost valid/invalid for the given models.
func _ghosts(ids: Array) -> void:
	m.set_process(false)  # drive the ghost exactly as match._process does, without the OS cursor
	for id: StringName in ids:
		var def: Resource = _def(id)
		var free_spot: Vector2 = _nearest_legal(def, 30.0, SIDE)
		var on_track: Vector3 = m.course.position_at(30.0)
		m.begin_placing(def)
		for pair: Array in [["valid", Vector3(free_spot.x, 0.0, free_spot.y)], ["invalid", on_track]]:
			var p: Vector3 = pair[1]
			m.ghost.visible = true
			m.ghost.position = Vector3(p.x, 0.0, p.z)
			m.ghost.show_ghost(m.placement_reason(def, Vector2(p.x, p.z)))
			await _shot("%s_ghost_%s" % [id, pair[0]])
		_say("%s ghost: valid reason '%s', on-track reason '%s', ghost model animated %s" % [id,
				m.placement_reason(def, free_spot), m.placement_reason(def, Vector2(on_track.x, on_track.z)),
				m.ghost._recoil_t != INF])
		m.cancel()
	m.set_process(true)


## Selection + upgrades (where the tower has them; the hero has none by rule) keep the model and footprint.
func _selection_upgrades() -> void:
	for id: StringName in NEW:
		var t: Node3D = towers[id]
		m.select(t)
		var ok: bool = m.buy_upgrade(t, 0) and m.buy_upgrade(t, 2)
		await _shot("%s_selected_upgraded" % id)
		_say("%s selected + upgraded %s -> tiers %s, model kept %s, footprint %s" % [id, ok, t.tiers,
				is_instance_valid(t._model), t.footprint()])
		m.select(null)


func _firing() -> void:
	var row_centre: Vector3 = Vector3.ZERO
	for id: StringName in ROSTER:
		row_centre += towers[id].position / ROSTER.size()
	# Firing: whole roster at the normal camera, then pause mid-reaction.
	for id: StringName in NEW:
		_say("%s reacted %s" % [id, await _wait_fire(towers[id], 40.0)])
	var ranger: Node3D = towers[&"biathlon_ranger"]
	await _wait_fire(ranger, 30.0)
	await _shot("gamecam_roster_firing")
	for id: StringName in NEW:
		var t: Node3D = towers[id]
		await _wait_fire(t, 40.0)
		while t._recoil_t < 0.03:
			await process_frame
		m.set_paused(true)
		var held: Transform3D = t._model.transform
		var flash: bool = t._flash.visible
		await _frames(30)
		_say("%s pause at t=%.3f s: model transform held %s, flash %s -> %s" % [id, t._recoil_t,
				t._model.transform == held, flash, t._flash.visible])
		m.set_paused(false)
	# Close-ups: no labels, kick peak held with the clock (the HUD pause menu stays closed), then at rest.
	_labels(false)
	var keep_xf: Transform3D = m.camera.global_transform
	var keep_size: float = m.camera.size
	_aim_camera(row_centre, 11.0)
	await _shot("closeup_roster_rest")
	# Deterministic: clock paused, the reaction triggered toward the camera-side track and stepped by hand.
	m.clock.paused = true
	for id: StringName in NEW:
		var t: Node3D = towers[id]
		_aim_camera(t.position + Vector3.UP * (1.0 if id == BOOTH else 0.4), 7.0 if id == BOOTH else 4.8)
		if id == BOOTH:
			t.play_income()
		else:
			t.play_attack(Vector3(-0.8, 0.0, 0.6) if id == &"biathlon_ranger" else Vector3(-0.6, 0.0, 0.8))
		t.animate(t._profile.recoil_kick_s * 0.8)
		await _shot("%s_closeup_firing" % id)
		t.animate(10.0)
		await _shot("%s_closeup_rest" % id)
	m.clock.paused = false
	m.camera.global_transform = keep_xf
	m.camera.size = keep_size
	_labels(true)
	# Reaction length in real time at 1x/2x/4x.
	for id: StringName in NEW:
		var t: Node3D = towers[id]
		var sim_ms: float = (t._profile.recoil_kick_s + t._profile.recoil_recover_s) * 1000.0
		for speed: float in [1.0, 2.0, 4.0]:
			m.clock.speed = speed
			if not await _wait_fire(t, 40.0):
				_say("%s %dx: did not react within 40 s" % [id, speed])
				continue
			var start: int = Time.get_ticks_usec()
			while t._recoil_t != INF:
				await process_frame
			_say("%s %dx: reaction took %.0f ms real (expected %.0f)" % [id, speed,
					(Time.get_ticks_usec() - start) / 1000.0, sim_ms / speed])
	# Rapid fire at 4x for 10 s real, then every model must settle exactly at rest (no drift).
	m.clock.speed = 4.0
	var shots: Dictionary = {}
	var end: int = Time.get_ticks_msec() + 10000
	while Time.get_ticks_msec() < end:
		_keep_firing()
		await process_frame
		for id: StringName in REACTORS:
			if towers[id]._recoil_t < 0.02:
				shots[id] = shots.get(id, 0) + 1
	m.clock.speed = 1.0
	m.clock.paused = false
	m.set_paused(true)  # no new shots; then step each pose past its reaction by hand
	for id: StringName in REACTORS:
		var t: Node3D = towers[id]
		t.animate(10.0)  # one long step past any reaction: the pose is a pure function of time since the kick
		_say("%s after rapid fire at 4x (%d shot frames seen): transform at rest %s, flash off %s" % [id,
				shots.get(id, 0), t._model.transform == Transform3D(Basis.from_scale(Vector3.ONE * 1.5)),
				not t._flash.visible])
	m.set_paused(false)
	await _frames(10)
	var img: Image = await _shot("gamecam_roster_round")
	img.resize(320, 180, Image.INTERPOLATE_LANCZOS)
	img.save_png(OUT + "thumb_320x180.png")
	# Selling removes the visual with the tower.
	for id: StringName in NEW:
		var t: Node3D = towers[id]
		var before: int = m.towers_root.get_child_count()
		m.sell(t)
		await _frames(2)
		_say("%s sell: towers %d -> %d, freed %s" % [id, before, m.towers_root.get_child_count(),
				not is_instance_valid(t)])


## Dev 10: drops all 8 possible ticket positions (2-2-0 drops 8 per round) around the Booth and reports which ones the
## building hides at the game camera (a Booth vertex in front of the ticket within 6 px on screen). Removed after.
func _ticket_visibility(b: Node3D) -> void:
	var cam: Camera3D = m.camera
	var mesh: MeshInstance3D = b._model.find_children("*", "MeshInstance3D")[0]
	var verts: PackedVector3Array = _verts(b)
	var pts: Array = []
	for j: int in range(0, verts.size(), 3):
		var w: Vector3 = mesh.global_transform * verts[j]
		pts.append([cam.unproject_position(w), -(cam.global_transform.affine_inverse() * w).z])
	for k: int in 8:
		m._drop_pickup(b, k)
	var hidden: Array = []
	for pk: Object in m.pickups:
		var top: Vector3 = pk.pos + Vector3.UP * 0.25
		var sp: Vector2 = cam.unproject_position(top)
		var depth: float = -(cam.global_transform.affine_inverse() * top).z
		var blocked: bool = pts.any(func(q: Array) -> bool: return q[0].distance_to(sp) < 6.0 and q[1] < depth - 0.05)
		if blocked:
			hidden.append(Vector2(pk.pos.x - b.position.x, pk.pos.z - b.position.z))
	_say("%s tickets: %d positions 1.80 m from the centre; behind the building at the game camera: %d %s (tickets draw without depth test, so they still show)" % [
			BOOTH, m.pickups.size(), hidden.size(), hidden])
	var img: Image = await _shot("booth_tickets")
	var sp: Vector2 = cam.unproject_position(b.position)
	img.get_region(Rect2i(int(sp.x) - 75, int(sp.y) - 95, 150, 140)).save_png(OUT + "booth_tickets_crop.png")
	for pk: Object in m.pickups.duplicate():
		m._remove_pickup(pk)


## Dev 11 hero feedback: level-up glint + XP pulse, Focus reticle/pose, Frenzy ring, each held with the clock and
## captured close; wind-up measured from the cooldown. Presentation only.
func _hero_feedback(h: Node3D) -> void:
	_labels(false)
	var keep_xf: Transform3D = m.camera.global_transform
	var keep_size: float = m.camera.size
	m.clock.paused = true
	_aim_camera(h.position + Vector3.UP * 0.8, 6.0)
	h.play_attack(Vector3(-0.6, 0.0, 0.8))
	h._recoil_t = INF
	h.animate(0.0)
	await _shot("camel_claus_closeup_rest")
	m.set_hero_level(4)
	h.animate(0.25)
	await _shot("camel_claus_levelup")
	_say("camel_claus level-up at 0.25 s: XP ring %s, hat glint %s (scale %.2f)" % [h._xp_ring.visible, h._glint.visible,
			h._glint.scale.x])
	h.animate(1.0)
	m.toggle_focus()
	h.animate(0.3)
	await _shot("camel_claus_focus")
	_say("camel_claus Focus: pose weight %.2f, reticle %s, model tilt %.1f deg" % [h._focus_k, h._focus_ring.visible,
			rad_to_deg(h._model.basis.orthonormalized().get_euler().length())])
	m.toggle_focus()
	h.animate(0.3)
	m.clock.paused = false
	m.use_frenzy()
	m.clock.paused = true
	h.play_attack(Vector3(-0.6, 0.0, 0.8))
	h.animate(0.03)
	await _shot("camel_claus_frenzy_firing")
	_say("camel_claus Frenzy: ring %s, interval %.3f s" % [h._frenzy_ring.visible, h.attacks[0].interval_s])
	# Wind-up: engaged hero, cooldown inside the anticipation window.
	h._since_shot = 0.1
	h.cooldowns[0] = h._profile.anticipation_s * 0.25
	h._recoil_t = INF
	h.animate(0.0)
	await _shot("camel_claus_windup")
	_say("camel_claus wind-up at 75%%: weight %.2f, model scale y %.3f" % [h._windup, h._model.scale.y])
	m.clock.paused = false
	m.camera.global_transform = keep_xf
	m.camera.size = keep_size
	# Frenzy at the normal camera with the HUD, hero firing.
	m.get_node("HUD").visible = true
	await _wait_fire(h, 30.0)
	await _shot("gamecam_hero_frenzy")
	_labels(true)


## Dev 11 size comparison: the whole roster side by side on a straight that runs across the screen (camera side, nearest
## legal spots, touching footprints), at the normal camera and close; then the hero alone at the 1.5 m-modelled
## alternative (display scale only, nothing re-prepared) for the owner's size decision.
func _lineup() -> void:
	for t: Node3D in m.towers_root.get_children():
		m.sell(t)
	m.get_node("HUD").visible = false  # size comparison without panels or the pause menu
	for s: Node3D in m.snowballs.duplicate():
		m.snowballs.erase(s)
		s.free()
	await _frames(2)
	# Longest run of track that crosses the screen (tangent along world X); the row starts 1 m into it.
	var d0: float = 0.0
	var best: float = 0.0
	var run_start: float = 0.0
	var d: float = 1.0
	while d < m.course.length() - 1.0:
		if absf(_frame_at(d)[2].x) < 0.98:
			run_start = d + 0.5
		elif d - run_start > best:
			best = d - run_start
			d0 = run_start + 1.0
		d += 0.5
	_say("lineup straight: %.1f m from track distance %.1f" % [best, d0 - 1.0])
	var f: Array = _frame_at(d0)
	var side: float = signf(f[1].z)  # toward the camera (+Z)
	var order: Array[StringName] = [&"snowball_rookie", &"avalanche_cannon", &"biathlon_ranger", &"slope_wax_sprayer",
			&"snow_sorcerer", HERO]
	var along: float = 0.0
	var placed: Array[Node3D] = []
	var centre: Vector3 = Vector3.ZERO
	for id: StringName in order:
		var def: Resource = _def(id)
		var r: float = def.footprint_units * 0.1
		if not placed.is_empty():
			along += placed[-1].footprint().z + r - 0.02
		var t: Node3D = null
		while t == null and along < 30.0:
			var spot: Vector2 = _nearest_legal(def, d0, side, along)
			t = m.try_place(def, spot) if spot != Vector2.INF else null
			along += 0.01
		if t == null:
			var w: Vector3 = f[0] + f[1] * side * 1.5 + f[2] * along
			_say("lineup %s: no legal spot at d %.1f (reason at 1.5 m: '%s')" % [id, d0,
					m.placement_reason(def, Vector2(w.x, w.z))])
			continue
		placed.append(t)
		centre += t.position
		var mesh: MeshInstance3D = t._model.find_children("*", "MeshInstance3D")[0]
		var box: AABB = mesh.global_transform * mesh.get_aabb()
		var top: Vector2 = m.camera.unproject_position(t.position + Vector3.UP * box.end.y)
		_say("lineup %s: %.2f m tall, %.0f px tall on screen at the game camera, half-width %.2f m" % [id, box.end.y,
				m.camera.unproject_position(t.position).y - top.y, maxf(box.size.x, box.size.z) / 2.0])
	centre /= placed.size()
	_labels(false)
	await _shot("gamecam_lineup")
	var cam_xf: Transform3D = m.camera.global_transform
	var cam_size: float = m.camera.size
	var sp: Vector2 = m.camera.unproject_position(centre)
	var img: Image = root.get_texture().get_image()
	img.get_region(Rect2i(int(sp.x) - 110, int(sp.y) - 60, 220, 80)).save_png(OUT + "gamecam_lineup_crop.png")
	_aim_camera(centre + Vector3.UP * 0.8, 10.0)
	await _shot("closeup_lineup")
	var h: Node3D = placed[order.find(HERO)]
	m.clock.paused = true  # animate() would restore the display scale every tick
	h._model.scale = Vector3.ONE * 1.5 * 1.5 / 1.68
	await _shot("closeup_lineup_hero150")
	m.camera.global_transform = cam_xf
	m.camera.size = cam_size
	await _shot("gamecam_lineup_hero150")
	h._model.scale = Vector3.ONE * 1.5
	m.clock.paused = false
	await _hero_feedback(h)
	m.get_node("HUD").visible = true
