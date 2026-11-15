extends SceneTree
## Dev 13: capture the ski-ticket pickups around a Booth (needs a window) -> docs/logs/evidence/dev13_tickets.png
##   godot --path . --resolution 1280x720 -s res://tests/tools/ticket_review.gd


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	root.size = Vector2i(1280, 720)
	var m: Node3D = load("res://scenes/main/match.tscn").instantiate()
	root.add_child(m)
	await process_frame
	m.ledger.credit(0, 5000, &"test", 0)
	var booth: Node3D = m.try_place(root.get_node("Content").get_tower(&"ski_resort_ticket_booth"), Vector2(2.0, 0.0))
	for k: int in 5:
		m._drop_pickup(booth, k)
	for f: int in 60:
		await process_frame
	await RenderingServer.frame_post_draw
	var img: Image = root.get_texture().get_image()
	var p: Vector2 = m.camera.unproject_position(booth.position) * (Vector2(img.get_size()) / root.get_visible_rect().size)
	img.get_region(Rect2i(int(p.x) - 160, int(p.y) - 150, 320, 240)).save_png("res://docs/logs/evidence/dev13_tickets.png")
	quit(0)
