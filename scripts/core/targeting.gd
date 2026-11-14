class_name Targeting
extends RefCounted
## Target choice (P06-T01/T02). Pure function: eligibility first (range, camo detection), then priority.
## Ties always go to the lower entity id, so equal candidates never flicker between ticks.

enum Priority { FIRST, LAST, CLOSE, STRONG }


## Best target in `snowballs` for a tower at `origin` (XZ plane), or null. Snowballs need
## `position`, `distance` (along the track), `def` and `entity_id`. `accept` (optional) is an extra
## eligibility test per snowball, e.g. line of sight for global towers.
static func pick(snowballs: Array[Node3D], origin: Vector3, range_m: float, priority: Priority,
		detects_camo: bool, accept: Callable = Callable()) -> Node3D:
	var best: Node3D = null
	var best_score: float = -INF
	for s: Node3D in snowballs:
		var d: float = Vector2(s.position.x - origin.x, s.position.z - origin.z).length()
		if d > range_m or (&"camo" in s.def.properties and not detects_camo):
			continue
		if accept.is_valid() and not accept.call(s):
			continue
		var score: float
		match priority:
			Priority.FIRST: score = s.distance
			Priority.LAST: score = -s.distance
			Priority.CLOSE: score = -d
			Priority.STRONG: score = Content.rbe(s.def.id) * 10000.0 + s.distance  # strongest, then first
		if score > best_score or (score == best_score and s.entity_id < best.entity_id):
			best = s
			best_score = score
	return best
