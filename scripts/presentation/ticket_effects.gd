extends Node3D
## Cosmetic ticket motion only. Match owns pickup positions, expiry and payment.
## Advanced by the fixed game clock: pause/speed apply without affecting collection.

const SPAWN_SECONDS: float = 0.42
const COLLECT_SECONDS: float = 0.22
const MAX_COLLECT_EFFECTS: int = 48

var motions: Array[Dictionary] = []


func spawn_ticket(node: MeshInstance3D, origin: Vector3, resting: Vector3) -> void:
	node.position = origin
	node.scale = Vector3.ONE * 0.25
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	motions.append({"node": node, "from": origin, "to": resting, "time": 0.0, "collect": false})


func collect_ticket(node: MeshInstance3D, target: Vector3) -> void:
	forget(node)
	# Bound collected visuals independently of authoritative tickets/payment.
	var collecting: Array[Dictionary] = motions.filter(func(m: Dictionary) -> bool: return m.collect)
	if collecting.size() >= MAX_COLLECT_EFFECTS:
		var oldest: Dictionary = collecting[0]
		motions.erase(oldest)
		if is_instance_valid(oldest.node):
			oldest.node.queue_free()
	motions.append({"node": node, "from": node.position, "to": target, "time": 0.0, "collect": true})


func forget(node: MeshInstance3D) -> void:
	for motion: Dictionary in motions.duplicate():
		if motion.node == node:
			motions.erase(motion)


func advance(dt: float, cursor: Variant) -> void:
	for motion: Dictionary in motions.duplicate():
		var node: MeshInstance3D = motion.node
		if not is_instance_valid(node) or node.is_queued_for_deletion():
			motions.erase(motion)
			continue
		motion.time += dt
		var collecting: bool = motion.collect
		var duration: float = COLLECT_SECONDS if collecting else SPAWN_SECONDS
		var t: float = clampf(motion.time / duration, 0.0, 1.0)
		var start: Vector3 = motion.from
		var finish: Vector3 = motion.to
		if collecting:
			if cursor != null:
				finish = cursor
				motion.to = finish
			node.position = start.lerp(finish, t * t)  # accelerating magnetic pull
			node.scale = Vector3.ONE * lerpf(1.0, 0.15, t * t * t)
		else:
			node.position = start.lerp(finish, smoothstep(0.0, 1.0, t)) + Vector3.UP * sin(PI * t) * 0.8
			node.scale = Vector3.ONE * (lerpf(0.25, 1.0, minf(t * 3.0, 1.0)) + sin(PI * t) * 0.12)
			node.rotation.y = sin(PI * t) * 0.5
		if t >= 1.0:
			motions.erase(motion)
			if collecting:
				node.queue_free()
			else:
				node.position = finish
				node.scale = Vector3.ONE
				node.rotation = Vector3.ZERO
