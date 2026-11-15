extends SceneTree
## Dev 13 VFX review capture (needs a window): every regular tower with a showcase upgrade firing at a stream that
## includes Black / White / Aurora / Camo shells. Writes docs/logs/evidence/dev13_vfx_*.png.
##   godot --path . --resolution 1280x720 -s res://tests/tools/vfx_review.gd

const MATCH: String = "res://scenes/main/match.tscn"
const OUT: String = "res://docs/logs/evidence/dev13_vfx_"
## [tower id, spot (x, z), tiers]
const SETUP: Array = [
	[&"snow_sorcerer", Vector2(-5.5, 0.0), Vector3i(0, 2, 0)],
	[&"avalanche_cannon", Vector2(2.0, 0.0), Vector3i(0, 0, 3)],
	[&"snowball_rookie", Vector2(-5.5, -3.0), Vector3i(2, 0, 0)],
	[&"slope_wax_sprayer", Vector2(2.0, 2.5), Vector3i(0, 2, 0)],
	[&"biathlon_ranger", Vector2(-12.0, -2.0), Vector3i(0, 3, 0)],
	[&"snow_sorcerer", Vector2(2.0, -2.5), Vector3i(0, 3, 0)],
]
const STREAM: Array[StringName] = [&"black", &"white", &"purple", &"camo_mint", &"coral", &"black", &"white",
		&"purple", &"camo_blue", &"violet"]


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	root.size = Vector2i(1280, 720)
	var content: Node = root.get_node("Content")
	var m: Node3D = load(MATCH).instantiate()
	root.add_child(m)
	await process_frame
	m.ledger.credit(0, 100000, &"test", 0)
	for spec: Array in SETUP:
		var t: Node3D = m.try_place(content.get_tower(spec[0]), spec[1])
		if t == null:
			print("could not place %s: %s" % [spec[0], m.placement_reason(content.get_tower(spec[0]), spec[1])])
			continue
		t.tiers = spec[2]
		t.rebuild_stats()
	m.state = m.State.ROUND_CLEANUP
	var k: int = 0
	for shot: int in 4:
		for i: int in 5:
			m._spawn(STREAM[k % STREAM.size()])
			k += 1
			for f: int in 18:
				await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(OUT + "%d.png" % shot)
		print("captured %d" % shot)
	quit(0)
