extends Node3D
## Greybox "Conn Winter Games — Ski Circuit" (P03, geometry map_v1). `waypoints`, `bounds`, `track_half_width`
## and the Blockers boxes are gameplay data: art may restyle meshes but must not move them without a balance
## review and re-running tests/test_map.gd (P03-T11).
## The track centre line is the `Waypoints` Marker3D children, entry first (metres, y = 0).

## Buildable ground (XZ metres): position = min x/z corner.
@export var bounds: Rect2 = Rect2(-16, -10, 32, 20)
@export var track_half_width: float = 1.1
@export var track_color: Color = Color("8fa3b5")

var waypoints: PackedVector3Array = []
var _cumulative: PackedFloat32Array = []


func _ready() -> void:
	_build_cumulative()
	# Track surface built from the waypoints so the visual can never drift from the simulated path.
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = track_color
	for i: int in waypoints.size() - 1:
		var a: Vector3 = waypoints[i]
		var b: Vector3 = waypoints[i + 1]
		var box: BoxMesh = BoxMesh.new()
		box.size = Vector3(track_half_width * 2.0, 0.04, a.distance_to(b) + track_half_width * 2.0)
		box.material = material
		var segment: MeshInstance3D = MeshInstance3D.new()
		segment.mesh = box
		segment.position = (a + b) / 2.0 + Vector3(0, 0.02, 0)
		segment.rotation.y = atan2(b.x - a.x, b.z - a.z)
		add_child(segment)


func length() -> float:
	_build_cumulative()
	return _cumulative[-1]


## Point on the centre line `distance` metres from the entry (clamped to the ends).
func position_at(distance: float) -> Vector3:
	_build_cumulative()
	for i: int in range(1, waypoints.size()):
		if distance <= _cumulative[i] or i == waypoints.size() - 1:
			var span: float = _cumulative[i] - _cumulative[i - 1]
			return waypoints[i - 1].lerp(waypoints[i], clampf((distance - _cumulative[i - 1]) / span, 0.0, 1.0))
	return waypoints[0]


## Returns "" if a tower footprint fits at `pos` (XZ), else the reason. `towers`: Vector3(x, z, radius).
func check_placement(pos: Vector2, radius: float, towers: Array[Vector3]) -> String:
	_build_cumulative()
	var track: PackedVector2Array = []
	for point: Vector3 in waypoints:
		track.append(Vector2(point.x, point.z))
	var blockers: Array[Rect2] = []
	for child: Node in get_node("Blockers").get_children():
		var box: MeshInstance3D = child as MeshInstance3D
		var size: Vector3 = (box.mesh as BoxMesh).size
		blockers.append(Rect2(box.position.x - size.x / 2.0, box.position.z - size.z / 2.0, size.x, size.z))
	return Placement.check(pos, radius, bounds, track, track_half_width, blockers, towers)


func _build_cumulative() -> void:
	if not _cumulative.is_empty():
		return
	for marker: Node in get_node("Waypoints").get_children():
		waypoints.append((marker as Node3D).position)
	_cumulative = [0.0]
	for i: int in range(1, waypoints.size()):
		_cumulative.append(_cumulative[i - 1] + waypoints[i - 1].distance_to(waypoints[i]))
