extends SceneTree
## Windowed review: -- old restores 60 degree pitch for comparison. Never changes source scenes.

var m: Node3D


func _initialize() -> void:
	_run.call_deferred()


func shot(label: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/logs/evidence/observations_" + label + ".png")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1152, 648))
	m = load("res://scenes/main/match.tscn").instantiate()
	root.add_child(m)
	m.clock.set_process(false)
	var old: bool = OS.get_cmdline_user_args().has("old")
	if old:
		m.camera.elevation_degrees = 60
		m.camera.apply_elevation()
	m.ledger.cash = 100000
	var content: Node = root.get_node("Content")
	var roster: Array[StringName] = [&"snowball_rookie", &"avalanche_cannon", &"biathlon_ranger", &"slope_wax_sprayer", &"snow_sorcerer"]
	for i: int in roster.size():
		var t: Node3D = m.try_place(content.get_tower(roster[i]), Vector2(-7.2, -3.0 + i * 1.4))
		if t:
			t.get_node("Label").visible = false
	var booth: Node3D = m.try_place(content.get_tower(&"ski_resort_ticket_booth"), Vector2(12, 1.5))
	if booth:
		booth.get_node("Label").visible = false
	for i: int in 12:
		m._spawn(&"blue")
		m.snowballs[-1].position = m.course.position_at(i * 5.0)
	await shot("camera_60" if old else "camera_50")
	if not old and booth:
		m._drop_pickup(booth, 0)
		for i: int in 10:
			m.clock.advance(1.0 / 60.0)
		await shot("ticket_spawn")
		m.set_collect_cursor(m.pickups[0].pos + Vector3(1.2, 0, 0))
		m.clock.advance(1.0 / 60.0)
		for i: int in 7:
			m.clock.advance(1.0 / 60.0)
		await shot("ticket_collect")
	quit()
