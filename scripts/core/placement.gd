class_name Placement
extends RefCounted
## Deterministic placement rules on the ground plane (P03-T05/T07). Pure function: same input, same answer.
## Positions are XZ in metres as Vector2(x, z).


## Returns "" if a footprint of `radius` fits at `pos`, otherwise the reason shown to the player.
static func check(pos: Vector2, radius: float, bounds: Rect2, track: PackedVector2Array, track_half_width: float,
		blockers: Array[Rect2], towers: Array[Vector3]) -> String:
	if not bounds.grow(-radius).has_point(pos):
		return "Outside the course"
	for i: int in track.size() - 1:
		var closest: Vector2 = Geometry2D.get_closest_point_to_segment(pos, track[i], track[i + 1])
		if pos.distance_to(closest) < track_half_width + radius:
			return "On the ski track"
	for rect: Rect2 in blockers:
		var nearest: Vector2 = pos.clamp(rect.position, rect.end)
		if pos.distance_to(nearest) < radius:
			return "Blocked by scenery"
	for tower: Vector3 in towers:  # Vector3(x, z, footprint radius)
		if pos.distance_to(Vector2(tower.x, tower.y)) < radius + tower.z:
			return "Too close to another tower"
	return ""
