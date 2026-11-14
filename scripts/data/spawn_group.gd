class_name SpawnGroup
extends Resource
## `count` enemies sent evenly from `start_s` to `start_s + duration_s` (BTD6 "sent over").

@export var enemy_id: StringName
@export var count: int = 1
@export var start_s: float = 0.0
@export var duration_s: float = 0.0
## Path lane; the only map has one.
@export var lane: int = 0


func spawn_time(index: int) -> float:
	return start_s + (duration_s * index / (count - 1) if count > 1 else 0.0)
