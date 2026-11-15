extends SceneTree
## P17-T07 ambient snow: the match builds one snowfall layer and one gust layer (one draw call each), a gust starts,
## runs and hides itself, and the cosmetic layer never touches the simulation (cash/lives/round unchanged).
## Run: godot --headless --path . -s res://tests/test_ambient_snow.gd   (exit 1 = failure)

const MATCH: String = "res://scenes/main/match.tscn"

var _failures: int = 0


func _check(ok: bool, what: String) -> void:
	if not ok:
		_failures += 1
		printerr("FAIL: " + what)


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var m: Node3D = load(MATCH).instantiate()
	root.add_child(m)
	await process_frame
	var snow: Node3D = m.get_node_or_null("AmbientSnow")
	_check(snow != null, "match has AmbientSnow")
	if snow == null:
		quit(1)
		return
	var layers: Array[Node] = snow.get_children()
	_check(layers.size() == 2, "snowfall + gust layers")
	_check((layers[0] as MultiMeshInstance3D).multimesh.instance_count == snow.flake_count, "flake count")
	_check((layers[1] as MultiMeshInstance3D).multimesh.instance_count == snow.gust_flakes, "gust flake count")
	_check(not layers[1].visible, "no gust before the first interval")
	var before: Array = [m.ledger.cash, m.lives, m.state]
	snow.gust_life_s = 0.2
	snow._next_gust_s = 0.0
	await process_frame
	_check(layers[1].visible, "gust starts when its timer runs out")
	await create_timer(0.5).timeout
	await process_frame
	_check(not layers[1].visible, "gust hides after its life")
	_check(before == [m.ledger.cash, m.lives, m.state], "cosmetic layer leaves the simulation alone")
	print("test_ambient_snow: %s" % ("PASS" if _failures == 0 else "%d FAILED" % _failures))
	quit(1 if _failures > 0 else 0)
