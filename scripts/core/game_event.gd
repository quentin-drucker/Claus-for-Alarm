class_name GameEvent
extends RefCounted
## Semantic gameplay event (master plan §6.1, M-02). Presentation subscribes; it never feeds back into combat.

var type: StringName
var tick: int
var source_id: int
var target_id: int
var position: Vector3
var magnitude: float
var tags: PackedStringArray


func _to_string() -> String:
	return "EVENT %s tick=%d src=%d tgt=%d mag=%s tags=%s" % [type, tick, source_id, target_id, magnitude, tags]
