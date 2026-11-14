class_name RoundDefinition
extends GameDefinition
## One scripted round (P02-T06). Round number = position in the sorted round list.

## Empty = exact source round; otherwise the custom set it belongs to (decision D-03).
@export var custom_label: String = ""
@export var groups: Array[SpawnGroup] = []


func validate() -> PackedStringArray:
	var errors: PackedStringArray = super()
	if groups.is_empty():
		errors.append("%s: no spawn groups (round can never start or end)" % id)
	for group: SpawnGroup in groups:
		if group.count <= 0 or group.start_s < 0.0 or group.duration_s < 0.0:
			errors.append("%s: group %s has count <= 0 or negative time" % [id, group.enemy_id])
	return errors


## [time_s, enemy_id] pairs in spawn order; equal times keep group order (deterministic).
func schedule() -> Array:
	var out: Array = []
	for group: SpawnGroup in groups:
		for i: int in group.count:
			out.append([group.spawn_time(i), group.enemy_id, out.size()])
	out.sort_custom(func(a: Array, b: Array) -> bool: return a[0] < b[0] or (a[0] == b[0] and a[2] < b[2]))
	return out
