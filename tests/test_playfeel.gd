extends SceneTree
## Owner gameplay experiments: pickup lifecycle, widened projectile contacts and camera projection.

const MATCH: String = "res://scenes/main/match.tscn"
const STEP: float = 1.0 / 60.0
var failures: int = 0


func _initialize() -> void:
	_run.call_deferred()


func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		printerr("FAIL: " + message)


func fresh() -> Node3D:
	var m: Node3D = load(MATCH).instantiate()
	root.add_child(m)
	m.clock.set_process(false)
	return m


func _run() -> void:
	var content: Node = root.get_node("Content")
	var m: Node3D = fresh()
	m.ledger.credit(0, 2000, &"test", 0)
	var booth: Node3D = m.try_place(content.get_tower(&"ski_resort_ticket_booth"), Vector2(12, 1.5))
	check(is_equal_approx(m.hover_collect_radius_m, 2.0), "pickup radius doubled to 2 m")
	m._drop_pickup(booth, 0)
	var p: Object = m.pickups[0]
	var visual: MeshInstance3D = p.node
	var resting: Vector3 = p.pos + Vector3.UP * 0.15
	check(visual.position.distance_to(booth.muzzle_position()) < 0.001, "ticket starts at Booth window")
	m.set_collect_cursor(p.pos + Vector3(2.01, 0, 0))
	for i: int in 10:
		m.clock.advance(STEP)
	check(p in m.pickups and visual.position.y > resting.y, "outside radius: ticket arcs upward without credit")
	m.set_paused(true)
	var held: Vector3 = visual.position
	m.clock.advance(0.5)
	check(visual.position == held, "ticket animation freezes with pause")
	m.set_paused(false)
	for i: int in 30:
		m.clock.advance(STEP)
	check(visual.position.distance_to(resting) < 0.001, "spawn settles at original pickup position")
	var before: int = m.ledger.cash
	var target: Vector3 = p.pos + Vector3(1.99, 0, 0)
	m.set_collect_cursor(target)
	m.clock.advance(STEP)
	check(p not in m.pickups and m.ledger.cash == before + 50, "inside 2 m: payment immediate and once")
	check(is_instance_valid(visual) and not visual.is_queued_for_deletion(), "magnetic visual survives authoritative collection")
	m.collect(p)
	check(m.ledger.cash == before + 50, "repeated collection cannot duplicate payment")
	var distance_before: float = visual.position.distance_to(target)
	for i: int in 6:
		m.clock.advance(STEP)
	check(visual.position.distance_to(target) < distance_before, "collected ticket moves toward cursor")
	for i: int in 20:
		m.clock.advance(STEP)
	check(visual.is_queued_for_deletion() and m.ticket_effects.motions.is_empty(), "collected effect finishes and releases visual")
	# A pickup may be collected on its spawn tick; its animation never controls payment.
	m._drop_pickup(booth, 1)
	p = m.pickups[0]
	m.set_collect_cursor(p.pos)
	m.clock.advance(STEP)
	check(m.pickups.is_empty() and m.ledger.cash == before + 100, "stationary cursor collects new spawn immediately")
	m.free()

	for spec: Array in [[1.0, 0.5, false], [1.5, 0.5, true], [1.5, 0.61, false]]:
		m = fresh()
		m.projectile_hitbox_multiplier = spec[0]
		m._spawn(&"powder")
		m.snowballs[0].position = Vector3.ZERO
		var a: AttackDefinition = content.get_tower(&"snowball_rookie").attacks[0].duplicate_deep()
		a.projectile_lifetime_s = 1.0
		var history: Dictionary[int, bool] = {}
		m._launch(a, Vector3(-1, 0, spec[1]), Vector3.RIGHT, history, 999)
		m._move_shots(0.1)
		check(m.snowballs.is_empty() == spec[2], "swept contact multiplier=%s offset=%s" % [spec[0], spec[1]])
		m.free()
	# Explosion radius stays original even with the experiment enabled.
	m = fresh()
	m._spawn(&"powder")
	m.snowballs[0].position = Vector3(1.5, 0, 0)
	var burst: AttackDefinition = AttackDefinition.new()
	burst.radius_units = 10.0
	burst.pierce = 10
	m._burst(burst, Vector3.ZERO, 999)
	check(m.snowballs.size() == 1, "1 m explosion plus original 0.4 m enemy radius does not reach 1.5 m")
	check(is_equal_approx(m.projectile_contact_radius(), 0.6), "0.4 m baseline x1.5 = 0.6 m")
	var camera: Camera3D = m.camera
	check(is_equal_approx(camera.elevation_degrees, 50.0) and is_equal_approx(camera.size, 46.0), "50 degree elevation; zoom remains 46")
	for point: Vector3 in [Vector3(-9, 0, -6), Vector3(-2, 0, 5), Vector3(6, 0, 6)]:
		var screen: Vector2 = camera.unproject_position(point)
		var hit: Vector3 = m.GROUND.intersects_ray(camera.project_ray_origin(screen), camera.project_ray_normal(screen))
		check(hit.distance_to(point) < 0.001, "camera ray roundtrip preserves placement %s" % point)
	m.free()
	print("test_playfeel: %s" % ("PASS" if failures == 0 else "%d FAILURES" % failures))
	quit(1 if failures else 0)
