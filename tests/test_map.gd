extends SceneTree
## P03 tests: frozen map_v1 geometry, path interpolation, deterministic placement rejection.
## Run: godot --headless --path . -s res://tests/test_map.gd   (exit 1 = failure)
## If this fails after an art pass, the track or blockers moved: that needs a balance review (P03-T11).

var _failures: int = 0


func _check(ok: bool, what: String) -> void:
	if not ok:
		_failures += 1
		printerr("FAIL: " + what)


func _initialize() -> void:
	var course: Node3D = load("res://scenes/world/ski_circuit.tscn").instantiate()

	# map_v1 freeze: waypoints (m), bounds, track width, blockers.
	_check(course.length() == 66.0, "route length 66 m (got %s)" % course.length())
	_check(course.waypoints == PackedVector3Array([Vector3(-17, 0, -6), Vector3(-9, 0, -6), Vector3(-9, 0, 5),
			Vector3(-2, 0, 5), Vector3(-2, 0, -5), Vector3(6, 0, -5), Vector3(6, 0, 6), Vector3(17, 0, 6)]), "waypoints")
	_check(course.bounds == Rect2(-16, -10, 32, 20) and course.track_half_width == 1.1, "bounds and track width")

	# Path interpolation (P03-T04).
	_check(course.position_at(0.0) == Vector3(-17, 0, -6), "start")
	_check(course.position_at(4.0) == Vector3(-13, 0, -6), "mid first segment")
	_check(course.position_at(8.0) == Vector3(-9, 0, -6), "first corner")
	_check(course.position_at(13.5) == Vector3(-9, 0, -0.5), "second segment")
	_check(course.position_at(66.0) == Vector3(17, 0, 6), "finish")
	_check(course.position_at(99.0) == Vector3(17, 0, 6), "past finish clamps")

	# Placement (P03-T05/T10): footprint 0.6 m (Dart 6 units).
	var r: float = 0.6
	var none: Array[Vector3] = []
	var cases: Array = [
		[Vector2(-5.5, 0), "", "open snow between track columns"],
		[Vector2(-9, 0), "On the ski track", "on track"],
		[Vector2(-7.4, 3.4), "On the ski track", "inside a bend"],
		[Vector2(-7.2, 3.2), "", "just clear of a bend"],
		[Vector2(-15.5, 0), "Outside the course", "footprint over the border"],
		[Vector2(20, 0), "Outside the course", "off the map"],
		[Vector2(11.5, -3), "Blocked by scenery", "on the lodge"],
		[Vector2(8.6, -3), "Blocked by scenery", "touching the lodge"],
		[Vector2(8.2, -3), "", "beside the lodge"],
		[Vector2(-13, 4), "Blocked by scenery", "on the pond"],
	]
	for c: Array in cases:
		var got: String = course.check_placement(c[0], r, none)
		_check(got == c[1], "%s %s: expected '%s' got '%s'" % [c[2], c[0], c[1], got])
		_check(course.check_placement(c[0], r, none) == got, "deterministic %s" % c[2])
	var placed: Array[Vector3] = [Vector3(-5.5, 0, 0.6)]
	_check(course.check_placement(Vector2(-5.0, 0), r, placed) == "Too close to another tower", "overlapping tower")
	_check(course.check_placement(Vector2(-4.29, 0), r, placed) == "", "footprints just apart are allowed")

	course.free()
	print("test_map: %s" % ("PASS" if _failures == 0 else "%d FAILURES" % _failures))
	quit(1 if _failures > 0 else 0)
